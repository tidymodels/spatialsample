#' Boston tree canopy and heat index data.
#'
#' A dataset containing data on tree canopy coverage and change for the city of
#' Boston, Massachusetts from 2014-2019,
#' as well as temperature and heat index data for July 2019. Data is aggregated
#' to a grid of regular 25 hectare hexagons, clipped to city boundaries.
#' This data is made available under the Public Domain Dedication and License
#' v1.0 whose full text can be found at:
#' \url{https://opendatacommons.org/licenses/pddl/1-0/}.
#'
#' Note that this dataset is in the EPSG:2249
#' (NAD83 / Massachusetts Mainland (ftUS)) coordinate reference system (CRS),
#' which may not be installed by default on your computer. Before working with
#' `boston_canopy`, run:
#'
#' - `sf::sf_proj_network(TRUE)` to install the CRS itself
#' - [sf::sf_add_proj_units()] to add US customary units to your units
#' database
#'
#' These steps only need to be taken once per computer (or per PROJ installation).
#'
#' @format A data frame (of class `sf`, `tbl_df`, `tbl`, and `data.frame`)
#' containing 682 records of 22 variables:
#' \describe{
#'   \item{grid_id}{Unique identifier for each hexagon. Letters represent the hexagon's X position in the grid (ordered West to East), while numbers represent the Y position (ordered North to South).}
#'   \item{land_area}{Area excluding water bodies}
#'   \item{canopy_gain}{Area of canopy gain between the two years}
#'   \item{canopy_loss}{Area of canopy loss between the two years}
#'   \item{canopy_no_change}{Area of no canopy change between the two years}
#'   \item{canopy_area_2014}{2014 total canopy area (baseline)}
#'   \item{canopy_area_2019}{2019 total canopy area}
#'   \item{change_canopy_area}{The change in area of tree canopy between the two years}
#'   \item{change_canopy_percentage}{Relative change calculation used in economics is the gain or loss of tree canopy relative to the earlier time period: (2019 Canopy-2014 Canopy)/(2014 Canopy)}
#'   \item{canopy_percentage_2014}{2014 canopy percentage}
#'   \item{canopy_percentage_2019}{2019 canopy percentage}
#'   \item{change_canopy_absolute}{Absolute change. Magnitude of change in percent tree canopy from 2014 to 2019 (% 2019 Canopy - % 2014 Canopy)}
#'   \item{mean_temp_morning}{Mean temperature for July 2019 from 6am - 7am}
#'   \item{mean_temp_evening}{Mean temperature for July 2019 from 7pm - 8pm}
#'   \item{mean_temp}{Mean temperature for July 2019 from 6am - 7am, 3pm - 4pm, and 7pm - 8pm (combined)}
#'   \item{mean_heat_index_morning}{Mean heat index for July 2019 from 6am - 7am}
#'   \item{mean_heat_index_evening}{Mean heat index for July 2019 from 7pm - 8pm}
#'   \item{mean_heat_index}{Mean heat index for July 2019 from 6am - 7am, 3pm - 4pm, and 7pm - 8pm (combined)}
#'   \item{geometry}{Geometry of each hexagon, encoded using EPSG:2249 as a coordinate reference system (NAD83 / Massachusetts Mainland (ftUS)). Note that the linear units of this CRS are in US feet.}
#' }
#'
#' @source Canopy data is from \url{https://data.boston.gov/dataset/hex-tree-canopy-change-metrics}.
#' Heat data is from \url{https://data.boston.gov/dataset/hex-mean-heat-index}.
#' Most field definitions are from \url{https://data.boston.gov/dataset/canopy-change-assessment-data-dictionary}.
"boston_canopy"
