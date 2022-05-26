#' Spatial block cross-validation
#'
#' Block cross-validation splits the area of your data into a number of
#' grid cells, or "blocks", and then assigns all data into folds based on the
#' blocks they fall into.
#'
#' @details
#' The grid blocks can be controlled by passing arguments to
#' [sf::st_make_grid()] via `...`. Some particularly useful arguments include:
#'
#' * `cellsize` Target cellsize, expressed as the "diameter" (shortest
#' straight-line distance between opposing sides; two times the apothem)
#' of each block, in map units.
#' * `n` The number of grid blocks in the x and y direction (columns, rows).
#' * `square` A logical value indicating whether to create square (`TRUE`) or
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
#' Currently, only `"random"` is supported.
#' @inheritParams rsample::vfold_cv
#' @param ... Arguments passed to [sf::st_make_grid()].
#'
#' @return A tibble with classes `spatial_block_cv`, `rset`, `tbl_df`, `tbl`,
#'   and `data.frame`. The results include a column for the data split objects
#'   and an identification variable `id`.
#'
#' @examples
#' data(Smithsonian, package = "modeldata")
#' smithsonian_sf <- sf::st_as_sf(Smithsonian,
#'                                coords = c("longitude", "latitude"),
#'                                # Set CRS to WGS84
#'                                crs = 4326)
#'
#' spatial_block_cv(smithsonian_sf, v = 3)
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
spatial_block_cv <- function(data, method = "random", v = 10, ...) {
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

  grid_box <- sf::st_bbox(data)
  if (sf::st_is_longlat(data)) {
    # cf https://github.com/ropensci/stplanr/pull/467
    # basically: spherical geometry means sometimes the straight line of the
    # grid will exclude points within the bounding box
    #
    # so here we'll expand our boundary by 0.1% in order to always contain our
    # points within the grid
    grid_box[1] <- grid_box[1] - abs(grid_box[1] * 0.001)
    grid_box[2] <- grid_box[2] - abs(grid_box[2] * 0.001)
    grid_box[3] <- grid_box[3] + abs(grid_box[3] * 0.001)
    grid_box[4] <- grid_box[4] + abs(grid_box[4] * 0.001)
  }
  grid_blocks <- sf::st_make_grid(grid_box, ...)
  split_objs <- switch(
    method,
    "random" = random_block_cv(data, grid_blocks, v)
  )
  v <- split_objs$v[[1]]
  split_objs$v <- NULL

  ## We remove the holdout indices since it will save space and we can
  ## derive them later when they are needed.
  split_objs$splits <- map(split_objs$splits, rm_out)

  ## Save some overall information
  cv_att <- list(v = v)

  new_rset(
    splits = split_objs$splits,
    ids = split_objs[, grepl("^id", names(split_objs))],
    attrib = cv_att,
    subclass = c("spatial_block_cv", "rset")
  )

}

random_block_cv <- function(data, grid_blocks, v) {
  n <- nrow(data)

  block_contains_points <- purrr::map_lgl(
    sf::st_intersects(grid_blocks, data),
    sgbp_is_not_empty
  )
  grid_blocks <- grid_blocks[block_contains_points]

  n_blocks <- length(grid_blocks)
  if (!is.numeric(v) || length(v) != 1) {
    rlang::abort("`v` must be a single integer.")
  }
  if (v > n_blocks) {
    rlang::warn(paste0(
      "Fewer than ", v, " blocks available for sampling; setting v to ",
      n_blocks, "."
    ))
    v <- n_blocks
  }

  grid_blocks <- sf::st_as_sf(grid_blocks)
  grid_blocks$fold <- sample(rep(seq_len(v), length.out = nrow(grid_blocks)))
  grid_blocks <- split_unnamed(grid_blocks, grid_blocks$fold)

  # grid_blocks is now a list of sgbp lists (?sf::sgbp)
  #
  # The first map() here iterates through the meta-list,
  # and the second checks each element of the relevant sgbp list
  # to see if it is integer(0) (no intersections) or not
  #
  # Each sgbp sub-list is nrow(data) elements long, so this which()
  # returns the list indices which are not empty, which is equivalent
  # to the row numbers that intersect with blocks in the fold
  indices <- purrr::map(
    grid_blocks,
    function(blocks) which(
      purrr::map_lgl(
        sf::st_intersects(data, blocks),
        sgbp_is_not_empty
      )
    )
  )

  indices <- lapply(indices, default_complement, n = n)
  split_objs <- purrr::map(
    indices,
    make_splits,
    data = data,
    class = "spatial_block_split"
  )
  tibble::tibble(
    splits = split_objs,
    id = names0(length(split_objs), "Fold"),
    v = v
  )
}

# Check sparse geometry binary predicate for empty elements
# See ?sf::sgbp for more information on the data structure
sgbp_is_not_empty <- function(x) !identical(x, integer(0))

#' @export
print.spatial_block_cv <- function(x, ...) {
  cat("# ", pretty(x), "\n")
  class(x) <- class(x)[!(class(x) %in% c("spatial_block_cv", "rset"))]
  print(x, ...)
}
