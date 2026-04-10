library(bfast)
attach(MODIS_EVI_TimeSeries_Multiple_Points)
attach(st_all_parcelas_indx)
nrow(MODIS_EVI_TimeSeries_Multiple_Points)

# Dividir los datos por la columna "Name"
split_data <- split(MODIS_EVI_TimeSeries_Multiple_Points, MODIS_EVI_TimeSeries_Multiple_Points$parcela_ID)

# Funcion para aplicar bfast a cada grupo
apply_bfast_magnitud <- function(data) {
  # Crear la serie temporal
  ts_data <- ts(data$EVI, start = c(2000, 1), frequency = 23)
  
  # Aplicar bfast
  bfast_result <- bfast(ts_data, h = 0.16, season = "dummy", max.iter = 100)
  
  # Para depuración
  print(bfast_result$Time)
  
  # Extraer tiempo del punto de ruptura y su magnitud (solo el de mayor valor)
  breakp <- bfast_result$Time
  magnit <- bfast_result$Magnitude
  
  return(data.frame(Name = unique(data$parcela_ID), Breakpoints = breakp, Magnitude = magnit ) )
}


# Aplicar la funcion a cada grupo
bfast_results_magn <- lapply(split_data, apply_bfast_magnitud)
print("Proceso finalizado")

# Unir los resultados en un solo data frame
bfast_magnitudes_df <- do.call(rbind, bfast_results_magn)

# Mostrar los resultados
print(bfast_magnitudes_df)

# SEGUNDA PARTE DEL PROCESAMIENTO DE ANALISIS
# OBJETIVO: UNIR TABLAS DE SERIES TEMPORALES CON LOS BREAKPOINTS

# Unir los dataframes donde coincidan Name y Breakpoints = subindice
df_merged <- merge(bfast_magnitudes_df, st_all_parcelas_indx, by.x = c("Name", "Breakpoints"), by.y = c("parcela_ID", "subindice"))

# Mostrar el resultado
print(df_merged)


