assert_string <- function(x, null = TRUE, n = 1L) {
  if (null && is.null(x)) return(invisible())
  if (
    (!is.character(x) ||
    !length(x) == n ||
    any(is.na(x)))
  ) {
    x_name <- deparse(substitute(x))
    stop(sprintf(
      "%s must be character (length %s), not %s (length %s)",
      x_name, n, typeof(x), length(x)
    ))
  }
}


assert_number <- function(x, null = TRUE, n = 1, int = FALSE) {
  if (null && is.null(x)) return(invisible())
  if (
    (!is.numeric(x) ||
     !length(x) == n ||
     any(is.na(x)) ||
     ifelse(int, x %% 1 != 0, FALSE))
  ) {
    x_name <- deparse(substitute(x))
    stop(sprintf(
      "%s must be %s (length %s), not %s (length %s)",
      x_name, ifelse(int, "integer", "numeric"), n, typeof(x), length(x)
    ))
  }
}


assert_flag <- function(x, null = TRUE) {
  if (null && is.null(x)) return(invisible())
  if (
    (!is.logical(x) ||
     !length(x) == 1 ||
     any(is.na(x)))
  ) {
    x_name <- deparse(substitute(x))
    stop(sprintf(
      "%s must be TRUE or FALSE, not %s (length %s)",
      x_name, typeof(x), length(x)
    ))
  }
}


assert_time <- function(x, null = TRUE, n = 1) {
  if (null && is.null(x)) return(invisible())
  if (
    (!inherits(x, "POSIXct") ||
     !length(x) == n ||
     any(is.na(x)))
  ) {
    x_name <- deparse(substitute(x))
    stop(sprintf(
      "%s must be a POSIXct object (length %s), not %s (length %s)",
      x_name, n, typeof(x), length(x)
    ))
  }
}


assert_url <- function(x) {
  assert_string(x, null = FALSE)

  regex <- "^(https?:\\/\\/)?[A-Za-z0-9_.\\-~]+(\\.[[:lower:]]+)|(:[[:digit:]])\\/?"
  if (!grepl(regex, x, perl = TRUE)) {
    x_name <- deparse(substitute(x))
    stop(sprintf("%s must be a valid URL", x))
  }
}


assert_dots_named <- function(...) {
  if (...length() && is.null(...names())) {
    stop("All arguments in ... must be named.")
  }
}
