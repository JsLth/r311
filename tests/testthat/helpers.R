add_test_endpoint <- function(name = "sd test", juris = NULL, ...) {
  o311_add_endpoint(
    name,
    root = "http://san-diego.spotreporters.com/open311/v2/",
    jurisdiction = juris,
    ...
  )
}
