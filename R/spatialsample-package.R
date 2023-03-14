#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rsample complement
#' @importFrom rsample new_rset
#' @importFrom stats as.dist
#' @importFrom stats cutree
#' @importFrom stats hclust
#' @importFrom stats kmeans
#' @importFrom rsample make_splits
#' @importFrom purrr map
#' @importFrom rlang is_empty
#' @importFrom dplyr dplyr_reconstruct
#' @useDynLib spatialsample, .registration = TRUE
## usethis namespace: end
NULL

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
