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
#'  hierarchical clustering of the data (by default using the complete linkage
#'  method, though this can be changed through arguments). These
#'  clusters are used as the folds for cross-validation. Depending on how the
#'  data are distributed spatially, there may not be an equal number of points
#'  in each fold.
#'
#' @param data A data frame, or an `sf` object (often from [sf::read_sf()]
#' or [sf::st_as_sf()]), to split into folds.
#' @param coords A vector of variable names, typically spatial coordinates,
#'  to partition the data into disjointed sets via k-means clustering.
#'  This argument is ignored (with a warning) if `data` is an `sf` object.
#' @param v The number of partitions of the data set.
#' @param fun Which function to use to cluster. Must be one of either
#' "kmeans" (to use [stats::kmeans()]) or "hclust" (to use [stats::hclust()]).
#' @param ... Extra arguments passed on to [stats::kmeans()] or
#' [stats::hclust()].
#'
#' @return A tibble with classes `spatial_cv`, `rset`, `tbl_df`, `tbl`, and
#'  `data.frame`. The results include a column for the data split objects and
#'  an identification variable `id`.
#'
#' @references
#'
#' A. Brenning, "Spatial cross-validation and bootstrap for the assessment of
#' prediction rules in remote sensing: The R package sperrorest," 2012 IEEE
#' International Geoscience and Remote Sensing Symposium, Munich, 2012,
#' pp. 5372-5375, doi: 10.1109/IGARSS.2012.6352393.
#'
#' @examples
#' data(Smithsonian, package = "modeldata")
#' spatial_clustering_cv(Smithsonian, coords = c(latitude, longitude), v = 5)
#'
#' # When providing sf objects, coords are inferred automatically
#' smithsonian_sf <- sf::st_as_sf(Smithsonian,
#'                         coords = c("longitude", "latitude"),
#'                         crs = 4326) # WGS84
#' spatial_clustering_cv(smithsonian_sf, v = 5)
#'
#' @rdname spatial_clustering_cv
#' @export
spatial_clustering_cv <- function(data, coords, v = 10, fun = c("kmeans", "hclust"), ...) {
  UseMethod("spatial_clustering_cv", data)
}

#' @rdname spatial_clustering_cv
#' @export
spatial_clustering_cv.default <- function(data, coords, v = 10, fun = c("kmeans", "hclust"), ...) {
  fun <- match.arg(fun)

  coords <- tidyselect::eval_select(rlang::enquo(coords), data = data)
  if (is_empty(coords)) {
    rlang::abort("`coords` are required and must be variables in `data`.")
  }
  coords <- data[coords]
  coords <- dist(coords)

  spatial_clustering_handler(data = data,
                             coords = coords,
                             v = v,
                             fun = fun,
                             ...)

}

#' @rdname spatial_clustering_cv
#' @export
spatial_clustering_cv.sf <- function(data, coords, v = 10, fun = c("kmeans", "hclust"), ...) {
  fun <- match.arg(fun)

  if (!missing(coords)) {
    rlang::warn("`coords` is ignored when providing `sf` objects to `data`.")
  }
  coords <- sf::st_centroid(sf::st_geometry(data))
  coords <- as.dist(sf::st_distance(coords))

  spatial_clustering_handler(data = data,
                             coords = coords,
                             v = v,
                             fun = fun,
                             ...)

}


spatial_clustering_handler <- function(data, coords, v = 10, fun = c("kmeans", "hclust"), ...) {
  split_objs <- spatial_clustering_splits(data = data,
                                          coords = coords,
                                          v = v,
                                          fun = fun,
                                          ...)

  ## We remove the holdout indices since it will save space and we can
  ## derive them later when they are needed.

  split_objs$splits <- map(split_objs$splits, rm_out)

  ## Save some overall information

  cv_att <- list(v = v, repeats = 1)

  new_rset(
    splits = split_objs$splits,
    ids = split_objs[, grepl("^id", names(split_objs))],
    attrib = cv_att,
    subclass = c("spatial_clustering_cv", "rset")
  )

}

spatial_clustering_splits <- function(data, coords, v = 10, fun = c("kmeans", "hclust"), ...) {
  if (!is.numeric(v) || length(v) != 1) {
    rlang::abort("`v` must be a single integer.")
  }

  n <- nrow(data)

  if (fun == "kmeans") {
    clusters <- kmeans(coords, centers = v, ...)
    folds <- clusters$cluster
  } else if (fun == "hclust") {
    clusters <- hclust(coords, ...)
    folds <- cutree(clusters, k = v)
  } else { # Not sure how this would ever fire, but just in case...
    rlang::abort("`fun` must be either 'kmeans' or 'hclust'")
  }

  idx <- seq_len(n)
  indices <- split_unnamed(idx, folds)
  indices <- lapply(indices, default_complement, n = n)
  split_objs <- purrr::map(indices, make_splits,
    data = data,
    class = "spatial_clustering_split"
  )
  tibble::tibble(
    splits = split_objs,
    id = names0(length(split_objs), "Fold")
  )
}

#' @export
print.spatial_clustering_cv <- function(x, ...) {
  cat("# ", pretty(x), "\n")
  class(x) <- class(x)[!(class(x) %in% c("spatial_clustering_cv", "rset"))]
  print(x, ...)
}
