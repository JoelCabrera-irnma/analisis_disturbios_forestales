# Primero convertimos la columna 'date' a formato Date
df_comb_ordenado$date <- as.Date(df_comb_ordenado$date)

# Definimos las fechas límite
fecha_limite1 <- as.Date("2013-04-11")
fecha_inicio_rango <- as.Date("2013-04-11")
fecha_fin_rango <- as.Date("2015-06-23")

# Contamos observaciones antes del 5 de noviembre de 2013
n_antes <- sum(df_comb_ordenado$date < fecha_limite1)

# Contamos observaciones entre el 11 de abril de 2013 y el 23 de junio de 2015
n_entre <- sum(df_comb_ordenado$date >= fecha_inicio_rango & df_comb_ordenado$date <= fecha_fin_rango)

# Contamos observaciones después del 23 de junio de 2015
n_despues <- sum(df_comb_ordenado$date > fecha_fin_rango)

# Mostramos los resultados
cat("Observaciones antes del 5 de noviembre de 2013:", n_antes, "\n")
cat("Observaciones entre el 11 de abril de 2013 y el 23 de junio de 2015:", n_entre, "\n")
cat("Observaciones después del 23 de junio de 2015:", n_despues, "\n")