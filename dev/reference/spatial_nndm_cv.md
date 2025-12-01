# Nearest neighbor distance matching (NNDM) cross-validation

NNDM is a variant of leave-one-out cross-validation which assigns each
observation to a single assessment fold, and then attempts to remove
data from each analysis fold until the nearest neighbor distance
distribution between assessment and analysis folds matches the nearest
neighbor distance distribution between training data and the locations a
model will be used to predict. Proposed by Milà et al. (2022), this
method aims to provide accurate estimates of how well models will
perform in the locations they will actually be predicting. This method
was originally implemented in the CAST package.

## Usage

``` r
spatial_nndm_cv(
  data,
  prediction_sites,
  ...,
  autocorrelation_range = NULL,
  prediction_sample_size = 1000,
  min_analysis_proportion = 0.5
)
```

## Arguments

- data:

  An object of class `sf` or `sfc`.

- prediction_sites:

  An `sf` or `sfc` object describing the areas to be predicted. If
  `prediction_sites` are all points, then those points are treated as
  the intended prediction points when calculating target nearest
  neighbor distances. If `prediction_sites` is a single (multi-)polygon,
  then points are sampled from within the boundaries of that polygon.
  Otherwise, if `prediction_sites` is of length \> 1 and not made up of
  points, then points are sampled from within the bounding box of
  `prediction_sites` and used as the intended prediction points.

- ...:

  Additional arguments passed to
  [`sf::st_sample()`](https://r-spatial.github.io/sf/reference/st_sample.html).
  Note that the number of points to sample is controlled by
  `prediction_sample_size`; trying to pass `size` via `...` will cause
  an error.

- autocorrelation_range:

  A numeric of length 1 representing the landscape autocorrelation range
  ("phi" in the terminology of Milà et al. (2022)). If `NULL`, the
  default, the autocorrelation range is assumed to be the distance
  between the opposite corners of the bounding box of
  `prediction_sites`.

- prediction_sample_size:

  A numeric of length 1: the number of points to sample when
  `prediction_sites` is not only composed of points. Note that this
  argument is passed to `size` in
  [`sf::st_sample()`](https://r-spatial.github.io/sf/reference/st_sample.html),
  meaning that no elements of `...` can be named `size`.

- min_analysis_proportion:

  The minimum proportion of `data` that must remain after removing
  points to match nearest neighbor distances. This function will stop
  removing data from analysis sets once only `min_analysis_proportion`
  of the original data remains in analysis sets, even if the nearest
  neighbor distances between analysis and assessment sets are still
  lower than those between training and prediction locations.

## Value

A tibble with classes `spatial_nndm_cv`, `spatial_rset`, `rset`,
`tbl_df`, `tbl`, and `data.frame`. The results include a column for the
data split objects and an identification variable `id`.

## Details

Note that, as a form of leave-one-out cross-validation, this method can
be rather slow for larger data (and fitting models to these resamples
will be even slower).

## References

C. Milà, J. Mateu, E. Pebesma, and H. Meyer. 2022. "Nearest Neighbour
Distance Matching Leave-One-Out Cross-Validation for map validation."
Methods in Ecology and Evolution 2022:13, pp 1304– 1316. doi:
10.1111/2041-210X.13851.

H. Meyer and E. Pebesma. 2022. "Machine learning-based global maps of
ecological variables and the challenge of assessing them." Nature
Communications 13, pp 2208. doi: 10.1038/s41467-022-29838-9.

## Examples

``` r
data(ames, package = "modeldata")
ames_sf <- sf::st_as_sf(ames, coords = c("Longitude", "Latitude"), crs = 4326)

# Using a small subset of the data, to make the example run faster:
spatial_nndm_cv(ames_sf[1:100, ], ames_sf[2001:2100, ])
#> # A tibble: 100 × 2
#>    splits         id     
#>    <list>         <chr>  
#>  1 <split [50/1]> Fold001
#>  2 <split [83/1]> Fold002
#>  3 <split [50/1]> Fold003
#>  4 <split [50/1]> Fold004
#>  5 <split [50/1]> Fold005
#>  6 <split [50/1]> Fold006
#>  7 <split [50/1]> Fold007
#>  8 <split [76/1]> Fold008
#>  9 <split [86/1]> Fold009
#> 10 <split [88/1]> Fold010
#> # ℹ 90 more rows
```
