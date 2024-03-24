o311_cache <- new.env(parent = emptyenv())


#' Mount a jurisdiction
#' @description
#' Attach an open311 jurisdiction to the active session. A jurisdiction
#' describes a city or a jurisdiction within a city that is served by
#' an open311 API. After running this function, the jurisdiction is available
#' to other \code{o311_*} functions until the session is terminated or until it
#' is overwritten.
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
#' \code{"sfgov.org"} for San Francisco.
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
#' be retrieved by calling \code{o311_api()} without arguments.
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
#' o311_api(city = "Cologne")
#'
#' # passing a jurisdiction is more explicit
#' o311_api(jurisdiction = "stadt-koeln.de")
#'
#' # calls without arguments return the current API
#' o311_api()
#' @seealso \code{\link{o311_requests}}, \code{\link{o311_request}},
#' \code{\link{o311_services}}
#' @export
o311_api <- function(endpoint = NULL,
                     jurisdiction = NULL,
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

  juris <- lapply(endpoints, "%NA%", NULL)
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

    if (endpoints_dup && !juris_dup) {
      abort(
        paste(
          "Multiple identical endpoints detected.",
          "Consider passing `jurisdiction` explicitly."
        ),
        class = "ambiguous_endpoints_error"
      )
    } else if (!endpoints_dup && juris_dup) {
      abort(
        paste(
          "Multiple identical jurisdictions detected.",
          "Consider passing `endpoint` explicitly."
        ),
        class = "ambiguous_juris_error"
      )
    } else {
      abort(
        paste(
          "Multiple identical jurisdictions for the same endpoint detected.",
          "Consider fixing the endpoints list using `o311_reset_endpoints()`."
        ),
        class = "endpoints_corrupt_error"
      )
    }
  }

  if (!nrow(endpoints)) {
    abort(
      paste(
        "No jurisdiction could be found given the specified",
        "city / jurisdiction ID. Run `o311_endpoints()`",
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
  } else if (!loadable("xml2") && identical(format, "xml")) {
    abort(
      "The `xml2` package is needed to accept XML responses.",
      class = "package_error"
    )
  }
}
