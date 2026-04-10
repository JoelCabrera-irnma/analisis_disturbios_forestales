library(ggplot2)
library(dplyr)
library(lubridate)
library(plotly)
library(dbscan)

# Corregimos fechas de la lista Completa de los 86 disturbios detectados en total por bfast
lista_disturb_full_fecha_correg <- df_comb_ordenado %>%
  mutate(date = date + days(48) )

# Extraemos el vector de  fechas
fechasV <- lista_disturb_full_fecha_correg$date

# Convertimos las fechas a números (días desde una referencia)
dias <- as.numeric(fechasV - min(fechasV))

# Aplicamos k-means (por ejemplo, 8 grupos)
k <- 8
clustering <- kmeans(dias, centers = k)

# DBSCAN requiere matriz, no vector
res <- dbscan(as.matrix(dias), eps =35,minPts = 3)  # eps define cuán cerca deben estar

# Agregamos los grupos a los datos
fsdfd <- data.frame(Parcela = lista_disturb_full_fecha_correg$parcela_ID,Fecha = fechasV, Grupo = res$cluster)

# Asegurarse de que Grupo sea un factor para colores distintos
fsdfd$Grupo <- as.factor(fsdfd$Grupo)

# Grafico de puntos
ggplot(fsdfd, aes(x = Fecha, y = 1, color = Grupo)) +
  geom_point(size = 4) +
  scale_y_continuous(breaks = NULL) +
  labs(
    title = "Fechas agrupadas por cercanía",
    x = "Fecha",
    y = ""
  ) +
  theme_minimal()

# Grafico de Lineas
asdasd <- fsdfd[order(fsdfd$Grupo, fsdfd$Fecha), ]
asdasd$ID <- seq_along(asdasd$Fecha)


ggplot(asdasd, aes(x = Fecha, y = Grupo, group = Grupo, color = Grupo)) +
  geom_point(size = 3) +
  geom_line() +
  labs(title = "Agrupamiento de fechas en clases temporales", x = "Fecha", y = "Grupo") +
  theme_minimal()

# Grafico de Gantt
# Calcular rango de fechas por grupo
rangos <- fsdfd %>%
  group_by(Grupo) %>%
  summarise(Inicio = min(Fecha), Fin = max(Fecha))

ggplot(rangos, aes(y = Grupo)) +
  geom_segment(aes(x = Inicio, xend = Fin, yend = Grupo), color = "steelblue", size = 4) +
  labs(title = "Rango de fechas por grupo", x = "Fecha", y = "Grupo") +
  theme_minimal()

# GRAFICO INTERACTIVO DE PUNTOS
# Crear el gráfico base con ggplot2
p <- ggplot(fsdfd, aes(x = Fecha, y = Grupo, color = Grupo,
                       text = paste("Parcela:", Parcela, "<br>Fecha:", Fecha))) +
  geom_point(size = 3) +
  labs(title = "Fechas agrupadas por cercanía",
       x = "Fecha", y = "Grupo") +
  theme_minimal()

# Convertirlo en gráfico interactivo con plotly
ggplotly(p, tooltip = "text")
