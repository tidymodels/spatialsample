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

# Get the indices of the analysis set from the assessment set
default_complement <- function(ind, n) {
    list(analysis = setdiff(1:n, ind),
         assessment = unique(ind))
}

split_unnamed <- function(x, f) {
    out <- split(x, f)
    unname(out)
}

dim_rset <- function(x, ...) {
    dims <- purrr::map(x$splits, dim)
    dims <- do.call("rbind", dims)
    dims <- tibble::as_tibble(dims)
    id_cols <- grep("^id", colnames(x), value = TRUE)
    for (i in seq_along(id_cols)) {
        dims[id_cols[i]] <- getElement(x, id_cols[i])
    }
    dims
}
