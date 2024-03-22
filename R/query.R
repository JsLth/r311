#' Query an open311 service
#' @description
#' Make a generic open311 query. Some open311 implementations support
#' unique operations that are not included in the official documentation.
#' This function can be used to access these URL paths.
#'
#' @param path Path appendix used to access endpoint-specific operations.
#' @param ... Additional query parameters.
#' @param simplify Whether to simplify the output using
#' \code{jsonlite::toJSON(..., simplify = TRUE)}.
#'
#' @returns The parsed query output, either as a list or dataframe.
#'
#' @examples
#' # example code
#'
#' @export
o311_query <- function(path, ..., simplify = TRUE) {
  juris <- get_juris()
  query <- drop_null(c(jurisdiction_id = juris$jurisdiction, list(...)))
  path <- paste0(path, ifelse(juris$json, ".json", ".xml"))

  GET(juris$root, path = path, query = query, simplify = simplify)
}


GET <- function(url,
                path = NULL,
                query = list(),
                simplify = TRUE,
                format = "json") {
  req <- httr2::request(url)
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, path)
  req <- do.call(httr2::req_url_query, c(list(.req = req), query))
  res <- httr2::req_perform(req)

  if (identical(format, "json")) {
    res <- httr2::resp_body_json(res, simplifyVector = simplify)
  } else if (identical(format, "xml")) {
    res <- httr2::resp_body_xml(res)
  }

  if (simplify) {
    res <- tidy_response(res, format)
  }

  res
}


tidy_response <- function(x, format) {
  if (identical(format, "json")) {
    #x <- cbind.data.frame(lapply(x, function(col) {
    #  if (is.data.frame(col)) unlist(col) else col
    #}))
    as_data_frame(x)
  } else if (identical(format, "xml")) {
    xml_to_dataframe(x)
  }
}
