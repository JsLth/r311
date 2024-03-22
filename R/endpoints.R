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
#' for identification in \code{[o311_jurisdiction]}.
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
#' responses. \code{"XML"} responses are harder to simplify.
#'
#' @returns For \code{o311_endpoints}, a dataframe containing all relevant
#' information on an endpoint. For \code{o311_add_endpoint}, the new endpoint,
#' invisibly. \code{o311_reset_endpoints} returns \code{NULL} invisibly.
#'
#' @note
#' This function uses \code{\link[tools]{R_user_dir}} to persistently store
#' custom endpoints data between sessions. To clean up, run
#' \code{o311_reset_endpoints()} which deletes the package-specific user
#' directory and defaults back to
#' \code{system.file("jurisdictions.json", package = "open311")}.
#'
#' @examples
#' # read default endpoints
#' o311_endpoints()
#'
#' # add a new endpoint
#' o311_add_endpoint(name = "test", root = "test.org/georeport/v2")
#'
#' # read new endpoints
#' o311_endpoints()
#'
#' @rdname o311_endpoints
#' @seealso \code{\link{o311_jurisdiction}}
#' @export
o311_add_endpoint <- function(name,
                              root,
                              jurisdiction = NULL,
                              key = FALSE,
                              pagination = FALSE,
                              limit = NULL,
                              json = TRUE) {
  assert_string(name)
  assert_url(root)
  assert_string(jurisdiction)
  assert_flag(key)
  assert_flag(pagination)
  assert_number(limit)
  assert_flag(json)

  new_endpoint <- drop_null(as.list(environment()))

  # for editing, always use the user path
  copy_jurisdictions_json()
  json_path <- user_jurisdictions_path()

  endpoints <- jsonlite::read_json(json_path)
  endpoints <- c(endpoints, list(new_endpoint))
  jsonlite::write_json(endpoints, json_path, pretty = TRUE, auto_unbox = TRUE)
  invisible(new_endpoint)
}


#' @rdname o311_endpoints
#' @export
o311_reset_endpoints <- function() {
  user_dir <- tools::R_user_dir("open311")
  unlink(user_dir, recursive = TRUE, force = TRUE)
}


#' @rdname o311_endpoints
#' @export
o311_endpoints <- function() {
  as_data_frame(jsonlite::read_json(
    jurisdictions_json(),
    simplifyVector = TRUE
  ))
}


copy_jurisdictions_json <- function() {
  user_dir <- tools::R_user_dir("open311")
  data_path <- file.path(user_dir, "jurisdictions.json")
  if (!file.exists(data_path)) {
    dir.create(user_dir, recursive = TRUE)
    file.copy(jurisdictions_json(), data_path)
  }
}


o311_jurisdictions_path <- function() {
  o311_path("jurisdictions.json")
}


user_jurisdictions_path <- function() {
  file.path(tools::R_user_dir("open311"), "jurisdictions.json")
}


jurisdictions_json <- function() {
  ifelse(
    file.exists(user_jurisdictions_path()),
    user_jurisdictions_path(),
    o311_jurisdictions_path()
  )
}
