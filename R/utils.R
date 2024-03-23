"%||%" <- function(x, y) {
  if (is.null(x)) y else x
}


"%NA%" <- function(x, y) {
  if (is.na(x)) y  else x
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


unbox <- function(x) {
  if (is.list(x) && length(x) == 1) {
    x <- x[[1]]
  }
  x
}


loadable <- function(x) {
  suppressPackageStartupMessages(requireNamespace(x, quietly = TRUE))
}


o311_path <- function(...) {
  system.file(..., package = "open311")
}


w3c_datetime <- function(x) {
  if (inherits(x, "POSIXct")) format(x, format = "%FT%R:%SZ")
}


rbind_list <- function(args) {
  nam <- lapply(args, names)
  unam <- unique(unlist(nam))
  len <- vapply(args, length, numeric(1))
  out <- vector("list", length(len))
  for (i in seq_along(len)) {
    if (nrow(args[[i]])) {
      nam_diff <- setdiff(unam, nam[[i]])
      if (length(nam_diff)) {
        args[[i]][nam_diff] <- NA
      }
    } else {
      next # nocov
    }
  }
  out <- do.call(rbind, args)
  rownames(out) <- NULL
  out
}
