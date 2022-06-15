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
      1 <split [37/553]> Fold1
      2 <split [54/529]> Fold2

---

    Code
      spatial_buffer_vfold_cv(boston_canopy, v = 682, radius = 500, buffer = 500)
    Output
      #  682-fold spatial cross-validation 
      # A tibble: 682 x 2
         splits          id     
         <list>          <chr>  
       1 <split [672/3]> Fold001
       2 <split [664/7]> Fold002
       3 <split [663/7]> Fold003
       4 <split [666/7]> Fold004
       5 <split [665/7]> Fold005
       6 <split [671/5]> Fold006
       7 <split [671/6]> Fold007
       8 <split [663/7]> Fold008
       9 <split [663/7]> Fold009
      10 <split [665/7]> Fold010
      # ... with 672 more rows

---

    Code
      spatial_leave_location_out_cv(ames_sf, Neighborhood, v = 682, radius = 500,
        buffer = 500)
    Condition
      Warning in `spatial_leave_location_out_cv()`:
      Fewer than 682 locations available for sampling
      i Setting `v` to 28
    Output
      #  28-fold spatial leave-location-out cross-validation 
      # A tibble: 28 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2194/555]> Fold01
       2 <split [2220/397]> Fold02
       3 <split [2435/279]> Fold03
       4 <split [2779/151]> Fold04
       5 <split [2597/127]> Fold05
       6 <split [2598/197]> Fold06
       7 <split [2640/166]> Fold07
       8 <split [2617/136]> Fold08
       9 <split [2764/150]> Fold09
      10 <split [2501/324]> Fold10
      # ... with 18 more rows

---

    Code
      spatial_block_cv(ames_sf, v = 2, method = "random", radius = 500, buffer = 500)
    Output
      #  2-fold spatial block cross-validation 
      # A tibble: 2 x 2
        splits             id   
        <list>             <chr>
      1 <split [209/2505]> Fold1
      2 <split [2/2470]>   Fold2

