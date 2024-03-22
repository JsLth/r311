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
  assert_dots_named()
  juris <- get_juris()
  root <- juris$root
  query <- drop_null(c(jurisdiction_id = juris$jurisdiction, list(...)))
  format <- ifelse(juris$json, "json", "xml")
  path <- paste(path, format, sep = ".")

  GET(root, path = path, query = query, simplify = simplify, format = format)
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
    as_data_frame(x)
  } else if (identical(format, "xml")) {
    # find the first xml tag that has a length of over 1
    # this usually works, but might not always
    tag <- unique(names(Find(function(x) length(x) > 1, xml2::as_list(x))))

    if (!is.null(tag) || length(tag) > 1) {
      as_data_frame(xmlconvert::xml_to_df(
        text = as.character(x),
        records.tags = tag,
        check.datatypes = TRUE
      ))
    } else { # nocov start
      warning(paste(
        "Could not tidy XML response.",
        "It might deviate from the open311 standard.",
        "Please use the JSON format instead or set simplify = FALSE."
      ))
      x
    } # nocov end
  }
}
