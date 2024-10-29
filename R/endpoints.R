#' Endpoints
#' @description
#' Modify and examine defined open311 endpoints. \code{o311_endpoints()}
#' retrieves a list of endpoints including additional information.
#' \code{o311_add_endpoint} adds to this list to define a new endpoint that
#' can be used for queries. \code{o311_reset_endpoints} restores the initial
#' state of the endpoints list.
#'
#' @param name \code{[character]}
#'
#' Name of an endpoint / city. This name can be arbitrary and only serves
#' for identification in \code{[o311_api]}.
#'
#' @param root \code{[character]}
#'
#' Base URL of the endpoint for sending production-grade requests. The root
#' URL commonly points to \code{"georeport/v2/"}.
#'
#' @param jurisdiction \code{[character]}
#'
#' Unique identifier of the jurisdiction. The jurisdiction is typically
#' defined as the domain of the respective city website. It is optional as
#' most endpoints only serve one jurisdiction.
#'
#' @param key \code{[logical]}
#'
#' Is an API key mandatory?
#'
#' @param pagination \code{[logical]}
#'
#' Are \code{requests} responses paginated?
#'
#' @param limit \code{[integer]}
#'
#' If paginated, how many requests does one page contain?
#'
#' @param json \code{[logical]}
#'
#' Are JSON responses supported? If \code{FALSE}, defaults to \code{"XML"}
#' responses. See also \code{\link{o311_api}}.
#'
#' @param dialect \code{[character]}
#'
#' open311 extension that the endpoint is built on. Common dialects include
#' CitySDK, Connected Bits, SeeClickFix and Mark-a-Spot. Currently, this
#' argument does nothing, but it could be used in the future to adjust
#' response handling based on dialect.
#'
#' @return For \code{o311_endpoints}, a dataframe containing all relevant
#' information on an endpoint. For \code{o311_add_endpoint}, the new endpoint,
#' invisibly. \code{o311_reset_endpoints} returns \code{NULL} invisibly.
#' If the new endpoint is a duplicate, \code{NULL} is returned invisibly.
#'
#' @details
#' \code{o311_endpoints()} returns a static list defined in the package
#' installation directory. This list contains a limited number of endpoints
#' that were proven to work at the time of package development. It does not
#' include newer/smaller/less known endpoints or test APIs. These can be
#' manually added using \code{o311_add_endpoint}. If an API is down and it
#' is unknown whether it will be up again or not, its \code{questioning} value
#' is set to \code{TRUE}. If they will not go up again, they are removed upon
#' the next release.
#'
#' @note
#' This function uses \code{\link[tools]{R_user_dir}} to persistently store
#' custom endpoints data between sessions. To set a different directory, you
#' may use \code{options("o311_user_dir")}. To clean up, run
#' \code{o311_reset_endpoints()} which deletes the package-specific user
#' directory and defaults back to
#' \code{system.file("endpoints.json", package = "r311")}.
#'
#' @examples
#' # read default endpoints
#' o311_endpoints()
#'
#' # get all endpoints powered by Connected Bits
#' o311_endpoints(dialect = "Connected Bits")
#'
#' # add a new endpoint
#' o311_add_endpoint(name = "test", root = "test.org/georeport/v2")
#'
#' # read new endpoints
#' o311_endpoints()
#'
#' # reset endpoints back to default
#' o311_reset_endpoints()
#' @rdname o311_endpoints
#' @seealso \code{\link{o311_api}}
#' @export
o311_add_endpoint <- function(name,
                              root,
                              jurisdiction = NULL,
                              key = FALSE,
                              pagination = FALSE,
                              limit = NULL,
                              json = TRUE,
                              dialect = NULL) {
  assert_string(name)
  assert_url(root)
  assert_string(jurisdiction)
  assert_flag(key)
  assert_flag(pagination)
  assert_number(limit)
  assert_flag(json)

  new_endpoint <- drop_null(as.list(environment()))

  # for editing, always use the user path
  copy_endpoints_json()
  json_path <- user_endpoints_path()

  endpoints <- jsonlite::read_json(json_path)

  if (has_duplicate_endpoints(endpoints, name, jurisdiction)) {
    return(invisible(new_endpoint))
  }

  endpoints <- c(endpoints, list(new_endpoint))
  jsonlite::write_json(endpoints, json_path, pretty = TRUE, auto_unbox = TRUE)
  invisible(new_endpoint)
}


#' @rdname o311_endpoints
#' @export
o311_reset_endpoints <- function() {
  unlink(o311_user_dir(), recursive = TRUE, force = TRUE)
}


#' @param ... List of key-value pairs where each pair is a filter.
#' The key represents the column and the value the requested column value.
#' All keys must be present in the column names of \code{o311_endpoints()}.
#' @rdname o311_endpoints
#' @export
o311_endpoints <- function(...) {
  assert_dots_named()

  endpoints <- as_data_frame(jsonlite::read_json(
    endpoints_json(),
    simplifyVector = TRUE
  ))

  dots <- list(...)

  if (!all(names(dots) %in% names(endpoints))) {
    abort(
      "Keys in `...` must correspond to an endpoints column.",
      class = "endpoints_filter_error"
    )
  }

  for (col in names(dots)) {
    endpoints <- endpoints[endpoints[[col]] %in% dots[[col]], ]
  }

  endpoints
}


copy_endpoints_json <- function() {
  user_dir <- o311_user_dir()
  data_path <- file.path(user_dir, "endpoints.json")
  if (!file.exists(data_path)) {
    dir.create(user_dir, recursive = TRUE, showWarnings = FALSE)
    file.copy(endpoints_json(), data_path)
  }
}


o311_endpoints_path <- function() {
  o311_path("endpoints.json")
}


user_endpoints_path <- function() {
  file.path(o311_user_dir(), "endpoints.json")
}


endpoints_json <- function() {
  ifelse(
    file.exists(user_endpoints_path()),
    user_endpoints_path(),
    o311_endpoints_path()
  )
}


has_duplicate_endpoints <- function(endpoints, name, jurisdiction) {
  any(vapply(
    endpoints,
    function(x) {
      identical(x[["name"]], name) &&
        identical(x[["jurisdiction"]], jurisdiction)
    },
    FUN.VALUE = logical(1)
  ))
}
