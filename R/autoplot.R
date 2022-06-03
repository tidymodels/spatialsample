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
