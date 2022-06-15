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
