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
#' @returns A list containing the most important information on a given
#' jurisdiction.
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
#' \dontrun{
#' # cities are matched using regex
#' o311_jurisdiction(city = "Cologne")
#'
#' # passing a jurisdiction is more explicit
#' o311_jurisdiction(jurisdiction = "stadt-koeln.de")
#' }
#'
#' @seealso \code{\link{o311_requests}}, \code{\link{o311_request}},
#' \code{\link{o311_services}}
#' @export
o311_jurisdiction <- function(endpoint = NULL, jurisdiction = NULL) {
  if (is.null(endpoint) && is.null(jurisdiction)) {
    stop("Either `endpoint` or `jurisdiction` must be specified.")
  }

  assert_string(endpoint)
  assert_string(jurisdiction)
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

  validate_jurisdiction(endpoints)

  juris <- as.list(endpoints)
  assign("juris", juris, envir = o311_cache)
  invisible(juris)
}


get_juris <- function() {
  get0("juris", envir = o311_cache) %||% setup_error()
}


setup_error <- function() {
  stop(
    paste(
      "Could not find root API.",
      "Please set up a jurisdiction using `o311_jurisdiction()`"
    ),
    call. = FALSE
  )
}


validate_jurisdiction <- function(endpoints) {
  if (nrow(endpoints) > 1) {
    endpoints_dup <- length(unique(endpoints$name)) == 1
    juris_dup <- length(unique(endpoints$jurisdiction)) == 1

    if (endpoints_dup && !juris_dup) {
      stop(paste(
        "Multiple identical endpoints detected.",
        "Consider passing `jurisdiction` explicitly."
      ))
    } else if (!endpoints_dup && juris_dup) {
      stop(paste(
        "Multiple identical jurisdictions detected.",
        "Consider passing `endpoint` explicitly."
      ))
    } else {
      stop(paste(
        "Multiple identical jurisdictions for the same endpoint detected.",
        "Consider fixing the endpoints list using `o311_reset_endpoints()`."
      ))
    }
  }

  if (!nrow(endpoints)) {
    stop(paste(
      "No jurisdiction could be found given the specified",
      "city / jurisdiction ID. Run `o311_endpoints()`",
      "to get an overview of available jurisdictions"
    ))
  }
}
