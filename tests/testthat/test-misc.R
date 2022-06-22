test_that("check_v errors appropriately", {
  expect_snapshot(
    check_v(-1),
    error = TRUE
  )
  expect_snapshot(
    check_v(c(5, 10)),
    error = TRUE
  )
  expect_snapshot(
    check_v("a"),
    error = TRUE
  )
  expect_snapshot(
    check_v(10, 5, "rows", FALSE),
    error = TRUE
  )
})

test_that("check_v updates v appropriately", {

  expect_snapshot(
    new_v <- check_v(10, 5, "rows")
  )

  expect_identical(
    new_v,
    5
  )
})

test_that("check_v handles NULL and Inf appropriately", {

  expect_snapshot(
    check_v(c(Inf, 1)),
    error = TRUE
  )

  expect_snapshot(
    check_v(Inf, 5, "rows", FALSE),
    error = TRUE
  )

  expect_snapshot(
    check_v(NULL, 5, "rows", FALSE),
    error = TRUE
  )

  expect_identical(
    check_v(NULL, 5, "rows"),
    5
  )

  expect_identical(
    check_v(Inf, 5, "rows"),
    5
  )

})
