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
      Error in `random_block_cv()`:
      ! `v` must be a single integer.

---

    Code
      spatial_block_cv(ames_sf, v = c(5, 10), method = "snake")
    Condition
      Error in `systematic_block_cv()`:
      ! `v` must be a single integer.

---

    Code
      spatial_block_cv(ames_sf, method = "snake", relevant_only = FALSE, v = 5)
    Condition
      Warning:
      Not all folds contained blocks with data: 
      5 folds were requested, but only 4 contain any data. 
      Empty folds were dropped.
      i To avoid this, set `relevant_only = TRUE`.
    Output
      #  4-fold spatial block cross-validation 
      # A tibble: 4 x 2
        splits              id   
        <list>              <chr>
      1 <split [1966/964]>  Fold1
      2 <split [2557/373]>  Fold2
      3 <split [2541/389]>  Fold3
      4 <split [1726/1204]> Fold4

---

    Code
      spatial_block_cv(ames_sf, method = "snake", v = 60)
    Condition
      Warning in `systematic_block_cv()`:
      Fewer than 60 blocks available for sampling; setting v to 17.
    Output
      #  17-fold spatial block cross-validation 
      # A tibble: 17 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2904/26]>  Fold01
       2 <split [2859/71]>  Fold02
       3 <split [2715/215]> Fold03
       4 <split [2591/339]> Fold04
       5 <split [2901/29]>  Fold05
       6 <split [2900/30]>  Fold06
       7 <split [2856/74]>  Fold07
       8 <split [2848/82]>  Fold08
       9 <split [2922/8]>   Fold09
      10 <split [2636/294]> Fold10
      11 <split [2836/94]>  Fold11
      12 <split [2376/554]> Fold12
      13 <split [2909/21]>  Fold13
      14 <split [2872/58]>  Fold14
      15 <split [2609/321]> Fold15
      16 <split [2563/367]> Fold16
      17 <split [2583/347]> Fold17

---

    Code
      spatial_block_cv(ames_sf, v = 60)
    Condition
      Warning in `random_block_cv()`:
      Fewer than 60 blocks available for sampling; setting v to 17.
    Output
      #  17-fold spatial block cross-validation 
      # A tibble: 17 x 2
         splits             id    
         <list>             <chr> 
       1 <split [2376/554]> Fold01
       2 <split [2591/339]> Fold02
       3 <split [2859/71]>  Fold03
       4 <split [2922/8]>   Fold04
       5 <split [2848/82]>  Fold05
       6 <split [2715/215]> Fold06
       7 <split [2563/367]> Fold07
       8 <split [2836/94]>  Fold08
       9 <split [2609/321]> Fold09
      10 <split [2901/29]>  Fold10
      11 <split [2636/294]> Fold11
      12 <split [2909/21]>  Fold12
      13 <split [2872/58]>  Fold13
      14 <split [2856/74]>  Fold14
      15 <split [2904/26]>  Fold15
      16 <split [2900/30]>  Fold16
      17 <split [2583/347]> Fold17

# printing

    #  10-fold spatial block cross-validation 
    # A tibble: 10 x 2
       splits             id    
       <list>             <chr> 
     1 <split [2082/848]> Fold01
     2 <split [2570/360]> Fold02
     3 <split [2801/129]> Fold03
     4 <split [2848/82]>  Fold04
     5 <split [2822/108]> Fold05
     6 <split [2685/245]> Fold06
     7 <split [2216/714]> Fold07
     8 <split [2836/94]>  Fold08
     9 <split [2609/321]> Fold09
    10 <split [2901/29]>  Fold10

