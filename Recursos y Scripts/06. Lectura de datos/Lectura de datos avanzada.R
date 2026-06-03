pacman::p_load(tidyverse,
               janitor,
               here,
               readxl,
               haven
              )

# skip, comment y na

notas <- read.csv(here("Datos","Lectura avanzada de datos","notas_seminario.csv"),
                  skip = 3,
                  comment = "#",
                  na = c("N/A",".",""))

# archivos sin encabezados

asistencia <- read_csv(here("Datos","Lectura avanzada de datos","asistencia.csv"),
                       col_names = F)

asistencia <- read_csv(here("Datos","Lectura avanzada de datos","asistencia.csv"),
                      col_names = c("carnet","fecha","presente"))

# Especificar el delimitador entre celdas

inscripciones <- read_delim(here("Datos","Lectura avanzada de datos","inscripciones.txt"),
                            delim = "|")

# Especificar tipos de columna manualmente

notas <- read_csv(here("Datos", "Lectura avanzada de datos","notas_seminario.csv"),
                  skip = 3,
                  comment = "#",
                  na = c("N/A", ".", ""),
                  col_types = list(
                    carnet = col_character(),
                    nombre = col_character(),
                    nota_parcial_1 = col_double(),
                    nota_parcial_2 = col_double(),
                    nota_final = col_double(),
                    asistencia_pct = col_double()
                  ))

# Adivinar los tipos de columna

graduandos2025 <- read_xlsx(here("Datos","2025-Grad-Internet.xlsx"),
                            guess_max = 3000,
                            na = ".")



