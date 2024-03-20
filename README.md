
<!-- README.md is generated from README.Rmd. Please edit that file -->

# open311

<!-- badges: start -->
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
#> $root
#> [1] "https://sags-uns.stadt-koeln.de/georeport/v2/"
#> 
#> $name
#> [1] "Köln / Cologne, Deutschland"
#> 
#> $country
#> [1] "DEU"
#> 
#> $discovery
#> [1] "https://sags-uns.stadt-koeln.de/georeport/v2/discovery.json"
#> 
#> $version
#> [1] "georeport-v2"
#> 
#> $jurisdiction
#> [1] "stadt-koeln.de"
o311_requests()
#> # A tibble: 100 × 13
#>    service_request_id title  description   lat  long address_string service_name
#>    <chr>              <chr>  <chr>       <dbl> <dbl> <chr>          <chr>       
#>  1 862-2023           #862-… "Kreuzung …  50.9  6.92 50931 Köln - … Gully verst…
#>  2 863-2023           #863-…  <NA>        50.9  6.97 50968 Köln - … Leuchtmitte…
#>  3 864-2023           #864-… "Led Lampe…  51.0  6.91 50827 Köln - … Leuchtmitte…
#>  4 865-2023           #865-… "Die Ampel…  51.0  6.91 50825 Köln - … Kfz-Ampel d…
#>  5 866-2023           #866-… "Auf Höhe …  50.9  7.00 51149 Köln - … Wilder Müll 
#>  6 867-2023           #867-… "Auf Höhe …  50.9  7.00 51149 Köln - … Wilder Müll 
#>  7 868-2023           #868-… "Erheblich…  51.0  6.98 50735 Köln - … Defekte Obe…
#>  8 869-2023           #869-… "Erheblich…  51.0  6.98 50735 Köln - … Defekte Obe…
#>  9 870-2023           #870-… "Auf der I…  51.0  6.95 50735 Köln - … Defekte Obe…
#> 10 871-2023           #871-… "Straße mi…  50.9  6.92 50931 Köln - … Gully verst…
#> # ℹ 90 more rows
#> # ℹ 6 more variables: requested_datetime <chr>, updated_datetime <chr>,
#> #   status <chr>, media_url <chr>, status_note <chr>, service_code <chr>
```
