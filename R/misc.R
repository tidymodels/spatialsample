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
    list(analysis = setdiff(1:n, ind),
         assessment = unique(ind))
}

## Split, but no names
split_unnamed <- function(x, f) {
    out <- split(x, f)
    unname(out)
}
