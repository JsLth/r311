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
#' @details
#' You can set \code{options(r311_echo = TRUE)} to display all requests sent
#' using \code{o311_query}.
#'
#' @examples
#' o311_api("rostock")
#'
#' can_connect <- o311_ok()
#' if (can_connect) {
#'   # manually query discovery
#'   o311_query(path = "discovery", simplify = FALSE)
#'
#'   # query a custom path defined by the Klarschiff API
#'   o311_query(path = "areas")
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

  if (isTRUE(getOption("r311_echo", FALSE))) {
    cat("Querying:", req, "\n")
  }

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
  if (endsWith(path, "/")) path <- substr(path, 1, nchar(path) - 1)
  paste0(url, path)
}


build_query <- function(url, query) {
  if (!length(query)) return(url)
  query <- paste(names(query), query, sep = "=")
  query <- paste(query, collapse = "&")
  paste0(url, "?", query)
}


handle_response <- function(resp, type, simplify) {
  if (resp$status_code != 200) {
    # handle all http errors defined by open311
    switch(
      as.character(resp$status_code),
      "400" = open311_error(resp, type), # nocov
      "403" = open311_error(resp, type),
      guess_error(resp) # nocov
    )
  }

  check_content_type(resp, type)
  content <- rawToChar(resp$content)

  if (identical(type, "json")) {
    jsonlite::fromJSON(content, simplifyVector = simplify, flatten = TRUE)
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


guess_error <- function(resp) { # nocov start
  headers <- rawToChar(resp$headers)
  headers <- curl::parse_headers_list(headers)
  content_type <- headers[["content-type"]]
  status <- resp$status_code

  if (grepl("application/json", content_type, fixed = TRUE)) {
    content <- rawToChar(resp$content)
    error <- jsonlite::fromJSON(content, simplifyVector = FALSE)
    has_error_fields <- !any(
      c("description", "message", "msg", "error") %in% names(error)
    )
    if (has_error_fields) { # nocov start
      error <- unbox(error)
    } # nocov end
    abort(
      sprintf(
        "Error code %s: %s",
        headers$status %||% status,
        if (is.list(error)) {
          error$description %||% error$message %||% error$msg %||% error$error
        } else if (is.character(error)) { # nocov start
          error
        } # nocov end
      ),
      class = status
    )
  } else {
    abort(sprintf("Error code %s", status), class = status)
  }
} # nocov end


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
    x <- as_data_frame(unbox(x))
  } else if (identical(format, "xml")) {
    # find the first xml tag that has a length of over 1
    # this usually works, but might not always
    tag <- unique(names(Find(function(x) length(x) > 1, xml2::as_list(x))))

    if (!is.null(tag) || length(tag) > 1) {
      x <- as_data_frame(xmlconvert::xml_to_df(
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

  response_to_sf(x)
}


response_to_sf <- function(res) {
  if (!nrow(res) || !loadable("sf")) return(res)
  cnames <- c("long", "lat")
  if (all(cnames %in% names(res))) {
    coords <- as.list(res[cnames])
    res <- res[!names(res) %in% cnames]
    geom <- coords_to_geom(coords)
    res <- sf::st_sf(res, geometry = geom, crs = 4326)
    res <- sf::st_as_sf(as_data_frame(res))
  } else if (identical(get_juris()$dialect, "CitySDK")) {
    wkt_col <- look_for_wkt_string(res)
    if (!is.null(wkt_col)) {
      res <- sf::st_as_sf(res, wkt = wkt_col)
    }
  }
  res
}


look_for_wkt_string <- function(res) {
  for (col in names(res)) {
    if (is.character(res[[col]]) &&
        any(startsWith(res[[col]][1], c("POLYGON", "MULTIPOLYGON")))) {
      return(col)
    }
  }
}


coords_to_geom <- function(coords) {
  coords <- lapply(coords, as.numeric)
  sfg <- lapply(Map(c, coords$long, coords$lat), sf::st_point)
  do.call(sf::st_sfc, sfg)
}
