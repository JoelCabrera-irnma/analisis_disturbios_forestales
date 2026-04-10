attach(MODIS_EVI_ST_analisis)

#Seleccion de la Parcela
parcela = MODIS_EVI_TimeSeries_Multiple_Points %>%
  filter(parcela_ID == 124)
tail(parcela)

#Creacion de Serie temporal
DatosSeriesTemporal_A1 = ts(data=parcela$EVI,start=c(2000,3),frequency=23,class="ts")
tsp(DatosSeriesTemporal_A1)
print(DatosSeriesTemporal_A1)
summary(DatosSeriesTemporal_A1)

#Grafica de serie temporal
plot(DatosSeriesTemporal_A1, ylab = "NDVI", xlab="Tiempo",main='Serie Temporal')

#Bfast con distinta longitud de segmento
result <- bfast(DatosSeriesTemporal_A1,h=0.16,season="dummy",max.iter=100)
print(result)

#Grafica de los componentes de bfast (type=c(c("components", "all", "data", "seasonal", "trend", "noise"))
plot(result, main= paste("Parcela", 124))
plot(result,type='trend')

# Agregar dos líneas verticales en fechas específicas para la ST del NDVI
parcela$date <- as.Date(parcela$date, format = "%Y-%m-%d")
plot(parcela$date, parcela$EVI, type = "l", col = "yellow",
     xlab = "Fecha", ylab = "EVI", main = "EVI de parcela 201")
abline(v = as.Date("2004-01-25"), col = "red", lty = 2, lwd = 1)
abline(v = as.Date("2006-01-30"), col = "green", lty = 2, lwd = 1)
abline(v = as.Date("2005-12-03"), col = "blue", lty = 2, lwd = 1)


