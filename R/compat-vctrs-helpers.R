# ------------------------------------------------------------------------------

# Keep this list up to date with known rset subclasses for testing.
# Delay assignment because we are creating this directly in the R script
# and not all of the required helpers might have been sourced yet.
test_data <- function() {
  x <- boston_canopy
  x$idx <- rep(c("a", "b"), length.out = nrow(x))
  x
}

delayedAssign("rset_subclasses", {
  if (rlang::is_installed("withr")) {
    withr::with_seed(
      123,
      list(
        spatial_block_cv              = spatial_block_cv(test_data()),
        spatial_clustering_cv         = spatial_clustering_cv(test_data()),
        spatial_buffer_vfold_cv       = spatial_buffer_vfold_cv(test_data(), radius = 1, buffer = 1),
        spatial_leave_location_out_cv = spatial_leave_location_out_cv(test_data(), idx)
      )
    )
  } else {
    NULL
  }
})
