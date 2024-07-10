#' API discovery
#' @description
#' Retrieve discovery information about the mounted endpoint.
#'
#' @returns A list containing details on the given open311 API.
#'
#' @export
#'
#' @examples
#' o311_api("zurich")
#'
#' can_connect <- o311_ok()
#' if (can_connect) {
#'   o311_discovery()
#' }
o311_discovery <- function() {
  o311_query(path = "discovery", simplify = FALSE)
}
