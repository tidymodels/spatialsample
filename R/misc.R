## Keep synced with rsample

names0 <- function(num, prefix = "x") {
    if (num == 0L) {
        return(character())
    }
    ind <- format(1:num)
    ind <- gsub(" ", "0", ind)
    paste0(prefix, ind)
}

# Get the indices of the analysis set from the assessment set
vfold_complement <- function(ind, n) {
    list(analysis = setdiff(1:n, ind),
         assessment = ind)
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
