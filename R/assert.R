assert_string <- function(x, null = TRUE, n = 1L) {
  if (
    (!is.character(x) ||
    !length(x) == n ||
    is.na(x)) &&
    ifelse(null, FALSE, is.null(x))
  ) {
    x_name <- deparse(substitute(x))
    stop(sprintf(
      "%s must be a character (length %s), not %s (length %s)",
      x_name, n, typeof(x), length(x)
    ))
  }
}


assert_number <- function(x, null = TRUE, n = 1) {
  if (
    (!is.numeric(x) ||
     !length(x) == n ||
     is.na(x)) &&
    ifelse(null, FALSE, is.null(x))
  ) {
    x_name <- deparse(substitute(x))
    stop(sprintf(
      "%s must be a numeric (length %s), not %s (length %s)",
      x_name, n, typeof(x), length(x)
    ))
  }
}


assert_time <- function(x, null = TRUE, n = 1) {
  if (
    (!inherits(x, "POSIXct") ||
     !length(x) == n ||
     is.na(x)) &&
    ifelse(null, FALSE, is.null(x))
  ) {
    x_name <- deparse(substitute(x))
    stop(sprintf(
      "%s must be a POSIXct object (length %s), not %s (length %s)",
      x_name, n, typeof(x), length(x)
    ))
  }
}
