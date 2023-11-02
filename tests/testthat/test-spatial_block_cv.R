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
    spatial_block_cv(ames_sf),
    error = TRUE
  )
  sf::sf_use_s2(s2_store)
})

test_that("random assignment", {
  skip_if_not(sf::sf_use_s2())
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

test_that("repeated", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)
  rs2 <- spatial_block_cv(ames_sf, repeats = 2)

  same_data <-
    purrr::map_lgl(rs2$splits, function(x) {
      all.equal(x$data, ames_sf)
    })
  expect_true(all(same_data))

  good_holdout <- purrr::map_lgl(
    rs2$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("systematic assignment -- snake", {
  skip_if_not(sf::sf_use_s2())
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

  # Not setting seed because this _should_ be deterministic
  boston_snake <- spatial_block_cv(
    boston_canopy,
    v = 10,
    method = "snake",
    relevant_only = FALSE,
    n = c(10, 23)
  )
  expect_snapshot(boston_snake)
  expect_snapshot(as.integer(boston_snake$splits[[1]]))
})

test_that("systematic assignment -- continuous", {
  skip_if_not(sf::sf_use_s2())
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

test_that("polygons are only assigned one fold", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)

  rs1 <- spatial_block_cv(boston_canopy, method = "continuous")
  rs2 <- spatial_block_cv(boston_canopy, method = "snake")
  rs3 <- spatial_block_cv(boston_canopy, method = "random")

  expect_identical(
    sum(map_int(rs1$splits, function(x) nrow(assessment(x)))),
    nrow(boston_canopy)
  )

  expect_identical(
    sum(map_int(rs2$splits, function(x) nrow(assessment(x)))),
    nrow(boston_canopy)
  )

  expect_identical(
    sum(map_int(rs3$splits, function(x) nrow(assessment(x)))),
    nrow(boston_canopy)
  )

  good_holdout <- map_lgl(
    c(
      rs1$splits,
      rs2$splits,
      rs3$splits
    ),
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("blocks are filtered based on centroids", {
  skip_if_not(sf::sf_use_s2())
  set.seed(123)
  rs1 <- spatial_block_cv(boston_canopy, v = 18, cellsize = 15000)
  expect_true(
    all(
      purrr::map_lgl(
        rs1$splits,
        ~ !is.null(nrow(assessment(.x))) && nrow(assessment(.x)) > 0
      )
    )
  )
})

test_that("duplicated observations in assessment sets throws an error", {
  # adapted from bug in https://stackoverflow.com/q/77374348/9625040
  # but the bigger grid makes it easier to visualize what's going on
  drought_sf <- sf::st_as_sf(
    expand.grid(
      x = seq(995494, 1018714, 430),
      y = seq(1019422, by = 430, length.out = 55)
    ),
    coords = c("x", "y"),
    crs = 7760
  )

  expect_snapshot_error(
    spatial_block_cv(drought_sf, expand_bbox = 0)
  )
  expect_no_error(
    spatial_block_cv(drought_sf)
  )
})

test_that("bad args", {
  skip_if_not(sf::sf_use_s2())
  set.seed(123)
  expect_snapshot(
    spatial_block_cv(ames),
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
    spatial_block_cv(ames_sf, method = "snake", relevant_only = FALSE, v = 28)
  )

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(ames_sf, method = "snake", v = 60)
  )

  skip_if_not(getRversion() >= numeric_version("3.6.0"))

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(sf::st_set_crs(ames_sf, sf::NA_crs_))
  )

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(ames_sf, v = 60)
  )

  set.seed(123)
  expect_snapshot(
    spatial_block_cv(boston_canopy, n = 200)
  )

  set.seed(123)
  expect_snapshot_error(
    spatial_block_cv(boston_canopy, method = "continuous", repeats = 2)
  )

  set.seed(123)
  expect_snapshot_error(
    spatial_block_cv(boston_canopy, method = "snake", repeats = 2)
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
  rs <- spatial_block_cv(ames_sf, v = 2)
  all_labs <- dplyr::bind_rows(purrr::map(rs$splits, labels))
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})
