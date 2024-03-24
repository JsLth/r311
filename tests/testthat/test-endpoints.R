test_that("endpoints can be modified", {
  o311_reset_endpoints()
  user_dir <- tools::R_user_dir("open311")
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


test_that("fails when not set up", {
  # test missing setup
  expect_error(o311_services(), class = "o311_setup_error")
})


test_that("selecting api works", {
  # test endpoint passed
  j1 <- o311_api("san francisco")
  expect_named(o311_cache, "juris")

  # test jurisdiction passed
  j2 <- o311_api(jurisdiction = "sfgov.org")
  expect_identical(j1, j2)
})


test_that("identical endpoints/jurisdictions fail", {
  # test identical endpoints and jurisdictions
  add_test_endpoint()
  add_test_endpoint()
  expect_error(
    o311_api("sf test"),
    class = "o311_endpoints_corrupt_error"
  )
  o311_reset_endpoints()

  # test identical endpoints
  add_test_endpoint()
  add_test_endpoint(juris = "test")
  expect_error(
    o311_api("sf test"),
    class = "o311_ambiguous_endpoints_error"
  )
  o311_reset_endpoints()

  # test identical jurisdictions
  add_test_endpoint(juris = "test")
  add_test_endpoint("sf test2", juris = "test")
  expect_error(
    o311_api(jurisdiction = "test"),
    class = "o311_ambiguous_juris_error"
  )
  o311_reset_endpoints()
})


test_that("no arguments returns current api", {
  expect_identical(o311_api(), get_juris())
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
    o311_api("sf test", format = "json"),
    class = "o311_json_unsupported_error"
  )
  with_mocked_bindings(
    expect_error(
      o311_api("sf test", format = "xml"),
      class = "o311_package_error"
    ),
    loadable = function(x) FALSE
  )
  o311_reset_endpoints()
})


test_that("path seperators are handled well", {
  p1 <- "test.org/path"
  p2 <- url_path("test.org", "/path/")
  expect_identical(p1, p2)
})


test_that("simple queries return the expected output", {
  skip_on_cran()
  add_test_endpoint()
  o311_api("sf test")

  expect_failure(expect_length(o311_discovery(), 0))
  expect_gt(nrow(serv <- o311_services()), 0)
  expect_gt(nrow(tick <- o311_requests()), 0)
  expect_s3_class(serv <- o311_services(), "tbl")
  expect_gt(nrow(o311_service(serv$service_code[1])), 0)
  expect_equal(nrow(o311_request(tick$service_request_id[1])), 1)
})


test_that("fails gracefully", {
  add_test_endpoint("sf invalid", juris = "test")
  o311_api("sf invalid")
  expect_error(o311_query("services"), class = "o311_403")
  o311_reset_endpoints()
  add_test_endpoint("sf test")
  expect_error(o311_query("no-endpoint", api_key = "test"), class = "o311_404")
})


test_that("tidying xml produces a valid dataframe", {
  skip_on_cran()
  o311_api("sf test", format = "xml")
  expect_gt(nrow(o311_requests()), 0)
})


test_that("queries change the response", {
  skip_on_cran()
  o311_api("sf test")
  tick <- o311_requests(status = "open")
  expect_identical(unique(tick$status), "open")
})


test_that("time is correctly formatted", {
  skip_on_cran()
  expect_gt(nrow(o311_requests(end_date = Sys.time())), 0)
})


test_that("o311_request_all can terminate", {
  skip_on_cran()
  expect_error(o311_request_all(page = 1), class = "o311_page_unsupported_error")
  expect_error(o311_request_all(status = "test"), "should be one of")
  expect_equal(nrow(with_mocked_bindings(
    o311_request_all(),
    o311_requests = function(...) data.frame(test = 1)
  )), 1)
  expect_equal(nrow(with_mocked_bindings(
    o311_request_all(),
    o311_requests = function(..., page) if (page == 1) {
      data.frame(test = 1)
    } else {
      stop()
    }
  )), 1)
  expect_equal(nrow(o311_request_all(max_pages = 2)), 100)
})


test_that("assertions work", {
  string <- "a"
  char <- c("a", "b")
  doub1 <- 1.5
  doub2 <- c(1.5, 1.5)
  int <- 1
  flag <- TRUE
  logi <- c(TRUE, FALSE)
  na <- NA
  url <- "google.com"
  time <- Sys.time()

  assert_string(NULL)
  assert_number(NULL)
  assert_flag(NULL)
  assert_string(string)
  assert_string(char, n = 2)
  assert_number(doub1)
  assert_number(doub2, n = 2)
  assert_number(int, int = TRUE)
  assert_flag(flag)
  assert_url(url)
  assert_time(time)
  assert_dots_named(a = string)

  expect_error(assert_string(NULL, null = FALSE))
  expect_error(assert_string(char))
  expect_error(assert_number(doub2))
  expect_error(assert_number(doub1, int = TRUE))
  expect_error(assert_flag(logi))
  expect_error(assert_flag(na))
  expect_error(assert_url(string))
  expect_error(assert_time("2024"))
  expect_error(assert_dots_named(string))
})

test_that("utils work", {
  expect_identical(unbox(list(list(1))), list(1))
})
