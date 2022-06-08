# spatialsample (development version)

* All resampling functions now support spatial buffering using two arguments.
  `radius` lets you specify an _inclusion_ radius for your test set, where any
  data within `radius` of the original assessment set will be added to the 
  assessment set. `buffer` specifies an _exclusion_ buffer around the test set,
  where any data within `buffer` of the assessment set (after `radius` is 
  applied) will be excluded from both sets. 

* `autoplot()` now has a method for spatial resamples built from `sf` objects.

* `ggplot2` has been moved to Imports. It had been in Suggests.

* `spatial_block_cv()` is a new function for performing spatial block cross validation.
  It currently supports randomly assigning blocks to folds.

* `spatial_clustering_cv()` gains an argument, `cluster_function`, which 
  specifies what type of clustering to perform. `cluster_function = "kmeans"`, 
  the default, uses `stats::kmeans()` for k-means clustering, while 
  `cluster_function = "hclust"` uses `stats::hclust()` for hierarchical 
  clustering. Users can also provide their own clustering function.
  
* `spatial_clustering_cv()` now supports `sf` objects! Coordinates are inferred
  automatically when using `sf` objects, and anything passed to `coords` will
  be ignored with a warning. Clusters made using `sf` objects will take 
  coordinate reference systems into account (using [sf::st_distance()]), 
  unlike those made using data frames.

* `sf` has been added to Imports.

# spatialsample 0.1.0

* Added a `NEWS.md` file to track changes to the package.
