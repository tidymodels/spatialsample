# Spatial Clustering Cross-Validation

Spatial clustering cross-validation splits the data into V groups of
disjointed sets by clustering points based on their spatial coordinates.
A resample of the analysis data consists of V-1 of the folds/clusters
while the assessment set contains the final fold/cluster.

## Usage

``` r
spatial_clustering_cv(
  data,
  v = 10,
  cluster_function = c("kmeans", "hclust"),
  radius = NULL,
  buffer = NULL,
  ...,
  repeats = 1,
  distance_function = function(x) as.dist(sf::st_distance(x))
)
```

## Arguments

- data:

  An `sf` object (often from
  [`sf::read_sf()`](https://r-spatial.github.io/sf/reference/st_read.html)
  or
  [`sf::st_as_sf()`](https://r-spatial.github.io/sf/reference/st_as_sf.html))
  to split into folds.

- v:

  The number of partitions of the data set.

- cluster_function:

  Which function should be used for clustering? Options are either
  `"kmeans"` (to use
  [`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html)) or
  `"hclust"` (to use
  [`stats::hclust()`](https://rdrr.io/r/stats/hclust.html)). You can
  also provide your own function; see `Details`.

- radius:

  Numeric: points within this distance of the initially-selected test
  points will be assigned to the assessment set. If `NULL`, no radius is
  applied.

- buffer:

  Numeric: points within this distance of any point in the test set
  (after `radius` is applied) will be assigned to neither the analysis
  or assessment set. If `NULL`, no buffer is applied.

- ...:

  Extra arguments passed on to
  [`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html) or
  [`stats::hclust()`](https://rdrr.io/r/stats/hclust.html).

- repeats:

  The number of times to repeat the clustered partitioning.

- distance_function:

  Which function should be used for distance calculations? Defaults to
  [`sf::st_distance()`](https://r-spatial.github.io/sf/reference/geos_measures.html),
  with the output matrix converted to a
  [`stats::dist()`](https://rdrr.io/r/stats/dist.html) object. You can
  also provide your own function; see Details.

## Value

A tibble with classes `spatial_clustering_cv`, `spatial_rset`, `rset`,
`tbl_df`, `tbl`, and `data.frame`. The results include a column for the
data split objects and an identification variable `id`. Resamples
created from non-`sf` objects will not have the `spatial_rset` class.

## Details

Clusters are created based on the distances between observations if
`data` is an `sf` object. Each cluster is used as a fold for
cross-validation. Depending on how the data are distributed spatially,
there may not be an equal number of observations in each fold.

You can optionally provide a custom function to `distance_function.` The
function should take an `sf` object and return a
[`stats::dist()`](https://rdrr.io/r/stats/dist.html) object with
distances between data points.

You can optionally provide a custom function to `cluster_function`. The
function must take three arguments:

- `dists`, a [`stats::dist()`](https://rdrr.io/r/stats/dist.html) object
  with distances between data points

- `v`, a length-1 numeric for the number of folds to create

- `...`, to pass any additional named arguments to your function

The function should return a vector of cluster assignments of length
`nrow(data)`, with each element of the vector corresponding to the
matching row of the data frame.

## Changes in spatialsample 0.3.0

As of spatialsample version 0.3.0, this function no longer accepts
non-`sf` objects as arguments to `data`. In order to perform clustering
with non-spatial data, consider using
[`rsample::clustering_cv()`](https://rsample.tidymodels.org/reference/clustering_cv.html).

Also as of version 0.3.0, this function now calculates edge-to-edge
distance for non-point geometries, in line with the rest of the package.
Earlier versions relied upon between-centroid distances.

## References

A. Brenning, "Spatial cross-validation and bootstrap for the assessment
of prediction rules in remote sensing: The R package sperrorest," 2012
IEEE International Geoscience and Remote Sensing Symposium, Munich,
2012, pp. 5372-5375, doi: 10.1109/IGARSS.2012.6352393.

## Examples

``` r
data(Smithsonian, package = "modeldata")

smithsonian_sf <- sf::st_as_sf(
  Smithsonian,
  coords = c("longitude", "latitude"),
  # Set CRS to WGS84
  crs = 4326
)

# When providing sf objects, coords are inferred automatically
spatial_clustering_cv(smithsonian_sf, v = 5)
#> #  5-fold spatial cross-validation 
#> # A tibble: 5 × 2
#>   splits         id   
#>   <list>         <chr>
#> 1 <split [19/1]> Fold1
#> 2 <split [18/2]> Fold2
#> 3 <split [5/15]> Fold3
#> 4 <split [19/1]> Fold4
#> 5 <split [19/1]> Fold5

# Can use hclust instead:
spatial_clustering_cv(smithsonian_sf, v = 5, cluster_function = "hclust")
#> #  5-fold spatial cross-validation 
#> # A tibble: 5 × 2
#>   splits         id   
#>   <list>         <chr>
#> 1 <split [19/1]> Fold1
#> 2 <split [4/16]> Fold2
#> 3 <split [19/1]> Fold3
#> 4 <split [19/1]> Fold4
#> 5 <split [19/1]> Fold5
```
