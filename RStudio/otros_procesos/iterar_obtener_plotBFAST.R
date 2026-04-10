# Vector con todas las parcelas a procesar
parcelas_id <- c(93, 166, 97, 204, 124, 95, 174, 169, 112, "170-S", 
                 199, 93, 137, 165, "134-S", 168, 198, 109, 136, 163, 
                 92, 174, 93, 114, 137, "172-S", 168, 136, 163, 97, 
                 98, 192, 116, 117, 188, 195, 166, 94, 112, 75)

# Lista para almacenar los resultados
resultados_bfast <- list()

# Crear carpeta para guardar gráficos si no existe
if(!dir.exists("graficos_bfast")) {
  dir.create("graficos_bfast")
}

# Bucle para procesar cada parcela
for(i in 1:length(parcelas_id)) {
  
  # Filtrar datos para la parcela actual
  parcela <- MODIS_EVI_TimeSeries_Multiple_Points %>%
    filter(parcela_ID == parcelas_id[i])
  
  # Verificar que la parcela tiene datos
  if(nrow(parcela) > 0) {
    
    # Creación de Serie temporal
    DatosSeriesTemporal <- ts(data = parcela$EVI, 
                              start = c(2000, 3), 
                              frequency = 23, 
                              class = "ts")
    
    # Aplicar BFAST
    tryCatch({
      result <- bfast(DatosSeriesTemporal, 
                      h = 0.16, 
                      season = "dummy", 
                      max.iter = 100)
      
      # Guardar resultado con nombre de parcela
      resultados_bfast[[paste0("parcela_", parcelas_id[i])]] <- result
      
      # Crear y guardar gráfico
      nombre_archivo <- paste0("graficos_bfast/bfast_parcela_", parcelas_id[i], ".png")
      png(filename = nombre_archivo, width = 1200, height = 800, res = 150)
      plot(result, main = paste("BFAST - Parcela", parcelas_id[i]))
      dev.off()
      
      # Imprimir resultado y confirmación de guardado
      cat("\n=== RESULTADO PARA PARCELA", parcelas_id[i], "===\n")
      print(result)
      cat("Gráfico guardado en:", nombre_archivo, "\n")
      
    }, error = function(e) {
      cat("Error en parcela", parcelas_id[i], ":", e$message, "\n")
    })
    
  } else {
    cat("No se encontraron datos para la parcela", parcelas_id[i], "\n")
  }
}


# Opcional: Acceder a resultados individuales
# Ejemplo: resultados_bfast$parcela_112

# Opcional: Crear un gráfico resumen con todas las parcelas
cat("\nCreando gráfico resumen con todas las parcelas...\n")
if(length(resultados_bfast) > 0) {
  png(filename = "graficos_bfast/resumen_todas_parcelas.png", width = 1600, height = 1200, res = 150)
  par(mfrow = c(ceiling(sqrt(length(resultados_bfast))), ceiling(sqrt(length(resultados_bfast)))))
  
  for(nombre in names(resultados_bfast)) {
    parcela_num <- gsub("parcela_", "", nombre)
    plot(resultados_bfast[[nombre]], main = paste("Parcela", parcela_num))
  }
  
  dev.off()
  cat("Gráfico resumen guardado en: graficos_bfast/resumen_todas_parcelas.png\n")
}