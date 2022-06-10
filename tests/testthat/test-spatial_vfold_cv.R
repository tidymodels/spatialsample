library(testthat)
library(rsample)
library(purrr)

skip_if_not_installed("modeldata")

data(ames, package = "modeldata")
ames_sf <- sf::st_as_sf(ames, coords = c("Longitude", "Latitude"), crs = 4326)

test_that("erroring when no S2", {
  s2_store <- sf::sf_use_s2()
  sf::sf_use_s2(FALSE)

  # suppressMessages to avoid:
  # + "Message"
  # + "  Note: Using an external vector in selections is ambiguous."
  # + "  i Use `all_of(group)` instead of `group` to silence this message."
  # + "  i See <https://tidyselect.r-lib.org/reference/faq-external-vector.html>."
  # + "  This message is displayed once per session."
  # This is percolating up from rsample but I can't find where https://github.com/tidymodels/rsample/runs/6760867450?check_suite_focus=true#step:6:182
  expect_snapshot(
    suppressMessages(spatial_buffer_vfold_cv(ames_sf, buffer = 500, radius = NULL)),
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

})

test_that("spatial_leave_location_out_cv", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)
  rs1 <- spatial_leave_location_out_cv(ames_sf, Neighborhood)
  sizes1 <- dim_rset(rs1)

  set.seed(11)
  rs2 <- rsample::group_vfold_cv(ames_sf,
                                 tidyselect::eval_select("Neighborhood", ames_sf))
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

})

test_that("bad args", {
  skip_if_not(sf::sf_use_s2())
  set.seed(123)
  expect_snapshot(
    spatial_buffer_vfold_cv(ames, buffer = 500, radius = NULL),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_buffer_vfold_cv(ames, radius = NULL),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_buffer_vfold_cv(ames, buffer = 500),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_buffer_vfold_cv(ames),
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
  all_labs <- map_df(rs$splits, labels)
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)

  set.seed(123)
  rs <- spatial_leave_location_out_cv(ames_sf, Neighborhood, v = 2)
  all_labs <- map_df(rs$splits, labels)
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})