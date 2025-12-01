# Check that "v" is sensible

Check that "v" is sensible

## Usage

``` r
check_v(v, max_v, objects, allow_max_v = TRUE, call = rlang::caller_env())
```

## Arguments

- v:

  The number of partitions for the resampling. Set to `NULL` or `Inf`
  for the maximum sensible value (for leave-one-X-out cross-validation).
