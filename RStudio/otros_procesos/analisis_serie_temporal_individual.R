# ELABORACION DE PLOTS COMPARATIVOS DE SERIES TEMPORALES
library(lubridate)
library(dplyr)
library(ggplot2)

# EJEMPLO PARCELA 93
# VALOR MEDIO Y MEDIANA ANUAL DE EVI
# Crear una columna de año
xValue_anual <- xValue %>%
  mutate(Year = year(Date)) %>%
  group_by(Year) %>%
  summarise(
    EVI_mean = mean(MOD13Q1_061__250m_16_days_EVI, na.rm = TRUE),
    EVI_median = median(MOD13Q1_061__250m_16_days_EVI, na.rm = TRUE),
    EVI_sd = sd(MOD13Q1_061__250m_16_days_EVI, na.rm = TRUE),
    n = n()
  )

# Ver resultados
print(xValue_anual)

# Gráfico básico
plot(xValue_anual$Year, xValue_anual$EVI_median, type = "o", 
     xlab = "Año", ylab = "EVI mediana anual",
     main = "Evolución del EVI mediana anual")

xValue %>%
  mutate(Year = year(Date)) %>%
  filter(Year == 2001) %>%
  pull(Date)

# EXTREAR VALORES MEDIOS POR FECHA (CADA 16 DIAS DE MODIS)
# 1. Crear referencia de períodos basada en 2001 (no bisiesto)
ref_periods <- data.frame(
  Periodo16d = 1:23,
  StartDate = seq(as.Date("2001-01-01"), by = 16, length.out = 23)
)

# 2. Asignar cada observación al período más cercano
xValue_periodos <- xValue %>%
  mutate(
    Date2001 = as.Date(paste0("2001-", format(Date, "%m-%d"))),
    # Encontrar el período más cercano
    Periodo16d = sapply(Date2001, function(d) which.min(abs(d - ref_periods$StartDate)))
  ) %>%
  group_by(Periodo16d) %>%
  summarise(
    EVI_mean = mean(MOD13Q1_061__250m_16_days_EVI, na.rm = TRUE),
    Date_representativa = first(ref_periods$StartDate[Periodo16d]),
    n_obs = n(),
    .groups = 'drop'
  )

# 3. Visualización
ggplot(xValue_periodos, aes(x = Date_representativa, y = EVI_mean)) +
  geom_line() +
  geom_point(aes(size = n_obs), color = "blue") +
  scale_x_date(date_labels = "%b-%d", date_breaks = "1 month") +
  labs(title = "EVI promedio por período de 16 días",
       subtitle = "Ajustado para variaciones entre años bisiestos",
       x = "Fecha representativa", 
       y = "EVI medio") +
  theme_minimal()

# COMPARATIVO

# Calcular valores medios por período (como antes)
valores_medios <- xValue %>%
  mutate(
      Date2001 = as.Date(paste0("2001-", format(Date, "%m-%d"))),
      Periodo16d = ceiling(yday(Date2001)/16)) %>%
  group_by(Periodo16d) %>%
  summarise(
        EVI_mean = mean(MOD13Q1_061__250m_16_days_EVI, na.rm = TRUE),
        Date_representativa = first(Date2001),
        .groups = 'drop')
    
# Filtrar datos de 2010
serie_2010 <- xValue %>%
  filter(year(Date) == 2010) %>%
  mutate(
    Date2001 = as.Date(paste0("2001-", format(Date, "%m-%d"))),
    Periodo16d = ceiling(yday(Date2001)/16)
    ) %>%
  left_join(valores_medios, by = "Periodo16d")

# VISUALIZAR 1
ggplot() +
# Línea de valores medios históricos
geom_line(data = valores_medios, 
          aes(x = Date_representativa, y = EVI_mean, 
              color = "Media Histórica"),
          linewidth = 1.2) +

# Puntos y línea para 2010
geom_line(data = serie_2010, 
          aes(x = Date2001, y = MOD13Q1_061__250m_16_days_EVI,
              color = "Año 2010"),
          linetype = "dashed") +
geom_point(data = serie_2010, 
           aes(x = Date2001, y = MOD13Q1_061__250m_16_days_EVI,
               color = "Año 2010"),
           size = 3) +

# Etiquetas de puntos (opcional)
geom_text(data = serie_2010, 
          aes(x = Date2001, y = MOD13Q1_061__250m_16_days_EVI,
              label = format(Date, "%b-%d")),
          vjust = -1, size = 3, check_overlap = TRUE) +

# Configuración del gráfico
scale_x_date(date_labels = "%b", date_breaks = "1 month") +
scale_color_manual(values = c("Media Histórica" = "darkblue", 
                              "Año 2010" = "red")) +
labs(title = "Comparación: Serie Temporal 2010 vs Media Histórica",
     x = "Mes", y = "EVI",
     color = "Serie") +
theme_minimal() +
theme(legend.position = "top")

# VISUALIZAR 2
# Si quieres comparar 2010 con otros años específicos
xValue %>%
  mutate(Year = year(Date),
         Date2001 = as.Date(paste0("2001-", format(Date, "%m-%d")))) %>%
           filter(Year %in% c(2010, 2008)) %>% # Selecciona años a comparar
           ggplot(aes(x = Date2001, y = MOD13Q1_061__250m_16_days_EVI, color = factor(Year))) +
           geom_line() +
           geom_point() +
           scale_x_date(date_labels = "%b", date_breaks = "1 month") +
           labs(title = "Comparación de Series Temporales",
                x = "Mes", y = "EVI") +
           theme_minimal()