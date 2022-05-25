library(testthat)
library(rsample)
library(purrr)
library(modeldata)

data(ames, package = "modeldata")
ames_sf <- sf::st_as_sf(ames, coords = c("Longitude", "Latitude"), crs = 4326)

test_that("random assignment", {
  set.seed(11)
  rs1 <- block_cv(ames_sf)
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis + sizes1$assessment == nrow(ames)))
  same_data <-
    map_lgl(rs1$splits, function(x) {
      isTRUE(all.equal(x$data, ames_sf))
    })
  expect_true(all(same_data))

  good_holdout <- map_lgl(
    rs1$splits,
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("printing", {
  # The default RNG changed in 3.6.0
  skip_if_not(getRversion() >= numeric_version("3.6.0"))
  set.seed(123)
  expect_snapshot_output(
    block_cv(ames_sf)
  )
})

test_that("rsplit labels", {
  rs <- block_cv(ames_sf, v = 2)
  all_labs <- map_df(rs$splits, labels)
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})
