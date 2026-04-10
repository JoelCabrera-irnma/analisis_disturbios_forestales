library(dplyr)
library(ggplot2)
library(lubridate)

parcela_seleccionada <- "93"
anio_con_disturb <- 2010
anio_sin_disturb <- 2008
anio_post_disturb <- 2013

parcela_X <- MODIS_EVI_TimeSeries_Multiple_Points %>%
  filter(parcela_ID == parcela_seleccionada) %>%
  mutate(Date = date)

# 1. Calcular valores medios históricos (ajustados para años bisiestos)
valores_medios <- parcela_X %>%
  mutate(
    Date2001 = as.Date(paste0("2001-", format(Date, "%m-%d"))),
    Periodo16d = ceiling(yday(Date2001)/16)
  ) %>%
  group_by(Periodo16d) %>%
  summarise(
    EVI_mean = mean(EVI, na.rm = TRUE),
    EVI_sd = sd(EVI, na.rm = TRUE),
    Date_representativa = first(Date2001),
    .groups = 'drop'
  )

# 2. Filtrar datos de año Con Disturbio y año Sin Disturbio
serie_comparativa <- parcela_X %>%
  filter(year(Date) %in% c(anio_con_disturb, anio_sin_disturb, anio_post_disturb)) %>%
  mutate(
    Year = year(Date),
    Date2001 = as.Date(paste0("2001-", format(Date, "%m-%d"))),
    Periodo16d = ceiling(yday(Date2001)/16)
  ) %>%
  left_join(valores_medios, by = "Periodo16d")


color_label_1 <- paste0("Año ", anio_con_disturb, " (Presencia Dist)")
color_label_2 <- paste0("Año ", anio_sin_disturb, " (Ausencia Dist)")
color_label_3 <- paste0("Año ", anio_post_disturb, " (Post Dist)")

# 3. Crear gráfico comparativo
ggplot() +
  # Área de variación histórica (media ± 1 SD)
  geom_ribbon(data = valores_medios,
              aes(x = Date_representativa, 
                  ymin = EVI_mean - EVI_sd,
                  ymax = EVI_mean + EVI_sd),
              fill = "gray80", alpha = 0.4) +
  
  # Línea de media histórica
  geom_line(data = valores_medios,
            aes(x = Date_representativa, y = EVI_mean,
                color = "Media Histórica"),
            linewidth = 1.2, linetype = "solid") +
  
  # Serie Año Con Disturbio
  geom_line(data = filter(serie_comparativa, Year == anio_con_disturb),
            aes(x = Date2001, y = EVI,
                color = color_label_1),
            linewidth = 0.8) +
  geom_point(data = filter(serie_comparativa, Year == anio_con_disturb),
             aes(x = Date2001, y = EVI,
                 color = color_label_1),
             size = 3, shape = 17) + 
  
  # Serie Año Sin Disturbio
  geom_line(data = filter(serie_comparativa, Year == anio_sin_disturb),
            aes(x = Date2001, y = EVI,
                color = color_label_2),
            linewidth = 0.8) +
  geom_point(data = filter(serie_comparativa, Year == anio_sin_disturb),
             aes(x = Date2001, y = EVI,
                 color = color_label_2),
             size = 3, shape = 19) +
  
  scale_y_continuous(
    limits = c(0.1, 0.8),        # Límites del eje
    breaks = seq(0.2, 0.8, 0.2)  # Subdivisiones cada 0.2 unidades
  ) +
  
  # Serie Año Post Disturbio
  # geom_line(data = filter(serie_comparativa, Year == anio_post_disturb),
  #           aes(x = Date2001, y = EVI,
  #               color = color_label_3),
  #           linewidth = 0.8) +
  # geom_point(data = filter(serie_comparativa, Year == anio_post_disturb),
  #            aes(x = Date2001, y = EVI,
  #                color = color_label_3),
  #            size = 3, shape = 19) + # Círculos para 2011
  
  # Configuración estética
  scale_x_date(date_labels = "%b", date_breaks = "1 month", 
               limits = c(as.Date("2001-01-01"), as.Date("2001-12-31"))) +
  scale_color_manual(values = c("Media Histórica" = "black",
                                "Año 2010 (Presencia Dist)" = "#F8766D",  # Rojo anaranjado #00BFC4
                                "Año 2008 (Ausencia Dist)" = "#00BFC4"  # Azul turquesa # Verde "#5CE65C"
                                #"Año 2013 (Post Dist)" = 
                               )) + 
  labs(title = paste0("Comparacion de EVI: Años 2008 y 2010 vs Media Histórica. P",parcela_seleccionada), #"Evolucion Post-disturbio y Media Histórica. P"
       subtitle = "Área gris muestra ±1 desviación estándar de la media histórica",
       x = "Mes", y = "Valor EVI",
       color = "Leyenda") +
  theme_minimal() +
  theme(legend.position = "top",
        panel.grid.minor = element_blank(),
        plot.subtitle = element_text(size = 9))

# Etiquetas de fechas (opcional)
# geom_text(data = filter(serie_comparativa, Year == anio_con_disturb),
#           aes(x = Date2001, y = EVI,
#               label = format(Date, "%b-%d")),
#           vjust = -1.2, size = 2.8, color = "#00BFC4", check_overlap = TRUE) +
# 
# geom_text(data = filter(serie_comparativa, Year == anio_sin_disturb),
#           aes(x = Date2001, y = EVI,
#               label = format(Date, "%b-%d")),
#           vjust = 1.5, size = 2.8, color = "#F8766D", check_overlap = TRUE) +