# Paquetes empleados
library(bfast)
library(dplyr)
library(tidyr)
# Datos de Serie Temporal (con dato de nombre de columna igual a "parcela_ID")
attach(MODIS_EVI_TimeSeries_Multiple_Points)
# Acortar el nombre a una variable mas corta
st_all_parcelas <- MODIS_EVI_TimeSeries_Multiple_Points

# 1 Dividir los datos por la columna parcela_ID (osea el nombre de los puntos de estudio)
split_data <- split(st_all_parcelas, st_all_parcelas$parcela_ID)
length(split_data)

# 2 Funcion para aplicar bfast a cada grupo (SOLO EXTRAE los valores de BREAKPOINTS)
apply_bfast <- function(data) {
  # Crear la serie temporal
  ts_data <- ts(data$EVI, start = c(2000, 1), frequency = 23)
  
  # Aplicar bfast
  bfast_result <- bfast(ts_data, h = 0.16, season = "dummy", max.iter = 100)
  
  niter <- length(bfast_result$output)
  
  # Extraer bp.Vt
  bp_Vt <- bfast_result$output[[niter]]$bp.Vt
  
  # Verificar si es una lista válida con breakpoints
  if (!is.null(bp_Vt) && is.list(bp_Vt) && "breakpoints" %in% names(bp_Vt)) {
    breakpoints <- bp_Vt$breakpoints
  } else {
    breakpoints <- NA
  }
  
  print(breakpoints)  # Para depuración
  return(breakpoints)
}

# 3 Aplicar la funcion BFAST a cada grupo
bfast_results <- lapply(split_data, apply_bfast)
print("Proceso Terminado")


# 4 Convertir la lista en un data frame
df <- data.frame(
  Nombre = rep(names(bfast_results), lengths(bfast_results)),  # Repetir nombres según la longitud de cada vector
  Valor = unlist(bfast_results)  # Convertir la lista en un vector
)

# 5 Agregar subindice a la lista original con fechas (para que coincida con los puntos de ruptura de cada parcela)
st_all_parcelas_indx <- st_all_parcelas %>%
  group_by(parcela_ID) %>%
  mutate(subindice = row_number())

# 6 Union de lista original con el data frame para obtener los valores en formato fecha
df_breakpoints <- st_all_parcelas_indx %>% 
  mutate(parcela_ID = as.character(parcela_ID) ) %>%
  inner_join(df, by = c("parcela_ID" = "Nombre", "subindice" = "Valor"))

# OBTENCION DE TABLA DE LISTADO DE PUNTOS DE QUIEBRE CON SU ID DE PARCELA, FECHA ASOCIADA Y EVI
df_breakpoints

# Contabilizar distutbios
length(df_breakpoints)

# lat long => df_parcelas (archvio que contiene las coordenadas latitud y longitud) !!!!!!
# Los campos que deben tener los nombres "parcela_ID", "latitud" y "longitud"
attach(df_parcelas) 
df_parcelas <- puntos_estudio_zona_test %>%
  mutate(parcela_ID = as.character(parcela_ID))

# 7 Desagrupar "df_breakpoints"
df_breakpoints_ungroup <- df_breakpoints %>% ungroup()

# 8 Agregar latitud y longitud. Unir las tablas por la columna "parcela_ID" y seleccionar columnas especificas
df_combinado <- df_breakpoints_ungroup %>%
  left_join(df_parcelas, by = "parcela_ID") %>%
  select(parcela_ID,date,longitud,latitud)

# RESULTADO FINAL: la parcela afectada, fechas de posible disturbio (formato fecha),  y sus coordenadas
# Listo para Analisis Visual rapido
df_combinado
