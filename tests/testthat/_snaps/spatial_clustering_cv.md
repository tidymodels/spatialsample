# bad args

    Code
      spatial_clustering_cv(Smithsonian, coords = c(latitude, longitude), v = "a")
    Error <rlang_error>
      `v` must be a single integer.

---

    Code
      spatial_clustering_cv(Smithsonian, coords = c(latitude, longitude), v = c(5, 10))
    Error <rlang_error>
      `v` must be a single integer.

# using sf

    Code
      spatial_clustering_cv(Smithsonian_sf, coords = c(latitude, longitude))
    Warning <rlang_warning>
      `coords` is ignored when providing `sf` objects to `data`.
    Output
      #  10-fold spatial cross-validation 
      # A tibble: 10 x 2
         splits         id    
         <list>         <chr> 
       1 <split [16/4]> Fold01
       2 <split [18/2]> Fold02
       3 <split [18/2]> Fold03
       4 <split [18/2]> Fold04
       5 <split [19/1]> Fold05
       6 <split [19/1]> Fold06
       7 <split [17/3]> Fold07
       8 <split [18/2]> Fold08
       9 <split [18/2]> Fold09
      10 <split [19/1]> Fold10

# printing

    #  2-fold spatial cross-validation 
    # A tibble: 2 x 2
      splits         id   
      <list>         <chr>
    1 <split [18/2]> Fold1
    2 <split [2/18]> Fold2

