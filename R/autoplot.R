#' Create a ggplot for spatial resamples.
#'
#' This method provides a good visualization method for spatial resampling.
#'
#' @details
#' The plot method for `spatial_rset` displays which fold each observation
#' is assigned to. Note that if data is assigned to multiple folds
#' (which is common if resamples were created with a non-zero `radius`) only
#' the "last" fold for each observation will appear on the plot.
#' Consider adding `ggplot2::facet_wrap(~ fold)` to visualize all members of
#' each fold separately.
#' Alternatively, consider plotting each split using the `spatial_rsplit` method
#' (for example, via `lapply(object$splits, autoplot)`).
#'
#' @param object A `spatial_rset` object or a `spatial_rsplit` object.
#' Note that only resamples made from
#' `sf` objects create `spatial_rset` and `spatial_rsplit` objects;
#' this function will not work for
#' resamples made with non-spatial tibbles or data.frames.
#' @param ... Options passed to [ggplot2::geom_sf()].
#' @param alpha Opacity, passed to [ggplot2::geom_sf()].
#' Values of alpha range from 0 to 1, with lower values corresponding to more
#' transparent colors.
#'
#' @return A ggplot object with each fold assigned a color, made using
#' [ggplot2::geom_sf()].
#'
#' @examples
#'
#' boston_block <- spatial_block_cv(boston_canopy, v = 2)
#' autoplot(boston_block)
#' lapply(boston_block$splits, autoplot)
#'
#' @rdname autoplot.spatial_rset
# registered in zzz.R
#' @export
autoplot.spatial_rset <- function(object, ..., alpha = 0.6) {
  # .fold. is named to not interfere with normal column names
  .fold. <- NULL

  object <- purrr::map2_dfr(
    object$splits,
    object$id,
    ~ cbind(assessment(.x), .fold. = .y)
  )

  p <- ggplot2::ggplot(
    data = object,
    mapping = ggplot2::aes(color = .fold., fill = .fold.)
  )
  p <- p + ggplot2::geom_sf(..., alpha = alpha)
  p <- p + ggplot2::guides(
    colour = ggplot2::guide_legend("Fold"),
    fill = ggplot2::guide_legend("Fold")
  )
  p + ggplot2::coord_sf()
}

#' @export
autoplot.spatial_rsplit <- function(object, ..., alpha = 0.6) {
  # .class. is named to not interfere with normal column names
  .class. <- NULL

  ins <- object$in_id
  outs <- if (identical(object$out_id, NA)) {
    rsample::complement(object)
  } else {
    object$out_id
  }
  object <- object$data
  object$.class. <- NA
  object$.class.[ins] <- "Analysis"
  object$.class.[outs] <- "Assessment"
  object$.class.[is.na(object$.class.)] <- "Buffer"

  p <- ggplot2::ggplot(data = object,
                       mapping = ggplot2::aes(color = .class., fill = .class.))
  p <- p + ggplot2::guides(
    colour = ggplot2::guide_legend("Class"),
    fill = ggplot2::guide_legend("Class")
  )
  p <- p + ggplot2::geom_sf(..., alpha = alpha)
  p + ggplot2::coord_sf()
}

#' @rdname autoplot.spatial_rset
#' @param show_grid When plotting [spatial_block_cv] objects, should the grid
#' itself be drawn on top of the data? Set to FALSE to remove the grid.
#' @export
autoplot.spatial_block_cv <- function(object, show_grid = TRUE, ..., alpha = 0.6) {
  p <- autoplot.spatial_rset(object, ..., alpha = alpha)

  if (!show_grid) return(p)

  data <- object$splits[[1]]$data

  plot_data <- data
  if (sf::st_is_longlat(data)) {
    plot_data <- sf::st_bbox(data)
    plot_data <- expand_grid(plot_data)
    plot_data <- sf::st_as_sfc(plot_data)
  }

  grid_args <- list(x = plot_data)
  grid_args$cellsize <- attr(object, "cellsize", TRUE)
  grid_args$offset <- attr(object, "offset", TRUE)
  grid_args$n <- attr(object, "n", TRUE)
  grid_args$crs <- attr(object, "crs", TRUE)
  grid_args$what <- attr(object, "what", TRUE)
  grid_args$square <- attr(object, "square", TRUE)
  grid_args$flat_topped <- attr(object, "flat_topped", TRUE)
  grid_blocks <- do.call(sf::st_make_grid, grid_args)

  if (attr(object, "relevant_only", TRUE)) {
    centroids <- sf::st_centroid(sf::st_geometry(data))
    grid_blocks <- filter_grid_blocks(grid_blocks, centroids)
  }

  # Always prints with "Coordinate system already present. Adding new coordinate system, which will replace the existing one."
  # So this silences that
  suppressMessages(p + ggplot2::geom_sf(data = grid_blocks, fill = NA))

}
