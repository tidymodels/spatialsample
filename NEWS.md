# spatialsample (development version)

* `spatial_clustering_cv()` gains an argument, `fun`, which specifies what
  type of clustering to perform. `fun = "kmeans"`, the default, uses 
  [stats::kmeans()] for k-means clustering, while `fun = "hclust"` uses
  [stats::hclust()] for hierarchical clustering.
  
* `spatial_clustering_cv()` now supports `sf` objects! Coordinates are inferred
  automatically when using `sf` objects, and anything passed to `coords` will
  be ignored with a warning. Clusters made using `sf` objects will take 
  coordinate reference systems into account (using [sf::st_distance()]), 
  unlike those made using data frames.

* `sf` has been added to Imports.

# spatialsample 0.1.0

* Added a `NEWS.md` file to track changes to the package.
