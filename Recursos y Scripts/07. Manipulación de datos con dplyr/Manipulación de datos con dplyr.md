# Lección 1: Manipulación de Filas y Columnas con dplyr
### Datos: Graduandos 2025 – DIGEDUCA

---

## Configuración inicial

```r
pacman::(tidyverse,
janitor,
readxl
)

# Cargar los datos de Graduandos 2025
graduandos <- read_excel("Datos/2025-Grad-Internet.xlsx") |>
  clean_names()
# clean_names() convierte todos los nombres de columna a snake_case minúsculas
# y elimina caracteres especiales (ej. Desempeño_Mate → desempeno_mate,
# Región → region, Cod_RECO → cod_reco)
```

> **Nota sobre conflictos:** Al cargar `tidyverse`, verás un mensaje de conflictos que indica que `dplyr` sobreescribe algunas funciones de base R (como `filter()` y `lag()`). Si necesitas usar las versiones originales, escríbelas con su nombre completo: `stats::filter()`.

---

## Exploración inicial del dataset

```r
# Vista general en consola: muestra las primeras filas y tipo de cada columna
graduandos

# Resumen compacto: ideal para datasets grandes (158,439 filas × 73 columnas)
glimpse(graduandos)

# Dimensiones: filas y columnas
dim(graduandos)

# Primeras y últimas filas
head(graduandos)
tail(graduandos)

# Impresión completa como tibble (muestra solo las primeras 10 filas)
print(graduandos)
```

**Tipos de datos que encontrarás:**
- `chr` = texto (carácter): `region`, `departamento`, `sector`, `area`
- `dbl` = número decimal: `measure_mate`, `measure_lect`, `cod_depa`
- `int` = número entero: `desempeno_mate`, `desempeno_lect`, `logro_mate`

---

## Los verbos de dplyr

En `dplyr`, un **verbo** es una función diseñada para transformar datos de forma legible e intuitiva. Tres reglas básicas:

1. El **primer argumento** siempre es un data frame.
2. Los **argumentos siguientes** describen qué columnas usar (sin comillas).
3. El **resultado** siempre es un nuevo data frame.

---

## El operador pipe `|>`

El pipe toma lo que está a su izquierda y lo pasa a la función de la derecha:  
`x |> f(y)` equivale a `f(x, y)`.  
Se lee como **"luego"** o **"entonces"**.

```r
# Ejemplo: promedio de puntaje en Matemáticas por región y sector
graduandos |>
  filter(desempeno_mate >= 3) |>        # solo estudiantes con desempeño satisfactorio o excelente
  group_by(region, sector) |>
  summarize(
    promedio_mate = mean(measure_mate, na.rm = TRUE)
  )
```

---

## Verbos que operan sobre FILAS

Los verbos principales para trabajar con filas son:
- `filter()`: mantiene filas que cumplen una condición
- `arrange()`: reordena las filas según el valor de una columna
- `distinct()`: elimina filas duplicadas

---

### `filter()` — Filtrar filas

```r
# Todos los estudiantes con logro en Matemáticas
graduandos |>
  filter(logro_mate == 1)

# Estudiantes del sector privado
graduandos |>
  filter(sector == "Privado")

# Estudiantes de la Región Metropolitana y área urbana
graduandos |>
  filter(region == "Región 1 o Metropolitana" & area == "Urbana")

# Estudiantes de dos departamentos específicos
graduandos |>
  filter(departamento == "Quetzaltenango" | departamento == "Huehuetenango")

# Forma más corta con %in% (equivalente al | anterior)
graduandos |>
  filter(departamento %in% c("Quetzaltenango", "Huehuetenango"))

# Guardar el resultado en un objeto
metropolitana <- graduandos |>
  filter(region == "Región 1 o Metropolitana")
```

---

### `arrange()` — Ordenar filas

```r
# Ordenar por puntaje de Matemáticas de menor a mayor
graduandos |>
  arrange(measure_mate)

# Ordenar de mayor a menor (descendente) — los mejores puntajes primero
graduandos |>
  arrange(desc(measure_mate))

# Ordenar por región, luego departamento, luego municipio
graduandos |>
  arrange(region, departamento, municipio)
```

---

### `distinct()` — Valores únicos

```r
# Ver todas las combinaciones únicas región–departamento
graduandos |>
  distinct(region, departamento)

# Mantener todas las columnas pero conservar solo la primera aparición
# de cada combinación región–departamento
graduandos |>
  distinct(region, departamento, .keep_all = TRUE)

# Si lo que necesitas es un conteo, usa count()
graduandos |>
  count(region, departamento, sort = TRUE)
```

---

## Ejercicios sobre filas

```r
# 1. Estudiantes con desempeño "Excelente" en Lectura (código 4)
graduandos |> filter(desempeno_lect == 4)

# 2. Estudiantes de los departamentos de Guatemala o Sacatepéquez
graduandos |> filter(departamento %in% c("Guatemala", "Sacatepéquez"))

# 3. Estudiantes que quieren seguir estudiando Y les gustaría ir a la universidad
graduandos |> filter(grad_seguir_estudiando == 1 & gustaria_universidad == 1)

# 4. Estudiantes de jornada matutina o vespertina
graduandos |> filter(jornada %in% c("Matutina", "Vespertina"))

# 5. Estudiantes con logro en Matemáticas pero sin logro en Lectura
graduandos |> filter(logro_mate == 1 & logro_lect == 0)

# 6. Los establecimientos con mayor número de estudiantes evaluados
graduandos |>
  arrange(desc(cantidad_estud)) |>
  relocate(cod_estable, cantidad_estud)

# 7. ¿Cuántas combinaciones únicas de región y sector existen?
graduandos |>
  distinct(region, sector) |>
  nrow()
# Usamos nrow() porque sin él solo veríamos las primeras 10 filas en pantalla

# 8. ¿Cuántos departamentos hay en los datos?
graduandos |>
  distinct(departamento) |>
  nrow()

# 9. Los estudiantes con el puntaje más alto en Matemáticas
graduandos |>
  arrange(desc(measure_mate)) |>
  relocate(measure_mate, departamento, sector)

# 10. Los estudiantes con el puntaje más bajo en Lectura
graduandos |>
  arrange(measure_lect) |>
  relocate(measure_lect, departamento, sector)
```

> **Nota:** El orden de `filter()` y `arrange()` no afecta el resultado porque filtramos por condición, no por número de fila. Sin embargo, filtrar primero y luego ordenar es más eficiente: reduce las filas antes de ordenarlas.

---

## Verbos que operan sobre COLUMNAS

Los cuatro verbos principales son:
- `mutate()`: crea nuevas columnas derivadas de las existentes o modificar columnas existentes
- `select()`: selecciona columnas
- `rename()`: renombra columnas
- `relocate()`: cambia la posición de las columnas

---

### `mutate()` — Crear nuevas columnas

```r
# Crear una variable que indique si el estudiante logró ambas materias
graduandos |>
  mutate(
    logro_ambas = logro_mate + logro_lect,  # 0 = ninguna, 1 = una, 2 = ambas
    .before = 1                              # colocar al inicio del data frame
  )

# El argumento .before coloca la nueva variable a la izquierda
# El punto (.) indica que es un argumento de la función, no una nueva variable

# Crear después de una columna específica
graduandos |>
  mutate(
    logro_ambas = logro_mate + logro_lect,
    .after = logro_lect
  )

# Usar .keep = "used" para mantener solo las columnas involucradas en el cálculo
graduandos |>
  mutate(
    logro_ambas       = logro_mate + logro_lect,
    promedio_medidas  = (measure_mate + measure_lect) / 2,
    .keep = "used"
  )
```

---

### `select()` — Seleccionar columnas

```r
# Seleccionar columnas por nombre
graduandos |>
  select(region, departamento, municipio)

# Seleccionar un rango de columnas (de region a jornada, inclusive)
graduandos |>
  select(region:jornada)

# Excluir un rango de columnas
graduandos |>
  select(!region:jornada)

# Seleccionar solo columnas de texto
graduandos |>
  select(where(is.character))

# Seleccionar columnas de resultado educativo
graduandos |>
  select(starts_with("measure") | starts_with("desempeno") | starts_with("logro"))

# Seleccionar columnas de servicios en el hogar
graduandos |>
  select(starts_with("sc_"))

# Seleccionar columnas de electrodomésticos
graduandos |>
  select(smart_tv:impresora)

# Renombrar al seleccionar (nuevo_nombre = nombre_original)
graduandos |>
  select(puntaje_mate = measure_mate, puntaje_lect = measure_lect)

# Seleccionar columnas usando un vector de nombres
vars <- c("region", "departamento", "municipio")

graduandos |>
  select(all_of(vars))

# Igual que all_of(), pero ignora nombres que no existen
vars <- c("region", "departamento", "inexistente")

graduandos |>
  select(any_of(vars))  
  
```

**Funciones auxiliares de `select()`:**
- `starts_with("sc_")`: columnas que empiezan con "sc_"
- `ends_with("_reco")`: columnas que terminan con "_reco"
- `contains("mate")`: columnas que contienen "mate"
- `where(is.numeric)`: columnas numéricas
- `all_of(vars)`: selecciona las columnas cuyos nombres están en el vector vars (genera error si falta alguna)
- `any_of(vars)`: selecciona las columnas cuyos nombres están en el vector vars (ignora las que no existen)
---

### `rename()` — Renombrar columnas

```r
# Renombrar 
# (nuevo_nombre = nombre_original)
graduandos |>
  rename(
    puntaje_mate = measure_mate,
    puntaje_lect = measure_lect
  )
```

---

### `relocate()` — Mover columnas

```r
# Mover los resultados educativos al inicio
graduandos |>
  relocate(measure_mate, measure_lect, desempeno_mate, desempeno_lect)

# Mover después de una columna específica
graduandos |>
  relocate(logro_mate, logro_lect, .after = departamento)

# Mover columnas de logro antes de las de desempeño
graduandos |>
  relocate(starts_with("logro"), .before = starts_with("desempeno"))
```

---

## Ejercicios sobre columnas

```r
# 1. ¿Cómo se relacionan measure_mate, desempeno_mate y logro_mate?
graduandos |>
  select(measure_mate, desempeno_mate, logro_mate)
# measure_mate es el puntaje continuo (logits)
# desempeno_mate es su categorización (1-4)
# logro_mate indica si superó el umbral mínimo (0 o 1)

# 2. Seleccionar todas las variables relacionadas con planes después de graduarse
graduandos |>
  select(starts_with("grad_"))

# 3. Seleccionar variables de contexto del hogar
graduandos |>
  select(starts_with("cc_") | starts_with("sc_") | starts_with("cu_"))

# 4. ¿Qué pasa si especificas la misma columna dos veces en select()?
graduandos |> select(region, region, region)
# R: Solo aparece una vez. select() elimina duplicados automáticamente.

# 5. Crear variable de brecha entre puntajes y moverla al inicio
graduandos |>
  mutate(
    brecha_mate_lect = measure_mate - measure_lect
  ) |>
  relocate(brecha_mate_lect)

# 6. Renombrar measure_mate y measure_lect indicando unidades
graduandos |>
  rename(
    puntaje_mate_logits = measure_mate,
    puntaje_lect_logits = measure_lect
  ) |>
  relocate(puntaje_mate_logits, puntaje_lect_logits)

# 7. Seleccionar variables de identificación y resultados usando any_of()
variables_clave <- c("region", "departamento", "sector", "area",
                     "desempeno_mate", "desempeno_lect", "logro_mate", "logro_lect")
graduandos |> select(any_of(variables_clave))
# any_of() es útil cuando no estás seguro si todas las variables existen

# 8. ¿contains() distingue mayúsculas y minúsculas?
graduandos |> select(contains("mate"))                        # encuentra desempeno_mate, logro_mate, etc.
graduandos |> select(contains("Mate", ignore.case = FALSE))   # no encuentra nada (todo quedó en minúscula tras clean_names)
# Por defecto, contains() ignora mayúsculas/minúsculas

# 9. ¿Por qué esto falla?
graduandos |> select(region) |> arrange(measure_mate)
# Error: al seleccionar solo region, la columna measure_mate ya no existe en el data frame
```

---

## El pipe en acción — Ejemplo integrador

```r
# Estudiantes del sector público en área rural con logro en Matemáticas:
# mostrar región, departamento, puntaje y desempeño, ordenados de mayor a menor puntaje

graduandos |>
  filter(sector == "Oficial", area == "Rural", logro_mate == 1) |>
  mutate(
    brecha = measure_mate - measure_lect
  ) |>
  select(region, departamento, measure_mate, desempeno_mate, brecha) |>
  arrange(desc(measure_mate))
```