# Spatial block cross-validation

Block cross-validation splits the area of your data into a number of
grid cells, or "blocks", and then assigns all data into folds based on
the blocks their centroid falls into.

## Usage

``` r
spatial_block_cv(
  data,
  method = c("random", "snake", "continuous"),
  v = 10,
  relevant_only = TRUE,
  radius = NULL,
  buffer = NULL,
  ...,
  repeats = 1,
  expand_bbox = 1e-05
)
```

## Arguments

- data:

  An object of class `sf` or `sfc`.

- method:

  The method used to sample blocks for cross validation folds. Currently
  supports `"random"`, which randomly assigns blocks to folds,
  `"snake"`, which labels the first row of blocks from left to right,
  then the next from right to left, and repeats from there, and
  `"continuous"`, which labels each row from left to right, moving from
  the bottom row up.

- v:

  The number of partitions for the resampling. Set to `NULL` or `Inf`
  for the maximum sensible value (for leave-one-X-out cross-validation).

- relevant_only:

  For systematic sampling, should only blocks containing data be
  included in fold labeling?

- radius:

  Numeric: points within this distance of the initially-selected test
  points will be assigned to the assessment set. If `NULL`, no radius is
  applied.

- buffer:

  Numeric: points within this distance of any point in the test set
  (after `radius` is applied) will be assigned to neither the analysis
  or assessment set. If `NULL`, no buffer is applied.

- ...:

  Arguments passed to
  [`sf::st_make_grid()`](https://r-spatial.github.io/sf/reference/st_make_grid.html).

- repeats:

  The number of times to repeat the V-fold partitioning.

- expand_bbox:

  A numeric of length 1, representing a proportion to expand the
  bounding box of `data` by before building a grid. Without this
  expansion, grids built from data in geographic coordinates may exclude
  observations and grids built from regularly spaced data might have
  observations fall exactly on the boundary between folds, duplicating
  them. In spatialsample \< 0.5.0, this was 0.00001 for data in a
  geographic CRS and 0 for data in a planar CRS. In spatialsample \>=
  0.5.0, this is 0.00001 for all data.

## Value

A tibble with classes `spatial_block_cv`, `spatial_rset`, `rset`,
`tbl_df`, `tbl`, and `data.frame`. The results include a column for the
data split objects and an identification variable `id`.

## Details

The grid blocks can be controlled by passing arguments to
[`sf::st_make_grid()`](https://r-spatial.github.io/sf/reference/st_make_grid.html)
via `...`. Some particularly useful arguments include:

- `cellsize`: Target cellsize, expressed as the "diameter" (shortest
  straight-line distance between opposing sides; two times the apothem)
  of each block, in map units.

- `n`: The number of grid blocks in the x and y direction (columns,
  rows).

- `square`: A logical value indicating whether to create square (`TRUE`)
  or hexagonal (`FALSE`) cells.

If both `cellsize` and `n` are provided, then the number of blocks
requested by `n` of sizes specified by `cellsize` will be returned,
likely not lining up with the bounding box of `data`. If only `cellsize`
is provided, this function will return as many blocks of size `cellsize`
as fit inside the bounding box of `data`. If only `n` is provided, then
`cellsize` will be automatically adjusted to create the requested number
of cells.

## References

D. R. Roberts, V. Bahn, S. Ciuti, M. S. Boyce, J. Elith, G.
Guillera-Arroita, S. Hauenstein, J. J. Lahoz-Monfort, B. Schröder, W.
Thuiller, D. I. Warton, B. A. Wintle, F. Hartig, and C. F. Dormann.
"Cross-validation strategies for data with temporal, spatial,
hierarchical, or phylogenetic structure," 2016, Ecography 40(8), pp.
913-929, doi: 10.1111/ecog.02881.

## Examples

``` r
spatial_block_cv(boston_canopy, v = 3)
#> #  3-fold spatial block cross-validation 
#> # A tibble: 3 × 2
#>   splits            id   
#>   <list>            <chr>
#> 1 <split [479/203]> Fold1
#> 2 <split [433/249]> Fold2
#> 3 <split [452/230]> Fold3
```
