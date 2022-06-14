## code to prepare `boston_canopy` dataset goes here
working_dir <- file.path(tempdir(), "boston_canopy")
if (!dir.exists(working_dir)) dir.create(working_dir)

download.file(
  "https://bostonopendata-boston.opendata.arcgis.com/datasets/boston::hex-tree-canopy-change-metrics.zip?outSR=%7B%22latestWkid%22%3A2249%2C%22wkid%22%3A102686%7D",
  file.path(working_dir, "canopy_metrics.zip")
)

unzip(
  file.path(working_dir, "canopy_metrics.zip"),
  exdir = working_dir
)

download.file(
  "https://bostonopendata-boston.opendata.arcgis.com/datasets/boston::hex-mean-heat-index.zip?outSR=%7B%22latestWkid%22%3A2249%2C%22wkid%22%3A102686%7D",
  file.path(working_dir, "heat_metrics.zip")
)

unzip(
  file.path(working_dir, "heat_metrics.zip"),
  exdir = working_dir
)

boston_canopy <- sf::read_sf(
  file.path(
    working_dir,
    "Canopy_Change_Assessment%3A_Tree_Canopy_Change_Metrics.shp"
  )
)

canopy_metrics <- c(
  "grid_id" = "GRID_ID",
  "land_area" = "LandArea",
  "canopy_gain" = "Gain",
  "canopy_loss" = "Loss",
  "canopy_no_change" = "No_Change",
  "canopy_area_2014" = "TreeCanopy",
  "canopy_area_2019" = "TreeCano_1",
  "change_canopy_area" = "Change_Are",
  "change_canopy_percentage" = "Change_Per",
  "canopy_percentage_2014" = "TreeCano_2",
  "canopy_percentage_2019" = "TreeCano_3",
  "change_canopy_absolute" = "Change_P_1",
  "geometry" = "geometry"
)

boston_canopy <- boston_canopy[canopy_metrics]
names(boston_canopy) <- names(canopy_metrics)

heat <- sf::read_sf(
  file.path(
    working_dir,
    "Canopy_Change_Assessment%3A_Heat_Metrics.shp"
  )
)

heat_metrics <- c(
  "mean_temp_morning" = "Mean_am_T_",
  "mean_temp_evening" = "Mean_ev_T_",
  "mean_temp" = "Mean_p2_T_",
  "mean_heat_index_morning" = "Mean_am_HI",
  "mean_heat_index_evening" = "Mean_ev_HI",
  "mean_heat_index" = "Mean_p2_HI",
  "geometry" = "geometry"
)

heat <- heat[heat_metrics]
names(heat) <- names(heat_metrics)

boston_canopy <- sf::st_join(boston_canopy, heat, sf::st_within, left = FALSE)
boston_canopy <- dplyr::relocate(boston_canopy, geometry, .after = everything())

usethis::use_data(boston_canopy, overwrite = TRUE, internal = TRUE)
unlink(working_dir, TRUE)
