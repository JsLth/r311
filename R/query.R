#' Query an open311 endpoint
#' @description
#' Low-level function to perform a generic request to the API currently
#' attached by \code{o311_api}. Some open311 implementations support
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
#' \dontrun{
#' # manually query discovery
#' o311_query(path = "discovery", simplify = FALSE)
#' }
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
  req <- url_path(url, path)
  req <- build_query(req, query)

  resp <- curl::curl_fetch_memory(req)
  resp <- handle_response(resp, type = format, simplify = simplify)

  if (simplify) {
    resp <- tidy_response(resp, format)
  }

  resp
}


url_path <- function(url, path) {
  if (!endsWith(url, "/")) url <- paste0(url, "/")
  if (startsWith(path, "/")) path <- substr(path, 2, nchar(path))
  paste0(url, path)
}


build_query <- function(url, query) {
  if (!length(query)) return(url)
  query <- paste(names(query), query, sep = "=")
  query <- paste(query, collapse = "&")
  paste0(url, "?", query)
}


handle_response <- function(resp, type, simplify) {
  if (resp$status != 200) {
    # handle all http errors defined by open311
    switch(
      as.character(resp$status),
      "400" = open311_error(resp, type),
      "403" = open311_error(resp, type),
      "404" = abort("Error code 404: Not Found", class = 404),
      abort(sprintf("Error code: %s", resp$status), class = resp$status)
    )
  }

  check_content_type(resp, type)
  content <- rawToChar(resp$content)

  if (identical(type, "json")) {
    jsonlite::fromJSON(content, simplifyVector = simplify)
  } else {
    xml2::read_xml(content, encoding = "UTF-8")
  }
}


open311_error <- function(resp, type) {
  check_content_type(resp, type)
  content <- rawToChar(resp$content)
  error <- unbox(jsonlite::fromJSON(content, simplifyVector = FALSE))
  abort(
    sprintf("Error code %s: %s", error$code, error$description),
    class = resp$status
  )
}


check_content_type <- function(resp, type) {
  type <- switch(type, json = "application/json", xml = "text/xml")

  if (!grepl(type, resp$type, fixed = TRUE)) { # nocov start
    abort(
      sprintf("Unexpected content type %s", dQuote(resp$type)),
      class = "type_error"
    )
  } # nocov end
}


tidy_response <- function(x, format) {
  if (identical(format, "json")) {
    as_data_frame(unbox(x))
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
