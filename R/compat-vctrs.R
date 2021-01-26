# Mimicking rsample `compat-vctrs.R`
# https://github.com/tidymodels/rsample/blob/master/R/compat-vctrs.R

# ------------------------------------------------------------------------------

#' @export
vec_restore.spatial_clustering_cv <- function(x, to, ...) {
    rsample::rset_reconstruct(x, to)
}


#' @export
vec_ptype2.spatial_clustering_cv.spatial_clustering_cv <- function(x, y, ..., x_arg = "", y_arg = "") {
    stop_never_called("vec_ptype2.spatial_clustering_cv.spatial_clustering_cv")
}
#' @export
vec_ptype2.spatial_clustering_cv.tbl_df <- function(x, y, ..., x_arg = "", y_arg = "") {
    stop_never_called("vec_ptype2.spatial_clustering_cv.tbl_df")
}
#' @export
vec_ptype2.tbl_df.spatial_clustering_cv <- function(x, y, ..., x_arg = "", y_arg = "") {
    stop_never_called("vec_ptype2.tbl_df.spatial_clustering_cv")
}
#' @export
vec_ptype2.spatial_clustering_cv.data.frame <- function(x, y, ..., x_arg = "", y_arg = "") {
    stop_never_called("vec_ptype2.spatial_clustering_cv.data.frame")
}
#' @export
vec_ptype2.data.frame.spatial_clustering_cv <- function(x, y, ..., x_arg = "", y_arg = "") {
    stop_never_called("vec_ptype2.data.frame.spatial_clustering_cv")
}


#' @export
vec_cast.spatial_clustering_cv.spatial_clustering_cv <- function(x, to, ..., x_arg = "", to_arg = "") {
    stop_incompatible_cast_rset(x, to, x_arg = x_arg, to_arg = to_arg)
}
#' @export
vec_cast.spatial_clustering_cv.tbl_df <- function(x, to, ..., x_arg = "", to_arg = "") {
    stop_incompatible_cast_rset(x, to, x_arg = x_arg, to_arg = to_arg)
}
#' @export
vec_cast.tbl_df.spatial_clustering_cv <- function(x, to, ..., x_arg = "", to_arg = "") {
    vctrs::tib_cast(x, to, ..., x_arg = x_arg, to_arg = to_arg)
}
#' @export
vec_cast.spatial_clustering_cv.data.frame <- function(x, to, ..., x_arg = "", to_arg = "") {
    stop_incompatible_cast_rset(x, to, x_arg = x_arg, to_arg = to_arg)
}
#' @export
vec_cast.data.frame.spatial_clustering_cv <- function(x, to, ..., x_arg = "", to_arg = "") {
    vctrs::df_cast(x, to, ..., x_arg = x_arg, to_arg = to_arg)
}

# ------------------------------------------------------------------------------

stop_incompatible_cast_rset <- function(x, to, ..., x_arg, to_arg) {
    details <- "Can't cast to an rset because attributes are likely incompatible."
    vctrs::stop_incompatible_cast(x, to, x_arg = x_arg, to_arg = to_arg, details = details)
}

stop_never_called <- function(fn) {
    rlang::abort(paste0("Internal error: `", fn, "()` should never be called."))
}
