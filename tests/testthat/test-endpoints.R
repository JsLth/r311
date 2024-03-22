test_that("endpoints can be modified", {
  o311_reset_endpoints()
  user_dir <- tools::R_user_dir("open311")
  expect_false(startsWith(jurisdictions_json(), user_dir))
  nrow1 <- nrow(o311_endpoints())

  add_test_endpoint()

  expect_true(startsWith(jurisdictions_json(), user_dir))
  nrow2 <- nrow(o311_endpoints())
  expect_true(nrow2 - nrow1 == 1)
  expect_failure(expect_named(jsonlite::read_json(jurisdictions_json())))

  o311_reset_endpoints()

  expect_false(startsWith(jurisdictions_json(), user_dir))
  nrow3 <- nrow(o311_endpoints())
  expect_true(nrow3 - nrow1 == 0)

  with_mocked_bindings(
    loadable = function(x) FALSE,
    expect_false(tibble::is_tibble(o311_endpoints()))
  )
})


test_that("setting a jurisdiction works", {
  expect_error(o311_services(), "Could not find root API")

  j1 <- o311_jurisdiction("san francisco")
  expect_named(o311_cache, "juris")

  j2 <- o311_jurisdiction(jurisdiction = "sfgov.org")
  expect_identical(j1, j2)

  expect_error(o311_jurisdiction())

  add_test_endpoint()
  add_test_endpoint()

  expect_error(
    o311_jurisdiction("sf test"),
    regexp = "Consider fixing the endpoints"
  )

  o311_reset_endpoints()

  add_test_endpoint()
  add_test_endpoint(juris = "test")

  expect_error(
    o311_jurisdiction("sf test"),
    regexp = "Multiple identical endpoints detected"
  )

  o311_reset_endpoints()

  add_test_endpoint(juris = "test")
  add_test_endpoint("sf test2", juris = "test")

  expect_error(
    o311_jurisdiction(jurisdiction = "test"),
    regexp = "Multiple identical jurisdictions"
  )

  o311_reset_endpoints()

  expect_error(o311_jurisdiction("invalid"))
  regexp = "No jurisdiction could be found"
})
