#' API discovery
#' @description
#' Retrieve discovery information about the mounted endpoint.
#'
#' @return A list containing details on the given open311 API.
#'
#' @export
#'
#' @examples
#' o311_api("zurich")
#' \donttest{
#' if (o311_ok()) {
#'   o311_discovery()
#' }
#' }
o311_discovery <- function() {
  o311_query(path = "discovery", simplify = FALSE)
}
