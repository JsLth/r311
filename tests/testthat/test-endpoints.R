local_mocked_bindings(o311_user_dir = function() tempdir())

test_that("endpoints can be modified", {
  o311_reset_endpoints()
  user_dir <- o311_user_dir()
  expect_false(startsWith(endpoints_json(), user_dir))
  nrow1 <- nrow(o311_endpoints())

  add_test_endpoint()

  expect_true(startsWith(endpoints_json(), user_dir))
  nrow2 <- nrow(o311_endpoints())
  expect_true(nrow2 - nrow1 == 1)
  expect_failure(expect_named(jsonlite::read_json(endpoints_json())))

  o311_reset_endpoints()

  expect_false(startsWith(endpoints_json(), user_dir))
  nrow3 <- nrow(o311_endpoints())
  expect_true(nrow3 - nrow1 == 0)

  with_mocked_bindings(
    loadable = function(x) FALSE,
    expect_false(tibble::is_tibble(o311_endpoints()))
  )
})


test_that("endpoints can be filtered", {
  endpoints <- o311_endpoints(dialect = "Mark-a-Spot", limit = 50)
  expect_identical(unique(endpoints$limit), 50L)
  expect_identical(unique(endpoints$dialect), "Mark-a-Spot")
  expect_error(o311_endpoints(test = 1), class = "o311_endpoints_filter_error")
})


test_that("doesnt duplicate endpoints", {
  nrow1 <- nrow(o311_endpoints())
  add_test_endpoint()
  add_test_endpoint()
  nrow2 <- nrow(o311_endpoints())
  expect_equal(nrow1, nrow2 - 1)
  o311_reset_endpoints()
})
