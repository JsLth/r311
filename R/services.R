#' Get service list
#' @description
#' Get a list of available services. Services are unique to the endpoint / city
#' and thus require an attached jurisdiction using
#' \code{\link{o311_api}}.
#'
#' @param ... Further endpoint-specific parameters as documented in the
#' respective endpoint reference.
#'
#' @returns A dataframe or list containing information about each service.
#'
#' @examples
#' # set up a jurisdiction
#' o311_add_endpoint(
#'   name = "helsinki test",
#'   root = "https://dev.hel.fi/open311-test/v1/"
#' )
#' o311_api("helsinki test")
#'
#' can_connect <- o311_ok()
#' if (can_connect) {
#'   # get a list of all services
#'   services <- o311_services()
#'
#'   # get a service list in finnish
#'   # the locale parameter is specific to the Helsinki API
#'   o311_services(locale = "fi_FI")
#'
#'   # inspect a service code
#'   o311_service(services$service_code[1])
#' }
#'
#' o311_reset_endpoints()
#' @export
o311_services <- function(...) {
  o311_query(path = "services", ..., simplify = TRUE)
}


#' @param service_code Identifier of a single service definition. Service
#' codes can usually be retrieved from \code{o311_services}.
#' @rdname o311_services
#' @export
o311_service <- function(service_code, ...) {
  assert_string(service_code)

  path <- sprintf("services/%s", service_code)
  o311_query(path = path, ..., simplify = TRUE)
}
