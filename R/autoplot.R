#' Create a ggplot for spatial resamples.
#'
#' This method provides a good visualization method for spatial resampling.
#'
#' @param object A `spatial_rset` object. Note that only resamples made from
#' `sf` objects are `spatial_rset` objects; this function will not work for
#' resamples made with non-spatial tibbles or data.frames.
#' @param ... Options passed to [ggplot2::geom_sf()].
#'
#' @return A ggplot object with each fold assigned a color, made using
#' [ggplot2::geom_sf()].
#'
#' @examplesIf rlang::is_installed("ggplot2") && rlang::is_installed("modeldata")
#' data(ames, package = "modeldata")
#' ames_sf <- sf::st_as_sf(
#'   ames,
#'   coords = c("Longitude", "Latitude"),
#'   crs = 4326
#' )
#'
#' ames_block <- spatial_block_cv(ames_sf)
#' autoplot(ames_block)
#'
# registered in zzz.R
#' @export
autoplot.spatial_rset <- function(object, ...) {
  fold <- NULL

  object <- purrr::map2_dfr(
    object$splits,
    object$id,
    ~ cbind(assessment(.x), fold = .y)
  )

  p <- ggplot2::ggplot(
    data = object,
    mapping = ggplot2::aes(color = fold, fill = fold)
  )
  p <- p + ggplot2::geom_sf(...)
  p + ggplot2::coord_sf()
}
