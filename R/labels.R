#' Short Descriptions of spatial rsets
#'
#' Produce a character vector describing the spatial resampling method.
#'
#' @param x An `rset` object
#' @param ... Not currently used.
#' @return A character vector.
#' @export pretty.spatial_clustering_cv
#' @export
#' @method pretty spatial_clustering_cv
#' @rdname pretty.spatial_clustering_cv
#' @keywords internal
pretty.spatial_clustering_cv <- function(x, ...) {
  details <- attributes(x)
  res <- paste0(details$v, "-fold spatial clustering cross-validation")
  res
}

#' Short Descriptions of spatial rsets
#'
#' Produce a character vector describing the spatial resampling method.
#'
#' @param x An `rset` object
#' @param ... Not currently used.
#' @return A character vector.
#' @export pretty.leave_location_out_cv
#' @export
#' @method pretty leave_location_out_cv
#' @rdname pretty.leave_location_out_cv
#' @keywords internal
pretty.leave_location_out_cv <- function(x, ...) {
    details <- attributes(x)
    res <- paste0(details$v, "-fold leave-location-out cross-validation")
    res
}
