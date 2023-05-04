#' Nearest neighbor distance matching (NNDM) cross-validation
#'
#' NNDM is a variant of leave-one-out cross-validation which assigns each
#' observation to a single assessment fold, and then attempts to remove data
#' from each analysis fold until the mean nearest neighbor distance between
#' assessment and analysis folds matches the mean nearest neighbor distance
#' between training data and the locations a model will be used to predict.
#' Proposed by Milà et al. (2022), this method aims to provide accurate
#' estimates of how well models will perform in the locations they will actually
#' be predicting. This method was originally implemented in the CAST package.
#'
#' Note that, as a form of leave-one-out cross-validation, this method can be
#' rather slow for larger data (and fitting models to these resamples will be
#' even slower).
#'
#' @param data An object of class `sf` or `sfc`.
#' @param prediction_sites An `sf` or `sfc` object describing the areas to be
#' predicted. If `prediction_sites` are all points, then those points are
#' treated as the intended prediction points when calculating target nearest
#' neighbor distances. If any element of `prediction_sites` is not a single
#' point, then points are sampled from within the bounding box of
#' `prediction_sites` and those points are then used as the intended prediction
#' points.
#' @param ... Additional arguments passed to [sf::st_sample()]. Note that the
#' number of points to sample is controlled by `prediction_sample_size`; trying
#' to pass `size` via `...` will cause an error.
#' @param autocorrelation_range A numeric of length 1 representing the landscape
#' autocorrelation range ("phi" in the terminology of Milà et al. (2022)). If
#' `NULL`, the default, the autocorrelation range is assumed to be the distance
#' between the opposite corners of the bounding box of `prediction_sites`.
#' @param prediction_sample_size A numeric of length 1: the number of points to
#' sample when `prediction_sites` is not only composed of points. Note that this
#' argument is passed to `size` in [sf::st_sample()], meaning that no elements
#' of `...` can be named `size`.
#' @param min_analysis_proportion The minimum proportion of `data` that must
#' remain after removing points to match nearest neighbor distances. This
#' function will stop removing data from analysis sets once only
#' `min_analysis_proportion` of the original data remains in analysis sets, even
#' if the nearest neighbor distances between analysis and assessment sets are
#' still lower than those between training and prediction locations.
#'
#' @return A tibble with classes `spatial_nndm_cv`,  `spatial_rset`, `rset`,
#'   `tbl_df`, `tbl`, and `data.frame`. The results include a column for the
#'   data split objects and an identification variable `id`.
#'
#' @references
#' C. Milà, J. Mateu, E. Pebesma, and H. Meyer. 2022. "Nearest Neighbour
#' Distance Matching Leave-One-Out Cross-Validation for map validation." Methods
#' in Ecology and Evolution 2022:13, pp 1304– 1316.
#' doi: 10.1111/2041-210X.13851.
#'
#' H. Meyer and E. Pebesma. 2022. "Machine learning-based global maps of
#' ecological variables and the challenge of assessing them."
#' Nature Communications 13, pp 2208. doi: 10.1038/s41467-022-29838-9.
#'
#' @examplesIf rlang::is_installed("modeldata")
#' data(ames, package = "modeldata")
#' ames_sf <- sf::st_as_sf(ames, coords = c("Longitude", "Latitude"), crs = 4326)
#'
#' # Using a small subset of the data, to make the example run faster:
#' spatial_nndm_cv(ames_sf[1:200, ], ames_sf[2001:2200, ])
#'
#' @export
spatial_nndm_cv <- function(data, prediction_sites, ...,
                            autocorrelation_range = NULL,
                            prediction_sample_size = 1000,
                            min_analysis_proportion = 0.5) {
  rlang::check_dots_used()

  standard_checks(data, "`spatial_nndm_cv()`", rlang::current_env())
  if (!is_sf(prediction_sites)) {
    rlang::abort(
      c(
        glue::glue("`spatial_nndm_cv()` currently only supports `sf` objects."),
        i = "Try converting `prediction_sites` to an `sf` object via `sf::st_as_sf()`."
      )
    )
  }

  if (!isTRUE(sf::st_crs(prediction_sites) == sf::st_crs(data))) {
    rlang::warn(
      c(
        "Reprojecting `prediction_sites` to match the CRS of `data`.",
        i = "Reproject `prediction_sites` and `data` to share a CRS to avoid this warning."
      )
    )
    prediction_sites <- sf::st_transform(prediction_sites, sf::st_crs(data))
  }

  cv_att <- list(
    prediction_sites = prediction_sites,
    prediction_sample_size = prediction_sample_size,
    autocorrelation_range = autocorrelation_range,
    min_analysis_proportion = min_analysis_proportion,
    ...
  )

  pred_geometry <- unique(sf::st_geometry_type(prediction_sites))
  if (length(pred_geometry) > 1 || pred_geometry != "POINT") {
    prediction_sites <- sf::st_sample(
      x = sf::st_as_sfc(sf::st_bbox(prediction_sites)),
      size = prediction_sample_size,
      ...
    )
  }

  if (is.null(autocorrelation_range)) {
    bbox <- sf::st_bbox(prediction_sites)

    autocorrelation_range <- sf::st_distance(
      sf::st_as_sf(
        data.frame(
          lon = bbox[c("xmin", "xmax")],
          lat = bbox[c("ymin", "ymax")]
        ),
        coords = c("lon", "lat"),
        crs = sf::st_crs(prediction_sites)
      )
    )[2]
  }

  nn_prediction <- apply(sf::st_distance(prediction_sites, data), 1, min)

  distance_matrix <- sf::st_distance(data)

  # We've enforced that prediction_sites and data are in the same CRS;
  # therefore nearest_neighbors and distance_matrix are in the same units
  # Force autocorrelation_range into the same units:
  units(autocorrelation_range) <- units(distance_matrix)

  # We're guaranteed to be working in one set of units now,
  # which means we should be able to drop units entirely at this point
  # (which should make some of the logic here easier)
  units(autocorrelation_range) <- NULL
  units(distance_matrix) <- NULL

  diag(distance_matrix) <- NA
  nn_training <- apply(distance_matrix, 1, min, na.rm = TRUE)

  indices <- list(
    distance = min(nn_training),
    row = which.min(nn_training)[1]
  )
  indices$col <- which.min(distance_matrix[indices$row, ])

  n_training <- nrow(data)

  while (indices$distance <= autocorrelation_range) {
    prop_close_training <-
      mean(nn_training <= indices$distance) - (1 / n_training)
    prop_close_prediction <- mean(nn_prediction <= indices$distance)

    n_remaining <- sum(!is.na(distance_matrix[indices$col, ]))

    if (prop_close_training >= prop_close_prediction &
      (n_remaining / n_training) > min_analysis_proportion) {
      distance_matrix[indices$row, indices$col] <- NA

      nn_training <- apply(distance_matrix, 1, min, na.rm = TRUE)

      indices$distance <- min(nn_training[nn_training >= indices$distance])
      indices$row <- which(nn_training == indices$distance)[1]
      indices$col <- which(distance_matrix[indices$row, ] == indices$distance)
    } else {
      indices$distance <- min(nn_training[nn_training > indices$distance])
      indices$row <- which(nn_training == indices$distance)[1]
      indices$col <- which(distance_matrix[indices$row, ] == indices$distance)
    }

    if (!any(nn_training > indices$distance)) {
      break
    }

  }

  indices <- purrr::map(
    seq_len(nrow(distance_matrix)),
    function(i) {
      list(
        analysis = which(!is.na(distance_matrix[i, ])),
        assessment = i
      )
    }
  )

  split_objs <- purrr::map(
    indices,
    make_splits,
    data = data,
    class = c("spatial_nndm_split", "spatial_rsplit")
  )

  new_rset(
    splits = split_objs,
    ids = names0(length(split_objs), "Fold"),
    attrib = cv_att,
    subclass = c("spatial_nndm_cv", "spatial_rset", "rset")
  )
}
