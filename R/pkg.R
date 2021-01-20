#' spatialsample: Spatial Resampling Infrastructure for R
#'
#'\pkg{spatialsample} has functions to create resamples of a spatial
#'  data set that can be used to evaluate models or to estimate the sampling
#'  distribution of some statistic. It is a specialized package designed with
#'  the same principles and terminology as \link[rsample]{rsample}.
#'
#' @section Terminology:
#'\itemize{
#'  \item A **resample** is the result of a split of a
#'  data set. For example, in cross-validation, a data set is split
#'  into complementary subsets, and different partitions of subsets are
#'  used for different purposes. The data structure
#'  `rsplit` is used to store a single resample.
#'  \item When the data are split in two, the portion that is
#'  used to estimate the model or calculate the statistic is
#'  called the **analysis** set here. In machine learning this
#'  is sometimes called the "training set", but this may be
#'  a poor name choice in a resampling context since it might conflict with
#'  an initial split of the original data.
#'  \item Conversely, the other data in the split are called the
#'     **assessment** data. In bootstrapping, these data are
#'     often called the "out-of-bag" samples.
#'  \item A collection of resamples is contained in an
#'  `rset` object.
#'}
#'
#' @section Basic Functions:
#' The main resampling functions are: [spatial_clustering_cv()]
#' @docType package
#' @name spatialsample
NULL
