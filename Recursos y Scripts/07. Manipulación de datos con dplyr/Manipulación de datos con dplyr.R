pacman::p_load(tidyverse, 
               readxl,
               janitor)

# Cargar los datos de Graduandos 2025 ----

graduandos <- read_excel("Datos/2025-Grad-Internet.xlsx",
                          na = ".") %>% 
  clean_names()
  

# Filas ---- 

## Filter ----

# Todos los estudiantes con logro en Matemáticas

graduandos_logro_mate <- graduandos  %>% 
  filter(logro_mate == 1)


# Estudiantes del sector privado
graduandos %>%
  filter(sector == "Privado")

# Estudiantes de la Región Metropolitana y área urbana
graduandos |>
  filter(region == "Región 1 o Metropolitana" & area == "Urbana")

graduandos |>
  filter(region == "Región 1 o Metropolitana",
         area == "Urbana")

# Estudiantes de dos departamentos específicos
graduandos |>
  filter(departamento == "Quetzaltenango" | departamento == "Huehuetenango")

# Forma más corta con %in% (equivalente al | anterior)
graduandos |>
  filter(departamento %in% c("Quetzaltenango", "Huehuetenango"))

# Guardar el resultado en un objeto
metropolitana <- graduandos |>
  filter(region == "Región 1 o Metropolitana")

## Arrange ----

# Ordenar por puntaje de Matemáticas de menor a mayor

graduandos_measure_menor_mayor <- graduandos %>% 
  arrange(measure_mate)

# Ordenar de mayor a menor (descendente) — los mejores puntajes primero
graduandos_measure_mayor_menor <- graduandos |>
  arrange(desc(measure_mate))

# Ordenar por región, luego departamento, luego municipio
graduandos |>
  arrange(region, departamento, municipio)

## distinct ----

# Ver todas las combinaciones únicas región–departamento
graduandos %>% 
  distinct(region, departamento)

graduandos %>% 
  distinct(cod_evaluacion)

# Mantener todas las columnas pero conservar solo la primera aparición de cada combinación región–departamento
graduandos |>
  distinct(region, departamento, .keep_all = T)

# Si lo que necesitas es un conteo, usa count()
graduandos |>
  count(region, departamento, sort = T)

# Verbos ----

## Mutate ----

# Crear una variable que indique si el estudiante logró ambas materias

df_logro_ambas <- graduandos  %>%
  mutate(
    logro_ambas = logro_mate + logro_lect,  # 0 = ninguna, 1 = una, 2 = ambas
    .before = 1                              # colocar al inicio del data frame
  )

## Select ----

### Seleccionar columnas por nombre ----

graduandos  %>%
  select(region, departamento, municipio)

### Seleccionar un rango de columnas (de region a jornada, inclusive)

graduandos  %>%
  select(region:jornada)

### Excluir un rango de columnas
graduandos |>
  select(!region:jornada)

### Seleccionar solo columnas de texto
graduandos |>
  select(where(is.character))

### Seleccionar columnas de resultado educativo con un patrón en el prefijo

graduandos  %>% 
  select(starts_with("measure") | starts_with("desempeno") | starts_with("logro"))

### Seleccionar columnas de servicios en el hogar
graduandos |>
  select(starts_with("sc_"))

### Seleccionar columnas de electrodomésticos
graduandos |>
  select(smart_tv:impresora)

### Renombrar al seleccionar (nuevo_nombre = nombre_original)

graduandos |>
  select(puntaje_mate = measure_mate, puntaje_lect = measure_lect)

# Seleccionar columnas usando un vector de nombres

vars <- c("region", "departamento", "municipio")

graduandos  %>% 
  select(all_of(vars))

# Igual que all_of(), pero ignora nombres que no existen
vars <- c("region", "departamento", "inexistente")

graduandos %>% 
  select(any_of(vars))  

## Rename ----
# (nuevo_nombre = nombre_original)

graduandos  %>% 
  rename(
    puntaje_mate = measure_mate,
    puntaje_lect = measure_lect
  )

## Relocate ----

### Mover los resultados educativos al inicio

graduandos  %>%
  relocate(measure_mate, measure_lect, desempeno_mate, desempeno_lect)

### Mover después de una columna específica
graduandos  %>%
  relocate(logro_mate, logro_lect,
           .after = departamento)

### Mover columnas de logro antes de las de desempeño

graduandos  %>% 
  relocate(starts_with("logro"), 
           .before = starts_with("desempeno"))











