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

test_that("reverse_splits is working", {
  skip_if_not(rlang::is_installed("withr"))

  for (x in rset_subclasses) {

    set.seed(123)
    rev_x <- rsample::reverse_splits(x)
    expect_identical(analysis(x$splits[[1]]), assessment(rev_x$splits[[1]]))
    expect_identical(assessment(x$splits[[1]]), analysis(rev_x$splits[[1]]))
    expect_identical(class(x), class(rev_x))
    expect_identical(class(x$splits[[1]]), class(rev_x$splits[[1]]))

  }

})

test_that("reshuffle_rset is working", {

  skip_if_not(rlang::is_installed("withr"))

  # Reshuffling with the same seed, in the same order,
  # should recreate the same objects
  out <- withr::with_seed(
    123,
    lapply(
      rset_subclasses,
      function(x) suppressWarnings(rsample::reshuffle_rset(x))
    )
  )

  for (i in seq_along(rset_subclasses)) {
    expect_identical(
      out[[i]],
      rset_subclasses[[i]]
    )
  }

})
