# Instalar si no lo tienes: install.packages("openxlsx")
library(openxlsx)

# Crear un libro de Excel
wb <- createWorkbook()

# 1. Hoja resumen general
resumen_df <- do.call(rbind, lapply(names(resultados_completos), function(obs) {
  resultado <- resultados_completos[[obs]]
  
  data.frame(
    Observacion = obs,
    Status = ifelse(is.null(resultado$error), "Exitoso", "Error"),
    N_Breakpoints = ifelse(is.null(resultado$breakpoints), 0, length(resultado$breakpoints)),
    Magnitud_Promedio = ifelse(is.null(resultado$magnitudes), NA, 
                               mean(resultado$magnitudes, na.rm = TRUE)),
    Magnitud_Max = ifelse(is.null(resultado$magnitudes), NA, 
                          max(resultado$magnitudes, na.rm = TRUE)),
    Magnitud_Min = ifelse(is.null(resultado$magnitudes), NA, 
                          min(resultado$magnitudes, na.rm = TRUE)),
    Error = ifelse(is.null(resultado$error), "", resultado$error),
    stringsAsFactors = FALSE
  )
}))

addWorksheet(wb, "Resumen_General")
writeData(wb, "Resumen_General", resumen_df)

# 2. Hoja detallada con todos los breakpoints
detalle_df <- do.call(rbind, lapply(names(resultados_completos), function(obs) {
  resultado <- resultados_completos[[obs]]
  
  if(!is.null(resultado$breakpoints) && length(resultado$breakpoints) > 0) {
    data.frame(
      Observacion = obs,
      Breakpoint_ID = seq_along(resultado$breakpoints),
      Breakpoint_Posicion = resultado$breakpoints,
      Magnitud = resultado$magnitudes,
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      Observacion = obs,
      Breakpoint_ID = NA,
      Breakpoint_Posicion = NA,
      Magnitud = NA,
      stringsAsFactors = FALSE
    )
  }
}))

addWorksheet(wb, "Detalle_Breakpoints")
writeData(wb, "Detalle_Breakpoints", detalle_df)

# Guardar archivo
saveWorkbook(wb, "resultados_bfast_noReciente.xlsx", overwrite = TRUE)