
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r311

<!-- badges: start -->

[![R-CMD-check](https://github.com/JsLth/r311/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JsLth/r311/actions/workflows/R-CMD-check.yaml)
[![](https://www.r-pkg.org/badges/version/r311)](https://cran.r-project.org/package=r311)
[![Codecov test
coverage](https://codecov.io/gh/JsLth/r311/branch/main/graph/badge.svg)](https://app.codecov.io/gh/JsLth/r311?branch=main)
[![CodeFactor](https://www.codefactor.io/repository/github/jslth/r311/badge)](https://www.codefactor.io/repository/github/jslth/r311)
<!-- badges: end -->

`{r311}` is an R interface to the international standard
[open311](https://www.open311.org/). Open311 APIs are used for civic
issue management and public service communication. The standard allows
administrations to better manage citizen requests, citizens to more
easily submit requests, and (hence this package) researchers and data
scientists to access data regarding public service communication.
`{r311}` supports the seamless management and supplementation of
available endpoints, the selection of appropriate APIs to access, and
the retrieval of civic service and request data. Custom queries and
extensions (e.g. from CitySDK) are implicitly supported. `{r311}` is
designed to require a minimal amount of dependencies, but allow for easy
integration into common R frameworks such as the tidyverse, `sf` or
`xml2`.

## Installation

You can install `{r311}` from CRAN with:

``` r
install.packages("r311")
```

Or you can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("JsLth/r311")
```

## Example

The following example loads `{r311}`, sets up a jurisdiction and
retrieves a small amount of data on service tickets in Cologne, Germany.

``` r
library(r311)

o311_api("Cologne")
o311_requests()
#> Simple feature collection with 100 features and 11 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 6.822994 ymin: 50.86506 xmax: 7.100928 ymax: 51.06279
#> Geodetic CRS:  WGS 84
#> # A tibble: 100 × 12
#>    service_request_id title              description address_string service_name
#>    <chr>              <chr>              <chr>       <chr>          <chr>       
#>  1 20477-2024         #20477-2024 Wilde… "Am Straße… 50739 Köln - … Wilder Müll 
#>  2 20478-2024         #20478-2024 Schro… "Rad mit n… 50933 Köln - … Schrottfahr…
#>  3 20479-2024         #20479-2024 Schro… "Fahrradle… 50939 Köln - … Schrottfahr…
#>  4 20480-2024         #20480-2024 Wilde… "Dämmplatt… 50739 Köln - … Wilder Müll 
#>  5 20481-2024         #20481-2024 Schro… "31.08.202… 51065 Köln - … Schrottfahr…
#>  6 20482-2024         #20482-2024 Wilde… "Vor Haus … 51105 Köln - … Wilder Müll 
#>  7 20483-2024         #20483-2024 Defek… "gefährlic… 50677 Köln - … Defekte Obe…
#>  8 20484-2024         #20484-2024 Straß… "auffahrra… 50674 Köln - … Straßenbaus…
#>  9 20485-2024         #20485-2024 Wilde…  <NA>       50765 Köln - … Wilder Müll 
#> 10 20486-2024         #20486-2024 Kölne… "Grünfläch… 50765 Köln - … Kölner Grün 
#> # ℹ 90 more rows
#> # ℹ 7 more variables: requested_datetime <chr>, updated_datetime <chr>,
#> #   status <chr>, media_url <chr>, status_note <chr>, service_code <chr>,
#> #   geometry <POINT [°]>
```

## API upkeep

`{r311}` is powered by a JSON of available APIs (see
[here](https://github.com/JsLth/r311/blob/main/inst/endpoints.json)).
This list does not claim to be comprehensive nor up-to-date at all times
but is updated from time to time. If an API is found to be unavailable
for an extended period of time, it will be marked as “questioning”.
Questionable APIs will be removed on the next release.

If you know about a stable open311 API that should be added to the list,
please consider opening an issue. Otherwise, you can also just use the
`o311_add_endpoint()` function to add the API locally.
