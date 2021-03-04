# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------

test_data <- function() {
    data.frame(
        x = 1:50,
        y = rep(c(1, 2), each = 25)
    )
}

# Keep this list up to date with known rset subclasses for testing.
rset_subclasses <- list(
    spatial_clustering_cv = spatial_clustering_cv(test_data(), coords = c(x, y), v = 3)
)

# ------------------------------------------------------------------------------

tib_upcast <- function(x) {
    size <- df_size(x)

    # Strip all attributes except names to construct
    # a bare list to build the tibble back up from.
    attributes(x) <- list(names = names(x))

    tibble::new_tibble(x, nrow = size)
}

df_size <- function(x) {
    if (!is.list(x)) {
        rlang::abort("Cannot get the df size of a non-list.")
    }

    if (length(x) == 0L) {
        return(0L)
    }

    col <- x[[1L]]

    vec_size(col)
}

# ------------------------------------------------------------------------------

expect_s3_class_rset <- function(x) {
    expect_s3_class(x, "rset")
}

expect_s3_class_bare_tibble <- function(x) {
    expect_s3_class(x, c("tbl_df", "tbl", "data.frame"), exact = TRUE)
}
