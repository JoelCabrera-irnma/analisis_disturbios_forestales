muestra_disturbios_fech_corregidas <- muestra_disturbios_fech_corregidas %>%
  mutate(id = row_number(), parcela = parcela_ID) %>%
  select(id, parcela, date, coordenadas)
  
  
write.csv(muestra_disturbios_fech_corregidas, "muestreo_fecha_corregidas.csv", row.names = FALSE)
write.xlsx(muestra_disturbios_fech_corregidas, "muestra_disturbios_fech_corregidas.xlsx")


