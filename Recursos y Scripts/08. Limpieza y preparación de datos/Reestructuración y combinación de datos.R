pacman::p_load(
  tidyverse,   # dplyr, tidyr, stringr
  janitor,     # clean_names()
  readxl,      # leer el archivo limpio en Excel
  here         # rutas reproducibles
)

# Lectura de datos ----

## Encuesta limpia (salida de la lección de limpieza)

df <- read_excel(here("Datos", "Datos limpios", "encuesta_limpia.xlsx")) %>% 
  clean_names()

## Catálogo oficial de centros educativos
datos_adicionales <- read_csv(here("Datos", "centros_metadatos.csv")) %>% 
  clean_names()

glimpse(datos_adicionales)

# Bloque 1 — Reestructuración con `tidyr` ----

## A filas, con separate_longer_delim()

df_longer <- df %>%
  separate_longer_delim(otras_dificultades, delim = ";") %>%
  mutate(otras_dificultades = str_squish(otras_dificultades)) %>%
  count(otras_dificultades, sort = TRUE) %>% 
  filter(!is.na(otras_dificultades))

## A columnas, con separate_wider_delim() ---- 

df_wider <- df %>% 
  separate_wider_delim(
    otras_dificultades,
    delim = ";",
    names = c("dificultad_1", "dificultad_2", "dificultad_3"),
    too_few  = "align_start",   # si hay menos partes, rellena con NA
    too_many = "merge",         # si hay más, junta el sobrante en la última
    cols_remove = FALSE         # conserva la columna original
  )

## De vuelta a lo ancho: variables indicadoras con pivot_wider() ----

df_valor_por_columna <- df %>%
  separate_longer_delim(otras_dificultades, delim = ";") %>%
  mutate(otras_dificultades = str_squish(otras_dificultades)) %>%
  mutate(presente = 1L) %>%                    # columna que servirá de valor
  pivot_wider(
    names_from  = otras_dificultades,          # cada categoría se vuelve una columna
    values_from = presente,                    # el valor que rellena (1)
    values_fill = 0L                           # lo que no se marcó queda en 0
  )

# Bloque 2 — Combinar tablas con *joins* ----

## 2.1 `left_join`: conservar todas las filas de la de la tabla de la izquierda ----

df_left <- df %>%
  left_join(datos_adicionales, by = join_by(codigo))

## 2.2 `inner_join`: conservar solo lo que casa en ambas ----

df_inner <- df %>%
  inner_join(datos_adicionales, by = join_by(codigo))

## 2.3 `anti_join`: detectar lo que NO casa ----

### Centros de la encuesta que no están en el catálogo:
  
df %>%
  anti_join(datos_adicionales, by = join_by(codigo)) %>%
  select(codigo, establecimiento) %>% 
  distinct()

## Centros del catálogo de los que no se recibió ninguna respuesta:
  
datos_adicionales %>%
  anti_join(df, by = join_by(codigo)) %>%
  select(codigo, nombre_oficial) %>% 
  distinct()

## Un uso del *join* para validar ----

df %>%
  left_join(datos_adicionales, by = join_by(codigo)) %>%
  filter(area != area_oficial) %>%
  select(codigo, establecimiento, area, area_oficial)

# Bloque 3 — Apilar tablas con `bind_rows` y `bind_cols` ----

## 3.1 `bind_rows`: apilar filas (a lo largo) ----

d_1 <- tibble(
  codigo = c("00-01-0001-43", "00-09-0301-44"),
  nota   = c(85, 90)
)

d_2 <- tibble(
  codigo = c("00-08-0077-43"),
  nota   = c(78)
)  

unir_datos <- bind_rows(ronda_1, ronda_2, .id = "datos")

## 3.2 `bind_cols`: pegar columnas (a lo ancho) ----

tabla_a <- tibble(codigo = c("00-01-0001-43", "00-09-0301-44"))

tabla_b <- tibble(jornada = c("Matutina", "Vespertina"))

bind_cols(tabla_a, tabla_b)













