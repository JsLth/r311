o311_services <- function(jurisdiction_id = NULL,
                          format = c("json", "xml"),
                          tidy = TRUE) {
  format <- match.arg(format)
  url <- get_root_api()

  req <- httr2::request(url)
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path(req, sprintf(
    "georeport/v2/services.%s%s",
    format,
    if (!is.null(jurisdiction_id)) sprintf(
      "?jurisdiction_id=%s",
      jurisdiction_id
    ) else {
      ""
    }
  ))

  res <- httr2::req_perform(req)

  res <- if (identical(format, "json")) {
    httr2::resp_body_json(res, simplifyVector = tidy, flatten = tidy)
    if (tidy) {

    }
  } else {
    httr2::resp_body_xml(res)
  }

  if (tidy) {
    res <- tidify_response(res, format)
  }

  res
}


tidify_response <- function(x, format) {
  if (identical(format, "json")) {
    as_data_frame(x)
  } else if (identical(format, "xml")) {
    xml_to_dataframe(x)
  }
}
