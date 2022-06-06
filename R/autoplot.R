#' Create a ggplot for spatial resamples.
#'
#' This method provides a good visualization method for spatial resampling.
#'
#' @param object A `spatial_rset` object or a `spatial_rsplit` object.
#' Note that only resamples made from
#' `sf` objects create `spatial_rset` and `spatial_rsplit` objects;
#' this function will not work for
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
#' @rdname autoplot.spatial_rset
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

#' @export
autoplot.spatial_rsplit <- function(object, ...) {
  # .Class. is named to not interfere with normal column names
  .Class. <- NULL

  ins <- object$in_id
  outs <- if (identical(object$out_id, NA)) {
    rsample::complement(object)
  } else {
    object$out_id
  }
  object <- object$data
  object$.Class. <- NA
  object$.Class.[ins] <- "Analysis"
  object$.Class.[outs] <- "Assessment"
  object$.Class.[is.na(object$.Class.)] <- "Buffer"

  p <- ggplot2::ggplot(data = object,
                       mapping = ggplot2::aes(color = .Class., fill = .Class.))
  p <- p + ggplot2::scale_fill_discrete(name = "Class")
  p <- p + ggplot2::scale_color_discrete(name = "Class")
  p <- p + ggplot2::geom_sf(...)
  p + ggplot2::coord_sf()

}

#' @rdname autoplot.spatial_rset
#' @param show_grid When plotting [spatial_block_cv] objects, should the grid
#' itself be drawn on top of the data? Set to FALSE to remove the grid.
#' @export
autoplot.spatial_block_cv <- function(object, show_grid = TRUE, ...) {
  p <- autoplot.spatial_rset(object, ...)

  if (!show_grid) return(p)

  data <- object$splits[[1]]$data
  grid_args <- list(x = data)
  grid_args$cellsize <- attr(object, "cellsize", TRUE)
  grid_args$offset <- attr(object, "offset", TRUE)
  grid_args$n <- attr(object, "n", TRUE)
  grid_args$crs <- attr(object, "crs", TRUE)
  grid_args$what <- attr(object, "what", TRUE)
  grid_args$square <- attr(object, "square", TRUE)
  grid_args$flat_topped <- attr(object, "flat_topped", TRUE)
  grid_blocks <- do.call(sf::st_make_grid, grid_args)

  if (attr(object, "relevant_only", TRUE)) {
    grid_blocks <- filter_grid_blocks(grid_blocks, data)
  }

  # Always prints with "Coordinate system already present. Adding new coordinate system, which will replace the existing one."
  # So this silences that
  suppressMessages(p + ggplot2::geom_sf(data = grid_blocks, fill = NA))

}
