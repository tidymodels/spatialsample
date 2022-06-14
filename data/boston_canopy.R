delayedAssign("boston_canopy", local({
  requireNamespace("sf", quietly = TRUE)
  spatialsample:::boston_canopy
}))
