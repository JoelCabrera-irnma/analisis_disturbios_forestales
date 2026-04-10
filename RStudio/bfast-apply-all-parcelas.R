attach(MODIS_EVI_TimeSeries_Multiple_Points)
nrow(MODIS_EVI_TimeSeries_Multiple_Points)
# Dividir los datos por la columna "Name"
split_data <- split(MODIS_EVI_TimeSeries_Multiple_Points, MODIS_EVI_TimeSeries_Multiple_Points$parcela_ID)

# Funcion para aplicar bfast a cada grupo
apply_bfast_full <- function(data) {
  # Crear la serie temporal
  ts_data <- ts(data$EVI, start = c(2000, 3), frequency = 23)
  
  # Aplicar bfast
  bfast_result <- bfast(ts_data, h = 0.16, season = "dummy", max.iter = 100)
  
  return(bfast_result)
}

# Aplicar la funcion a cada grupo
bfast_results_full <- lapply(split_data, apply_bfast_full)
print("Finalizado")


# Ver los resultados
bfast_results_full
str(bfast_results_full)


print(bfast_results_full[[1]])
print(names(bfast_results_full)[1])

