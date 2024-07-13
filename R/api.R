o311_cache <- new.env(parent = emptyenv())


#' Select an open311 API
#' @description
#' Select an open311 API and attach it to the active session. An open311 API is
#' an implementation of the open311 standard. It consists of an endpoint name
#' (e.g. a city), a root URL, and a jurisdiction ID. To unambiguously identify
#' an API, you can provide an endpoint, a jurisdiction ID, or both. The input
#' is matched with \code{\link{o311_endpoints}} to select an API. The
#' selected API is available to other \code{o311_*} functions until the
#' session is terminated or until it is overwritten.
#'
#' @param endpoint \code{[character]}
#'
#' Name of an endpoint that runs an open311 API. This is usually a
#' city, but can be any provider of an open311 API.
#'
#' @param jurisdiction \code{[character]}
#'
#' ID of a jurisdiction that is served by an open311 API. A jurisdiction
#' ID is usually the root URL of the jurisdiction website, e.g.
#' \code{"sandiego.gov"} for San Diego.
#'
#' @param key \code{[character]}
#'
#' If a key is required by the selected API, this argument can be used to
#' store the key in the R session. The API key is automatically used in
#' API requests. If \code{key} is \code{NULL} although a key is required,
#' a warning is emitted.
#'
#' @param format \code{[character]}
#'
#' Response format. Must be one of \code{"json"} or \code{"xml"}. Defaults to
#' \code{"json"} because simplification is more difficult and unsafe for
#' \code{xml2} objects. It is advisable to use \code{"json"} whenever
#' possible and applicable. Additionally, \code{"xml"} requires the
#' \code{xml2} package for queries and the \code{xmlconvert} package for
#' simplification.
#'
#' @returns A list containing the most important information on a given
#' jurisdiction, invisibly. This list is attached to the session and can
#' be retrieved by calling \code{o311_api()} without arguments. Passing no
#' arguments returns the currently attached API object.
#'
#' @details
#' In theory, several jurisdictions can exist for a single endpoints, e.g.
#' if a region serves multiple jurisdictions. Similarly, multiple endpoints
#' can exist for a single jurisdiction, e.g. if a provider has set up both
#' production and test endpoints for a jurisdictions. Providing both
#' endpoint and jurisdiction is thus the most safe way to identify an API.
#'
#' By default, only a handful of endpoints are supported. For a list of
#' currently supported endpoints, run \code{\link{o311_endpoints}}. You can
#' add non-default endpoints using \code{\link{o311_add_endpoint}}.
#'
#' @examples
#' # cities are matched using regex
#' o311_api("Cologne")
#'
#' # passing a jurisdiction is more explicit
#' o311_api(jurisdiction = "stadt-koeln.de")
#'
#' # calls without arguments return the current API
#' o311_api()
#' @seealso
#' \code{\link{o311_requests}}, \code{\link{o311_request}},
#' \code{\link{o311_services}}
#' @export
o311_api <- function(endpoint = NULL,
                     jurisdiction = NULL,
                     key = NULL,
                     format = c("json", "xml")) {
  if (is.null(endpoint) && is.null(jurisdiction)) {
    return(get_juris())
  }

  assert_string(endpoint)
  assert_string(jurisdiction)
  format <- match.arg(format)
  endpoints <- o311_endpoints()

  if (!is.null(jurisdiction)) {
    endpoints <- endpoints[endpoints$jurisdiction %in% jurisdiction, ]
  } else if (!is.null(endpoint)) {
    endpoints <- endpoints[grepl(
      endpoint,
      endpoints$name,
      ignore.case = TRUE
    ), ]
  }

  check_jurisdiction(endpoints)
  check_format(endpoints, format)
  endpoints$json <- identical(format, "json")

  if (isTRUE(endpoints$key) && !is.null(key)) {
    assign("api_key", key, envir = o311_cache)
  } else if (isTRUE(endpoints$key)) {
    warning(paste(
      "An API key is needed to use this API.",
      "If necessary, pass a valid key to `o311_api()`"
    ))
  } else {
    name <- intersect("api_key", ls(envir = o311_cache))
    rm(list = name, envir = o311_cache)
  }

  juris <- lapply(endpoints, "%NA%", NULL)
  class(juris) <- "r311_api"
  assign("juris", juris, envir = o311_cache)
  invisible(juris)
}


get_juris <- function() {
  get0("juris", envir = o311_cache) %||% setup_error()
}


setup_error <- function() {
  abort(
    paste(
      "Could not find root API.",
      "Please set an active API using `o311_api()`"
    ),
    call. = FALSE,
    class = "setup_error"
  )
}


check_jurisdiction <- function(endpoints) {
  if (nrow(endpoints) > 1) {
    endpoints_dup <- length(unique(endpoints$name)) == 1
    juris_dup <- length(unique(endpoints$jurisdiction)) == 1

    abort(
      paste(
        "Multiple APIs matched.\n",
        "Consider changing the input arguments or fixing the endpoints list",
        "using `o311_reset_endpoints()`."
      ),
      class = "endpoints_corrupt_error"
    )
  }

  if (!nrow(endpoints)) {
    abort(
      paste(
        "No jurisdiction could be found given the specified",
        "city / jurisdiction ID.\nRun `o311_endpoints()`",
        "to get an overview of available jurisdictions."
      ),
      class = "not_found_error"
    )
  }
}


check_format <- function(endpoints, format) {
  if (!endpoints$json && identical(format, "json")) {
    abort(
      paste(
        "JSON responses are not supported by the given API.",
        "Change the `format` argument to \"xml\"."
      ),
      class = "json_unsupported_error"
    )
  } else if (!loadable("xml2", "xmlconvert") && identical(format, "xml")) {
    abort(
      "The `xml2` package is needed to accept XML responses.",
      class = "package_error"
    )
  }
}


#' @export
print.r311_api <- function(x, ...) {
  fmt <- vapply(names(x), FUN.VALUE = character(1), function(i) {
    nws <- strrep(" ", 12 - nchar(i))
    paste0(" ", i, nws, " : ", x[[i]] %||% "None")
  })
  fmt <- paste0("<r311_api>\n", paste(fmt, collapse = "\n"))
  cat(fmt, "\n")
  invisible(x)
}
