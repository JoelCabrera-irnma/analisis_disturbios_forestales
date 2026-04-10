# GENERAR ARCHIVO PDF DEL LISTADO DE BREAKPOINTS CON TODOS SUS DATOS ADJUNTADOS EN TABLA

# Cargar paquetes necesarios
library(gridExtra)
library(grid)
library(dplyr)
library(openxlsx)

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
pdf("Tabla_Final_Disturbios.pdf", height = 11, width = 8.5)
draw_table(Tabla_Final_Disturbios, rows_per_page = 30)  # Ajusta rows_per_page segun el tamano de la pagina
dev.off()

# Generar el Excel
write.xlsx(df_combinado2, "Tabla_2000-2024.xlsx")


