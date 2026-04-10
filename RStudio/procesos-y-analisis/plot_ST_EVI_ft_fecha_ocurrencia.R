library(ggplot2)
library(plotly)

parcela_UM <-93
fecha_ruptura <- as.Date('2010-06-26')

#Seleccion de la Parcela
parcela = MODIS_EVI_TimeSeries_Multiple_Points %>%
  filter(parcela_ID == parcela_UM)
tail(parcela)
  
# Agregar dos líneas verticales en fechas especificas para la ST del NDVI
parcela$date <- as.Date(parcela$date, format = "%Y-%m-%d")
plot(parcela$date, parcela$EVI, type = "l", col = "blue",
     xlab = "Fecha", ylab = "EVI", main = paste("EVI de parcela", parcela_UM) )
abline(v = fecha_ruptura, col = "red", lty = 2, lwd = 1)

# Grafico normal
p <- ggplot(parcela, aes(x = date, y = EVI)) +
  geom_line(color = "blue") +
  geom_vline(xintercept = as.numeric(fecha_ruptura), linetype = "dashed", color = "red") +
  labs(title = paste("EVI de parcela", parcela_UM),
       x = "Fecha", y = "EVI")
# Grafico interactivo
ggplotly(p)

# Grafico de datos de APPEARS
xValue <- MODIS_EVI_TS_APPEARS %>%
  filter(ID == 93) %>%
  mutate(Date = as.Date(Date)) %>%
  select(Date ,MOD13Q1_061__250m_16_days_EVI)

qp <- ggplot(xValue, aes(x =Date, y=MOD13Q1_061__250m_16_days_EVI)) +
  geom_line(color = "blue") +
  geom_vline(xintercept = as.numeric(fecha_ruptura), linetype = "dashed", color = "red") +
  labs(title = paste("EVI de parcela", parcela_UM),
       x = "Fecha", y = "EVI")
# Grafico interactivo
ggplotly(qp)


# Analisis de EVI fechas especificas 
filtradoFechaEsp <- parcela %>%
  filter(
    month(date) == 7,      # Mes 2 (febrero)
    day(date) %in% 11:13,        # Día 18
    year(date) %in% 2000:2024  # Rango de años
  )
print(filtradoFechaEsp)
filter(filtradoFechaEsp,date=='2006-07-12') %>% pull(EVI) - mean(filtradoFechaEsp$EVI) 
