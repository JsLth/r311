#' Is open311 API ok?
#' @description
#' Checks whether an open311 API mounted by \code{\link{o311_api}} is reachable
#' and returns a valid requests response.
#'
#' @param error \code{[logical]}
#'
#' Whether to return a logical or the error message describing why the
#' API is not ok.
#'
#' @return A logical describing whether the API is reachable or not.
#' If \code{error = TRUE}, returns the corresponding error object if one
#' occurs.
#' @examples
#' \donttest{
#' # check if Bonn API is reachable
#' o311_api("Bonn")
#' o311_ok()
#'
#' # check if Helsinki API is reachable - fails
#' o311_add_endpoint(
#'   name = "Helsinki",
#'   root = "asiointi.hel.fi/palautews/rest/v1/"
#' )
#'
#' o311_api("Helsinki")
#' o311_ok()
#'
#' # return error message
#' try(o311_ok(error = TRUE))
#'
#' # reset endpoints database
#' o311_reset_endpoints()
#' }
#'@export
o311_ok <- function(error = FALSE) {
  tryCatch(
    expr = {
      # query requests because discovery and services are sometimes defined
      # but requests cannot be retrieved
      res <- o311_query("requests")

      # check if requests.json returns a valid requests json
      ok <- length(res) > 1 && "service_request_id" %in% names(res)

      if (!ok) {
        abort(
          "Request query did not return a valid requests.json response.",
          class = "ok_error"
        )
      }

      ok
    },
    error = function(e) {
      if (error) e else FALSE
    }
  )
}
