# bad args

    Code
      buffer_indices(ames_sf)
    Condition
      Error:
      ! Buffering can only process geographic coordinates when using the s2 geometry library.
      i Reproject your data into a projected coordinate reference system using `sf::st_transform()`.
      i Or install the `s2` package and enable it using `sf::sf_use_s2(TRUE)`.

---

    Code
      spatial_clustering_cv(ames_sf, buffer = 0.01)
    Output
      #  10-fold spatial cross-validation 
      # A tibble: 10 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2586/344]> Fold01
       2 <split [2506/424]> Fold02
       3 <split [2701/229]> Fold03
       4 <split [2740/190]> Fold04
       5 <split [2625/305]> Fold05
       6 <split [2757/173]> Fold06
       7 <split [2404/526]> Fold07
       8 <split [2665/265]> Fold08
       9 <split [2661/269]> Fold09
      10 <split [2725/205]> Fold10

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
       1 <split [2194/555]> Resample01
       2 <split [2220/397]> Resample02
       3 <split [2435/279]> Resample03
       4 <split [2779/151]> Resample04
       5 <split [2597/127]> Resample05
       6 <split [2598/197]> Resample06
       7 <split [2640/166]> Resample07
       8 <split [2617/136]> Resample08
       9 <split [2764/150]> Resample09
      10 <split [2501/324]> Resample10
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

