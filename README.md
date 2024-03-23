
<!-- README.md is generated from README.Rmd. Please edit that file -->

# open311

<!-- badges: start -->

[![R-CMD-check](https://github.com/JsLth/open311/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JsLth/open311/actions/workflows/R-CMD-check.yaml)
[![](https://www.r-pkg.org/badges/version/rors)](https://cran.r-project.org/package=rors)
[![Codecov test
coverage](https://codecov.io/gh/JsLth/open311/branch/main/graph/badge.svg)](https://app.codecov.io/gh/JsLth/open311?branch=main)
[![CodeFactor](https://www.codefactor.io/repository/github/jslth/open311/badge)](https://www.codefactor.io/repository/github/jslth/open311)
<!-- badges: end -->

`open311` is an R package that allows you to query any endpoint that
uses the open311 API standard for public service communication. Usually,
such APIs are established alongside web services that allow citizens to
submit public service tickets on public spaces. These tickets can be
retrieved using open311 APIs.

`open311` supports all official endpoints which currently include
`services` and `requests`.

## Installation

You can install the development version of open311 from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("JsLth/open311")
```

## Example

The following example loads `open311`, sets up a jurisdiction and
retrieves a small amount of data on service tickets in Cologne, Germany.

``` r
library(open311)

o311_jurisdiction("Cologne")
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
