str(EVI_desest)

# 1 CARGAR LA FECHA DE DISTURBIO
fecha_disturb <- as.Date("2005-12-03")

# 2 CALCULAR LIMITER SUPERIOR E INFERIOR. UMBRAL DE 2 AÑOS
lim_inferior <- fecha_disturb - years(2)
lim_superior <- fecha_disturb + years(2)

# 3 SUBFILTRAR POR PARCELA ANALIZADA
st_subfiltrado <- EVI_desest %>%
  filter(parcela_ID == 97)

# Grafico Serie EVI Desestacionalizada
plot(x = st_subfiltrado$date, y = st_subfiltrado$EVI_desestacio,type = "l")
abline(v = lim_inferior, col = "red", lty = 2, lwd = 1)
abline(v = lim_superior, col = "green", lty = 2, lwd = 1)
abline(v = as.Date("2005-12-03"), col = "blue", lty = 2, lwd = 1)

# 4 OBTENER MUESTRAS DE EVI ANTERIOR Y POSTERIOR A FECHA DISTURBIO
muestra_st_Anterior <- st_subfiltrado %>%
  filter(between(date,lim_inferior,fecha_disturb)) %>%
  pull(EVI_desestacio)

muestra_st_Posterior <- st_subfiltrado %>%
  filter(between(date,fecha_disturb,lim_superior)) %>%
  pull(EVI_desestacio)

# 5 PARA VARIANZAS, EMPLEAMOS F DE IGUALDAD DE VARIANZAS !! Verificar si se aplica alas varianzas o a los coeficientes de variacion
print(var.test(muestra_st_Anterior,muestra_st_Posterior))
result_pruebaF <- var.test(muestra_st_Anterior,muestra_st_Posterior)

# 6 PARA LAS MEDIAS, VERIFICAR NORMALIDAD DE LOS DATOS
print(shapiro.test(muestra_st_Anterior)$p.value > 0.05)
print(shapiro.test(muestra_st_Posterior)$p.value > 0.05)

# 7.A EN CASO DE NORMALIDAD EN AMBAS MUESTRAS, USAMOS PRUEBA T DE STUDENT
result_pruebaT <- t.test(muestra_st_Anterior,muestra_st_Posterior)
print(result_pruebaT)

# 7.B EN CASO DE NO NORMALIDAD, USAMOS PRUEBA DE WILCOX
result_pruebaW <- wilcox.test(muestra_st_Anterior,muestra_st_Posterior)
print(result_pruebaW)

# 8 CALCULO DE MEDIAS Y CV
media_prev <- mean(muestra_st_Anterior)
print(media_prev)
media_post <- mean(muestra_st_Posterior)
cv_prev <- sd(muestra_st_Anterior)/media_prev
cv_post <- sd(media_post)/media_post

# 9 SI LAS DIFERENCIAS SON SIGNIFICATIVAS EN LAS MEDIAS Y/O VARIANZAS
diff_medias <- ((media_post  - media_prev) * 100)/media_prev
print(diff_medias)

# Falta Averiguar para el caso de la varianza, si empleamos el CV o las varianzas o desvio st

