## code to prepare `boston_canopy` dataset goes here
working_dir <- file.path(tempdir(), "boston_canopy")
if (!dir.exists(working_dir)) dir.create(working_dir)

download.file(
  "https://bostonopendata-boston.opendata.arcgis.com/datasets/boston::hex-tree-canopy-change-metrics.zip?outSR=%7B%22latestWkid%22%3A2249%2C%22wkid%22%3A102686%7D",
  file.path(working_dir, "canopy_metrics.zip")
)

unzip(file.path(working_dir, "canopy_metrics.zip"),
      exdir = working_dir)

download.file(
  "https://bostonopendata-boston.opendata.arcgis.com/datasets/boston::hex-mean-heat-index.zip?outSR=%7B%22latestWkid%22%3A2249%2C%22wkid%22%3A102686%7D",
  file.path(working_dir, "heat_metrics.zip")
)

unzip(file.path(working_dir, "heat_metrics.zip"),
      exdir = working_dir)

boston_canopy <- sf::read_sf(
  file.path(working_dir,
            "Canopy_Change_Assessment%3A_Tree_Canopy_Change_Metrics.shp")
)

canopy_metrics <- c(
  "FID" = "FID",
  "GRID_ID" = "GRID_ID",
  "TC_ID" = "TC_ID",
  "OBJECTID" = "OBJECTID",
  "Land_Area" = "LandArea",
  "Canopy_Gain" = "Gain",
  "Canopy_Loss" = "Loss",
  "Canopy_No_Change" = "No_Change",
  "Canopy_Area_2014" = "TreeCanopy",
  "Canopy_Area_2019" = "TreeCano_1",
  "Change_Canopy_Area" = "Change_Are",
  "Change_Canopy_Percentage" = "Change_Per",
  "Canopy_Percentage_2014" = "TreeCano_2",
  "Canopy_Percentage_2019" = "TreeCano_3",
  "Change_Canopy_Absolute" = "Change_P_1",
  "geometry" = "geometry"
)

boston_canopy <- boston_canopy[canopy_metrics]
names(boston_canopy) <- names(canopy_metrics)

heat <- sf::read_sf(
  file.path(working_dir,
            "Canopy_Change_Assessment%3A_Heat_Metrics.shp")
)

heat_metrics <- c(
  "Mean_T_Morning" = "Mean_am_T_",
  "Mean_T_Evening" = "Mean_ev_T_",
  "Mean_T" = "Mean_p2_T_",
  "Mean_Heat_Index_Morning" = "Mean_am_HI",
  "Mean_Heat_Index_Evening" = "Mean_ev_HI",
  "Mean_Heat_Index" = "Mean_p2_HI",
  "geometry" = "geometry"
)

heat <- heat[heat_metrics]
names(heat) <- names(heat_metrics)

boston_canopy <- sf::st_join(boston_canopy, heat, sf::st_within, left = FALSE)
boston_canopy <- dplyr::relocate(boston_canopy, geometry, .after = everything())

usethis::use_data(boston_canopy, overwrite = TRUE)
unlink(working_dir, TRUE)
