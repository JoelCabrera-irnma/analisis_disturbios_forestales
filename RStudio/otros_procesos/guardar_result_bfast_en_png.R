library(magick) # image_annotate()

# Capturar la salida de la función en una variable
texto <- capture.output(print(result))

# Convertir la salida en un solo string con saltos de línea
texto <- paste(texto, collapse = "\n")

# Crear una imagen con el texto
img <- image_blank(width = 800, height = 600, color = "white") %>%
  image_annotate(texto, size = 20, color = "black", gravity = "center")

# Guardar la imagen en formato PNG
image_write(img, path = "Parcela_93_2010-05-09.png", format = "png")

# Guardar en formato JPG
image_write(img, path = "resultado.jpg", format = "jpeg")
