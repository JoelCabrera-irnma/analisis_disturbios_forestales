# CORRECION FECHAS PARA EL TOTAL DE DISTURBIOS
fechas_correg_df_disturbios <- df_combinado %>%
  mutate(date = as.Date(date)  + days(48))

# CONTEO DE FECHAS ENTRE MESES JUNIO A SEPTIEMBRE
conteo_dist_inverno <- fechas_correg_df_disturbios %>%
  summarise(conteo = sum(month(date) >= 6 & month(date) <= 9))

print(conteo_dist_inverno) # 35 en total

# CONTEO DE FECHAS ENTRE MESES DICIEMBRE A MARZO
conteo_dist_verano <- fechas_correg_df_disturbios %>%
  summarise(conteo = sum(month(date) %in% c(12, 1, 2, 3)))

print(conteo_dist_verano)

# Función personalizada según las nuevas estaciones
estaciones_rangos <- function(mes) {
  case_when(
    mes %in% c(1, 2, 3)   ~ "Verano",
    mes %in% c(4, 5, 6)   ~ "Otoño",
    mes %in% c(7, 8, 9)   ~ "Invierno",
    mes %in% c(10, 11, 12) ~ "Primavera"
  )
}

# MODIFICACION descontando parcelas en Zonas de cultivo
parcelas_a_eliminar <- c(167, 200, 143, "170-N", 144, 119, 145, "172-N", 146, 121, 122, 123, 148, 149, 175, "170-S", 99)

PQ_soloBosque_fechas_correg <- subset(fechas_correg_df_disturbios, !parcela_ID %in% parcelas_a_eliminar)

# Agregar columna de estación y contar registros
conteo_disturb_estaciones <- PQ_soloBosque_fechas_correg %>%
  mutate(estacion = estaciones_rangos(month(date))) %>%
  count(estacion)

print(conteo_disturb_estaciones)
