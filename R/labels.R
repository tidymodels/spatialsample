#' @export
pretty.spatial_clustering_cv <- function(x, ...) {
  details <- attributes(x)
  res <- paste0(details$v, "-fold spatial cross-validation")
  res
}

#' @export
print.spatial_clustering_cv <- function(x, ...) {
  cat("# ", pretty(x), "\n")
  class(x) <- class(x)[!(class(x) %in% c(
    "spatial_clustering_cv",
    "spatial_rset",
    "rset"
  ))]
  print(x, ...)
}

#' @export
pretty.spatial_block_cv <- function(x, ...) {
  details <- attributes(x)
  res <- paste0(details$v, "-fold spatial block cross-validation")
  res
}

#' @export
print.spatial_block_cv <- function(x, ...) {
  cat("# ", pretty(x), "\n")
  class(x) <- class(x)[!(class(x) %in% c(
    "spatial_block_cv",
    "spatial_rset",
    "rset"
  ))]
  print(x, ...)
}

#' @export
pretty.spatial_leave_location_out_cv <- function(x, ...) {
  details <- attributes(x)
  res <- paste0(details$v, "-fold spatial leave-location-out cross-validation")
  res
}

#' @export
print.spatial_leave_location_out_cv <- function(x, ...) {
  cat("# ", pretty(x), "\n")
  class(x) <- class(x)[!(class(x) %in% c(
    "spatial_leave_location_out_cv",
    "spatial_rset",
    "rset"
  ))]
  print(x, ...)
}

#' @export
pretty.spatial_buffer_vfold_cv <- function(x, ...) {
  details <- attributes(x)
  res <- paste0(details$v, "-fold spatial cross-validation")
  res
}

#' @export
print.spatial_buffer_vfold_cv <- function(x, ...) {
  cat("# ", pretty(x), "\n")
  class(x) <- class(x)[!(class(x) %in% c(
    "spatial_buffer_vfold_cv",
    "spatial_rset",
    "rset"
  ))]
  print(x, ...)
}
