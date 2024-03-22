"%||%" <- function(x, y) {
  if (is.null(x)) y else x
}


"%NA%" <- function(x, y) {
  if (is.na(x)) y  else x
}


data_frame <- function(...) {
  if (loadable("tibble")) {
    tibble::tibble(...)
  } else {
    data.frame(...)
  }
}


as_data_frame <- function(...) {
  if (loadable("tibble")) {
    tibble::as_tibble(...)
  } else {
    as.data.frame(...)
  }
}


drop_null <- function(x) {
  x[!vapply(x, FUN.VALUE = logical(1), is.null)]
}


loadable <- function(x) {
  suppressPackageStartupMessages(requireNamespace(x, quietly = TRUE))
}


o311_path <- function(...) {
  system.file(..., package = "open311")
}



w3c_datetime <- function(x) {
  if (is.character(x)) format(x, format = "%FT%R:%SZ")
}
