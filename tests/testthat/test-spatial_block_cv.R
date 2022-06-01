library(testthat)
library(rsample)
library(purrr)

skip_if_not_installed("modeldata")

data(ames, package = "modeldata")
ames_sf <- sf::st_as_sf(ames, coords = c("Longitude", "Latitude"), crs = 4326)

test_that("random assignment", {
  set.seed(11)
  rs1 <- spatial_block_cv(ames_sf)
  sizes1 <- dim_rset(rs1)

  set.seed(11)
  rs2 <- spatial_block_cv(ames_sf, method = "random")
  expect_identical(rs1, rs2)

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

test_that("systematic assignment -- snake", {
  set.seed(11)
  rs1 <- spatial_block_cv(ames_sf, method = "snake")
  sizes1 <- dim_rset(rs1)
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
  rs3 <- spatial_block_cv(
    ames_sf,
    method = "snake",
    relevant_only = FALSE,
    v = 4
  )
  sizes3 <- dim_rset(rs3)
  expect_true(all(sizes3$analysis + sizes3$assessment == nrow(ames)))
  same_data <- map_lgl(
    rs3$splits,
    function(x) {
      isTRUE(all.equal(x$data, ames_sf))
    }
  )
  expect_true(all(same_data))

  good_holdout <- map_lgl(
    rs3$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("systematic assignment -- continuous", {
  set.seed(11)
  rs1 <- spatial_block_cv(ames_sf, method = "continuous")

  sizes1 <- dim_rset(rs1)
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
  rs3 <- spatial_block_cv(ames_sf,
    method = "continuous",
    relevant_only = FALSE,
    v = 4
  )
  sizes3 <- dim_rset(rs3)
  expect_true(all(sizes3$analysis + sizes3$assessment == nrow(ames)))
  same_data <- map_lgl(
    rs3$splits,
    function(x) {
      isTRUE(all.equal(x$data, ames_sf))
    }
  )
  expect_true(all(same_data))

  good_holdout <- map_lgl(
    rs3$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("bad args", {
  set.seed(123)
  expect_snapshot(
    spatial_block_cv(ames),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(sf::st_set_crs(ames_sf, sf::NA_crs_)),
    error = TRUE
  )

  skip_if_not(sf::sf_use_s2())

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(ames_sf, v = c(5, 10)),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(ames_sf, v = c(5, 10), method = "snake"),
    error = TRUE
  )

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(ames_sf, method = "snake", relevant_only = FALSE, v = 5)
  )

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(ames_sf, method = "snake", v = 60)
  )

  skip_if_not(getRversion() >= numeric_version("3.6.0"))

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(ames_sf, v = 60)
  )
})

test_that("printing", {
  # The default RNG changed in 3.6.0
  skip_if_not(getRversion() >= numeric_version("3.6.0"))
  set.seed(123)
  expect_snapshot_output(
    spatial_block_cv(ames_sf)
  )
})

test_that("rsplit labels", {
  set.seed(123)
  rs <- spatial_block_cv(ames_sf, v = 2)
  all_labs <- map_df(rs$splits, labels)
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})
