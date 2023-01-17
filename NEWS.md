# spatialsample 0.3.0

## Breaking changes

* `spatial_clustering_cv()` no longer accepts non-sf objects. Use 
  `rsample::clustering_cv()` for these instead (#126).
  
* `spatial_clustering_cv()` now uses edge-to-edge distances, like the rest of
  the package, rather than centroids (#126).

## New features

* All functions now have a `repeats` argument, defaulting to 1, allowing for 
  repeated cross-validation (#122, #125, #126). 

* `spatial_clustering_cv()` now has a `distance_function` argument, set by 
  default to `as.dist(sf::st_distance(x))` (#126).

## Minor improvements and fixes

* Outputs from `spatial_buffer_vfold_cv()` should now have the correct `radius` and `buffer` attributes (#110).

* `spatial_buffer_vfold_cv()` now has the correct `id` values when using repeats (#116).

* `spatial_buffer_vfold_cv()` now throws an error when `repeats > 1 && v >= nrow(data)` (#116).

* The minimum `sf` version required is now `>= 1.0-9`, so that unit objects can be passed to `cellsize` in `spatial_block_cv()` (#113; #124).

* `autoplot()` now handles repeated cross-validation properly (#123).

# spatialsample 0.2.1

* Mike Mahoney is taking over as package maintainer, as Julia Silge (who remains
  a package author) moves to focus on ModelOps work. 

* Functions will now return rsplits without `out_id`, like most rsample 
  functions, whenever `buffer` is `NULL`.

* `spatial_block_cv()`, `spatial_buffer_vfold_cv()`, and buffering now support
  using sf or sfc objects with a missing CRS. The assumption is that data in an
  NA CRS is projected, with all distance values in the same unit as the 
  projection. Trying to use alternative units will fail. Set a CRS if these
  assumptions aren't correct.
  
* `spatial_buffer_vfold_cv()` and buffering no longer support tibble or 
  data.frame inputs (they now require sf or sfc objects). It was not easy to 
  use these to begin with, but should have always caused an error: use 
  `rsample::vfold_cv()` instead or transform your data into an sf object.

* `spatial_buffer_vfold_cv()` has had some attribute changes to match `rsample`:
  * `strata` attribute is now the name of the column used for stratification, 
     or not set if there was no stratification.
  * `pool` and `breaks` have been added as attributes
  * `radius` and `buffer` are now set to 0 if they were passed as `NULL`.

# spatialsample 0.2.0

## New features

* `spatial_buffer_vfold_cv()` is a new function which wraps 
  `rsample::vfold_cv()`, allowing users to add inclusion radii and exclusion
  buffers to their vfold resamples. This is the supported way to perform
  spatially buffered leave-one-out cross validation (set `v` to `nrow(data)`).
  
* `spatial_leave_location_out_cv()` is a new function with wraps 
  `rsample::group_vfold_cv()`, allowing users to add inclusion radii and 
  exclusion buffers to their vfold resamples.

* `spatial_block_cv()` is a new function for performing spatial block
  cross-validation. It currently supports randomly assigning blocks to folds.

* `spatial_clustering_cv()` gains an argument, `cluster_function`, which 
  specifies what type of clustering to perform. `cluster_function = "kmeans"`, 
  the default, uses `stats::kmeans()` for k-means clustering, while 
  `cluster_function = "hclust"` uses `stats::hclust()` for hierarchical 
  clustering. Users can also provide their own clustering function.
  
* `spatial_clustering_cv()` now supports `sf` objects! Coordinates are inferred
  automatically when using `sf` objects, and anything passed to `coords` will
  be ignored with a warning. Clusters made using `sf` objects will take 
  coordinate reference systems into account (using `sf::st_distance()`), 
  unlike those made using data frames.

* All resampling functions now support spatial buffering using two arguments.
  `radius` lets you specify an _inclusion_ radius for your test set, where any
  data within `radius` of the original assessment set will be added to the 
  assessment set. `buffer` specifies an _exclusion_ buffer around the test set,
  where any data within `buffer` of the assessment set (after `radius` is 
  applied) will be excluded from both sets. 

* `autoplot()` now has a method for spatial resamples built from `sf` objects.
  It works both on `rset` objects and on `rsplit` objects, and has a special 
  method for outputs from `spatial_block_cv()`. 

* `boston_canopy` is a new dataset with data on tree canopy change over time in
  Boston, Massachusetts, USA. It uses a projected coordinate reference system 
  and US customary units; see `?boston_canopy` for instructions on how to 
  install these into your PROJ installation if needed.

## Documentation

* The "Getting Started" vignette has been revised to demonstrate the new 
  features and clustering methods. 
  
* A new vignette has been added walking through the spatial buffering process.

## Dependency changes

* R versions before 3.4 are no longer supported.

* `glue`, `sf`, and `units` have been added to Imports.

* `ggplot2` has been moved to Imports. It had been in Suggests.

* `covr`, `gifski`, `lwgeom`, and `vdiffr` are now in Suggests.

* `rlang` now has a minimum version of 1.0.0 (was previously unversioned).

# spatialsample 0.1.0

* Added a `NEWS.md` file to track changes to the package.
