pacman::p_load(
  tidyverse,   # dplyr, tidyr, stringr, readr, forcats, ggplot2
  janitor,     # clean_names(), tabyl()
  naniar,      # exploración de datos faltantes
  validate,    # reglas de validación
  writexl,     # exportar a Excel
  here         # rutas reproducibles dentro del proyecto
)

# lectura de datos ----

df <- read_csv(here("Datos", "encuesta_cruda.csv")) %>% clean_names()


# corregir nombres de variables

df <- df %>% 
  rename(
    establecimiento = nombredelestablecimiento,
    conocimiento   = x1_conocimiento,
    capacitacion   = x2_capacitacion,
    materiales     = x3_materiales,
    aplicacion     = x4_aplicacion,
    otras_dificultades = x334_que_otras_dificultades_de_implementacion_identifica_en_el_centro_educativo,
    nota           = nota_evaluacion
  )

# Tabla de exclusiones

n_inicial <- nrow(df)

bitacora <- tibble(
  etapa            = "Registros iniciales",
  motivo_exclusion = NA_character_,
  n_excluidos      = 0L,
  n_restante       = n_inicial
)

# Bloque 1 — Corregir tipos y valores ----

## 1.1 Variable numérica leída como texto ----

class(df$edad)

df <- df %>% 
  mutate(edad = parse_number(edad))

## 1.2 Anonimización de identificadores directos ----

### con base R
df["nombre"] <- NA          # equivalente: df$nombre <- NA

### con dplyr

df <- df %>% 
  mutate(nombre = NA_character_)

## 1.3 Corrección puntual de errores con R base ----

df %>% count(area) # se empieza con una exploración

# Corregir un error de digitación puntual
df$area[df$area == "Urbanaa"] <- "Urbana"

# Corregir un NA puntual del que se conoce el valor verdadero
df$area[df$codigo == "00-11-0099-41"] <- "Rural"

# Bloque 2 — Depurar el universo de casos ----

## 2.1 Consentimiento informado ----

n_antes <- nrow(df)

df <- df %>% 
  filter(consentimiento != "No doy mi consentimiento para participar en esta encuesta")

bitacora <- bitacora %>% 
  add_row(
    etapa            = "Filtro de consentimiento",
    motivo_exclusion = "Sin consentimiento informado",
    n_excluidos      = n_antes - nrow(df),
    n_restante       = nrow(df)
  )

## 2.2 Limpieza por fecha (registros de prueba) ----

# class(df$start) verificar si la variable con la fecha es de tipo POSIXct, si no lo es, hay que hacer la transformación.

# df <- df %>% 
#   mutate(start = as.POSIXct(start))

n_antes <- nrow(df)

df <- df %>% 
  filter(start >= as.POSIXct("2025-08-25 00:00:00"))

bitacora <- bitacora %>% 
  add_row(
    etapa            = "Filtro por fecha",
    motivo_exclusion = "Registro de prueba (previo al inicio de recolección)",
    n_excluidos      = n_antes - nrow(df),
    n_restante       = nrow(df)
  )

## 2.3 "No respuesta" excesiva ----

umbral_no_respuesta <- 0.30   # se modifica aquí si se quiere otro corte

# (A) NOMBRES de columnas: names(df)[ ... ] devuelve un vector de CARACTERES
vars_preguntas <- names(df)[
  match("conocimiento", names(df)):match("otras_dificultades", names(df))
]


# (B) ÍNDICES de columnas: el c(match:match, ...) devuelve un vector de POSICIONES (enteros)

rango_vars <- c(
  match("conocimiento", names(df)):match("aplicacion", names(df)),
  match("otras_dificultades", names(df)):match("otras_dificultades", names(df))
)

## Limpiar los casos con alta no respuesta ---

df <- df %>% 
  mutate(prop_na = rowMeans(is.na(across(all_of(vars_preguntas)))))

n_antes <- nrow(df)

df <- df %>% 
  filter(prop_na <= umbral_no_respuesta) %>%
  select(-prop_na)

bitacora <- bitacora %>% 
  add_row(
    etapa            = "Filtro por no respuesta",
    motivo_exclusion = paste0("No respondió > ", umbral_no_respuesta * 100, "% del bloque de preguntas"),
    n_excluidos      = n_antes - nrow(df),
    n_restante       = nrow(df)
  )

### 2.4 Fuera del rango de edad

n_antes <- nrow(df)

df <- df %>% 
  filter(edad >= 18)

bitacora <- bitacora %>% 
  add_row(
    etapa            = "Filtro por edad",
    motivo_exclusion = "Fuera del rango de edad (criterio de inclusión: 18+)",
    n_excluidos      = n_antes - nrow(df),
    n_restante       = nrow(df)
  )

### 2.5 Tabla de exclusiones

total_excluidos <- tibble(
  registros_iniciales = n_inicial,
  total_excluidos     = sum(bitacora$n_excluidos),
  registros_validos   = nrow(df)
)

# Bloque 3 — Recodificación y categorías ----

## 3.1 `case_match`, `case_when` e `ifelse` ----

### case_match ----

df %>%  count(sexo) # explorar la variable

df <- df %>% 
  mutate(sexo = case_match(sexo,
                           c("M", "Masculino", "masculino") ~ "Masculino",
                           c("F", "Femenino",  "femenino")  ~ "Femenino"
  ))

### case_when ----

df <- df |>
  mutate(grupo_edad = case_when(
    edad < 30          ~ "18 a 29",
    edad < 45          ~ "30 a 44",
    TRUE               ~ "45 o más"
  ))

### if_else ----

df <- df %>%
  mutate(nota = if_else(nota > 100, NA_real_, nota))

## 3.2 `grepl` para recodificar texto ----

df %>% count(departamento) # explorar la variable

df <- df %>%
  mutate(departamento = case_when(
    grepl("solol",    departamento, ignore.case = TRUE) ~ "Sololá",
    grepl("quetzal",  departamento, ignore.case = TRUE) ~ "Quetzaltenango",
    grepl("totonic",  departamento, ignore.case = TRUE) ~ "Totonicapán",
    grepl("guatemal", departamento, ignore.case = TRUE) ~ "Guatemala",
    TRUE ~ departamento
  ))

## 3.3 `fct_relevel` para ordenar niveles ---- 

### Establecer los factores ----

niveles_likert <- c("Nada", "Poco", "Algo", "Bastante", "Mucho")

df <- df %>%
  mutate(across(
    c(conocimiento, capacitacion, materiales, aplicacion),
    ~ factor(.x, levels = niveles_likert)
  ))

### Factor relevel ----

df <- df %>%
  mutate(area = fct_relevel(area, "Urbana", "Rural"))

levels(df$area)

## 3.4 `coalesce` para unir columnas con saltos de formulario ----

df <- df %>%
  mutate(municipio = coalesce(
    municipio_guatemala,
    municipio_solola,
    municipio_quetzaltenango,
    municipio_totonicapan
  ))

df <- df %>%
  mutate(municipio = reduce(across(starts_with("municipio_")), coalesce))  %>%
  relocate(municipio, .after = departamento) %>% 
  select(-starts_with("municipio_"), municipio)

# Bloque 4 — Datos faltantes y validación de reglas ----

## 4.1 Explorar faltantes con `naniar` ----

df %>% miss_var_summary()   # tabla de faltantes por variable

gg_miss_var(df)             # gráfico de barras de faltantes por variable
vis_miss(df)                # mapa visual de toda la matriz de datos

df %>% tabyl(capacitacion) 

### transformar explícitamente el `NA` en una categoría con nombre ----

df %>%
  mutate(capacitacion = replace_na(as.character(capacitacion), "Sin información")) %>%
  tabyl(capacitacion)

## 4.2 Identificar inconsistencias con `validate` ----

reglas <- validator(
  edad_valida   = edad >= 18 & edad <= 100,
  nota_en_rango = nota >= 0 & nota <= 100,
  muni_si_gt    = if (departamento == "Guatemala") !is.na(municipio)
)

resultado <- confront(df, reglas)

summary(resultado)

violating(df, resultado["nota_en_rango"]) # Para ver exactamente qué registros fallan una regla

# Bloque 5 — Exportar el conjunto de datos limpio ----

write_xlsx(df, here("Datos", "Datos limpios", "encuesta_limpia.xlsx"))

write_xlsx(bitacora, here("Datos", "Datos limpios","bitacora de limpieza.xlsx"))



