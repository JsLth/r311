test_that("fails when not set up", {
  # test missing setup
  expect_error(o311_services(), class = "o311_setup_error")
})


test_that("selecting api works", {
  # test endpoint passed
  j1 <- o311_api("san diego")
  expect_named(o311_cache, "juris")

  # test jurisdiction passed
  j2 <- o311_api(jurisdiction = "sandiego.gov")
  expect_identical(j1, j2)
})


test_that("identical endpoints/jurisdictions fail", {
  # test identical endpoints and jurisdictions
  with_mocked_bindings(
    {
      add_test_endpoint()
      add_test_endpoint()
    },
    has_duplicate_endpoints = function(...) FALSE
  )
  expect_error(
    o311_api("sd test"),
    class = "o311_endpoints_corrupt_error"
  )
  o311_reset_endpoints()
})


test_that("no arguments returns current api", {
  expect_identical(o311_api(), get_juris())
})


test_that("print method works", {
  expect_output(print(o311_api()), "r311_api")
})


test_that("invalid api fails", {
  # test invalid jurisdiction
  expect_error(
    o311_api("invalid"),
    class = "o311_not_found_error"
  )
})


test_that("format checks in place", {
  # test format errors
  add_test_endpoint(json = FALSE)
  expect_error(
    o311_api("sd test", format = "json"),
    class = "o311_json_unsupported_error"
  )
  with_mocked_bindings(
    expect_error(
      o311_api("sd test", format = "xml"),
      class = "o311_package_error"
    ),
    loadable = function(...) FALSE
  )
  o311_reset_endpoints()
})
