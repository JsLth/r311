assert_string <- function(x, null = TRUE, n = 1L) {
  if (null && is.null(x)) return(invisible())
  if (
    (!is.character(x) ||
    !length(x) %in% n ||
    any(is.na(x)))
  ) {
    x_name <- deparse(substitute(x))
    type <- ifelse(is.na(x), NA, typeof(x))[1]
    abort(sprintf(
      "%s must be character (length %s), not %s (length %s)",
      x_name, n, type, length(x)
    ))
  }
}


assert_number <- function(x, null = TRUE, n = 1, int = FALSE, inf = FALSE) {
  if (null && is.null(x)) return(invisible())
  if (inf && is.infinite(x)) return(invisible())
  if (
    (!is.numeric(x) ||
     !length(x) %in% n ||
     any(is.na(x)) ||
     ifelse(int, x %% 1 != 0, FALSE))
  ) {
    x_name <- deparse(substitute(x))
    type <- ifelse(is.na(x), NA, typeof(x))[1]
    abort(sprintf(
      "%s must be %s (length %s), not %s (length %s)",
      x_name, ifelse(int, "integer", "numeric"), n, type, length(x)
    ))
  }
}


assert_flag <- function(x, null = FALSE) {
  if (null && is.null(x)) return(invisible())
  if (
    (!is.logical(x) ||
     !length(x) %in% 1 ||
     any(is.na(x)))
  ) {
    x_name <- deparse(substitute(x))
    type <- ifelse(is.na(x), NA, typeof(x))[1]
    abort(sprintf(
      "%s must be TRUE or FALSE, not %s (length %s)",
      x_name, type, length(x)
    ))
  }
}


assert_time <- function(x, null = TRUE, n = 1) {
  if (null && is.null(x)) return(invisible())
  if (
    (!inherits(x, "POSIXct") ||
     !length(x) %in% n ||
     any(is.na(x)))
  ) {
    x_name <- deparse(substitute(x))
    type <- ifelse(is.na(x), NA, typeof(x))[1]
    abort(sprintf(
      "%s must be a POSIXct object (length %s), not %s (length %s)",
      x_name, n, type, length(x)
    ))
  }
}


assert_url <- function(x) {
  assert_string(x, null = FALSE)

  regex <- "^(https?:\\/\\/)?[A-Za-z0-9_.\\-~]+(\\.[[:lower:]]+)|(:[[:digit:]])\\/?"
  if (!grepl(regex, x, perl = TRUE)) {
    x_name <- deparse(substitute(x))
    abort(sprintf("%s must be a valid URL", x))
  }
}


assert_dots_named <- function(...) {
  if (...length() && is.null(...names())) {
    abort("All arguments in ... must be named.")
  }
}
