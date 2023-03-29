library(testthat)
library(rsample)
library(purrr)

skip_if_not_installed("modeldata")

data(ames, package = "modeldata")
ames_sf <- sf::st_as_sf(ames, coords = c("Longitude", "Latitude"), crs = 4326)

test_that("erroring when no S2", {
  s2_store <- sf::sf_use_s2()
  sf::sf_use_s2(FALSE)
  expect_snapshot(
    spatial_buffer_vfold_cv(ames_sf, buffer = 500, radius = NULL),
    error = TRUE
  )
  expect_snapshot(
    suppressMessages(spatial_leave_location_out_cv(ames_sf, Neighborhood, buffer = 500)),
    error = TRUE
  )
  sf::sf_use_s2(s2_store)
})

test_that("spatial_buffer_vfold_cv", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)
  rs1 <- spatial_buffer_vfold_cv(ames_sf, radius = NULL, buffer = NULL)
  sizes1 <- dim_rset(rs1)

  set.seed(11)
  rs2 <- rsample::vfold_cv(ames_sf)
  expect_identical(
    purrr::map(rs1$splits, purrr::pluck, "in_id"),
    purrr::map(rs2$splits, purrr::pluck, "in_id")
  )

  expect_true(all(sizes1$analysis + sizes1$assessment == nrow(ames)))
  same_data <- map_lgl(
    rs1$splits,
    function(x) {
      isTRUE(all.equal(x$data, ames_sf))
    }
  )
  expect_true(all(same_data))

  good_holdout <- map_lgl(
    rs1$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))

  set.seed(123)
  rs1 <- spatial_buffer_vfold_cv(
    ames_sf,
    v = 2,
    radius = NULL,
    buffer = NULL,
    repeats = 2
  )
  expect_identical(
    names(rs1),
    c("splits", "id", "id2")
  )
  expect_snapshot(rs1)
  same_data <- map_lgl(
    rs1$splits,
    function(x) {
      isTRUE(all.equal(x$data, ames_sf))
    }
  )
  expect_true(all(same_data))

  good_holdout <- map_lgl(
    rs1$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("spatial_leave_location_out_cv", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)
  rs1 <- spatial_leave_location_out_cv(ames_sf, Neighborhood)
  sizes1 <- dim_rset(rs1)

  set.seed(11)
  rs2 <- rsample::group_vfold_cv(
    ames_sf,
    tidyselect::eval_select("Neighborhood", ames_sf)
  )
  expect_identical(
    purrr::map(rs1$splits, purrr::pluck, "in_id"),
    purrr::map(rs2$splits, purrr::pluck, "in_id")
  )

  expect_true(all(sizes1$analysis + sizes1$assessment == nrow(ames)))
  same_data <- map_lgl(
    rs1$splits,
    function(x) {
      isTRUE(all.equal(x$data, ames_sf))
    }
  )
  expect_true(all(same_data))

  good_holdout <- map_lgl(
    rs1$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))

  set.seed(123)
  rs1 <- spatial_leave_location_out_cv(
    ames_sf,
    Neighborhood,
    v = 2,
    repeats = 2
  )
  same_data <- map_lgl(
    rs1$splits,
    function(x) {
      isTRUE(all.equal(x$data, ames_sf))
    }
  )
  expect_true(all(same_data))

  good_holdout <- map_lgl(
    rs1$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))

  expect_identical(
    names(rs1),
    c("splits", "id", "id2")
  )
  skip_if_not(getRversion() >= numeric_version("3.6.0"))
  expect_snapshot(rs1)
})

test_that("bad args", {
  skip_if_not(sf::sf_use_s2())
  set.seed(123)

  set.seed(123)
  expect_snapshot(
    spatial_buffer_vfold_cv(ames_sf, radius = NULL),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_buffer_vfold_cv(ames_sf, buffer = 500),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_buffer_vfold_cv(ames_sf),
    error = TRUE
  )

  expect_snapshot(
    spatial_leave_location_out_cv(ames),
    error = TRUE
  )

  expect_snapshot(
    spatial_leave_location_out_cv(ames, Neighborhood, buffer = 500),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_leave_location_out_cv(ames_sf, v = c(5, 10)),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_buffer_vfold_cv(ames_sf, v = c(5, 10), buffer = NULL, radius = NULL),
    error = TRUE
  )

  skip_if_not(getRversion() >= numeric_version("3.6.0"))

  set.seed(123)
  expect_snapshot(
    spatial_leave_location_out_cv(ames_sf, Neighborhood, v = 60)
  )

  set.seed(123)
  expect_snapshot(
    spatial_buffer_vfold_cv(boston_canopy, v = 683, buffer = NULL, radius = NULL)
  )

  set.seed(123)
  expect_snapshot_error(
    spatial_buffer_vfold_cv(
      boston_canopy,
      v = 682,
      buffer = NULL,
      radius = NULL,
      repeats = 2
    )
  )

  set.seed(123)
  expect_snapshot_error(
    spatial_leave_location_out_cv(
      ames_sf,
      Neighborhood,
      repeats = 2
    )
  )
})

test_that("printing", {
  skip_if_not(sf::sf_use_s2())
  # The default RNG changed in 3.6.0
  skip_if_not(getRversion() >= numeric_version("3.6.0"))
  set.seed(123)
  expect_snapshot_output(
    spatial_block_cv(ames_sf)
  )
})

test_that("rsplit labels", {
  skip_if_not(sf::sf_use_s2())
  set.seed(123)
  rs <- spatial_buffer_vfold_cv(ames_sf, v = 2, buffer = NULL, radius = NULL)
  all_labs <- dplyr::bind_rows(purrr::map(rs$splits, labels))
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)

  set.seed(123)
  rs <- spatial_leave_location_out_cv(ames_sf, Neighborhood, v = 2)
  all_labs <- dplyr::bind_rows(purrr::map(rs$splits, labels))
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})
