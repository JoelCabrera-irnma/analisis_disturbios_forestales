
attach(MODIS_EVI_TS_APPEARS)
nrow(MODIS_EVI_TS_APPEARS)

ST_appEars <- MODIS_EVI_TS_APPEARS %>%
  select(ID,MOD13Q1_061__250m_16_days_EVI)
str(ST_appEars)

# Dividir los datos por la columna "Name"
split_data2 <- split(ST_appEars, ST_appEars$ID)

# Funcion para aplicar bfast a cada grupo
apply_bfast2 <- function(data) {
  # Crear la serie temporal
  ts_data <- ts(data$MOD13Q1_061__250m_16_days_EVI, start = c(2000, 1), frequency = 23)
  
  
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
  return(list( breakpoints = breakpoints )) 
}

# Aplicar la funcion a cada grupo
bfast_results2 <- lapply(split_data2, apply_bfast2)
print("Finalizado")

# Ver los resultados
bfast_results2
str(bfast_results2)

# Extraer solo los elementos con cambios detectados:
cambios_detectados2 <- Filter(function(x) {
  bp <- x$breakpoints
  !all(is.na(bp))  # Mantiene solo si hay al menos un valor numérico
}, bfast_results2)
print(length(cambios_detectados2)) # Imprimir numeros de cambios detectados

# Convertir la lista en un dataframe largo
df_fast2 <- tibble(
  ID = names(cambios_detectados2),
  breakpoints = lapply(cambios_detectados2, `[[`, "breakpoints")
) %>%
  unnest_longer(breakpoints)  # Expande los valores en filas separadas

# Ver resultado
print(df_fast2)

# Obtener un vector de los puntos de quiebre detectados:
breakpoints_list <- lapply(bfast_results, function(x) x$breakpoints)
breakpoints_vector <- unlist(breakpoints_list)  # Convertir en un vector
breakpoints_vector <- breakpoints_vector[!is.na(breakpoints_vector)]  # Remover NAs


