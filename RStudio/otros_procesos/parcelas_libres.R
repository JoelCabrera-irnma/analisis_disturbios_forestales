# PARCELAS SIN DISTURBIOS NI RECIENTES NI EN LA SERIE ENTERA
parcelas_full <- unique(MODIS_EVI_TimeSeries_Multiple_Points$parcela_ID)
parcelas_break <- unique(df_breakpoints$parcela_ID)

parcelas_sin_break <- setdiff(parcelas_full,parcelas_break)

parcelas_break_2000_2024 <- unique(c(
  "66", "93", "195", "89", "67", "65", "91", "90", "192", "221", "141", "222",
  "158", "142", "117", "118", "163", "86", "88", "92", "116", "114", "115", 
  "170-N", "94", "87", "171-S", "170-N", "75", "170-N", "171-S", "122", "143", 
  "142", "186", "185", "131", "95", "94", "114", "156", "200", "89", "115", "75", 
  "90", "118", "88", "117", "131", "92", "91", "195", "135-S", "93", "116", 
  "134-S", "95", "192", "65", "110", "222", "187"
))

parcelas_libres <- setdiff(parcelas_sin_break,parcelas_break_2000_2024)

parc_libres_lat_long <- df_parcelasApp %>%
  filter(ID %in% parcelas_libres)

write.csv(parc_libres_lat_long, file = "datos_UM_libresDisturb.csv", row.names = FALSE)

# PARCELAS CON DISTURBIOS RECIENTES 2020-2024
parcelas_con_break_reciente <- c(
  "66", "93", "195", "89", "67", "65", "91", "90", "192", "221", "141", "222",
  "158", "142", "117", "118", "163", "86", "88", "92", "116", "114", "115"
)

parc_disturb_recientes <- df_parcelasApp %>%
  filter(ID %in% parcelas_con_break_reciente)

write.csv(parc_disturb_recientes, file = "datos_UM_Disturb_rec.csv", row.names = FALSE)

