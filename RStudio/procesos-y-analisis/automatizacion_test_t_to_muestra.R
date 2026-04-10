library(purrr)
library(lubridate)
library(dplyr)
library(openxlsx)

str(EVI_n40_desestacion)

# 1. Convertir a formato fecha
EVI_desest <- EVI_n40_desestacion %>%
  mutate(date = dmy(date))

# 2. Definir funcion para automatizar proceso de calculo de prueba t (medias) y F (varianzas) 
resultEstadisticos <- function(fecha_disturb, UM) {
  
  # 1 CALCULAR LIMITER SUPERIOR E INFERIOR. UMBRAL DE 2 AÑOS
  lim_inferior <- fecha_disturb - years(2)
  lim_superior <- fecha_disturb + years(2)
  
  # 2 SUBFILTRAR POR PARCELA ANALIZADA
  st_subfiltrado <- EVI_desest %>% filter(parcela_ID == UM)
  
  # 3 OBTENER MUESTRAS DE EVI ANTERIOR Y POSTERIOR A FECHA DISTURBIO
  datos_muestra_Prev <- st_subfiltrado %>%
    filter(between(date, lim_inferior, fecha_disturb)) %>%
    pull(EVI_desestacio)
  
  datos_muestra_Post <- st_subfiltrado %>%
    filter(between(date, fecha_disturb, lim_superior)) %>%
    pull(EVI_desestacio)
  
  # 5 PARA VARIANZAS, EMPLEAMOS F DE IGUALDAD DE VARIANZAS !! Verificar si se aplica alas varianzas o a los coeficientes de variacion
  result_pruebaF <- var.test(datos_muestra_Prev,datos_muestra_Post)
  
  # 6 PARA LAS MEDIAS, VERIFICAR NORMALIDAD DE LOS DATOS
  m_anterior_test <- shapiro.test(datos_muestra_Prev)$p.value > 0.05
  m_posterior_test <- shapiro.test(datos_muestra_Post)$p.value > 0.05
  
  if(m_anterior_test & m_posterior_test) {
    result_prueba_t <- t.test(datos_muestra_Prev,datos_muestra_Post)$p.value
    result_prueba_W <- NA
    result_prueba_media <- t.test(datos_muestra_Prev,datos_muestra_Post)
  } else {
    result_prueba_W <- wilcox.test(datos_muestra_Prev,datos_muestra_Post)$p.value
    result_prueba_t <- NA
    result_prueba_media <-  wilcox.test(datos_muestra_Prev,datos_muestra_Post)
  }
  
  # 8 CALCULO DE MEDIAS Y CV
  media_prev <- mean(datos_muestra_Prev)
  media_post <- mean(datos_muestra_Post)
  print(UM)
  cat("valor media prev", media_prev,"\n")
  cv_prev <- sd(datos_muestra_Prev)/media_prev
  cv_post <- sd(datos_muestra_Post)/media_post
  
  # 9 SI LAS DIFERENCIAS SON SIGNIFICATIVAS EN LAS MEDIAS Y/O VARIANZAS
  if(result_prueba_media$p.value < 0.05) {
    diff_medias <- ((media_post  - media_prev) * 100)/media_prev
  } else {
    diff_medias <- NA
  }
  
  if(result_pruebaF$p.value < 0.05){
    diff_CV <- ((cv_post - cv_prev)*100)/cv_prev
  } else {
    diff_CV <- NA
  }
  
  # Falta Averiguar para el caso de la varianza, si empleamos el CV o las varianzas o desvio st
  
  return(list(
              media_prev,media_post,cv_prev,cv_post,
              result_pruebaF$p.value,
              result_prueba_t,
              result_prueba_W,
              diff_medias,
              diff_CV
              ))
}

# 3. Aplicar a cada una de las muestras de parcelas n=40
resultados_est_final <-  map2(
  muestra_disturbios40$date,
  muestra_disturbios40$parcela_ID,
  resultEstadisticos
)

# 4. Convertir a dataframe
resultados_test_df <- tibble(
  parcela_ID = muestra_disturbios40$parcela_ID,
  fecha_disturbio = muestra_disturbios40$date
) %>%
  mutate(
    resultados = resultados_est_final
  ) %>%
  mutate(
    media_prev = map_dbl(resultados, ~ ifelse(is.null(.x), NA, .x[[1]])),
    media_post = map_dbl(resultados, ~ ifelse(is.null(.x), NA, .x[[2]])),
    cv_prev = map_dbl(resultados, ~ ifelse(is.null(.x), NA, .x[[3]])),
    cv_post = map_dbl(resultados, ~ ifelse(is.null(.x), NA, .x[[4]])),
    valor_p_F = map_dbl(resultados, ~ ifelse(is.null(.x), NA, .x[[5]])),
    valor_p_t = map_dbl(resultados, ~ ifelse(is.null(.x), NA, .x[[6]])),
    valor_p_W = map_dbl(resultados, ~ ifelse(is.null(.x), NA, .x[[7]])),
    dif_medias = map_dbl(resultados, ~ ifelse(is.null(.x), NA, .x[[8]])),
    dif_CV = map_dbl(resultados, ~ ifelse(is.null(.x), NA, .x[[9]]))
  ) %>%
  select(-resultados)

# IMPRIMIR EN EXCEL
write.xlsx(resultados_test_df, "borrame_despues_leer.xlsx")


