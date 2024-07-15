#' Validate endpoints
#' @description
#' Checks whether and which endpoints are correctly defined, reachable,
#' and/or valid. Iterates through all endpoints defined in
#' \code{\link{o311_endpoints}} and returns their status along with a
#' reason, if applicable.
#'
#' @param idx \code{[integer]}
#'
#' Index numbers of endpoints to check. Index numbers follow
#' row numbers in \code{\link{o311_endpoints}}.
#'
#' @param checks \code{[character]}
#'
#' Which open311 method to check. By default, checks all
#' methods.
#'
#' @param methods \code{[character]}
#'
#' Which checks to apply. \code{formal} checks whether an
#' endpoint is uniquely identifiable through given names and jurisdictions
#' in \code{\link{o311_endpoints}}. \code{down} checks whether an endpoint
#' is reachable and ready for requests. \code{valid} checks whether a method
#' returns a valid output, i.e. a list or dataframe with more than 0
#' rows/elements. By default, applies all methods.
#'
#' @return A dataframe containing the name of the endpoint, one to three
#' columns on check results, and one to three columns on reasons if a check
#' turned out to be negative.
#'
#' @export
#'
#' @examples
#' \donttest{
#' # check the first three endpoints in o311_endpoints()
#' validate_endpoints(1:3)
#'
#' # check only requests
#' validate_endpoints(1:3, checks = "requests")
#'
#' # check only whether an endpoint is down
#' validate_endpoints(1:3, methods = "down")
#' }
validate_endpoints <- function(idx = NULL,
                               checks = c("discovery", "services", "requests"),
                               methods = c("formal", "down", "valid")) {
  checks <- match.arg(checks, several.ok = TRUE)
  methods <- match.arg(methods, several.ok = TRUE)

  endpoints <- o311_endpoints()
  idx <- idx %||% seq_len(nrow(endpoints))
  ok <- lapply(idx, function(i) {
    waiter(current = which(i == idx), total = length(idx), unit = "endpoint")
    name <- endpoints$name[i] %NA% NULL
    juris <- endpoints$jurisdiction[i] %NA% NULL

    formal <- try(o311_api(endpoint = name, jurisdiction = juris), silent = TRUE)
    if (inherits(formal, "try-error")) {
      do_formal <- rep("formal" %in% methods, 3)
      ok <- do.call(cbind.data.frame, as.list(!do_formal))
      reasons <- do.call(
        cbind.data.frame,
        as.list(ifelse(do_formal, "Endpoints not unique", NA))
      )
    } else {
      down <- lapply(checks, check_down, methods)
      invalid <- lapply(down, check_valid, methods)

      ok <- do.call(cbind.data.frame, as.list(is.na(invalid)))
      reasons <- do.call(cbind.data.frame, invalid)
    }

    names(ok) <- checks
    names(reasons) <- paste0("reason_", checks)
    cbind(name = name, ok, reasons)
  })
  as_data_frame(rbind_list(ok))
}


check_down <- function(x, methods) {
  if (!"down" %in% methods) return(NA) # nocov
  fun <- match.fun(paste0("o311_", x))
  res <- try(fun(), silent = TRUE)
  if (inherits(res, "try-error")) {
    return("API not reachable")
  }
  res
}


check_valid <- function(x, methods) {
  if (!"valid" %in% methods) return(NA) # nocov
  if (is.character(x)) return(x)

  if (is.data.frame(x)) {
    ok <- nrow(x) > 0
  } else {
    ok <- length(x) > 0
  }

  if (!ok) {
    return("Output invalid") # nocov
  }

  NA
}
