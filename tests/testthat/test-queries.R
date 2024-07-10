test_that("path seperators are handled well", {
  p1 <- "test.org/path"
  p2 <- url_path("test.org", "/path/")
  expect_identical(p1, p2)
})


test_that("simple queries return the expected output", {
  skip_on_cran()
  add_test_endpoint()
  o311_api("sd test")

  expect_failure(expect_length(o311_discovery(), 0))
  expect_gt(nrow(serv <- o311_services()), 0)
  expect_gt(nrow(tick <- o311_requests()), 0)
  expect_s3_class(serv <- o311_services(), "tbl")
  expect_gt(nrow(o311_service(serv$service_code[1])), 0)
  expect_equal(nrow(o311_request(na.omit(tick$service_request_id)[1])), 1)
})


test_that("fails gracefully", {
  add_test_endpoint("sf invalid", juris = "test")
  o311_api("sf invalid")
  expect_error(o311_query("services"), class = "o311_403")
  o311_reset_endpoints()
  add_test_endpoint("sd test")
  expect_error(o311_query("no-endpoint", api_key = "test"), class = "o311_404")
})


test_that("validation works", {
  add_test_endpoint("sf invalid", juris = "test")
  ep <- o311_endpoints()
  vldt <- validate_endpoints(c(1, nrow(ep)))
  expect_identical(vldt$reason_requests, c(NA, "API not reachable"))
  expect_identical(vldt$requests, c(TRUE, FALSE))
  o311_reset_endpoints()
})

test_that("formal validation works", {
  with_mocked_bindings(
    {
      add_test_endpoint()
      add_test_endpoint()
    },
    has_duplicate_endpoints = function(...) FALSE
  )
  ep <- o311_endpoints()
  vldt <- validate_endpoints(c(nrow(ep), nrow(ep) - 1))
  expect_in(vldt$reason_requests, "Endpoints not unique")
  expect_identical(vldt$requests, c(FALSE, FALSE))
})

test_that("tidying xml produces a valid dataframe", {
  skip_on_cran()
  add_test_endpoint("sd test")
  o311_api("sd test", format = "xml")
  expect_gt(nrow(o311_requests()), 0)
})


test_that("wkt is parsed if needed", {
  o311_api("greifswald")
  expect_s3_class(o311_query("areas"), "sf")
})


test_that("o311_ok detects wrong roots", {
  o311_add_endpoint("unavailable", root = "google.com/open311/v2")
  o311_api("unavailable")
  expect_false(o311_ok())
  expect_s3_class(o311_ok(error = TRUE), class = "o311_404")

  o311_add_endpoint("empty", root = "https://seeclickfix.com/open311/v2/20/")
  o311_api("empty")
  expect_s3_class(o311_ok(error = TRUE), class = "o311_ok_error")
  expect_equal(nrow(o311_requests()), 0)

  o311_add_endpoint("invalid", root = "http://echo.jsontest.com/key/value/one/two")
  o311_api("invalid")
  expect_s3_class(o311_ok(error = TRUE), class = "o311_ok_error")

  add_test_endpoint()
  o311_api("sd test")
  expect_true(o311_ok())

  o311_reset_endpoints()
})


test_that("queries change the response", {
  skip_on_cran()
  add_test_endpoint()
  o311_api("sd test")
  tick <- o311_requests(status = "open")
  expect_identical(unique(tick$status), "open")
  o311_reset_endpoints()
})


test_that("time is correctly formatted", {
  skip_on_cran()
  add_test_endpoint()
  o311_api("sd test")
  expect_gt(nrow(o311_requests(end_date = Sys.time())), 0)
  o311_reset_endpoints()
})


test_that("o311_request_all can terminate", {
  skip_on_cran()
  add_test_endpoint()
  o311_api("sd test")
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
  o311_reset_endpoints()
})
