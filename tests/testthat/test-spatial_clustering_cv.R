library(testthat)
library(rsample)
library(purrr)
library(modeldata)

data("Smithsonian")


test_that("using kmeans", {
  set.seed(11)
  rs1 <- spatial_clustering_cv(Smithsonian,
    coords = c(latitude, longitude),
    v = 2
  )
  set.seed(11)
  rs2 <- spatial_clustering_cv(Smithsonian,
                               coords = c(latitude, longitude),
                               v = 2,
                               fun = "kmeans"
  )
  expect_identical(rs1, rs2)
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis + sizes1$assessment == 20))
  same_data <-
    map_lgl(rs1$splits, function(x) {
      all.equal(x$data, Smithsonian)
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


test_that("using hclust", {
    set.seed(11)
    rs1 <- spatial_clustering_cv(Smithsonian,
                                 coords = c(latitude, longitude),
                                 v = 2,
                                 fun = "hclust"
    )
    sizes1 <- dim_rset(rs1)

    expect_true(all(sizes1$analysis + sizes1$assessment == 20))
    same_data <-
        map_lgl(rs1$splits, function(x) {
            all.equal(x$data, Smithsonian)
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


test_that("bad args", {
  expect_error(spatial_clustering_cv(Smithsonian, coords = NULL))
  expect_error(spatial_clustering_cv(Smithsonian, coords = c(Species, Sepal.Width)))
  expect_error(
    spatial_clustering_cv(Smithsonian,
                          coords = c(latitude, longitude),
                          v = "a"),
    "`v` must be a single integer"
  )
  expect_error(
    spatial_clustering_cv(Smithsonian,
                          coords = c(latitude, longitude),
                          v = c(5, 10)),
    "`v` must be a single integer"
  )
})

test_that("can pass the dots to kmeans", {
  expect_error(
    spatial_clustering_cv(Smithsonian,
      coords = c(latitude, longitude),
      v = 2,
      algorithm = "MacQueen"
    ),
    NA
  )
})

test_that("using sf", {

  Smithsonian_sf <- sf::st_as_sf(Smithsonian,
                                 coords = c("longitude", "latitude"),
                                 crs = 4326)

  expect_warning(
    spatial_clustering_cv(Smithsonian_sf, coords = c(latitude, longitude)),
    "`coords` is ignored when providing `sf` objects to `data`."
  )

  set.seed(11)
  rs1 <- spatial_clustering_cv(Smithsonian_sf,
                               v = 2
  )
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis + sizes1$assessment == 20))
  same_data <-
    map_lgl(rs1$splits, function(x) {
      all.equal(x$data, Smithsonian_sf)
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
  suppressWarnings(
    RNGversion("3.5.3") # RNG changes in 3.6.0 cause this to fail in < 3.6
  )
  set.seed(123)
  expect_snapshot_output(
    spatial_clustering_cv(Smithsonian,
      coords = c(latitude, longitude),
      v = 2
    )
  )
})

test_that("rsplit labels", {
  rs <- spatial_clustering_cv(Smithsonian, coords = c(latitude, longitude), v = 2)
  all_labs <- map_df(rs$splits, labels)
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})
