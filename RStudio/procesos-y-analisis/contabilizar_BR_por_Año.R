library(tidyr)
library(tibble)
attach(breakPoints_all_P)

# MODIFICACION descontando parcelas en Zonas de cultivo
parcelas_a_eliminar <- c(167, 200, 143, "170-N", 144, 119, 145, "172-N", 146, 121, 122, 123, 148, 149, 175, "170-S", 99)

PQ_soloBosque <- subset(breakPoints_all_P, !parcela_ID %in% parcelas_a_eliminar)

# Corregir fechas y columna año
PQ_soloBosque <- PQ_soloBosque %>%
  mutate(date = as.Date(date)  + days(48)) %>%
  mutate(year = year(date))

# Agrupar por año, contablizar y ordenar de menor a mayor
num_BR_porYear <- PQ_soloBosque %>%
  group_by(year) %>%
  summarise(num=n()) %>%
  arrange(year) %>%
  ungroup()

str(num_BR_porYear)



# Crear un tibble con todos los años de 2000 a 2024
all_years <- tibble(year = as.double(2000:2024))

# Unir con los datos originales y reemplazar NA con 0
num_BR_completo <- all_years %>%
  left_join(num_BR_porYear, by = "year") %>%
  mutate(num = replace_na(num, 0))

# Crear el gráfico de Cantidad de Disturbios por Año
ggplot(num_BR_completo, aes(x = year, y = num)) +
  geom_col(fill = "steelblue") +  # Barras con color azul
  geom_text(aes(label = num), vjust = -0.5, size = 3.5) +  # Etiquetas con valores
  theme_minimal() +  # Tema limpio
  labs(
    x = "Año",
    y = "Frecuencia"
  ) +
  scale_y_continuous(limits = c(0, max(num_BR_completo$num) * 1.1)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotar etiquetas del eje X


# OPCIONAL - EXTRA:

# Obtener listado de parcelas (UM) del Año donde hay mas posibles disturbios 
# (para el caso 2013)
listUM_año_con_masBR <- df_combinado %>% 
  mutate(year = substr(date, 1, 4)) %>%
  arrange(desc(year)) %>%
  filter (year == 2013)

# Hacer un print de Parcelas con filter: year == 2013
cat("(", paste(listUM_año_con_masBR$parcela_ID, collapse = ", "), ")", sep = "")
