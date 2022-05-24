#' Leave-Location-Out Cross Validation
#'
#' @description
#' In situations where you have a clear idea of what data are most likely
#' to be related to one another, it often makes sense to use those groupings
#' to create validation folds rather than trying to cluster or block data into
#' sensible groups.
#' For instance, if your samples are collected from several islands and you're
#' primarily interested in how your model generalizes to unmeasured islands,
#' then the easiest way to assess your model is to treat each island as a "fold"
#' for the purposes of v-fold CV.
#' This function breaks `data` into `v` folds, grouping data which share a
#' `location` into the same folds. When `v` is equal to the number of unique
#' `location`s, this function produces "leave-one-location-out" resamples.
#'
#' @inheritParams rsample::vfold_cv
#' @param location A variable in data (single character or name) used to
#' indicate "location" groupings. Data are immediately converted to factors,
#' so it is possible to use integer indicators.
#' @param pool A proportion of data used to determine if a particular location
#' is too small and should be pooled into another group. For instance, if
#' `pool = 0.1`, then only locations constituting 10% or more of the data will
#' be preserved, with the remainder being folded into a single "pooled" location.
#'
#' @examples
#' data(Sacramento, package = "modeldata")
#'
#' leave_location_out_cv(Sacramento, city)
#' leave_location_out_cv(Sacramento, city, pool = 0.03)
#' leave_location_out_cv(Sacramento, city, pool = 0.03, v = 5)
#'
#' @references
#'
#' H. Meyer, C. Reudenbach, T. Hengl, M. Katurji, and T. Nauss, 2018.
#' "Improving performance of spatio-temporal machine learning models using
#' forward feature selection and target-oriented validation,"
#' Environmental Modelling & Software 101,
#' pp. 1-9, doi: 10.1016/j.envsoft.2017.12.001.
#'
#' @export
leave_location_out_cv <- function(data, location, v = length(unique(location)),
                                  pool = 0, ...) {
  location <- tidyselect::eval_select(rlang::enquo(location), data = data)

  if (is_empty(location)) {
    rlang::abort("`location` is required and must be variables in `data`.")
  }
  location <- make_location(getElement(data, location), pool = pool)
  n_locations <- length(unique(location))

  if (missing(v)) {
    v <- n_locations
  } else if (!is.numeric(v) || length(v) != 1) {
    rlang::abort("`v` must be a single integer.")
  } else if (v > n_locations) {
    rlang::warn(paste0(
      "Fewer than ", v, " locations available for sampling; setting v to ",
      n_locations, "."
    ))
    v <- n_locations
  }

  split_objs <- llo_splits(
    data = data, location = location, v = v, pool = pool
  )

  ## We remove the holdout indices since it will save space and we can
  ## derive them later when they are needed.

  split_objs$splits <- map(split_objs$splits, rm_out)

  ## Save some overall information

  cv_att <- list(v = v)

  new_rset(
    splits = split_objs$splits,
    ids = split_objs[, grepl("^id", names(split_objs))],
    attrib = cv_att,
    subclass = c("leave_location_out_cv", "rset")
  )
}

llo_splits <- function(data, location, v, pool = 0.1) {

  n <- nrow(data)
  locations <- tibble::tibble(
    idx = seq_len(n),
    location = location
  )

  folds <- tibble::tibble(
    location = unique(locations$location),
    fold = sample(rep(seq_len(v), length.out = length(unique(locations$location))))
  )

  locations <- merge(locations, folds, by = c("location"))
  indices <- split_unnamed(locations$idx, locations$fold)
  indices <- lapply(indices, default_complement, n = n)
  split_objs <- purrr::map(
    indices,
    make_splits,
    data = data,
    class = "llo_split"
  )
  tibble::tibble(
    splits = split_objs,
    id = names0(length(split_objs), "Fold")
  )
}

#' @export
print.leave_location_out_cv <- function(x, ...) {
    cat("# ", pretty(x), "\n")
    class(x) <- class(x)[!(class(x) %in% c("leave_location_out_cv", "rset"))]
    print(x, ...)
}

#' Create or Modify Location Variables
#'
#' @details
#' For categorical inputs, the function will find levels of `x` than
#'   occur in the data with percentage less than `pool`. The values from
#'   these groups will be pooled into a single category (if they make up
#'   a greater than `pool` percentage of the data) or combined with the smallest
#'   extant category (if not).
#'
#' @param x An input vector.
#' @param pool A proportion of data used to determine if a particular group is
#'   too small and should be pooled into another group.
#' @return  A factor vector.
#'
#' @keywords internal
make_location <- function(x, pool = .1) {

  n <- length(x)
  x <- factor(x)
  xtab <- sort(table(x))
  pcts <- xtab / n

  if (all(pcts < pool) || sum(pcts > pool) == 1) {
    rlang::abort(c(
      "Fewer than two locations had enough data to use without pooling.",
      "Consider providing a less granular location variable."
    ))
  }

  ## Small groups will all be thrown into either a single pooled location,
  ## or appended to the smallest extant grouping
  if (any(pcts < pool)) {
    x[x %in% names(pcts)[pcts < pool]] <- NA
  }

  default_name <- ".pooled_locations"
  replacement_name <- default_name

  ## If the combined location itself wouldn't be bigger than `pool`,
  ## combine them with the smallest group that does:
  if ((sum(pcts < pool) / n) < pool) {
      replacement_name <- xtab[which(pcts > pool)]
      replacement_name <- names(replacement_name[which.min(replacement_name)])
    rlang::warn(c(
      paste0("Combining small locations into a new group would create a ",
             "group smaller than ", round(100 * pool), "% of the data."),
      paste0("They have been combined with '", replacement_name, "' instead.")
    ))
  }

  ## The next line will also relevel the data if `x` was a factor
  out <- factor(as.character(x))

  ## Warn if the default_name group is already in the data
  ##
  ## I don't know if this is the right way to handle this, three other ways:
  ##
  ## 1. If default_name already exists, error out
  ## 2. If default_name already exists, don't check for < pool but combine
  ## with default_name automatically (so users can select a fallback group)
  ## 3. If default_name already exists, try alternative names until one works
  if (any(levels(x) == default_name)) {
    rlang::warn(c(
      paste0("Missing and small locations are being combined with ",
             "the pre-existing '", default_name, "' group."),
      paste0("Rename '", default_name, "'", " to avoid this.")
    ))
  }

  num_miss <- sum(is.na(x))
  if (num_miss > 0) {
    levels(out) <- unique(c(levels(out), replacement_name))
    out[is.na(x)] <- replacement_name
  }

  out
}
