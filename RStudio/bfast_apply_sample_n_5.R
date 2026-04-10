attach(sample_5_MODIS_NDVI_TimeSeries_Multiple_Points)
st_5_parcelas <- sample_5_MODIS_NDVI_TimeSeries_Multiple_Points

resultados <- numeric(0)  # Variable vacía

# Dividir los datos por la columna Name
split_data <- split(st_5_parcelas, st_5_parcelas$Name)

# Funcion para aplicar bfast a cada grupo
apply_bfast <- function(data) {
  # Crear la serie temporal
  ts_data <- ts(data$NDVI, start = c(2000, 1), frequency = 23)
  
  # Aplicar bfast
  bfast_result <- bfast(ts_data, h = 0.16, season = "dummy", max.iter = 100)
  
  # Extraer bp.Vt
  bp_Vt <- bfast_result$output[[1]]$bp.Vt
  
  # Verificar si es una lista válida con breakpoints
  if (!is.null(bp_Vt) && is.list(bp_Vt) && "breakpoints" %in% names(bp_Vt)) {
    breakpoints <- bp_Vt$breakpoints
  } else {
    breakpoints <- NA
  }
  
  print(breakpoints)  # Para depuración
  return(list(bfast_result = bfast_result, breakpoints = breakpoints))
}



# Aplicar la funcion a cada grupo
bfast_results <- lapply(split_data, apply_bfast)

# Ver los resultados
bfast_results

#Extraer solo los breakpoints
breakpoints_list <- lapply(bfast_results, function(x) x$breakpoints)

print(breakpoints_list)


