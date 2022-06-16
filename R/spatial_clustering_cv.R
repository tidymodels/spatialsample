#' Spatial or Cluster Cross-Validation
#'
#' Spatial or cluster cross-validation splits the data into V groups of
#'  disjointed sets using k-means clustering of some variables, typically
#'  spatial coordinates. A resample of the analysis data consists of V-1 of the
#'  folds/clusters while the assessment set contains the final fold/cluster. In
#'  basic spatial cross-validation (i.e. no repeats), the number of resamples
#'  is equal to V.
#'
#' @details
#' The variables in the `coords` argument are used for k-means clustering of
#'  the data into disjointed sets, as outlined in Brenning (2012), or for
#'  hierarchical clustering of the data. These
#'  clusters are used as the folds for cross-validation. Depending on how the
#'  data are distributed spatially, there may not be an equal number of points
#'  in each fold.
#'
#' You can optionally provide a custom function to `cluster_function`. The
#' function must take three arguments:
#' - `dists`, a [stats::dist()] object with distances between data points
#' - `v`, a length-1 numeric for the number of folds to create
#' - `...`, to pass any additional named arguments to your function
#'
#' The function should return a vector of cluster assignments of length
#' `nrow(data)`, with each element of the vector corresponding to the matching
#' row of the data frame.
#'
#' @param data A data frame or an `sf` object (often from [sf::read_sf()]
#' or [sf::st_as_sf()]), to split into folds.
#' @param coords A vector of variable names, typically spatial coordinates,
#'  to partition the data into disjointed sets via k-means clustering.
#'  This argument is ignored (with a warning) if `data` is an `sf` object.
#' @inheritParams buffer_indices
#' @param v The number of partitions of the data set.
#' @param cluster_function Which function should be used for clustering?
#' Options are either `"kmeans"` (to use [stats::kmeans()])
#' or `"hclust"` (to use [stats::hclust()]). You can also provide your own
#' function; see `Details`.
#' @param ... Extra arguments passed on to [stats::kmeans()] or
#' [stats::hclust()].
#'
#' @return A tibble with classes `spatial_clustering_cv`, `spatial_rset`,
#'  `rset`, `tbl_df`, `tbl`, and `data.frame`.
#'  The results include a column for the data split objects and
#'  an identification variable `id`.
#'  Resamples created from non-`sf` objects will not have the
#'  `spatial_rset` class.
#'
#' @references
#'
#' A. Brenning, "Spatial cross-validation and bootstrap for the assessment of
#' prediction rules in remote sensing: The R package sperrorest," 2012 IEEE
#' International Geoscience and Remote Sensing Symposium, Munich, 2012,
#' pp. 5372-5375, doi: 10.1109/IGARSS.2012.6352393.
#'
#' @examplesIf rlang::is_installed("modeldata")
#' data(Smithsonian, package = "modeldata")
#' spatial_clustering_cv(Smithsonian, coords = c(latitude, longitude), v = 5)
#'
#' smithsonian_sf <- sf::st_as_sf(
#'   Smithsonian,
#'   coords = c("longitude", "latitude"),
#'   # Set CRS to WGS84
#'   crs = 4326
#' )
#'
#' # When providing sf objects, coords are inferred automatically
#' spatial_clustering_cv(smithsonian_sf, v = 5)
#'
#' # Can use hclust instead:
#' spatial_clustering_cv(smithsonian_sf, v = 5, cluster_function = "hclust")
#'
#' @rdname spatial_clustering_cv
#' @export
spatial_clustering_cv <- function(data,
                                  coords,
                                  v = 10,
                                  cluster_function = c("kmeans", "hclust"),
                                  radius = NULL,
                                  buffer = NULL,
                                  ...) {
  if (!rlang::is_function(cluster_function)) {
    cluster_function <- rlang::arg_match(cluster_function)
  }

  subclasses <- c("spatial_clustering_cv", "spatial_rset", "rset")
  if ("sf" %in% class(data)) {
    if (!missing(coords)) {
      rlang::warn("`coords` is ignored when providing `sf` objects to `data`.")
    }
    coords <- sf::st_centroid(sf::st_geometry(data))
    dists <- as.dist(sf::st_distance(coords))
  } else {
    if (!missing(radius) || !missing(buffer)) {
      rlang::abort("Neither `radius` or `buffer` can be used when providing non-`sf` objects to `data`.")
    }
    coords <- tidyselect::eval_select(rlang::enquo(coords), data = data)
    if (is_empty(coords)) {
      rlang::abort("`coords` are required and must be variables in `data`.")
    }
    coords <- data[coords]
    if (!all(purrr::map_lgl(coords, is.numeric))) {
      rlang::abort("`coords` must be numeric variables in `data`.")
    }
    dists <- dist(coords)
    subclasses <- setdiff(subclasses, "spatial_rset")
  }

  split_objs <- spatial_clustering_splits(
    data = data,
    dists = dists,
    v = v,
    cluster_function = cluster_function,
    radius = radius,
    buffer = buffer,
    ...
  )

  ## Save some overall information

  cv_att <- list(v = v, repeats = 1, radius = radius, buffer = buffer)

  new_rset(
    splits = split_objs$splits,
    ids = split_objs[, grepl("^id", names(split_objs))],
    attrib = cv_att,
    subclass = subclasses
  )
}

spatial_clustering_splits <- function(data,
                                      dists,
                                      v = 10,
                                      cluster_function = c("kmeans", "hclust"),
                                      radius = NULL,
                                      buffer = NULL,
                                      ...) {
  if (!rlang::is_function(cluster_function)) {
    cluster_function <- rlang::arg_match(cluster_function)
  }

  v <- check_v(v, nrow(data), "data points", allow_max_v = FALSE, call = rlang::caller_env())

  classes <- c("spatial_clustering_split")
  if ("sf" %in% class(data)) classes <- c(classes, "spatial_rsplit")

  classes <- c("spatial_clustering_split")
  if ("sf" %in% class(data)) classes <- c(classes, "spatial_rsplit")

  n <- nrow(data)

  clusterer <- ifelse(
    rlang::is_function(cluster_function),
    "custom",
    cluster_function
  )

  folds <- switch(
    clusterer,
    "kmeans" = {
      clusters <- kmeans(dists, centers = v, ...)
      clusters$cluster
    },
    "hclust" = {
      clusters <- hclust(dists, ...)
      cutree(clusters, k = v)
    },
    do.call(cluster_function, list(dists = dists, v = v, ...))
  )

  idx <- seq_len(n)
  indices <- split_unnamed(idx, folds)
  if (is.null(radius) && is.null(buffer)) {
    indices <- lapply(indices, default_complement, n = n)
  } else {
    indices <- buffer_indices(
      data,
      indices,
      radius,
      buffer,
      call = rlang::caller_env()
    )
  }
  split_objs <- purrr::map(
    indices,
    make_splits,
    data = data,
    class = classes
  )
  tibble::tibble(
    splits = split_objs,
    id = names0(length(split_objs), "Fold")
  )
}
