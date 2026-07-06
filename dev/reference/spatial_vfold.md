# V-Fold Cross-Validation with Buffering

V-fold cross-validation (also known as k-fold cross-validation) randomly
splits the data into V groups of roughly equal size (called "folds"). A
resample of the analysis data consists of V-1 of the folds while the
assessment set contains the final fold. These functions extend
[`rsample::vfold_cv()`](https://rsample.tidymodels.org/reference/vfold_cv.html)
and
[`rsample::group_vfold_cv()`](https://rsample.tidymodels.org/reference/group_vfold_cv.html)
to also apply an inclusion radius and exclusion buffer to the assessment
set, ensuring that your analysis data is spatially separated from the
assessment set. In basic V-fold cross-validation (i.e. no repeats), the
number of resamples is equal to V.

## Usage

``` r
spatial_buffer_vfold_cv(
  data,
  radius,
  buffer,
  v = 10,
  repeats = 1,
  strata = NULL,
  breaks = 4,
  pool = 0.1,
  ...
)

spatial_leave_location_out_cv(
  data,
  group,
  v = NULL,
  radius = NULL,
  buffer = NULL,
  ...,
  repeats = 1
)
```

## Arguments

- data:

  A data frame.

- radius:

  Numeric: points within this distance of the initially-selected test
  points will be assigned to the assessment set. If `NULL`, no radius is
  applied.

- buffer:

  Numeric: points within this distance of any point in the test set
  (after `radius` is applied) will be assigned to neither the analysis
  or assessment set. If `NULL`, no buffer is applied.

- v:

  The number of partitions for the resampling. Set to `NULL` or `Inf`
  for the maximum sensible value (for leave-one-X-out cross-validation).

- repeats:

  The number of times to repeat the V-fold partitioning.

- strata:

  A variable in `data` (single character or name) used to conduct
  stratified sampling. When not `NULL`, each resample is created within
  the stratification variable. Numeric `strata` are binned into
  quartiles.

- breaks:

  A single number giving the number of bins desired to stratify a
  numeric stratification variable.

- pool:

  A proportion of data used to determine if a particular group is too
  small and should be pooled into another group. We do not recommend
  decreasing this argument below its default of 0.1 because of the
  dangers of stratifying groups that are too small.

- ...:

  These dots are for future extensions and must be empty.

- group:

  A variable in data (single character or name) used to create folds.
  For leave-location-out CV, this should be a variable containing the
  locations to group observations by, for leave-time-out CV the time
  blocks to group by, and for leave-location-and-time-out the
  spatiotemporal blocks to group by.

## Details

When `radius` and `buffer` are both `NULL`, `spatial_buffer_vfold_cv` is
equivalent to
[`rsample::vfold_cv()`](https://rsample.tidymodels.org/reference/vfold_cv.html)
and `spatial_leave_location_out_cv` is equivalent to
[`rsample::group_vfold_cv()`](https://rsample.tidymodels.org/reference/group_vfold_cv.html).

## References

K. Le Rest, D. Pinaud, P. Monestiez, J. Chadoeuf, and C. Bretagnolle.
2014. "Spatial leave-one-out cross-validation for variable selection in
the presence of spatial autocorrelation," Global Ecology and
Biogeography 23, pp. 811-820, doi: 10.1111/geb.12161.

H. Meyer, C. Reudenbach, T. Hengl, M. Katurji, and T. Nauss. 2018.
"Improving performance of spatio-temporal machine learning models using
forward feature selection and target-oriented validation," Environmental
Modelling & Software 101, pp. 1-9, doi: 10.1016/j.envsoft.2017.12.001.

## Examples

``` r

data(Smithsonian, package = "modeldata")
Smithsonian_sf <- sf::st_as_sf(
  Smithsonian,
  coords = c("longitude", "latitude"),
  crs = 4326
)

spatial_buffer_vfold_cv(
  Smithsonian_sf,
  buffer = 500,
  radius = NULL
)
#> #  10-fold spatial cross-validation 
#> # A tibble: 10 × 2
#>    splits         id    
#>    <list>         <chr> 
#>  1 <split [11/2]> Fold01
#>  2 <split [17/2]> Fold02
#>  3 <split [11/2]> Fold03
#>  4 <split [11/2]> Fold04
#>  5 <split [11/2]> Fold05
#>  6 <split [11/2]> Fold06
#>  7 <split [17/2]> Fold07
#>  8 <split [17/2]> Fold08
#>  9 <split [11/2]> Fold09
#> 10 <split [13/2]> Fold10

data(ames, package = "modeldata")
ames_sf <- sf::st_as_sf(ames, coords = c("Longitude", "Latitude"), crs = 4326)
ames_neighborhoods <- spatial_leave_location_out_cv(ames_sf, Neighborhood)
```
