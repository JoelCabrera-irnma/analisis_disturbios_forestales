
observacion <- '92'
# Extraer componente de tendencia
niter <- length(bfast_results[[observacion]]$output)
trend <- bfast_results[[observacion]]$output[[niter]]$Tt

# Extraer fechas de quiebre
breakpoints <- bfast_results[[observacion]]$output[[niter]]$bp.Vt$breakpoints

# Calcular magnitudes como diferencia entre medias antes y después del quiebre
magnitudes <- sapply(breakpoints, function(bp) {
  before <- mean(trend[(bp-12):(bp-1)], na.rm = TRUE)
  after <- mean(trend[(bp+1):(bp+12)], na.rm = TRUE)
  return(after - before)
})

magnitudes


plot(bfast_results[[observacion]])
print(bfast_results[[observacion]])
