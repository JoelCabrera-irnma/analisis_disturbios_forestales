# Cargar la librería dplyr
library(dplyr)
library(gridExtra)
library(grid)
library(lubridate)
library(openxlsx)

# Definir las fechas de corte
fecha_corte1 <- as.Date("2011-11-03")
fecha_corte2 <- as.Date("2013-03-25")
fecha_corte3 <- as.Date("2015-09-11")

# Crear la nueva columna con el formato deseado
df_comb_ord_col_extra <- df_comb_ordenado %>%
  mutate(coordenadas = paste0(
    "[", 
    sprintf("%.6f", longitud),  # Formatear longitud a 6 decimales
    ", ", 
    sprintf("%.6f", latitud),   # Formatear latitud a 6 decimales
    "]"
  )) %>%
  mutate(
    fecha_resta = date - months(14),  # Restar 1 año y 2 meses (14 meses)
    fecha_suma = date + months(14)    # Sumar 1 año y 2 meses (14 meses)
  ) %>%
  mutate(
    imgAnt = case_when(
      fecha_resta < fecha_corte1 ~ "Landsat 5",
      fecha_resta >= fecha_corte1 & fecha_resta <= fecha_corte2 ~ "Landsat 7",
      fecha_resta > fecha_corte2 & fecha_resta <= fecha_corte3 ~ "Landsat 8",
      fecha_resta > fecha_corte3 ~ "Sentinel 2"
    ),
    imgDesp = case_when(
      fecha_suma < fecha_corte1 ~ "Landsat 5",
      fecha_suma >= fecha_corte1 & fecha_suma <= fecha_corte2 ~ "Landsat 7",
      fecha_suma > fecha_corte2 & fecha_suma <= fecha_corte3 ~ "Landsat 8",
      fecha_suma > fecha_corte3 ~ "Sentinel 2"
    )
  ) %>%
  mutate(num = row_number()) %>%
  select(num, parcela_ID, coordenadas, date, imgAnt, imgDesp)

# Ver el resultado
head(df_comb_ord_col_extra)

# Crear una funcion para dividir la tabla en páginas
draw_table <- function(data, rows_per_page = 30) {
  total_rows <- nrow(data)
  num_pages <- ceiling(total_rows / rows_per_page)
  
  for (page in 1:num_pages) {
    start_row <- (page - 1) * rows_per_page + 1
    end_row <- min(page * rows_per_page, total_rows)
    page_data <- data[start_row:end_row, ]
    
    grid.newpage()
    grid.table(page_data)
  }
}

# Generar el PDF
pdf("df_br_planilla-control-2.pdf", height = 11, width = 8.5)
draw_table(df_comb_ord_col_extra, rows_per_page = 30)  # Ajusta rows_per_page segun el tamano de la pagina
dev.off()

# Generar Excel
write.xlsx(df_comb_ord_col_extra, "mi_dataframe.xlsx")

