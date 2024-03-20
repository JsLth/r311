o311_cache <- new.env(parent = emptyenv())


o311_jurisdiction <- function(city) {
  all_endpoints <- o311_endpoints()

  endpoints <- all_endpoints[grepl(
    city,
    all_endpoints$name,
    ignore.case = TRUE
  ), ]

  juris <- list(
    root = endpoints$base_url,
    name = endpoints$name,
    country = endpoints$country,
    discovery = endpoints$api_discovery,
    version = endpoints$version,
    jurisdiction = endpoints$jurisdiction_id
  )

  assign("juris", juris, envir = o311_cache)
  juris
}


get_root_api <- function() {
  get0("juris", envir = o311_cache)$root %||% setup_error()
}


setup_error <- function() {
  stop(
    paste(
      "Could not find root API.",
      "Please set up a jurisdiction using `o311_jurisdiction()`"
    ),
    call. = FALSE
  )
}


o311_endpoints <- function() {
  req <- httr2::request("http://wiki.open311.org/GeoReport_v2/servers.json")
  res <- httr2::req_perform(req)
  res <- httr2::resp_body_json(res, simplifyVector = TRUE)
  as_data_frame(res)
}


o311_discovery <- function(url) {
  req <- httr2::request(url)
  res <- httr2::req_perform(req)
  httr2::resp_body_json(res)
}
