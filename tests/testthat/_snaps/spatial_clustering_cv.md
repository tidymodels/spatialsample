# bad args

    Code
      spatial_clustering_cv(Smithsonian, coords = c(latitude, longitude), v = "a")
    Condition
      Error in `spatial_clustering_splits()`:
      ! `v` must be a single integer.

---

    Code
      spatial_clustering_cv(Smithsonian, coords = c(latitude, longitude), v = c(5, 10))
    Condition
      Error in `spatial_clustering_splits()`:
      ! `v` must be a single integer.

---

    Code
      spatial_clustering_cv(Smithsonian, coords = c(latitude, longitude), v = 100)
    Condition
      Error in `spatial_clustering_splits()`:
      ! The number of data points is less than `v = 100` (20)
      i Set `v` to a smaller value than {max_v}

# using sf

    Code
      spatial_clustering_cv(Smithsonian_sf, coords = c(latitude, longitude))
    Condition
      Warning:
      `coords` is ignored when providing `sf` objects to `data`.
    Output
      #  10-fold spatial cross-validation 
      # A tibble: 10 x 2
         splits         id    
         <list>         <chr> 
       1 <split [18/2]> Fold01
       2 <split [19/1]> Fold02
       3 <split [18/2]> Fold03
       4 <split [17/3]> Fold04
       5 <split [18/2]> Fold05
       6 <split [19/1]> Fold06
       7 <split [18/2]> Fold07
       8 <split [18/2]> Fold08
       9 <split [17/3]> Fold09
      10 <split [18/2]> Fold10

# printing

    #  2-fold spatial cross-validation 
    # A tibble: 2 x 2
      splits         id   
      <list>         <chr>
    1 <split [18/2]> Fold1
    2 <split [2/18]> Fold2

