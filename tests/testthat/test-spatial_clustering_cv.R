library(testthat)
library(rsample)
library(purrr)
skip_if_not_installed("modeldata")

data("Smithsonian", package = "modeldata")
Smithsonian_sf <- sf::st_as_sf(
  Smithsonian,
  coords = c("longitude", "latitude"),
  crs = 4326
)

test_that("repeats", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)
  rs1 <- spatial_clustering_cv(
    Smithsonian_sf,
    v = 2,
    repeats = 2
  )
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis + sizes1$assessment == 20))
  same_data <- map_lgl(
    rs1$splits,
    function(x) {
      isTRUE(all.equal(x$data, Smithsonian_sf))
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

test_that("using hclust", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)
  rs1 <- spatial_clustering_cv(
    Smithsonian_sf,
    v = 2,
    cluster_function = "hclust"
  )
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$analysis + sizes1$assessment == 20))
  same_data <- map_lgl(
    rs1$splits,
    function(x) {
      isTRUE(all.equal(x$data, Smithsonian_sf))
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
    spatial_clustering_cv(Smithsonian),
    error = TRUE
  )
  expect_snapshot(
    spatial_clustering_cv(
      Smithsonian_sf,
      v = "a"
    ),
    error = TRUE
  )
  expect_snapshot(
    spatial_clustering_cv(
      Smithsonian_sf,
      v = c(5, 10)
    ),
    error = TRUE
  )
  expect_snapshot(
    spatial_clustering_cv(
      Smithsonian_sf,
      v = 100
    ),
    error = TRUE
  )
})

test_that("can pass the dots to kmeans", {
  skip_if_not(sf::sf_use_s2())
  expect_error(
    spatial_clustering_cv(
      Smithsonian_sf,
      v = 2,
      algorithm = "MacQueen"
    ),
    NA
  )
})

test_that("using sf", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)
  rs1 <- spatial_clustering_cv(
    Smithsonian_sf,
    v = 2
  )
  sizes1 <- dim_rset(rs1)

  set.seed(11)
  rs2 <- spatial_clustering_cv(
    Smithsonian_sf,
    v = 2,
    cluster_function = "kmeans"
  )
  expect_identical(rs1, rs2)

  expect_true(all(sizes1$analysis + sizes1$assessment == 20))
  same_data <- map_lgl(
    rs1$splits,
    function(x) {
      isTRUE(all.equal(x$data, Smithsonian_sf))
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

  # This tests to ensure that _other_ warnings don't fire on _most_ platforms
  # The default RNG changed in 3.6.0 (skips oldrel-4)
  skip_if_not(getRversion() >= numeric_version("3.6.0"))
  # Older builds without s2 give additional warnings,
  # as running sf::st_centroid pre-s2 gives inaccurate results
  # for geographic CRS (skips windows-3.6)
  skip_if_not(sf::sf_use_s2())
  set.seed(123)
  expect_snapshot(
    spatial_clustering_cv(Smithsonian_sf)
  )
})

test_that("using custom functions", {
  skip_if_not(sf::sf_use_s2())
  custom_cluster <- function(dists, v, ...) {
    clusters <- kmeans(dists, centers = v, ...)
    letters[clusters$cluster]
  }

  set.seed(11)
  rs1 <- spatial_clustering_cv(
    Smithsonian_sf,
    v = 2
  )
  set.seed(11)
  rs2 <- spatial_clustering_cv(
    Smithsonian_sf,
    v = 2,
    cluster_function = custom_cluster
  )
  expect_identical(rs1$splits, rs2$splits)

  expect_error(
    spatial_clustering_cv(
      Smithsonian_sf,
      v = 2,
      cluster_function = custom_cluster,
      algorithm = "MacQueen"
    ),
    NA
  )
})

test_that("polygons are only assigned one fold", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)

  rs1 <- spatial_clustering_cv(boston_canopy, cluster_function = "hclust")
  rs2 <- spatial_clustering_cv(boston_canopy, cluster_function = "kmeans")

  expect_identical(
    sum(map_int(rs1$splits, function(x) nrow(assessment(x)))),
    nrow(boston_canopy)
  )

  expect_identical(
    sum(map_int(rs2$splits, function(x) nrow(assessment(x)))),
    nrow(boston_canopy)
  )

  good_holdout <- map_lgl(
    c(
      rs1$splits,
      rs2$splits
    ),
    function(x) {
      length(intersect(x$in_ind, x$out_id)) == 0
    }
  )
  expect_true(all(good_holdout))
})

test_that("printing", {
  skip_if_not(sf::sf_use_s2())
  # The default RNG changed in 3.6.0
  skip_if_not(getRversion() >= numeric_version("3.6.0"))
  set.seed(123)
  expect_snapshot_output(
    spatial_clustering_cv(
      Smithsonian_sf,
      v = 2
    )
  )
})

test_that("rsplit labels", {
  skip_if_not(sf::sf_use_s2())
  rs <- spatial_clustering_cv(Smithsonian_sf, v = 2)
  all_labs <- dplyr::bind_rows(purrr::map(rs$splits, labels))
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})
