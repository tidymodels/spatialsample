# bad args

    Code
      spatial_clustering_cv(Smithsonian)
    Condition
      Error in `spatial_clustering_cv()`:
      ! `spatial_clustering_cv()` currently only supports `sf` objects.
      i Try converting `data` to an `sf` object via `sf::st_as_sf()`.

---

    Code
      spatial_clustering_cv(Smithsonian_sf, v = "a")
    Condition
      Error in `spatial_clustering_cv()`:
      ! `v` must be a single positive integer.

---

    Code
      spatial_clustering_cv(Smithsonian_sf, v = c(5, 10))
    Condition
      Error in `spatial_clustering_cv()`:
      ! `v` must be a single positive integer.

---

    Code
      spatial_clustering_cv(Smithsonian_sf, v = 100)
    Condition
      Error in `spatial_clustering_cv()`:
      ! The number of data points is less than `v = 100` (20)
      i Set `v` to a smaller value than 20

# using sf

    Code
      spatial_clustering_cv(Smithsonian_sf)
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

