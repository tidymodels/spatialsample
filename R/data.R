#' Boston tree canopy and heat index data.
#'
#' A dataset containing data on tree canopy coverage and change for the city of
#' Boston, Massachusetts from 2014-2019,
#' as well as temperature and heat index data for July 2019. Data is aggregated
#' to a grid of regular 25 hectare hexagons, clipped to city boundaries.
#' This data is made available under the Public Domain Dedication and License
#' v1.0 whose full text can be found at:
#' \url{http://opendatacommons.org/licenses/pddl/1.0/}.
#'
#' @format A data frame (of class `sf`, `tbl_df`, `tbl`, and `data.frame`)
#' containing 682 records of 22 variables:
#' \describe{
#'   \item{FID}{FID field uniquely identifying each hexagon}
#'   \item{GRID_ID}{GRID_ID field uniquely identifying each hexagon}
#'   \item{TC_ID}{TC_ID field uniquely identifying each hexagon}
#'   \item{OBJECTID}{OBJECTID field uniquely identifying each hexagon}
#'   \item{Land_Area}{Area excluding water bodies}
#'   \item{Canopy_Gain}{Area of canopy gain between the two years}
#'   \item{Canopy_Loss}{Area of canopy loss between the two years}
#'   \item{Canopy_No_Change}{Area of no canopy change between the two years}
#'   \item{Canopy_Area_2014}{2014 total canopy area (baseline)}
#'   \item{Canopy_Area_2019}{2019 total canopy area}
#'   \item{Change_Canopy_Area}{The change in area of tree canopy between the two years}
#'   \item{Change_Canopy_Percentage}{Relative change calculation used in economics is the gain or loss of tree canopy relative to the earlier time period: (2019 Canopy-2014 Canopy)/(2014 Canopy)}
#'   \item{Canopy_Percentage_2014}{2014 canopy percentage}
#'   \item{Canopy_Percentage_2019}{2019 canopy percentage}
#'   \item{Change_Canopy_Absolute}{Absolute change. Magnitude of change in percent tree canopy from 2014 to 2019 (% 2019 Canopy - % 2014 Canopy)}
#'   \item{Mean_T_Morning}{Mean temperature for July 2019 from 6am - 7am}
#'   \item{Mean_T_Evening}{Mean temperature for July 2019 from 7pm - 8pm}
#'   \item{Mean_T}{Mean temperature for July 2019 from 6am - 7am, 3pm - 4pm, and 7pm - 8pm (combined)}
#'   \item{Mean_Heat_Index_Morning}{Mean heat index for July 2019 from 6am - 7am}
#'   \item{Mean_Heat_Index_Evening}{Mean heat index for July 2019 from 7pm - 8pm}
#'   \item{Mean_Heat_Index}{Mean heat index for July 2019 from 6am - 7am, 3pm - 4pm, and 7pm - 8pm (combined)}
#'   \item{geometry}{Geometry of each hexagon, encoded using EPSG:2249 as a coordinate reference system}
#' }
#'
#' @source Canopy data is from \url{https://data.boston.gov/dataset/hex-tree-canopy-change-metrics2}.
#' Heat data is from \url{https://data.boston.gov/dataset/hex-mean-heat-index2}.
#' Most field definitions are from \url{https://data.boston.gov/dataset/canopy-change-assessment-data-dictionary}.
"boston_canopy"
