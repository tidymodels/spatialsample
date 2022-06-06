# bad args

    Code
      spatial_clustering_cv(ames_sf, buffer = 50)
    Condition
      Error in `spatial_clustering_cv()`:
      ! `buffer` and `radius` require `data` to have a non-NA coordinate reference system
      i Set the CRS for your data using `sf::st_set_crs()`

---

    Code
      buffer_indices(ames_sf)
    Condition
      Error:
      ! `buffer` and `radius` can only be used with geographic coordinates when using the s2 geometry library
      i Reproject your data into a projected coordinate reference system using `sf::st_transform()`
      i Or install the `s2` package and enable it using `sf::sf_use_s2(TRUE)`

# using buffers

    Code
      spatial_clustering_cv(ames_sf, v = 2, radius = 500, buffer = 500)
    Output
      #  2-fold spatial cross-validation 
      # A tibble: 2 x 2
        splits              id   
        <list>              <chr>
      1 <split [1753/1177]> Fold1
      2 <split [1101/1795]> Fold2

---

    Code
      spatial_block_cv(boston_canopy, v = 2, method = "snake", radius = 500, buffer = 500)
    Output
      #  2-fold spatial block cross-validation 
      # A tibble: 2 x 2
        splits           id   
        <list>           <chr>
      1 <split [40/567]> Fold1
      2 <split [23/585]> Fold2

---

    Code
      spatial_block_cv(ames_sf, v = 2, method = "random", radius = 500, buffer = 500)
    Output
      #  2-fold spatial block cross-validation 
      # A tibble: 2 x 2
        splits             id   
        <list>             <chr>
      1 <split [192/2174]> Fold1
      2 <split [445/2029]> Fold2

