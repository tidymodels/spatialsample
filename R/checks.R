check_sf <- function(data, calling_function, call = rlang::caller_env()) {
  if (!is_sf(data)) {
    rlang::abort(
      c(
        glue::glue("{calling_function} currently only supports `sf` objects."),
        i = "Try converting `data` to an `sf` object via `sf::st_as_sf()`."
      ),
      call = call
    )
  }
}

check_s2 <- function(data, calling_function, call = rlang::caller_env()) {
  if (is_longlat(data) && !sf::sf_use_s2()) {
    rlang::abort(
      c(
        glue::glue("{calling_function} can only process geographic coordinates when using the s2 geometry library."),
        "i" = "Reproject your data into a projected coordinate reference system using `sf::st_transform()`.",
        "i" = "Or install the `s2` package and enable it using `sf::sf_use_s2(TRUE)`."
      ),
      call = call
    )
  }
}

check_na_crs <- function(data, calling_function, call = rlang::caller_env()) {
  if (sf::st_crs(data) == sf::NA_crs_) {
    rlang::warn(
      c(
        glue::glue("{calling_function} expects your data to have an appropriate coordinate reference system (CRS)."),
        i = "If possible, try setting a CRS using `sf::st_set_crs()`.",
        i = glue::glue("Otherwise, {tolower(calling_function)} will assume your data is in projected coordinates.")
      ),
      call = call
    )
  }
}

standard_checks <- function(data, calling_function, call = rlang::caller_env()) {
  check_sf(data, calling_function, call)
  check_na_crs(data, calling_function, call)
  check_s2(data, calling_function, call)
}

#' Check that "v" is sensible
#'
#' @param v The number of partitions for the resampling. Set to `NULL` or `Inf`
#' for the maximum sensible value (for leave-one-X-out cross-validation).
#' @keywords internal
check_v <- function(v,
                    max_v,
                    objects,
                    allow_max_v = TRUE,
                    call = rlang::caller_env()) {

  if (is.null(v)) v <- Inf

  if (!rlang::is_integerish(v) || length(v) != 1 || v < 1) {
    rlang::abort("`v` must be a single positive integer.", call = call)
  }

  if (is.infinite(v)) {
    if (!allow_max_v) {
      rlang::abort(
        "`v` cannot be `NULL` or `Inf` for this function",
        call = call
      )
    }
    v <- max_v
  }

  if (v > max_v) {
    if (!allow_max_v) {
      rlang::abort(
        c(
          glue::glue(
            "The number of {objects} is less than `v = {v}` ({max_v})"
          ),
          i = glue::glue("Set `v` to a smaller value than {max_v}")
        ),
        call = call
      )
    }

    rlang::warn(
      c(
        glue::glue("Fewer than {v} {objects} available for sampling"),
        i = glue::glue("Setting `v` to {max_v}")
      ),
      call = call
    )

    v <- max_v
  }
  v
}
