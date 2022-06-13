# check_v errors appropriately

    Code
      check_v(-1)
    Condition
      Error:
      ! `v` must be a single positive integer.

---

    Code
      check_v(c(5, 10))
    Condition
      Error:
      ! `v` must be a single positive integer.

---

    Code
      check_v("a")
    Condition
      Error:
      ! `v` must be a single positive integer.

---

    Code
      check_v(10, 5, "rows", FALSE)
    Condition
      Error:
      ! The number of rows is less than `v = 10` (5)
      i Set `v` to a smaller value than 5

# check_v updates v appropriately

    Code
      new_v <- check_v(10, 5, "rows")
    Condition
      Warning:
      Fewer than 10 rows available for sampling
      i Setting `v` to 5

