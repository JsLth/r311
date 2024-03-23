add_test_endpoint <- function(name = "sf test", juris = NULL, ...) {
  o311_add_endpoint(
    name,
    root = "http://mobile311-dev.sfgov.org/open311/v2/",
    jurisdiction = juris,
    ...
  )
}
