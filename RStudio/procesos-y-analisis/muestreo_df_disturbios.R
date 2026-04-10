disturbios <- df_comb_ordenado %>%
  mutate(n = row_number()) %>%
  select(n, everything())

# MUESTRA 
muestra <- disturbios %>%
  slice_sample(n = 40) # NO TOCAR

# Verficacion de coincidencias con disturbios muy evidentes
vectorDist <- c(3,5,6,7,8,10,13,21,23,32,37,39,40,52,55,57,65,69,71,82,83,86) # 22 disturbios destacados

percent_coincid <- muestra %>% 
  filter(n %in% vectorDist) %>%  # Filtrar coincidencias
  summarise(
    n_coincidencias = n(),          # Contar coincidencias
    ids_coincidentes = toString(n)  # Opcional: listar IDs encontrados
  )

print(percent_coincid)

# IMPRIMIR resultados en Excel 
muestra_disturbios40 <- muestra %>%
  arrange(n) %>%
  mutate(coordenadas = paste0(
    "[", 
    sprintf("%.6f", longitud),  # Formatear longitud a 6 decimales
    ", ", 
    sprintf("%.6f", latitud),   # Formatear latitud a 6 decimales
    "]"
  )) %>%
  select(n, parcela_ID, date, coordenadas)

# Generar Excel
write.xlsx(muestra_disturbios40, "Muestreo_disturbios.xlsx")
