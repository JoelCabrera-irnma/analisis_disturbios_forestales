library(dplyr)
library(ggplot2)
library(lubridate)
library(RColorBrewer)

# Configuración inicial
parcela_seleccionada <- "93"

# DEFINIR AÑOS A VISUALIZAR - Puedes modificar esta lista fácilmente
anos_interes <- c(2010, 2011, 2012)  # Añade o quita años según necesites

# Opcional: definir etiquetas personalizadas para cada año


# Si no defines etiquetas personalizadas, usa solo el año
if(length(etiquetas_anos) == 0 || !all(as.character(anos_interes) %in% names(etiquetas_anos))) {
  etiquetas_anos <- setNames(as.character(anos_interes), as.character(anos_interes))
}

# Filtrar datos de la parcela seleccionada
parcela_X <- MODIS_EVI_TimeSeries_Multiple_Points %>%
  filter(parcela_ID == parcela_seleccionada) %>%
  mutate(Date = date)

# 1. Calcular valores medios históricos (excluyendo años de interés para análisis más robusto)
valores_medios <- parcela_X %>%
  filter(!year(Date) %in% anos_interes) %>%  # Excluir años de interés del cálculo histórico
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

# 2. Filtrar datos de años de interés
serie_comparativa <- parcela_X %>%
  filter(year(Date) %in% anos_interes) %>%
  mutate(
    Year = year(Date),
    Date2001 = as.Date(paste0("2001-", format(Date, "%m-%d"))),
    Periodo16d = ceiling(yday(Date2001)/16),
    Year_label = etiquetas_anos[as.character(Year)]
  ) %>%
  left_join(valores_medios, by = "Periodo16d")

# 3. Generar paleta de colores automática
n_anos <- length(anos_interes)
if(n_anos <= 3) {
  colores_anos <- c("#F8766D", "#00BFC4", "#7CAE00")[1:n_anos]
} else if(n_anos <= 8) {
  colores_anos <- brewer.pal(max(3, n_anos), "Set2")
} else {
  colores_anos <- rainbow(n_anos)
}

# Crear vector de colores nombrado
colores_finales <- c("Media Histórica" = "black")
names(colores_anos) <- unique(serie_comparativa$Year_label)
colores_finales <- c(colores_finales, colores_anos)

# 4. Definir formas automáticas para los puntos
formas_puntos <- c(15, 16, 17, 18, 19, 3, 4, 8)[1:n_anos]  # Diferentes formas
names(formas_puntos) <- anos_interes

# 5. Crear gráfico dinámico
p <- ggplot() +
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
            linewidth = 1.2, linetype = "solid")

# Añadir líneas y puntos para cada año dinámicamente
for(ano in anos_interes) {
  datos_ano <- filter(serie_comparativa, Year == ano)
  etiqueta_ano <- unique(datos_ano$Year_label)
  
  p <- p +
    geom_line(data = datos_ano,
              aes(x = Date2001, y = EVI,
                  color = etiqueta_ano),
              linewidth = 0.8) +
    geom_point(data = datos_ano,
               aes(x = Date2001, y = EVI,
                   color = etiqueta_ano),
               size = 3, shape = formas_puntos[as.character(ano)])
}

# Completar el gráfico
p <- p +
  scale_x_date(date_labels = "%b", date_breaks = "1 month", 
               limits = c(as.Date("2001-01-01"), as.Date("2001-12-31"))) +
  scale_color_manual(values = colores_finales) + 
  labs(title = paste0("Comparación EVI Multi-Anual vs Media Histórica - Parcela ", parcela_seleccionada),
       subtitle = paste0("Años analizados: ", paste(anos_interes, collapse = ", "), 
                         " | Área gris: ±1 SD media histórica"),
       x = "Mes", y = "Valor EVI",
       color = "Leyenda") +
  theme_minimal() +
  theme(legend.position = "top",
        panel.grid.minor = element_blank(),
        plot.subtitle = element_text(size = 9),
        legend.text = element_text(size = 8))

# Mostrar el gráfico
print(p)

# FUNCIÓN ALTERNATIVA PARA MAYOR FLEXIBILIDAD
crear_grafico_evi_multianos <- function(parcela_id, anos_interes, etiquetas_personalizadas = NULL, 
                                        excluir_anos_de_historico = TRUE) {
  
  # Si no se proporcionan etiquetas, usar solo los años
  if(is.null(etiquetas_personalizadas)) {
    etiquetas_personalizadas <- setNames(as.character(anos_interes), as.character(anos_interes))
  }
  
  # Filtrar datos de la parcela
  parcela_X <- MODIS_EVI_TimeSeries_Multiple_Points %>%
    filter(parcela_ID == parcela_id) %>%
    mutate(Date = date)
  
  # Calcular media histórica
  if(excluir_anos_de_historico) {
    datos_historicos <- filter(parcela_X, !year(Date) %in% anos_interes)
  } else {
    datos_historicos <- parcela_X
  }
  
  valores_medios <- datos_historicos %>%
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
  
  # Preparar datos de años de interés
  serie_comparativa <- parcela_X %>%
    filter(year(Date) %in% anos_interes) %>%
    mutate(
      Year = year(Date),
      Date2001 = as.Date(paste0("2001-", format(Date, "%m-%d"))),
      Periodo16d = ceiling(yday(Date2001)/16),
      Year_label = etiquetas_personalizadas[as.character(Year)]
    ) %>%
    left_join(valores_medios, by = "Periodo16d")
  
  # Generar colores y formas
  n_anos <- length(anos_interes)
  if(n_anos <= 8) {
    colores_anos <- brewer.pal(max(3, n_anos), "Set2")
  } else {
    colores_anos <- rainbow(n_anos)
  }
  
  colores_finales <- c("Media Histórica" = "black")
  names(colores_anos) <- unique(serie_comparativa$Year_label)
  colores_finales <- c(colores_finales, colores_anos)
  
  formas_puntos <- c(15, 16, 17, 18, 19, 3, 4, 8, 10, 11, 12, 13)[1:n_anos]
  names(formas_puntos) <- anos_interes
  
  # Crear gráfico
  p <- ggplot() +
    geom_ribbon(data = valores_medios,
                aes(x = Date_representativa, 
                    ymin = EVI_mean - EVI_sd,
                    ymax = EVI_mean + EVI_sd),
                fill = "gray80", alpha = 0.4) +
    geom_line(data = valores_medios,
              aes(x = Date_representativa, y = EVI_mean,
                  color = "Media Histórica"),
              linewidth = 1.2, linetype = "solid")
  
  for(ano in anos_interes) {
    datos_ano <- filter(serie_comparativa, Year == ano)
    etiqueta_ano <- unique(datos_ano$Year_label)
    
    p <- p +
      geom_line(data = datos_ano,
                aes(x = Date2001, y = EVI, color = etiqueta_ano),
                linewidth = 0.8) +
      geom_point(data = datos_ano,
                 aes(x = Date2001, y = EVI, color = etiqueta_ano),
                 size = 3, shape = formas_puntos[as.character(ano)])
  }
  
  p <- p +
    scale_x_date(date_labels = "%b", date_breaks = "1 month", 
                 limits = c(as.Date("2001-01-01"), as.Date("2001-12-31"))) +
    scale_color_manual(values = colores_finales) + 
    labs(title = paste0("Comparación EVI Multi-Anual vs Media Histórica - Parcela ", parcela_id),
         subtitle = paste0("Años: ", paste(anos_interes, collapse = ", "), 
                           " | Área gris: ±1 SD media histórica"),
         x = "Mes", y = "Valor EVI", color = "Leyenda") +
    theme_minimal() +
    theme(legend.position = "top", panel.grid.minor = element_blank(),
          plot.subtitle = element_text(size = 9), legend.text = element_text(size = 8))
  
  return(p)
}

# EJEMPLOS DE USO DE LA FUNCIÓN:

# Ejemplo 1: Años básicos sin etiquetas personalizadas
# grafico1 <- crear_grafico_evi_multianos("93", c(2008, 2012, 2015))

# Ejemplo 2: Con etiquetas personalizadas
# etiquetas_custom <- c("2008" = "Pre-Disturbio", "2012" = "Disturbio", 
#                      "2015" = "Recuperación", "2018" = "Post-Recuperación")
# grafico2 <- crear_grafico_evi_multianos("93", c(2008, 2012, 2015, 2018), etiquetas_custom)

# Ejemplo 3: Incluyendo años de interés en el cálculo histórico
# grafico3 <- crear_grafico_evi_multianos("93", c(2008, 2012), excluir_anos_de_historico = FALSE)