# erroring when no S2

    Code
      spatial_block_cv(ames_sf)
    Condition
      Error in `spatial_block_cv()`:
      ! `spatial_block_cv()` can only process geographic coordinates when using the s2 geometry library
      i Reproject your data into a projected coordinate reference system using `sf::st_transform()`
      i Or install the `s2` package and enable it using `sf::sf_use_s2(TRUE)`

# bad args

    Code
      spatial_block_cv(ames)
    Condition
      Error in `spatial_block_cv()`:
      ! `spatial_block_cv()` currently only supports `sf` objects.
      i Try converting `data` to an `sf` object via `sf::st_as_sf()`.

---

    Code
      spatial_block_cv(sf::st_set_crs(ames_sf, sf::NA_crs_))
    Condition
      Error in `spatial_block_cv()`:
      ! `spatial_block_cv()` requires your data to have an appropriate coordinate reference system (CRS).
      i Try setting a CRS using `sf::st_set_crs()`.

---

    Code
      spatial_block_cv(ames_sf, v = c(5, 10))
    Condition
      Error in `spatial_block_cv()`:
      ! `v` must be a single positive integer.

---

    Code
      spatial_block_cv(ames_sf, v = c(5, 10), method = "snake")
    Condition
      Error in `spatial_block_cv()`:
      ! `v` must be a single positive integer.

---

    Code
      spatial_block_cv(ames_sf, method = "snake", relevant_only = FALSE, v = 28)
    Condition
      Warning:
      Not all folds contained blocks with data:
      x 28 folds were requested, but only 27 contain any data.
      x Empty folds were dropped.
      i To avoid this, set `relevant_only = TRUE`.
    Output
      #  27-fold spatial block cross-validation 
      # A tibble: 27 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2790/140]> Fold01
       2 <split [2726/204]> Fold02
       3 <split [2820/110]> Fold03
       4 <split [2877/53]>  Fold04
       5 <split [2851/79]>  Fold05
       6 <split [2877/53]>  Fold06
       7 <split [2886/44]>  Fold07
       8 <split [2736/194]> Fold08
       9 <split [2919/11]>  Fold09
      10 <split [2855/75]>  Fold10
      # ... with 17 more rows

---

    Code
      spatial_block_cv(ames_sf, method = "snake", v = 60)
    Condition
      Warning in `spatial_block_cv()`:
      Fewer than 60 blocks available for sampling
      i Setting `v` to 54
    Output
      #  54-fold spatial block cross-validation 
      # A tibble: 54 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2917/13]>  Fold01
       2 <split [2818/112]> Fold02
       3 <split [2926/4]>   Fold03
       4 <split [2928/2]>   Fold04
       5 <split [2929/1]>   Fold05
       6 <split [2896/34]>  Fold06
       7 <split [2905/25]>  Fold07
       8 <split [2900/30]>  Fold08
       9 <split [2929/1]>   Fold09
      10 <split [2923/7]>   Fold10
      # ... with 44 more rows

---

    Code
      spatial_block_cv(ames_sf, v = 60)
    Condition
      Warning in `spatial_block_cv()`:
      Fewer than 60 blocks available for sampling
      i Setting `v` to 54
    Output
      #  54-fold spatial block cross-validation 
      # A tibble: 54 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2745/185]> Fold01
       2 <split [2803/127]> Fold02
       3 <split [2900/30]>  Fold03
       4 <split [2927/3]>   Fold04
       5 <split [2915/15]>  Fold05
       6 <split [2918/12]>  Fold06
       7 <split [2887/43]>  Fold07
       8 <split [2854/76]>  Fold08
       9 <split [2927/3]>   Fold09
      10 <split [2870/60]>  Fold10
      # ... with 44 more rows

---

    Code
      spatial_block_cv(boston_canopy, n = 200)
    Message
      Only 1.7% of blocks contain any data
      i Check that your block sizes make sense for your data
    Output
      #  10-fold spatial block cross-validation 
      # A tibble: 10 x 2
         splits           id    
         <list>           <chr> 
       1 <split [613/69]> Fold01
       2 <split [613/69]> Fold02
       3 <split [614/68]> Fold03
       4 <split [614/68]> Fold04
       5 <split [614/68]> Fold05
       6 <split [614/68]> Fold06
       7 <split [614/68]> Fold07
       8 <split [614/68]> Fold08
       9 <split [614/68]> Fold09
      10 <split [614/68]> Fold10

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

