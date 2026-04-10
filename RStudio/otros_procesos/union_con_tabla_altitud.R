Tabla_Final_Disturbios_Alt <- Tabla_Final_Disturbios %>%
  inner_join(coordenadas.XY.parcelas_Altitud, by = c("Parcela"="parcela_ID")) %>%
  select(ID, Parcela, Fecha, longitud = longitud.x, latitud=latitud.y, altitud = Altitud1)

write.xlsx(Tabla_Final_Disturbios_Alt, "Tabla_Final_Disturbios_Altitud.xlsx")
