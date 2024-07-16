## R CMD check results

0 errors | 0 warnings | 0 notes


## This is a resubmission, after review on 2024-07-16

### Comments by Benjamin Altmann

```
Possibly misspelled words in DESCRIPTION:
     CitySDK (12:13)
     GeoReport (9:5)
     uReport (12:24)
-> Please write software names in singl quotes.
Also, you write 'open311' in single quotes only twice in title and description. Please write it in a consistent way.
```

Answer: Description rewritten to quote software names in a more consistent manner.

```
If there are references describing the methods in your package, please add these in the description field of your DESCRIPTION file in the form authors (year) <doi:...> authors (year, ISBN:...) or if those are not available: <https:...> with no space after 'doi:', 'https:' and angle brackets for auto-linking. (If you want to add a title as well please put it in
quotes: "Title")
```

Answer: Added reference to the Georeport v2 standard in angle brackets.


```
Please ensure that your functions do not write by default or in your examples/vignettes/tests in the user's home filespace (including the package directory and getwd()). This is not allowed by CRAN policies. 
Please omit any default path in writing functions. In your examples/vignettes/tests you can write to tempdir().
-> R/endpoints.R and R/utils.R
```

Answer: I have checked the files and I am not aware of any CRAN policy violations. `o311_add_endpoint()` copies a file from the package directory and moves it to the user directory as returned by `tools::R_user_dir()`. According to the CRAN policy, this is allowed if the package depends on R version >= 4.0. Users explicitly manage this process by calling either `o311_add_endpoint()` or `o311_reset_endpoints()` to cleanup.

If I have overlooked anything, please let me know the specific lines and I will fix it.
