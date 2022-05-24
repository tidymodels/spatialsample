# bad args

    Code
      leave_location_out_cv(Sacramento, city, pool = 0.47)
    Error <rlang_error>
      Fewer than two locations had enough data to use without pooling.
      * Consider providing a less granular location variable.

---

    Code
      leave_location_out_cv(Sacramento, city, v = c(2, 5))
    Error <rlang_error>
      `v` must be a single integer.

---

    Code
      leave_location_out_cv(Sacramento, not_a_column)
    Error <vctrs_error_subscript_oob>
      Can't subset columns that don't exist.
      x Column `not_a_column` doesn't exist.

---

    Code
      leave_location_out_cv(Sacramento_tmp, city, pool = 0.03)
    Warning <rlang_warning>
      Missing and small locations are being combined with the pre-existing '.pooled_locations' group.
      * Rename '.pooled_locations' to avoid this.
    Output
      #  7-fold leave-location-out cross-validation 
      # A tibble: 7 x 2
        splits            id   
        <list>            <chr>
      1 <split [818/114]> Fold1
      2 <split [495/437]> Fold2
      3 <split [884/48]>  Fold3
      4 <split [695/237]> Fold4
      5 <split [904/28]>  Fold5
      6 <split [899/33]>  Fold6
      7 <split [897/35]>  Fold7

---

    Code
      leave_location_out_cv(Sacramento, city, pool = 0.03, v = 8)
    Warning <rlang_warning>
      Fewer than 8 locations available for sampling; setting v to 7.
    Output
      #  7-fold leave-location-out cross-validation 
      # A tibble: 7 x 2
        splits            id   
        <list>            <chr>
      1 <split [818/114]> Fold1
      2 <split [897/35]>  Fold2
      3 <split [899/33]>  Fold3
      4 <split [904/28]>  Fold4
      5 <split [696/236]> Fold5
      6 <split [494/438]> Fold6
      7 <split [884/48]>  Fold7

---

    Code
      leave_location_out_cv(Sacramento, city, pool = 0.04)
    Warning <rlang_warning>
      Combining small locations into a new group would create a group smaller than 4% of the data.
      * They have been combined with 'ROSEVILLE' instead.
    Output
      #  3-fold leave-location-out cross-validation 
      # A tibble: 3 x 2
        splits            id   
        <list>            <chr>
      1 <split [818/114]> Fold1
      2 <split [552/380]> Fold2
      3 <split [494/438]> Fold3

# printing

    #  4-fold leave-location-out cross-validation 
    # A tibble: 4 x 2
      splits            id   
      <list>            <chr>
    1 <split [396/536]> Fold1
    2 <split [831/101]> Fold2
    3 <split [725/207]> Fold3
    4 <split [844/88]>  Fold4

