#' Spatial Clustering Cross-Validation
#'
#' Spatial clustering cross-validation splits the data into V groups of
#'  disjointed sets by clustering points based on their spatial coordinates.
#'  A resample of the analysis data consists of V-1 of the folds/clusters
#'  while the assessment set contains the final fold/cluster.
#'
#' @section Changes in spatialsample 0.3.0:
#' As of spatialsample version 0.3.0, this function no longer accepts non-`sf`
#' objects as arguments to `data`. In order to perform clustering with
#' non-spatial data, consider using [rsample::clustering_cv()].
#'
#' Also as of version 0.3.0, this function now calculates edge-to-edge distance
#' for non-point geometries, in line with the rest of the package. Earlier
#' versions relied upon between-centroid distances.
#'
#' @details
#' Clusters are created based on the distances between observations
#'  if `data` is an `sf` object. Each cluster is used as a fold for
#'  cross-validation. Depending on how the data are distributed spatially, there
#'  may not be an equal number of observations in each fold.
#'
#' You can optionally provide a custom function to `distance_function.` The
#' function should take an `sf` object and return a [stats::dist()] object with
#' distances between data points.
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
#' @inheritParams buffer_indices
#' @inheritParams rsample::clustering_cv
#' @param distance_function Which function should be used for distance
#' calculations? Defaults to [sf::st_distance()], with the output matrix
#' converted to a [stats::dist()] object. You can also provide your own
#' function; see Details.
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
                                  v = 10,
                                  cluster_function = c("kmeans", "hclust"),
                                  radius = NULL,
                                  buffer = NULL,
                                  ...,
                                  repeats = 1,
                                  distance_function = function(x) as.dist(sf::st_distance(x))) {
  if (!rlang::is_function(cluster_function)) {
    cluster_function <- rlang::arg_match(cluster_function)
  }

  standard_checks(data, "`spatial_clustering_cv()`")

  n <- nrow(data)
  v <- check_v(
    v,
    n,
    "data points",
    allow_max_v = FALSE
  )

  cv_att <- list(
    v = v,
    repeats = repeats,
    radius = radius,
    buffer = buffer,
    cluster_function = cluster_function,
    distance_function = distance_function
  )

  rset <- rsample::clustering_cv(
    data = data,
    vars = names(data),
    v = v,
    repeats = {{ repeats }},
    distance_function = distance_function,
    cluster_function = cluster_function,
    ...
  )

  posthoc_buffer_rset(
    data = data,
    rset = rset,
    rsplit_class = c("spatial_clustering_split", "spatial_rsplit"),
    rset_class = c("spatial_clustering_cv", "spatial_rset", "rset"),
    radius = radius,
    buffer = buffer,
    n = n,
    v = v,
    cv_att = cv_att
  )
}

