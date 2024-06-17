#' Get civic service request data
#' @description
#' Get civic service request data from a registered open311 endpoint.
#' \code{o311_request} queries a single service request by ID.
#' \code{o311_requests} queries a single page of service requests.
#' \code{o311_request_all} tries to iterate through all pages of an endpoint
#' to return a complete dataset of service requests.
#'
#' @param service_code \code{[character]}
#'
#' IDs of the service types to be queried. Defaults to all available codes of
#' an endpoint. A list of all available service codes can be retrieved using
#' \code{\link{o311_services}}.
#'
#' @param start_date,end_date \code{[POSIXt]}
#'
#' Start date and end date of the query results. Must be date-time objects.
#' If not specified, defaults to the last 90 days.
#'
#' @param status \code{[character]}
#'
#' Status of the public service ticket. Can be one of \code{"open"} or
#' \code{"closed"}. If \code{NULL}, returns all types of tickets.
#'
#' @param page \code{[integer]}
#'
#' Page of the response. Most endpoints paginate their responses in a way
#' that only a limited number of tickets are returned with each query.
#' To retrieve all data, consider using \code{\link{o311_request_all}}.
#'
#' @param ... Further endpoint-specific parameters as documented in the
#' respective endpoint reference.
#'
#' @returns A dataframe containing data on civic service requests. The
#' dataframe can contain varying columns depending on the open311
#' implementation.
#'
#' @details
#' \code{o311_request_all} applies a number of checks to determine when to
#' stop searching. First, many endpoints return an error if the last page
#' is exceeded. Thus, if the last page request failed, break.
#' Second, if exceeding the pagination limit does not return an error, the
#' response is compared with the previous response. If identical, the
#' response is discarded and all previous responses returned. Finally,
#' if the page exceeds \code{max_pages}, the responses up to this point are
#' returned.
#'
#' open311 leaves space for endpoints to implement their own request
#' parameters. These parameters can be provided using dot arguments.
#' These arguments are not validated or pre-processed. Date-time objects
#' must be formatted according to the
#' \href{https://www.w3.org/TR/NOTE-datetime}{w3c} standard.
#' Some more common parameters include:
#'
#' \itemize{
#'  \item{\code{q}: Perform a text search across all requests.}
#'  \item{\code{update_after}/\code{updated_before}: Limit request according
#'  to request update dates.}
#'  \item{\code{per_page}: Specifiy the maximum number of requests per page.}
#'  \item{\code{extensions}: Adds a nested attribute
#'  \code{"extended_attributes"} to the response.}
#'  \item{\code{long}/\code{lat}/\code{radius}: Searches for requests in a fixed radius
#'  around a coordinate.}
#' }
#'
#' As dot arguments deviate from the open311 standard, they are not guaranteed
#' to be available for every endpoint and might be removed without further
#' notice. Refer to the endpoint docs to learn more about custom parameters
#' (\code{o311_endpoints()$docs}).
#'
#' @examples
#' \dontrun{
#' o311_api("chicago")
#'
#' # retrieve requests from the last two days
#' now <- Sys.time()
#' two_days <- 60 * 60 * 24 * 2
#' o311_requests(end_date = now, start_date = now - two_days)
#'
#' # retrieve only open tickets
#' tickets <- o311_requests(status = "open")
#'
#' # request the first ticket of the previous response
#' o311_request(tickets$service_request_id[1])
#'
#' # request all data
#' o311_request_all()
#'
#' # request data of the first 5 pages
#' o311_request_all(max_pages = 5)
#' }
#' @seealso \code{\link{o311_api}}
#' @export
o311_requests <- function(service_code = NULL,
                          start_date = NULL,
                          end_date = NULL,
                          status = NULL,
                          page = NULL,
                          ...) {
  assert_string(service_code)
  assert_time(start_date)
  assert_time(end_date)
  assert_string(status, null = TRUE)
  assert_number(page, int = TRUE)

  start_date <- w3c_datetime(start_date)
  end_date <- w3c_datetime(end_date)

  o311_query(
    path = "requests",
    service_code = service_code,
    start_date = start_date,
    end_date = end_date,
    status = status,
    page = page,
    ...,
    simplify = TRUE
  )
}


#' @param service_request_id \code{[character]}
#'
#' Identifier of a single service request. Request IDs can usually be retrieved
#' from \code{o311_requests}.
#' @rdname o311_requests
#' @export
o311_request <- function(service_request_id, ...) {
  assert_string(service_request_id)

  path <- sprintf("requests/%s", service_request_id)
  o311_query(path = path, ..., simplify = TRUE)
}


#' @param max_pages \code{[integer]}
#'
#' Number of pages to search until the result is returned.
#'
#' @param progress \code{[logical]}
#'
#' Whether to show a waiter indicating the current page iteration.
#' @rdname o311_requests
#' @export
o311_request_all <- function(service_code = NULL,
                             start_date = NULL,
                             end_date = NULL,
                             status = NULL,
                             ...,
                             max_pages = Inf,
                             progress = TRUE) {
  assert_number(max_pages, null = FALSE, int = TRUE, inf = TRUE)
  assert_flag(progress)
  if ("page" %in% ...names()) {
    abort(
      paste(
        "`page` is unsupported in `o311_request_all`.",
        "The function iterates through all pages."
      ),
      class = "page_unsupported_error"
    )
  }

  out <- list()
  i <- 1
  while (i <= max_pages) { # break if page limit is reached
    if (i > 3 && progress) { # nocov start
      waiter(current = i, total = max_pages)
    } # nocov end

    res <- tryCatch(
      o311_requests(
        service_code = service_code,
        start_date = start_date,
        end_date = end_date,
        status = status,
        page = i,
        ...
      ),
      error = identity
    )

    # break if last request failed
    if (inherits(res, "error")) {
      if (!length(out)) abort(res)
      break
    }

    # break if last request is identical to previous one
    if (length(out) && identical(res, out[[length(out)]])) break

    out[[i]] <- res
    i <- i + 1
  }

  rbind_list(out)
}
