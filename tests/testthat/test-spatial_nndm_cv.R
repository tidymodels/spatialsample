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

test_that("bad args", {

  expect_snapshot(
    spatial_nndm_cv(Smithsonian_sf[1:15, ], Smithsonian[16:20, ]),
    error = TRUE
  )

  expect_snapshot(
    spatial_nndm_cv(Smithsonian[1:15, ], Smithsonian_sf[16:20, ]),
    error = TRUE
  )
})

test_that("can pass the dots to st_sample", {
  skip_if_not(sf::sf_use_s2())
  expect_no_error(
    spatial_nndm_cv(
      Smithsonian_sf[1:15, ],
      Smithsonian_sf[16:20, ],
      type = "regular"
    )
  )
})

test_that("normal usage", {
  skip_if_not(sf::sf_use_s2())
  set.seed(11)
  rs1 <- spatial_nndm_cv(
    Smithsonian_sf[1:15, ],
    Smithsonian_sf[16:20, ]
  )
  sizes1 <- dim_rset(rs1)

  expect_true(all(sizes1$assessment == 1))
  same_data <- map_lgl(
    rs1$splits,
    function(x) {
      isTRUE(all.equal(x$data, Smithsonian_sf[1:15, ]))
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
    spatial_nndm_cv(Smithsonian_sf[1:15, ], Smithsonian_sf[16:20, ])
  )
})

test_that("can pass a single polygon to sample within", {
  library(sf)
  skip_if_not(sf::sf_use_s2())

  example_poly <- sf::st_as_sfc(
    list(
      sf::st_point(c(-77.03, 40)),
      sf::st_point(c(-76, 40.5)),
      sf::st_point(c(-76.5, 39.5))
    )
  )
  example_poly <- sf::st_set_crs(example_poly, sf::st_crs(Smithsonian_sf))
  example_poly <- sf::st_union(example_poly)
  example_poly <- sf::st_cast(example_poly, "POLYGON")

  expect_snapshot(
    spatial_nndm_cv(
      Smithsonian_sf,
      example_poly
    )
  )
})



test_that("printing", {
  skip_if_not(sf::sf_use_s2())
  # The default RNG changed in 3.6.0
  skip_if_not(getRversion() >= numeric_version("3.6.0"))
  set.seed(123)
  expect_snapshot_output(
    spatial_nndm_cv(Smithsonian_sf[1:15, ], Smithsonian_sf[16:20, ])
  )
})

test_that("rsplit labels", {
  skip_if_not(sf::sf_use_s2())
  rs <- spatial_nndm_cv(Smithsonian_sf[1:15, ], Smithsonian_sf[16:20, ])
  all_labs <- dplyr::bind_rows(purrr::map(rs$splits, labels))
  original_id <- rs[, grepl("^id", names(rs))]
  expect_equal(all_labs, original_id)
})

test_that("passing a polygon works correctly", {
  skip_if_not(sf::sf_use_s2())
  ames_sf <- sf::st_as_sf(
    modeldata::ames,
    coords = c("Longitude", "Latitude"), 
    crs = 4326
  )
  ch <- sf::st_as_sfc(sf::st_bbox(ames_sf))

  withr::with_seed(
    123,
    pts <- sf::st_sample(ch, 1000)
  )
  nndm_1 <- spatial_nndm_cv(ames_sf[1:100, ], pts)
  attr(nndm_1, "prediction_sites") <- ch
  withr::with_seed(
    123,
    nndm_2 <- spatial_nndm_cv(ames_sf[1:100, ], ch)
  )
  expect_identical(nndm_1, nndm_2)
})