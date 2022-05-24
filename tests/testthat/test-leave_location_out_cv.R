library(testthat)
library(rsample)
library(purrr)
library(modeldata)

data("Sacramento")

test_that("default params", {
  set.seed(11)
  rs1 <- leave_location_out_cv(Sacramento, city)
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis + sizes1$assessment == 932))
  same_data <- map_lgl(
    rs1$splits,
    function(x) {
      all.equal(x$data, Sacramento)
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
  expect_snapshot(
    leave_location_out_cv(Sacramento, city, pool = 0.47),
    error = TRUE
  )

  expect_snapshot(
    leave_location_out_cv(Sacramento, city, v = c(2, 5)),
    error = TRUE
  )

  expect_snapshot(
    leave_location_out_cv(Sacramento, not_a_column),
    error = TRUE
  )

  Sacramento_tmp <- Sacramento
  levels(Sacramento_tmp$city) <- c(levels(Sacramento_tmp$city), ".pooled_locations")
  Sacramento_tmp$city[[1]] <- ".pooled_locations"
  expect_snapshot(
    leave_location_out_cv(Sacramento_tmp, city, pool = 0.03)
  )
  rm(Sacramento_tmp)

  expect_snapshot(
    leave_location_out_cv(Sacramento, city, pool = 0.03, v = 8)
  )

  expect_snapshot(
    leave_location_out_cv(Sacramento, city, pool = 0.04)
  )
})


test_that("printing", {
  expect_snapshot_output(
    leave_location_out_cv(Sacramento, city, v = 4)
  )
})

test_that("rsplit labels", {
  rs <- leave_location_out_cv(Sacramento, city, v = 4)
  all_labs <- map_df(rs$splits, labels)
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})

test_that("sf objects are accepted", {
  Sacramento_sf <- sf::st_as_sf(
    Sacramento,
    coords = c("longitude", "latitude"),
    crs = 4326 # WGS84
  )

  set.seed(11)
  rs1 <- leave_location_out_cv(Sacramento_sf, city)
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis + sizes1$assessment == 932))
  same_data <- map_lgl(
      rs1$splits,
      function(x) {
          all.equal(x$data, Sacramento_sf)
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
