#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @useDynLib spatialsample, .registration = TRUE
## usethis namespace: end
NULL

#' @importFrom rsample complement new_rset make_splits
#' @importFrom purrr map
#' @importFrom rlang is_empty
#' @importFrom stats kmeans hclust cutree as.dist dist
#' @importFrom dplyr dplyr_reconstruct
#'
#' @importFrom rsample analysis
#' @export
rsample::analysis

#' @importFrom rsample assessment
#' @export
rsample::assessment

#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot

#' @import vctrs
NULL

#' @import sf
NULL
