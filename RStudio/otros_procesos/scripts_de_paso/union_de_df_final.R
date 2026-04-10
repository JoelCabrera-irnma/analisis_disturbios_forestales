lista_disturb_full_fecha_correg <- lista_disturb_full_fecha_correg %>%
  mutate(ID = row_number())

fsdfd <- fsdfd %>%
  mutate(ID = row_number())

Tabla_Final_Disturbios <- inner_join(lista_disturb_full_fecha_correg,fsdfd, by="ID")

Tabla_Final_Disturbios <- lista_disturb_full_fecha_correg %>%
  select(ID, Parcela = parcela_ID, Fecha = date, longitud, latitud)