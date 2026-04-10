procesar_observacion <- function(observacion, bfast_data) {
  tryCatch({
    # Extraer componente de tendencia
    niter <- length(bfast_data$output)
    trend <- bfast_data$output[[niter]]$Tt
    
    # Extraer fechas de quiebre
    breakpoints <- bfast_data$output[[niter]]$bp.Vt$breakpoints
    
    if(is.null(breakpoints) || length(breakpoints) == 0) {
      return(list(observacion = observacion, status = "sin_breakpoints"))
    }
    
    # Calcular magnitudes
    magnitudes <- sapply(breakpoints, function(bp) {
      start_before <- max(1, bp - 12)
      end_before <- max(1, bp - 1)
      start_after <- min(length(trend), bp + 1)
      end_after <- min(length(trend), bp + 12)
      
      if (end_before >= start_before && end_after >= start_after) {
        before <- mean(trend[start_before:end_before], na.rm = TRUE)
        after <- mean(trend[start_after:end_after], na.rm = TRUE)
        return(after - before)
      } else {
        return(NA)
      }
    })
    
    return(list(
      observacion = observacion,
      trend = trend,
      breakpoints = breakpoints,
      magnitudes = magnitudes,
      status = "exitoso"
    ))
    
  }, error = function(e) {
    return(list(
      observacion = observacion,
      error = e$message,
      status = "error"
    ))
  })
}

# Aplicar a todos los elementos
resultados_completos <- lapply(names(bfast_results_full), function(obs) {
  procesar_observacion(obs, bfast_results_full[[obs]])
})
names(resultados_completos) <- names(bfast_results_full)