
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
#> Simple feature collection with 100 features and 11 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 6.829609 ymin: 50.8609 xmax: 7.10357 ymax: 51.06044
#> Geodetic CRS:  WGS 84
#> # A tibble: 100 × 12
#>    service_request_id title              description address_string service_name
#>  * <chr>              <chr>              <chr>       <chr>          <chr>       
#>  1 7748-2024          #7748-2024 Schrot… "Schwarzer… 51067 Köln - … Schrott-Kfz 
#>  2 7775-2024          #7775-2024 Lichtm… "Seit dem … 51105 Köln - … Lichtmast d…
#>  3 7776-2024          #7776-2024 Lichtm… "Seit dem … 51105 Köln - … Lichtmast d…
#>  4 7777-2024          #7777-2024 Wilder… "An der Ei… 50679 Köln - … Wilder Müll 
#>  5 7783-2024          #7783-2024 Straße… "Baustelle… 50823 Köln - … Straßenbaus…
#>  6 7795-2024          #7795-2024 Straße… "Ergänzung… 50823 Köln - … Straßenbaus…
#>  7 7817-2024          #7817-2024 Schrot… "Hallo, \r… 51147 Köln - … Schrott-Kfz 
#>  8 7824-2024          #7824-2024 Schrot… "Hinteraus… 51065 Köln - … Schrottfahr…
#>  9 7834-2024          #7834-2024 Fußgän… "Gestern w… 51103 Köln - … Fußgängeram…
#> 10 7838-2024          #7838-2024 Spiel-… "Sehr geeh… Köln,          Spiel- und …
#> # ℹ 90 more rows
#> # ℹ 7 more variables: requested_datetime <chr>, updated_datetime <chr>,
#> #   status <chr>, media_url <chr>, status_note <chr>, service_code <chr>,
#> #   geometry <POINT [°]>
```
