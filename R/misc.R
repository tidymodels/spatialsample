## Keep synced with rsample

names0 <- function(num, prefix = "x") {
  if (num == 0L) {
    return(character())
  }
  ind <- format(1:num)
  ind <- gsub(" ", "0", ind)
  paste0(prefix, ind)
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

## This will remove the assessment indices from an rsplit object
rm_out <- function(x, buffer = NULL) {
  if (is.null(buffer)) x$out_id <- NA
  x
}

# Check sparse geometry binary predicate for empty elements
# See ?sf::sgbp for more information on the data structure
sgbp_is_not_empty <- function(x) !identical(x, integer(0))

is_sf <- function(x) {
  inherits(x, "sf") || inherits(x, "sfc")
}

is_longlat <- function(x) {
  !(sf::st_crs(x) == sf::NA_crs_) && sf::st_is_longlat(x)
}
