## Keep synced with rsample

names0 <- function(num, prefix = "x") {
  if (num == 0L) {
    return(character())
  }
  ind <- format(1:num)
  ind <- gsub(" ", "0", ind)
  paste0(prefix, ind)
}

## This will remove the assessment indices from an rsplit object
rm_out <- function(x) {
  x$out_id <- NA
  x
}

## Get the indices of the analysis set from the assessment set
default_complement <- function(ind, n) {
  list(
    analysis = setdiff(1:n, ind),
    assessment = unique(ind)
  )
}

## Split, but no names
split_unnamed <- function(x, f) {
  out <- split(x, f)
  unname(out)
}

### Functions below are spatialsample-specific

#' Check that "v" is sensible
#'
#' @param v The number of partitions of the data set. Set to `NULL` or `Inf` to
#' set it to the maximum sensible value (for leave-one-X-out cross-validation).
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

# Check sparse geometry binary predicate for empty elements
# See ?sf::sgbp for more information on the data structure
sgbp_is_not_empty <- function(x) !identical(x, integer(0))
