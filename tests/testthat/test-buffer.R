chosen_points <- sf::st_as_sf(
  data.frame(x = c(0, 1, 3), y = 1),
  coords = c("x", "y"),
  # Any projected CRS should be fine here
  crs = 2249
)

test_that("buffering selects the expected points", {

  skip_if_offline()
  sf::sf_proj_network(enable = TRUE)

  skip_if_not(sf::sf_use_s2())

  # These points fall along a number line: point 1 is 1 away from point 2,
  # point 3 is 2 away from point 2

  # Using a projected CRS (so no geographic weirdness), that means buffering
  # should be conceptually straightforward: points X units away should be
  # "caught" by any radius or buffer (or the two combined) >= X

  # No buffer or radius: only the selected point (2) should be in test:
  expect_identical(
    buffer_indices(chosen_points, list(2), 0, 0),
    list(
      list(
        analysis = c(1L, 3L),
        assessment = 2
      )
    )
  )

  # 1 radius 0 buffer: the point at 1 should be in test:
  expect_identical(
    buffer_indices(chosen_points, list(2), 1, 0),
    list(
      list(
        analysis = c(3L),
        assessment = c(2, 1)
      )
    )
  )

  # 0 radius 1 buffer: the point at 1 should be nowhere:
  expect_identical(
    buffer_indices(chosen_points, list(2), 0, 1),
    list(
      list(
        analysis = c(3L),
        assessment = c(2)
      )
    )
  )

  # 1 radius 2 buffer: the point at 3 should be nowhere:
  expect_identical(
    buffer_indices(chosen_points, list(2), 1, 2),
    list(
      list(
        analysis = integer(),
        assessment = c(2, 1)
      )
    )
  )

  # 0 radius 2 buffer: the point at 3 should be nowhere:
  expect_identical(
    buffer_indices(chosen_points, list(2), 0, 2),
    list(
      list(
        analysis = integer(),
        assessment = c(2)
      )
    )
  )

  # >1 radius 1 buffer: the point at 3 should be in test:
  expect_identical(
    buffer_indices(chosen_points, list(2), 1.8, 1),
    list(
      list(
        analysis = c(3L),
        assessment = c(2, 1)
      )
    )
  )

})

skip_if_not_installed("modeldata")
data("ames", package = "modeldata")

test_that("bad args", {
  ames_sf <- sf::st_as_sf(
    ames,
    coords = c("Longitude", "Latitude")
  )
  expect_snapshot(
    spatial_clustering_cv(ames_sf, buffer = 50),
    error = TRUE
  )
  ames_sf <- sf::st_set_crs(
    ames_sf,
    4326
  )
  s2_status <- sf::sf_use_s2()
  sf::sf_use_s2(FALSE)
  expect_snapshot(
    buffer_indices(ames_sf),
    error = TRUE
  )
  sf::sf_use_s2(s2_status)
})

ames_sf <- sf::st_as_sf(
  ames,
  coords = c("Longitude", "Latitude"),
  crs = 4326
)

test_that("using buffers", {

  skip_if_not(sf::sf_use_s2())
  skip_if_offline()
  sf::sf_proj_network(enable = TRUE)

  set.seed(11)
  rs1 <- spatial_clustering_cv(
    ames_sf,
    v = 2
  )
  set.seed(11)
  rs2 <- spatial_clustering_cv(
    ames_sf,
    v = 2,
    radius = 0,
    buffer = 0
  )

  attr(rs2, "radius") <- NULL
  attr(rs2, "buffer") <- NULL
  expect_identical(rs1, rs2)

  set.seed(11)
  expect_snapshot(
    spatial_clustering_cv(
      ames_sf,
      v = 2,
      radius = 500,
      buffer = 500
    )
  )

  set.seed(11)
  expect_snapshot(
    spatial_block_cv(
      boston_canopy,
      v = 2,
      method = "snake",
      radius = 500,
      buffer = 500
    )
  )

  # The default RNG changed in 3.6.0
  skip_if_not(getRversion() >= numeric_version("3.6.0"))

  set.seed(11)
  expect_snapshot(
    spatial_block_cv(
      ames_sf,
      v = 2,
      method = "random",
      radius = 500,
      buffer = 500
    )
  )

})
