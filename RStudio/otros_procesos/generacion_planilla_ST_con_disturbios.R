print(MODIS_EVI_TimeSeries_Multiple_Points)
str(MODIS_EVI_TimeSeries_Multiple_Points)

MODIS_EVI_TimeSeries_Multiple_Points$date <- as.Date(MODIS_EVI_TimeSeries_Multiple_Points$date)

EVI_filtrado <- MODIS_EVI_TimeSeries_Multiple_Points %>%
  filter(date >= as.Date("2000-09-29")) %>%
  filter(parcela_ID %in% Libro1$puntos)

print(EVI_filtrado)
# Generar Excel
write.xlsx(EVI_filtrado, "EVI_filtrado.xlsx")

