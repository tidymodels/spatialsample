# bad args

    Code
      spatial_nndm_cv(Smithsonian_sf[1:15, ], Smithsonian[16:20, ])
    Condition
      Error in `spatial_nndm_cv()`:
      ! `spatial_nndm_cv()` currently only supports `sf` objects.
      i Try converting `prediction_sites` to an `sf` object via `sf::st_as_sf()`.

---

    Code
      spatial_nndm_cv(Smithsonian[1:15, ], Smithsonian_sf[16:20, ])
    Condition
      Error in `spatial_nndm_cv()`:
      ! `spatial_nndm_cv()` currently only supports `sf` objects.
      i Try converting `data` to an `sf` object via `sf::st_as_sf()`.

# normal usage

    Code
      spatial_nndm_cv(Smithsonian_sf[1:15, ], Smithsonian_sf[16:20, ])
    Output
      # A tibble: 15 x 2
         splits         id    
         <list>         <chr> 
       1 <split [14/1]> Fold01
       2 <split [14/1]> Fold02
       3 <split [14/1]> Fold03
       4 <split [14/1]> Fold04
       5 <split [13/1]> Fold05
       6 <split [14/1]> Fold06
       7 <split [7/1]>  Fold07
       8 <split [14/1]> Fold08
       9 <split [10/1]> Fold09
      10 <split [14/1]> Fold10
      11 <split [14/1]> Fold11
      12 <split [7/1]>  Fold12
      13 <split [14/1]> Fold13
      14 <split [7/1]>  Fold14
      15 <split [14/1]> Fold15

# can pass a single polygon to sample within

    Code
      spatial_nndm_cv(Smithsonian_sf, example_poly)
    Output
      # A tibble: 20 x 2
         splits         id    
         <list>         <chr> 
       1 <split [10/1]> Fold01
       2 <split [10/1]> Fold02
       3 <split [10/1]> Fold03
       4 <split [18/1]> Fold04
       5 <split [10/1]> Fold05
       6 <split [10/1]> Fold06
       7 <split [10/1]> Fold07
       8 <split [10/1]> Fold08
       9 <split [14/1]> Fold09
      10 <split [10/1]> Fold10
      11 <split [10/1]> Fold11
      12 <split [15/1]> Fold12
      13 <split [18/1]> Fold13
      14 <split [10/1]> Fold14
      15 <split [17/1]> Fold15
      16 <split [10/1]> Fold16
      17 <split [10/1]> Fold17
      18 <split [11/1]> Fold18
      19 <split [10/1]> Fold19
      20 <split [10/1]> Fold20

# printing

    # A tibble: 15 x 2
       splits         id    
       <list>         <chr> 
     1 <split [14/1]> Fold01
     2 <split [14/1]> Fold02
     3 <split [14/1]> Fold03
     4 <split [14/1]> Fold04
     5 <split [13/1]> Fold05
     6 <split [14/1]> Fold06
     7 <split [7/1]>  Fold07
     8 <split [14/1]> Fold08
     9 <split [10/1]> Fold09
    10 <split [14/1]> Fold10
    11 <split [14/1]> Fold11
    12 <split [7/1]>  Fold12
    13 <split [14/1]> Fold13
    14 <split [7/1]>  Fold14
    15 <split [14/1]> Fold15

