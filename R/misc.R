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
check_v <- function(v, max_v, objects, call = rlang::caller_env()) {
  if (!is.numeric(v) || length(v) != 1) {
    rlang::abort("`v` must be a single integer.", call = call)
  }
  if (v > max_v) {
    rlang::warn(paste0(
      "Fewer than ", v, " ", objects, " available for sampling; setting v to ",
      max_v, "."
    ), call = call)
    v <- max_v
  }
  v
}

# Check sparse geometry binary predicate for empty elements
# See ?sf::sgbp for more information on the data structure
sgbp_is_not_empty <- function(x) !identical(x, integer(0))
