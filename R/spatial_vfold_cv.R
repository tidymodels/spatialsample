#' V-Fold Cross-Validation with Buffering
#'
#' V-fold cross-validation (also known as k-fold cross-validation) randomly
#' splits the data into V groups of roughly equal size (called "folds").
#' A resample of the analysis data consists of V-1 of the folds while the
#' assessment set contains the final fold.
#' These functions extend [rsample::vfold_cv()] and [rsample::group_vfold_cv()]
#' to also apply an inclusion radius and exclusion buffer to the assessment set,
#' ensuring that your analysis data is spatially separated from the assessment
#' set.
#' In basic V-fold cross-validation (i.e. no repeats), the number of resamples
#' is equal to V.
#'
#' @details
#' When `radius` and `buffer` are both `NULL`, `spatial_buffer_vfold_cv`
#' is equivalent to [rsample::vfold_cv()] and `spatial_leave_location_out_cv`
#' is equivalent to [rsample::group_vfold_cv()].
#'
#' @inheritParams check_v
#' @inheritParams rsample::vfold_cv
#' @inheritParams rsample::group_vfold_cv
#' @param group A variable in data (single character or name) used to create
#' folds. For leave-location-out CV, this should be a variable containing
#' the locations to group observations by, for leave-time-out CV the
#' time blocks to group by, and for leave-location-and-time-out the
#' spatiotemporal blocks to group by.
#' @inheritParams buffer_indices
#'
#' @references
#'
#' K. Le Rest, D. Pinaud, P. Monestiez, J. Chadoeuf, and C. Bretagnolle. 2014.
#' "Spatial leave-one-out cross-validation for variable selection in the
#' presence of spatial autocorrelation," Global Ecology and Biogeography 23,
#' pp. 811-820, doi: 10.1111/geb.12161.
#'
#' H. Meyer, C. Reudenbach, T. Hengl, M. Katurji, and T. Nauss. 2018.
#' "Improving performance of spatio-temporal machine learning models using
#' forward feature selection and target-oriented validation,"
#' Environmental Modelling & Software 101, pp. 1-9,
#' doi: 10.1016/j.envsoft.2017.12.001.
#'
#' @rdname spatial_vfold
#'
#' @examplesIf sf::sf_use_s2() && rlang::is_installed("modeldata")
#'
#' data(Smithsonian, package = "modeldata")
#' Smithsonian_sf <- sf::st_as_sf(
#'   Smithsonian,
#'   coords = c("longitude", "latitude"),
#'   crs = 4326
#' )
#'
#' spatial_buffer_vfold_cv(
#'   Smithsonian_sf,
#'   buffer = 500,
#'   radius = NULL
#' )
#'
#' data(ames, package = "modeldata")
#' ames_sf <- sf::st_as_sf(ames, coords = c("Longitude", "Latitude"), crs = 4326)
#' ames_neighborhoods <- spatial_leave_location_out_cv(ames_sf, Neighborhood)
#'
#' @export
spatial_buffer_vfold_cv <- function(data,
                                    radius,
                                    buffer,
                                    v = 10,
                                    repeats = 1,
                                    strata = NULL,
                                    breaks = 4,
                                    pool = 0.1,
                                    ...) {

  standard_checks(data, "`spatial_buffer_vfold_cv()`")

  if (missing(radius) || missing(buffer)) {
    use_vfold <- NULL
    if (missing(radius) && missing(buffer)) {
      use_vfold <- c(i = "Or use `rsample::vfold_cv() to use a non-spatial V-fold.")
    }
    rlang::abort(
      c(
        "`spatial_buffer_vfold_cv()` requires both `radius` and `buffer` be provided.",
        i = "Use `NULL` for resampling without one of `radius` or `buffer`, like `radius = NULL, buffer = 5000`.",
        use_vfold
      )
    )
  }

  n <- nrow(data)
  v <- check_v(v, n, "rows")

  rset <- rsample::vfold_cv(
    data = data,
    v = v,
    repeats = repeats,
    strata = {{ strata }},
    breaks = breaks,
    pool = pool,
    ...
  )

  if (!missing(strata)) {
    strata <- tidyselect::vars_select(names(data), {{ strata }})
    if (length(strata) == 0) strata <- NULL
  }

  if (!is.null(strata)) names(strata) <- NULL
  cv_att <- list(v = v,
                 repeats = repeats,
                 strata  = strata,
                 breaks  = breaks,
                 pool    = pool,
                 # Set radius and buffer to 0 if NULL or negative
                 # This enables rsample::reshuffle_rset to work
                 radius  = min(c(radius, 0)),
                 buffer  = min(c(buffer, 0)))

  if ("sf" %in% class(data)) {
    rset_class <- c("spatial_buffer_vfold_cv", "spatial_rset", "rset")
    rsplit_class <- c("spatial_buffer_vfold_split", "spatial_rsplit")
  } else {
    rset_class <- c("spatial_buffer_vfold_cv", "rset")
    rsplit_class <- c("spatial_buffer_vfold_split")
  }

  posthoc_buffer_rset(
    data = data,
    rset = rset,
    rsplit_class = rsplit_class,
    rset_class = rset_class,
    radius = radius,
    buffer = buffer,
    n = n,
    v = v,
    cv_att = cv_att
  )

}


#' @rdname spatial_vfold
#'
#' @export
spatial_leave_location_out_cv <- function(data,
                                          group,
                                          v = NULL,
                                          radius = NULL,
                                          buffer = NULL,
                                          ...) {

  if (!missing(group)) {
    group <- tidyselect::eval_select(rlang::enquo(group), data)
  }

  if (missing(group) || length(group) == 0) {
    group <- NULL
  } else {
    if (is.null(v)) v <- length(unique(data[[group]]))
    v <- check_v(v, length(unique(data[[group]])), "locations")
  }

  n <- nrow(data)

  rset <- rsample::group_vfold_cv(
    data = data,
    v = v,
    group = {{ group }},
    ...
  )

  cv_att <- list(v = v,
                 group = group,
                 radius = radius,
                 buffer = buffer)

  if ("sf" %in% class(data)) {
    rset_class <- c("spatial_leave_location_out_cv", "spatial_rset", "rset")
    rsplit_class <- c("spatial_leave_location_out_cv", "spatial_rsplit")
  } else {
    rset_class <- c("spatial_leave_location_out_cv", "rset")
    rsplit_class <- c("spatial_leave_location_out_cv")
  }

  posthoc_buffer_rset(
    data = data,
    rset = rset,
    rsplit_class = rsplit_class,
    rset_class = rset_class,
    radius = radius,
    buffer = buffer,
    n = n,
    v = v,
    cv_att = cv_att
  )

}

posthoc_buffer_rset <- function(data,
                                rset,
                                rsplit_class,
                                rset_class,
                                radius,
                                buffer,
                                n,
                                v,
                                cv_att) {
  # This basically undoes everything post-`split_unnamed` for us
  # so we're back to an unnamed list of assessment-set indices
  indices <- purrr::map(rset$splits, as.integer, "assessment")

  if (is.null(radius) && is.null(buffer)) {
    indices <- lapply(indices, default_complement, n = n)
  } else {
    indices <- buffer_indices(
      data,
      indices,
      radius,
      buffer,
      call = rlang::caller_env()
    )
  }

  split_objs <- purrr::map(
    indices,
    make_splits,
    data = data,
    class = rsplit_class
  )

  split_objs <- tibble::tibble(
    splits = split_objs,
    id = names0(length(split_objs), "Fold"),
    v = v
  )

  split_objs$splits <- map(split_objs$splits, rm_out, buffer = buffer)

  new_rset(
    splits = split_objs$splits,
    ids = split_objs[, grepl("^id", names(split_objs))],
    attrib = cv_att,
    subclass = rset_class
  )

}
