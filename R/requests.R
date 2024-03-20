#' Query the current status of multiple requests
#' @description
#' Get data from a registered open311 endpoint.
#'
#' @param jurisdiction_id ID of a specific jurisdiction. Only required if
#' an endpoint serves multiple jurisdictions.
#' @param service_code \code{[character]}
#'
#' IDs of the service types to be queried. Defaults to all available codes of
#' an endpoint. A list of all available service codes can be retrieved using
#' \code{\link{o311_services}}.
#'
#' @param start_date,end_date \code{[POSIXct]}
#'
#' Start date and end date of the query results. Must be date-time objects.
#' If not specified, defaults to the last 90 days.
#'
#' @param status \code{[character]}
#'
#' Status of the public service ticket. Can be one of \code{"open"} or
#' \code{"closed"}. If \code{NULL}, returns all types of tickets.
#'
#' @param ... Further endpoint-specific parameters as documented in the
#' respective endpoint reference.
#'
#' @export
o311_requests <- function(jurisdiction_id = NULL,
                          service_code = NULL,
                          start_date = NULL,
                          end_date = NULL,
                          status = NULL,
                          ...) {
  assert_string(jurisdiction_id)
  assert_string(service_code)
  assert_time(start_date)
  assert_time(end_date)

  status <- match.arg(status, c("open", "closed"))
  start_date <- w3c_datetime(start_date)
  end_date <- w3c_datetime(end_date)
  url <- get_root_api()

  req <- httr2::request(url)
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path(req, "georeport/v2/requests.json")

  args <- as.list(match.call()[-1])
  req <- do.call(httr2::req_url_query, c(args, list(req)))

  res <- httr2::req_perform(req)
  res <- httr2::resp_body_json(res, simplifyVector = TRUE, flatten = TRUE)
  as_data_frame(res)
}
