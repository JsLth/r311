
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r311

<!-- badges: start -->

[![R-CMD-check](https://github.com/JsLth/r311/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JsLth/r311/actions/workflows/R-CMD-check.yaml)
[![](https://www.r-pkg.org/badges/version/r311)](https://cran.r-project.org/package=r311)
[![Codecov test
coverage](https://codecov.io/gh/JsLth/r311/branch/main/graph/badge.svg)](https://app.codecov.io/gh/JsLth/r311?branch=main)
[![CodeFactor](https://www.codefactor.io/repository/github/jslth/r311/badge)](https://www.codefactor.io/repository/github/jslth/r311)
[![](https://cranlogs.r-pkg.org/badges/r311)](https://cran.r-project.org/package=r311)
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

You can install r311 from CRAN with:

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

The following example loads `r311`, sets up a jurisdiction and retrieves
a small amount of data on service tickets in Cologne, Germany.

``` r
library(r311)

o311_api("Cologne")
o311_requests()
#> Simple feature collection with 100 features and 11 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 6.833572 ymin: 50.84786 xmax: 7.098123 ymax: 51.05979
#> Geodetic CRS:  WGS 84
#> # A tibble: 100 × 12
#>    service_request_id title              description address_string service_name
#>    <chr>              <chr>              <chr>       <chr>          <chr>       
#>  1 8421-2024          #8421-2024 Schrot… "An der Me… 50931 Köln - … Schrottfahr…
#>  2 8422-2024          #8422-2024 Stadts… "Hier wird… 51061 Köln - … Stadtsauber…
#>  3 8423-2024          #8423-2024 Wilder… "Sperrmüll… 50933 Köln - … Wilder Müll 
#>  4 8424-2024          #8424-2024 Defekt… "Zwischen … 50933 Köln - … Defekte Obe…
#>  5 8425-2024          #8425-2024 Defekt… "Mitten au… 50933 Köln - … Defekte Obe…
#>  6 8426-2024          #8426-2024 Schrot… "Heidestr.… 51069 Köln - … Schrott-Kfz 
#>  7 8427-2024          #8427-2024 Defekt… "mehrere g… 50737 Köln - … Defekte Obe…
#>  8 8428-2024          #8428-2024 Schrot…  <NA>       50968 Köln - … Schrott-Kfz 
#>  9 8429-2024          #8429-2024 Defekt… "Auf dem G… 50825 Köln - … Defekte Obe…
#> 10 8430-2024          #8430-2024 Wilder… "In unsere… 50670 Köln - … Wilder Müll 
#> # ℹ 90 more rows
#> # ℹ 7 more variables: requested_datetime <chr>, updated_datetime <chr>,
#> #   status <chr>, media_url <chr>, status_note <chr>, service_code <chr>,
#> #   geometry <POINT [°]>
```
