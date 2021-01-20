#' @importFrom rsample complement
#' @export
#'
complement.spatial_clustering_split <- function(x, ...) {
    class(x) <- "vfold_split"
    complement(x)
}

## This will remove the assessment indices from an rsplit object
rm_out <- function(x) {
    x$out_id <- NA
    x
}
