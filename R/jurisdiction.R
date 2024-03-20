o311_cache <- new.env(parent = emptyenv())


o311_jurisdiction <- function(root) {


  juris <- list(
    root = root
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

}
