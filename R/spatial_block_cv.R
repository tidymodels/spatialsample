#' Spatial block cross-validation
#'
#' Block cross-validation splits the area of your data into a number of
#' grid cells, or "blocks", and then assigns all data into folds based on the
#' blocks their centroid falls into.
#'
#' @details
#' The grid blocks can be controlled by passing arguments to
#' [sf::st_make_grid()] via `...`. Some particularly useful arguments include:
#'
#' * `cellsize`: Target cellsize, expressed as the "diameter" (shortest
#' straight-line distance between opposing sides; two times the apothem)
#' of each block, in map units.
#' * `n`: The number of grid blocks in the x and y direction (columns, rows).
#' * `square`: A logical value indicating whether to create square (`TRUE`) or
#' hexagonal (`FALSE`) cells.
#'
#' If both `cellsize` and `n` are provided, then the number of blocks requested
#' by `n` of sizes specified by `cellsize` will be returned, likely not
#' lining up with the bounding box of `data`. If only `cellsize`
#' is provided, this function will return as many blocks of size
#' `cellsize` as fit inside the bounding box of `data`. If only `n` is provided,
#' then `cellsize` will be automatically adjusted to create the requested
#' number of cells.
#'
#' @param data An object of class `sf` or `sfc`.
#' @param method The method used to sample blocks for cross validation folds.
#' Currently supports `"random"`, which randomly assigns blocks to folds,
#' `"snake"`, which labels the first row of blocks from left to right,
#' then the next from right to left, and repeats from there,
#' and `"continuous"`, which labels each row from left
#' to right, moving from the bottom row up.
#' @inheritParams rsample::vfold_cv
#' @param relevant_only For systematic sampling, should only blocks containing
#' data be included in fold labeling?
#' @inheritParams buffer_indices
#' @param ... Arguments passed to [sf::st_make_grid()].
#'
#' @return A tibble with classes `spatial_block_cv`,  `spatial_rset`, `rset`,
#'   `tbl_df`, `tbl`, and `data.frame`. The results include a column for the
#'   data split objects and an identification variable `id`.
#'
#' @examples
#'
#' spatial_block_cv(boston_canopy, v = 3)
#'
#' @references
#'
#' D. R. Roberts, V. Bahn, S. Ciuti, M. S. Boyce, J. Elith, G. Guillera-Arroita,
#' S. Hauenstein, J. J. Lahoz-Monfort, B. Schröder, W. Thuiller, D. I. Warton,
#' B. A. Wintle, F. Hartig, and C. F. Dormann. "Cross-validation strategies for
#' data with temporal, spatial, hierarchical, or phylogenetic structure," 2016,
#' Ecography 40(8), pp. 913-929, doi: 10.1111/ecog.02881.
#'
#' @export
spatial_block_cv <- function(data,
                             method = c("random", "snake", "continuous"),
                             v = 10,
                             relevant_only = TRUE,
                             radius = NULL,
                             buffer = NULL,
                             ...) {
  method <- rlang::arg_match(method)

  if (!"sf" %in% class(data)) {
    rlang::abort(
      c(
        "`spatial_block_cv()` currently only supports `sf` objects.",
        i = "Try converting `data` to an `sf` object via `sf::st_as_sf()`."
      )
    )
  }

  if (sf::st_crs(data) == sf::NA_crs_) {
    rlang::abort(
      c(
        "`spatial_block_cv()` requires your data to have an appropriate coordinate reference system (CRS).",
        i = "Try setting a CRS using `sf::st_set_crs()`."
      )
    )
  }

  if (sf::st_is_longlat(data) && !sf::sf_use_s2()) {
    rlang::abort(
      c(
        "`spatial_block_cv()` can only process geographic coordinates when using the s2 geometry library",
        "i" = "Reproject your data into a projected coordinate reference system using `sf::st_transform()`",
        "i" = "Or install the `s2` package and enable it using `sf::sf_use_s2(TRUE)`"
      )
    )
  }

  centroids <- sf::st_centroid(sf::st_geometry(data))

  grid_box <- sf::st_bbox(data)
  if (sf::st_is_longlat(data)) {
    # cf https://github.com/ropensci/stplanr/pull/467
    # basically: spherical geometry means sometimes the straight line of the
    # grid will exclude points within the bounding box
    #
    # so here we'll expand our boundary by a small bit in order to always contain our
    # points within the grid
    grid_box <- expand_grid(grid_box)
  }

  grid_blocks <- sf::st_make_grid(grid_box, ...)
  original_number_of_blocks <- length(grid_blocks)
  split_objs <- switch(
    method,
    "random" = random_block_cv(
      data,
      centroids,
      grid_blocks,
      v,
      radius = radius,
      buffer = buffer
    ),
    systematic_block_cv(
      data,
      centroids,
      grid_blocks,
      v,
      ordering = method,
      relevant_only,
      radius = radius,
      buffer = buffer
    )
  )

  percent_used <- split_objs$filtered_number_of_blocks[[1]] / original_number_of_blocks

  if (percent_used < 0.1) {
    percent_used <- round(percent_used * 100, 2)
    rlang::inform(
      c(
        glue::glue("Only {percent_used}% of blocks contain any data"),
        i = "Check that your block sizes make sense for your data"
      )
    )
  }
  split_objs$filtered_number_of_blocks <- NULL

  v <- split_objs$v[[1]]
  split_objs$v <- NULL

  ## Save some overall information
  cv_att <- list(v = v,
                 method = method,
                 relevant_only = relevant_only,
                 radius = radius,
                 buffer = buffer,
                 ...)

  new_rset(
    splits = split_objs$splits,
    ids = split_objs[, grepl("^id", names(split_objs))],
    attrib = cv_att,
    subclass = c("spatial_block_cv", "spatial_rset", "rset")
  )
}

expand_grid <- function(grid_box, expansion = 0.00001) {
  grid_box[1] <- grid_box[1] - abs(grid_box[1] * expansion)
  grid_box[2] <- grid_box[2] - abs(grid_box[2] * expansion)
  grid_box[3] <- grid_box[3] + abs(grid_box[3] * expansion)
  grid_box[4] <- grid_box[4] + abs(grid_box[4] * expansion)
  grid_box
}

random_block_cv <- function(data,
                            centroids,
                            grid_blocks,
                            v,
                            radius = NULL,
                            buffer = NULL) {
  n <- length(centroids)

  grid_blocks <- filter_grid_blocks(grid_blocks, centroids)

  n_blocks <- length(grid_blocks)
  v <- check_v(v, n_blocks, "blocks", call = rlang::caller_env())

  grid_blocks <- sf::st_as_sf(grid_blocks)
  grid_blocks$fold <- sample(rep(seq_len(v), length.out = nrow(grid_blocks)))

  generate_folds_from_blocks(data, centroids, grid_blocks, v, n, radius, buffer)
}

systematic_block_cv <- function(data,
                                centroids,
                                grid_blocks,
                                v,
                                ordering = c("snake", "continuous"),
                                relevant_only = TRUE,
                                radius = NULL,
                                buffer = NULL) {
  n <- length(centroids)
  ordering <- rlang::arg_match(ordering)

  if (relevant_only) grid_blocks <- filter_grid_blocks(grid_blocks, centroids)

  n_blocks <- length(grid_blocks)
  v <- check_v(v, n_blocks, "blocks", call = rlang::caller_env())

  folds <- rep(seq_len(v), length.out = length(grid_blocks))
  if (ordering == "snake") folds <- make_snake_ordering(folds, grid_blocks)

  grid_blocks <- sf::st_as_sf(grid_blocks)
  grid_blocks$fold <- folds
  if (!relevant_only) grid_blocks <- filter_grid_blocks(grid_blocks, centroids)

  num_folds <- length(unique(grid_blocks$fold))
  if (num_folds != v) {
    rlang::warn(c(
      "Not all folds contained blocks with data:",
      x = glue::glue("{v} folds were requested, \\
                     but only {num_folds} contain any data."),
      x = "Empty folds were dropped.",
      i = "To avoid this, set `relevant_only = TRUE`."
    ))
    v <- num_folds
  }

  generate_folds_from_blocks(data, centroids, grid_blocks, v, n, radius, buffer)
}

generate_folds_from_blocks <- function(data, centroids, grid_blocks, v, n, radius, buffer) {
  filtered_number_of_blocks <- nrow(grid_blocks)
  grid_blocks <- split_unnamed(grid_blocks, grid_blocks$fold)

  indices <- row_ids_intersecting_fold_blocks(grid_blocks, centroids)

  if (is.null(radius) && is.null(buffer)) {
    indices <- lapply(indices, default_complement, n = n)
  } else {
    indices <- buffer_indices(data, indices, radius, buffer)
  }

  split_objs <- purrr::map(
    indices,
    make_splits,
    data = data,
    class = c("spatial_block_split", "spatial_rsplit")
  )
  tibble::tibble(
    splits = split_objs,
    id = names0(length(split_objs), "Fold"),
    v = v,
    filtered_number_of_blocks = filtered_number_of_blocks
  )
}

filter_grid_blocks <- function(grid_blocks, centroids) {
  block_contains_points <- purrr::map_lgl(
    sf::st_intersects(grid_blocks, centroids),
    sgbp_is_not_empty
  )
  if ("data.frame" %in% class(grid_blocks)) {
    grid_blocks[block_contains_points, , drop = FALSE]
  } else {
    grid_blocks[block_contains_points]
  }
}

make_snake_ordering <- function(folds, grid_blocks) {
  rowtab <- table(
    purrr::map_dbl(
      grid_blocks,
      ~ sf::st_bbox(.x)[["ymin"]]
    )
  )
  sum_rowtab <- cumsum(rowtab)
  reverse <- FALSE
  for (i in seq_along(rowtab)) {
    idx_one <- ifelse(i == 1, 1, sum_rowtab[[i - 1]] + 1)
    idx_two <- sum_rowtab[[i]]
    if (reverse) {
      folds[idx_one:idx_two] <- rev(folds[idx_one:idx_two])
    }
    reverse <- !reverse
  }
  folds
}

row_ids_intersecting_fold_blocks <- function(grid_blocks, data) {
  # grid_blocks is a list of sgbp lists (?sf::sgbp)
  #
  # The first map() here iterates through the meta-list,
  # and the second checks each element of the relevant sgbp list
  # to see if it is integer(0) (no intersections) or not
  #
  # Each sgbp sub-list is nrow(data) elements long, so this which()
  # returns the list indices which are not empty, which is equivalent
  # to the row numbers that intersect with blocks in the fold
  purrr::map(
    grid_blocks,
    function(blocks) {
      which(
        purrr::map_lgl(
          sf::st_intersects(data, blocks),
          sgbp_is_not_empty
        )
      )
    }
  )
}
