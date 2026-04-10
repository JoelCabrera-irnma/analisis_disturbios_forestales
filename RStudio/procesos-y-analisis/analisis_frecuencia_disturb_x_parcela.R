#ANALISIS DE DATOS
library(dplyr)
library(lubridate)
library(ggplot2)
attach(df_breakpoints)
length(df_breakpoints$parcela_ID)

# Añadimos columna Year y ordenamos en forma descendente por Year
breakPoints_all_P <- df_breakpoints %>%
  mutate(year = substr(date, 1, 4)) %>%
  arrange(desc(year))

print(breakPoints_all_P)
View(breakPoints_all_P)

# Obtener la frecuencia de cada valor en la columna 'Name'
frecuencia_df <- as.data.frame(table(breakPoints_all_P$parcela_ID))
colnames(frecuencia_df) <- c("Parcela", "Frecuencia")

# MODIFICACION descontando parcelas en Zonas de cultivo
parcelas_a_eliminar <- c(167, 200, 143, "170-N", 144, 119, 145, "172-N", 146, 121, 122, 123, 148, 149, 175, "170-S", 99)

frecuencia_df_2 <- subset(frecuencia_df, !Parcela %in% parcelas_a_eliminar)

# Hacer un print de Parcelas con breakpoints
cat("(", paste(frecuencia_df_2$Parcela, collapse = ", "), ")", sep = "")

# Contar cuántas veces se repiten los valores de Frecuencia
conteo_frecuencia <- as.data.frame(table(frecuencia_df_2$Frecuencia))
colnames(conteo_frecuencia) <- c("Frecuencia", "Cantidad")

# Mostrar el resultado
print(conteo_frecuencia)

# Agregar el nivel "0" a la variable factor
conteo_frecuencia$Frecuencia <- factor(conteo_frecuencia$Frecuencia, levels = c("0", levels(conteo_frecuencia$Frecuencia)))

# Agregar la nueva fila con Frecuencia "0" y un valor de Cantidad
nuevo_fila <- data.frame(Frecuencia = factor("0", levels = levels(conteo_frecuencia$Frecuencia)), Cantidad = 37)

# Combinar el dataframe original con la nueva fila
conteo_frecuencia <- rbind(conteo_frecuencia, nuevo_fila)

# Crear el gráfico de barras " FRECUENCIA VS CANTIDAD "
# ggplot(conteo_frecuencia, aes(x = Frecuencia, y = Cantidad)) +
#   geom_bar(stat = "identity", fill = "skyblue", color = "black") +
#   labs(title = "Frecuencia de Posibles Disturbios", x = "N° BreakPoints/Parcela", y = "Cantidad") +
#   theme_minimal()

ggplot(conteo_frecuencia, aes(x = Frecuencia, y = Cantidad)) +
  geom_bar(stat = "identity", fill = "skyblue", color = "black", width = 0.9) +
  geom_text(aes(label = Cantidad), vjust = -0.3, size = 4) +
  labs(
    title = "Frecuencia de Posibles Disturbios",
    x = "N° Puntos Quiebre / Pixel",
    y = "Frecuencia"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(margin = margin(b = 15)),  # b = margen inferior en puntos
    axis.title.x = element_text(size = 14),  # Título del eje X más grande
    axis.title.y = element_text(size = 14)   # Título del eje Y más grande
  ) + 
  expand_limits(y = max(conteo_frecuencia$Cantidad) * 1.1)

  