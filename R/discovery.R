#' API discovery
#' @description
#' Retrieve discovery information about the mounted endpoint.
#'
#' @returns A list containing details on the given open311 API.
#'
#' @export
o311_discovery <- function() {
  o311_query(path = "discovery", simplify = FALSE)
}
