#' @importFrom rsample complement new_rset make_splits
#' @importFrom purrr map
#' @importFrom rlang is_empty
#' @importFrom stats kmeans
#'
split_unnamed <- function(x, f) {
    out <- split(x, f)
    unname(out)
}
