# lat long => df_parcelas (obtenido de file "procesar-coordenadas-de-parcelas.R")
attach(df_parcelas)
# df_breakpoints (obtenido de file "bfast-apply-all-parcelas_v2.R")
attach(df_breakpoints)

# Desagrupar "df_breakpoints"
df_breakpoints_ungroup <- df_breakpoints %>% ungroup()

# Unir las tablas por la columna "parcela_ID" y seleccionar columnas especificas
df_combinado2 <- df_breakpoints_ungroup %>%
  left_join(df_parcelas, by = "parcela_ID") %>%
  select(-subindice,-id,-Name)

# RESULTADO FINAL: fechas de posible disturbio (date), la parcela afectada y sus coordenadas
# Listo para Analisis Visual rapido
df_combinado$parcela_ID



