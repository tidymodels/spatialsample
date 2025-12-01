# Changelog

## spatialsample (development version)

- Minor update to follow update in rsample and testthat. No user-facing
  impacts.

## spatialsample 0.6.0

CRAN release: 2024-10-02

- Fixed bug where passing a polygon to
  [`spatial_nndm_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_nndm_cv.md)
  forced leave-one-out CV, rather than the intended sampling of
  prediction points from the polygon.

## spatialsample 0.5.1

CRAN release: 2023-11-07

- [`spatial_block_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_block_cv.md)
  now adds an `expand_bbox` attribute to the resulting rset for
  compatibility with
  [`rsample::reshuffle_rset()`](https://rsample.tidymodels.org/reference/reshuffle_rset.html)

- [`autoplot.spatial_block_cv()`](https://spatialsample.tidymodels.org/dev/reference/autoplot.spatial_rset.md)
  now plots the proper grid (using the new `expand_bbox` attribute).

## spatialsample 0.5.0

CRAN release: 2023-11-03

- [`spatial_block_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_block_cv.md)
  gains an argument, `expand_bbox`, which represents the proportion a
  bounding box should be expanded by (each corner of the bounding box is
  expanded by `bbox_corner_value * expand_bbox`).

  - **This is a breaking change** for data in planar coordinate
    reference systems. Set to 0 to obtain previous behaviors.
  - Data in geographic coordinates was already having its bounding box
    expanded by the default 0.00001.
  - This makes it so that regularly spaced data is less likely to fall
    precisely along grid lines (and therefore fall into two assessment
    sets) and so that geographic data falls is more likely to fall
    within the constructed grid.
  - Thanks to Nikos on StackOverflow for reporting this behavior:
    <https://stackoverflow.com/q/77374348/9625040>

- [`spatial_block_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_block_cv.md)
  will now throw an error if observations are in multiple assessment
  folds (caused by observations, or observation centroids, falling
  precisely along grid polygon boundaries).

- In
  [`spatial_nndm_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_nndm_cv.md),
  passing a single polygon (or multipolygon) to the `prediction_sites`
  argument will result in prediction sites being sampled from that
  polygon, rather than from its bounding box.

- [`get_rsplit()`](https://rsample.tidymodels.org/reference/get_rsplit.html)
  is now re-exported from the rsample package. This provides a more
  natural, pipe-able interface for accessing individual splits;
  `get_rsplit(rset, 1)` is identical to `rset$splits[[1]]`.

## spatialsample 0.4.0

CRAN release: 2023-05-17

- [`spatial_nndm_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_nndm_cv.md)
  is a new function for nearest neighbor distance matching
  cross-validation, as described in Milà et al. 2022 (doi:
  10.1111/2041-210X.13851). NNDM was first implemented in CAST
  (<https://cran.r-project.org/package=CAST>).

## spatialsample 0.3.0

CRAN release: 2023-01-17

### Breaking changes

- [`spatial_clustering_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_clustering_cv.md)
  no longer accepts non-sf objects. Use
  [`rsample::clustering_cv()`](https://rsample.tidymodels.org/reference/clustering_cv.html)
  for these instead
  ([\#126](https://github.com/tidymodels/spatialsample/issues/126)).

- [`spatial_clustering_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_clustering_cv.md)
  now uses edge-to-edge distances, like the rest of the package, rather
  than centroids
  ([\#126](https://github.com/tidymodels/spatialsample/issues/126)).

### New features

- All functions now have a `repeats` argument, defaulting to 1, allowing
  for repeated cross-validation
  ([\#122](https://github.com/tidymodels/spatialsample/issues/122),
  [\#125](https://github.com/tidymodels/spatialsample/issues/125),
  [\#126](https://github.com/tidymodels/spatialsample/issues/126)).

- [`spatial_clustering_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_clustering_cv.md)
  now has a `distance_function` argument, set by default to
  `as.dist(sf::st_distance(x))`
  ([\#126](https://github.com/tidymodels/spatialsample/issues/126)).

### Minor improvements and fixes

- Outputs from
  [`spatial_buffer_vfold_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_vfold.md)
  should now have the correct `radius` and `buffer` attributes
  ([\#110](https://github.com/tidymodels/spatialsample/issues/110)).

- [`spatial_buffer_vfold_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_vfold.md)
  now has the correct `id` values when using repeats
  ([\#116](https://github.com/tidymodels/spatialsample/issues/116)).

- [`spatial_buffer_vfold_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_vfold.md)
  now throws an error when `repeats > 1 && v >= nrow(data)`
  ([\#116](https://github.com/tidymodels/spatialsample/issues/116)).

- The minimum `sf` version required is now `>= 1.0-9`, so that unit
  objects can be passed to `cellsize` in
  [`spatial_block_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_block_cv.md)
  ([\#113](https://github.com/tidymodels/spatialsample/issues/113);
  [\#124](https://github.com/tidymodels/spatialsample/issues/124)).

- [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  now handles repeated cross-validation properly
  ([\#123](https://github.com/tidymodels/spatialsample/issues/123)).

## spatialsample 0.2.1

CRAN release: 2022-08-05

- Mike Mahoney is taking over as package maintainer, as Julia Silge (who
  remains a package author) moves to focus on ModelOps work.

- Functions will now return rsplits without `out_id`, like most rsample
  functions, whenever `buffer` is `NULL`.

- [`spatial_block_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_block_cv.md),
  [`spatial_buffer_vfold_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_vfold.md),
  and buffering now support using sf or sfc objects with a missing CRS.
  The assumption is that data in an NA CRS is projected, with all
  distance values in the same unit as the projection. Trying to use
  alternative units will fail. Set a CRS if these assumptions aren’t
  correct.

- [`spatial_buffer_vfold_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_vfold.md)
  and buffering no longer support tibble or data.frame inputs (they now
  require sf or sfc objects). It was not easy to use these to begin
  with, but should have always caused an error: use
  [`rsample::vfold_cv()`](https://rsample.tidymodels.org/reference/vfold_cv.html)
  instead or transform your data into an sf object.

- [`spatial_buffer_vfold_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_vfold.md)
  has had some attribute changes to match `rsample`:

  - `strata` attribute is now the name of the column used for
    stratification, or not set if there was no stratification.
  - `pool` and `breaks` have been added as attributes
  - `radius` and `buffer` are now set to 0 if they were passed as
    `NULL`.

## spatialsample 0.2.0

CRAN release: 2022-06-17

### New features

- [`spatial_buffer_vfold_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_vfold.md)
  is a new function which wraps
  [`rsample::vfold_cv()`](https://rsample.tidymodels.org/reference/vfold_cv.html),
  allowing users to add inclusion radii and exclusion buffers to their
  vfold resamples. This is the supported way to perform spatially
  buffered leave-one-out cross validation (set `v` to `nrow(data)`).

- [`spatial_leave_location_out_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_vfold.md)
  is a new function with wraps
  [`rsample::group_vfold_cv()`](https://rsample.tidymodels.org/reference/group_vfold_cv.html),
  allowing users to add inclusion radii and exclusion buffers to their
  vfold resamples.

- [`spatial_block_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_block_cv.md)
  is a new function for performing spatial block cross-validation. It
  currently supports randomly assigning blocks to folds.

- [`spatial_clustering_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_clustering_cv.md)
  gains an argument, `cluster_function`, which specifies what type of
  clustering to perform. `cluster_function = "kmeans"`, the default,
  uses [`stats::kmeans()`](https://rdrr.io/r/stats/kmeans.html) for
  k-means clustering, while `cluster_function = "hclust"` uses
  [`stats::hclust()`](https://rdrr.io/r/stats/hclust.html) for
  hierarchical clustering. Users can also provide their own clustering
  function.

- [`spatial_clustering_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_clustering_cv.md)
  now supports `sf` objects! Coordinates are inferred automatically when
  using `sf` objects, and anything passed to `coords` will be ignored
  with a warning. Clusters made using `sf` objects will take coordinate
  reference systems into account (using
  [`sf::st_distance()`](https://r-spatial.github.io/sf/reference/geos_measures.html)),
  unlike those made using data frames.

- All resampling functions now support spatial buffering using two
  arguments. `radius` lets you specify an *inclusion* radius for your
  test set, where any data within `radius` of the original assessment
  set will be added to the assessment set. `buffer` specifies an
  *exclusion* buffer around the test set, where any data within `buffer`
  of the assessment set (after `radius` is applied) will be excluded
  from both sets.

- [`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
  now has a method for spatial resamples built from `sf` objects. It
  works both on `rset` objects and on `rsplit` objects, and has a
  special method for outputs from
  [`spatial_block_cv()`](https://spatialsample.tidymodels.org/dev/reference/spatial_block_cv.md).

- `boston_canopy` is a new dataset with data on tree canopy change over
  time in Boston, Massachusetts, USA. It uses a projected coordinate
  reference system and US customary units; see
  [`?boston_canopy`](https://spatialsample.tidymodels.org/dev/reference/boston_canopy.md)
  for instructions on how to install these into your PROJ installation
  if needed.

### Documentation

- The “Getting Started” vignette has been revised to demonstrate the new
  features and clustering methods.

- A new vignette has been added walking through the spatial buffering
  process.

### Dependency changes

- R versions before 3.4 are no longer supported.

- `glue`, `sf`, and `units` have been added to Imports.

- `ggplot2` has been moved to Imports. It had been in Suggests.

- `covr`, `gifski`, `lwgeom`, and `vdiffr` are now in Suggests.

- `rlang` now has a minimum version of 1.0.0 (was previously
  unversioned).

## spatialsample 0.1.0

CRAN release: 2021-03-04

- Added a `NEWS.md` file to track changes to the package.
