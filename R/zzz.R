.onLoad <- function(libname, pkgname) {
  vctrs::s3_register("ggplot2::autoplot", "spatial_rset")
}
