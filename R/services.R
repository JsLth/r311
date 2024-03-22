#' Get service list
#' @description
#' Get a list of available services. Services are unique to the endpoint / city
#' and thus require an attached jurisdiction using
#' \code{\link{o311_jurisdiction}}.
#'
#' @returns A dataframe containing information about each service. The following
#' columns are included:
#'
#' \describe{
#'
#' }
#'
o311_services <- function() {
  o311_query(path = "services", simplify = TRUE)
}
