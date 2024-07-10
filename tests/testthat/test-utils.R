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
  assert_string(string)
  assert_string(char, n = 2)
  assert_number(doub1)
  assert_number(doub2, n = 2)
  assert_number(int, int = TRUE)
  assert_flag(flag)
  assert_url(url)
  assert_time(time)
  assert_dots_named(a = string)
  assert_flag(NULL, null = TRUE)

  expect_error(assert_flag(NULL))
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

  expect_output(waiter(1, 10), "Receiving page 1 out of 10...")
  expect_output(waiter(1), "Receiving page 1...")
})
