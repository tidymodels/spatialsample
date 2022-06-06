skip_if_not_installed("modeldata")
skip_if_not_installed("vdiffr")

data(ames, package = "modeldata")

ames_sf <- sf::st_as_sf(ames, coords = c("Longitude", "Latitude"), crs = 4326)
set.seed(123)
ames_cluster <- spatial_clustering_cv(ames_sf)

set.seed(123)
ames_block <- spatial_block_cv(ames_sf)

set.seed(123)
ames_non_sf <- spatial_clustering_cv(ames, coords = c("Longitude", "Latitude"))

test_that("autoplot is stable", {
  p <- autoplot(ames_cluster)
  vdiffr::expect_doppelganger("cluster plots", p)

  p <- autoplot(ames_block, show_grid = FALSE)
  vdiffr::expect_doppelganger("block plots", p)

  p <- autoplot(ames_block)
  vdiffr::expect_doppelganger("block plots with grid", p)

  p <- autoplot(ames_cluster$splits[[1]])
  vdiffr::expect_doppelganger("cluster split plots", p)

  p <- autoplot(ames_block$splits[[1]])
  vdiffr::expect_doppelganger("block split plots", p)

  expect_snapshot(
    autoplot(ames_non_sf),
    error = TRUE
  )
})
