"%||%" <- function(x, y) {
  if (is.null(x)) y else x
}


"%NA%" <- function(x, y) {
  if (is.na(x)) y  else x
}


abort <- function(msg, class = NULL, call = NULL, ...) {
  error <- list(message = msg, call = call %||% sys.call(-1))
  class(error) <- c(paste0("o311_", class %||% "error"), "error", "condition")
  stop(error)
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


loadable <- function(...) {
  all(vapply(c(...), FUN.VALUE = logical(1), function(pkg) {
    suppressPackageStartupMessages(requireNamespace(pkg, quietly = TRUE))
  }))
}


o311_path <- function(...) {
  system.file(..., package = "r311")
}


o311_user_dir <- function(...) {
  getOption("o311_user_dir", default = tools::R_user_dir("r311"))
}


w3c_datetime <- function(x) {
  if (inherits(x, "POSIXt")) format(x, format = "%FT%R:%SZ")
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
        args[[i]][nam_diff] <- NA # nocov
      }
    } else {
      next # nocov
    }
  }
  out <- do.call(rbind, args)
  rownames(out) <- NULL
  out
}


waiter <- function(current = NULL, total = Inf, unit = "page") {
  msg <- sprintf("Receiving %s %s", unit, current)
  if (!is.infinite(total)) {
    msg <- sprintf(paste(msg, "out of %s"), total)
  }
  cat(paste0(msg, "...\r"))
}
