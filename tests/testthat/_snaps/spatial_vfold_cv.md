# erroring when no S2

    Code
      spatial_buffer_vfold_cv(ames_sf, buffer = 500, radius = NULL)
    Condition
      Error in `spatial_buffer_vfold_cv()`:
      ! `spatial_buffer_vfold_cv()` can only process geographic coordinates when using the s2 geometry library.
      i Reproject your data into a projected coordinate reference system using `sf::st_transform()`.
      i Or install the `s2` package and enable it using `sf::sf_use_s2(TRUE)`.

---

    Code
      suppressMessages(spatial_leave_location_out_cv(ames_sf, Neighborhood, buffer = 500))
    Condition
      Error in `spatial_leave_location_out_cv()`:
      ! Buffering can only process geographic coordinates when using the s2 geometry library.
      i Reproject your data into a projected coordinate reference system using `sf::st_transform()`.
      i Or install the `s2` package and enable it using `sf::sf_use_s2(TRUE)`.

# spatial_buffer_vfold_cv

    Code
      rs1
    Output
      #  2-fold spatial cross-validation 
      # A tibble: 4 x 3
        splits              id      id2  
        <list>              <chr>   <chr>
      1 <split [1465/1465]> Repeat1 Fold1
      2 <split [1465/1465]> Repeat1 Fold2
      3 <split [1465/1465]> Repeat2 Fold1
      4 <split [1465/1465]> Repeat2 Fold2

# spatial_leave_location_out_cv

    Code
      rs1
    Output
      #  2-fold spatial leave-location-out cross-validation 
      # A tibble: 4 x 3
        splits              id      id2      
        <list>              <chr>   <chr>    
      1 <split [1268/1662]> Repeat1 Resample1
      2 <split [1662/1268]> Repeat1 Resample2
      3 <split [1548/1382]> Repeat2 Resample1
      4 <split [1382/1548]> Repeat2 Resample2

# bad args

    Code
      spatial_buffer_vfold_cv(ames_sf, radius = NULL)
    Condition
      Error in `spatial_buffer_vfold_cv()`:
      ! `spatial_buffer_vfold_cv()` requires both `radius` and `buffer` be provided.
      i Use `NULL` for resampling without one of `radius` or `buffer`, like `radius = NULL, buffer = 5000`.

---

    Code
      spatial_buffer_vfold_cv(ames_sf, buffer = 500)
    Condition
      Error in `spatial_buffer_vfold_cv()`:
      ! `spatial_buffer_vfold_cv()` requires both `radius` and `buffer` be provided.
      i Use `NULL` for resampling without one of `radius` or `buffer`, like `radius = NULL, buffer = 5000`.

---

    Code
      spatial_buffer_vfold_cv(ames_sf)
    Condition
      Error in `spatial_buffer_vfold_cv()`:
      ! `spatial_buffer_vfold_cv()` requires both `radius` and `buffer` be provided.
      i Use `NULL` for resampling without one of `radius` or `buffer`, like `radius = NULL, buffer = 5000`.
      i Or use `rsample::vfold_cv() to use a non-spatial V-fold.

---

    Code
      spatial_leave_location_out_cv(ames)
    Condition
      Error in `rsample::group_vfold_cv()`:
      ! `group` should be a single character value for the column that will be used for splitting.

---

    Code
      spatial_leave_location_out_cv(ames, Neighborhood, buffer = 500)
    Condition
      Error in `spatial_leave_location_out_cv()`:
      ! Buffering currently only supports `sf` objects.
      i Try converting `data` to an `sf` object via `sf::st_as_sf()`.

---

    Code
      spatial_leave_location_out_cv(ames_sf, v = c(5, 10))
    Condition
      Error in `rsample::group_vfold_cv()`:
      ! `group` should be a single character value for the column that will be used for splitting.

---

    Code
      spatial_buffer_vfold_cv(ames_sf, v = c(5, 10), buffer = NULL, radius = NULL)
    Condition
      Error in `spatial_buffer_vfold_cv()`:
      ! `v` must be a single positive integer.

---

    Code
      spatial_leave_location_out_cv(ames_sf, Neighborhood, v = 60)
    Condition
      Warning in `spatial_leave_location_out_cv()`:
      Fewer than 60 locations available for sampling
      i Setting `v` to 28
    Output
      #  28-fold spatial leave-location-out cross-validation 
      # A tibble: 28 x 2
         splits             id        
         <list>             <chr>     
       1 <split [2816/114]> Resample01
       2 <split [2928/2]>   Resample02
       3 <split [2799/131]> Resample03
       4 <split [2827/103]> Resample04
       5 <split [2902/28]>  Resample05
       6 <split [2920/10]>  Resample06
       7 <split [2886/44]>  Resample07
       8 <split [2691/239]> Resample08
       9 <split [2779/151]> Resample09
      10 <split [2748/182]> Resample10
      # ... with 18 more rows

---

    Code
      spatial_buffer_vfold_cv(boston_canopy, v = 683, buffer = NULL, radius = NULL)
    Condition
      Warning in `spatial_buffer_vfold_cv()`:
      Fewer than 683 rows available for sampling
      i Setting `v` to 682
    Output
      #  682-fold spatial cross-validation 
      # A tibble: 682 x 2
         splits          id     
         <list>          <chr>  
       1 <split [681/1]> Fold001
       2 <split [681/1]> Fold002
       3 <split [681/1]> Fold003
       4 <split [681/1]> Fold004
       5 <split [681/1]> Fold005
       6 <split [681/1]> Fold006
       7 <split [681/1]> Fold007
       8 <split [681/1]> Fold008
       9 <split [681/1]> Fold009
      10 <split [681/1]> Fold010
      # ... with 672 more rows

---

    Repeated cross-validation doesn't make sense when performing leave-one-out cross-validation.
    i Set `v` to a lower value.
    i Or set `repeats = 1`.

---

    Repeated resampling when `v` is 28 would create identical resamples

# printing

    #  10-fold spatial block cross-validation 
    # A tibble: 10 x 2
       splits             id    
       <list>             <chr> 
     1 <split [2524/406]> Fold01
     2 <split [2656/274]> Fold02
     3 <split [2476/454]> Fold03
     4 <split [2771/159]> Fold04
     5 <split [2607/323]> Fold05
     6 <split [2762/168]> Fold06
     7 <split [2718/212]> Fold07
     8 <split [2665/265]> Fold08
     9 <split [2642/288]> Fold09
    10 <split [2549/381]> Fold10

