"%||%" <- function(x, y) {
  if (is.null(x)) y else x
}


data_frame <- function(...) {
  if (loadable("tibble")) {
    tibble::tibble(...)
  } else {
    data.frame(...)
  }
}


as_data_frame <- function(...) {
  if (loadable("tibble")) {
    tibble::as_tibble(...)
  } else {
    as.data.frame(...)
  }
}


drop_null <- function(x) {
  x[!vapply(x, FUN.VALUE = logical(1), is.null)]
}


loadable <- function(x) {
  suppressPackageStartupMessages(suppressWarnings(requireNamespace(x)))
}


xml_to_dataframe <- function(doc) {
  nodes <- xml2::xml_find_all(doc, "//*")
  leafs <- which(xml2::xml_length(xml2::xml_children(nodes)) == 0)
  leafs <- nodes[leafs + 1]

  cols <- xml2::xml_name(leafs)
  cols <- unique(unlist(drop_null(cols)))

  values <- lapply(cols, function(x) {
    all_values <- xml2::xml_find_all(nodes, x)
    xml2::xml_text(all_values)
  })

  names(values) <- cols
  do.call(data_frame, values)
}


w3c_datetime <- function(x) {
  format(x, format = "%FT%R:%SZ")
}
