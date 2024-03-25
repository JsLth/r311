
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r311

<!-- badges: start -->

[![R-CMD-check](https://github.com/JsLth/r311/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JsLth/r311/actions/workflows/R-CMD-check.yaml)
[![](https://www.r-pkg.org/badges/version/r311)](https://cran.r-project.org/package=r311)
[![Codecov test
coverage](https://codecov.io/gh/JsLth/r311/branch/main/graph/badge.svg)](https://app.codecov.io/gh/JsLth/r311?branch=main)
[![CodeFactor](https://www.codefactor.io/repository/github/jslth/r311/badge)](https://www.codefactor.io/repository/github/jslth/r311)
<!-- badges: end -->

`r311` is an R interface to the international standard
[open311](https://www.open311.org/). Open311 APIs are used for civic
issue management and public service communication. The standard allows
administrations to better manage citizen requests, citizens to more
easily submit requests, and (hence this package) researchers and data
scientists to access data regarding public service communication. `r311`
supports the seamless management and supplementation of available
endpoints, the selection of appropriate APIs to access, and the
retrieval of civic service and request data. Custom queries and
extensions (e.g. from CitySDK) are implicitly supported. `r311` is
designed to require a minimal amount of dependencies, but allow for easy
integration into common R frameworks such as the tidyverse, `sf` or
`xml2`.

## Installation

You can install the development version of open311 from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("JsLth/r311")
```

## Example

The following example loads `r311`, sets up a jurisdiction and retrieves
a small amount of data on service tickets in Cologne, Germany.

``` r
library(r311)

o311_api("Cologne")
o311_requests()
#> Simple feature collection with 50 features and 14 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 6.833799 ymin: 50.85938 xmax: 7.10085 ymax: 51.0604
#> Geodetic CRS:  WGS 84
#> # A tibble: 50 × 15
#>    service_request_id status service_code service_name               description
#>  * <chr>              <chr>  <chr>        <chr>                      <chr>      
#>  1 A-173480           open   009          Schrottfahrzeuge/-fahrräd… "Rondorfer…
#>  2 A-173476           open   012          Straßenbaustellen          "Baustelle…
#>  3 A-173472           open   012          Straßenbaustellen          "Guten Tag…
#>  4 A-173470           open   009          Schrottfahrzeuge/-fahrräd… "Unabgesch…
#>  5 A-173455           open   009          Schrottfahrzeuge/-fahrräd… "Am Rand d…
#>  6 A-173438           open   006          Gully verstopft            "Bachemer …
#>  7 A-173430           open   009          Schrottfahrzeuge/-fahrräd… "Auf der W…
#>  8 A-173409           open   009          Schrottfahrzeuge/-fahrräd… "Räder ste…
#>  9 A-173407           open   009          Schrottfahrzeuge/-fahrräd… "Ohne Kenn…
#> 10 A-173390           open   009          Schrottfahrzeuge/-fahrräd… "Auto steh…
#> # ℹ 40 more rows
#> # ℹ 10 more variables: agency_responsible <lgl>, service_notice <lgl>,
#> #   address_id <lgl>, requested_datetime <chr>, updated_datetime <chr>,
#> #   address <chr>, zipcode <lgl>, status_notes <chr>, media_url <chr>,
#> #   geometry <POINT [°]>
```
