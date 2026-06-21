# Reestructuración y combinación de datos

La lección anterior dejó una sola tabla limpia y depurada. Pero los proyectos reales casi nunca trabajan
con una única tabla en su forma definitiva. La información llega fragmentada en tres situaciones muy
frecuentes:

- **Dentro de una celda:** varias respuestas agrupadas en un mismo campo, separadas por un delimitador
  (típico de las preguntas de "marque todas las que apliquen").
- **En varias tablas o archivos:** los datos de la encuesta por un lado y un catálogo de información
  adicional de los centros por otro, que hay que unir por una llave común.
- **En lotes separados:** varias rondas de recolección, o archivos de distintas regiones, que hay que
  apilar en una sola base.

Esta lección cubre las herramientas para cada caso: **reestructurar** valores con `tidyr`, **combinar**
tablas con *joins*, y **apilar** tablas con `bind_rows()` y `bind_cols()`. Ninguna de estas operaciones
corrige errores (eso fue la limpieza); todas cambian la forma de los datos o los traen de varias piezas a
una sola.

---

## 0. Preparación del entorno

```r
pacman::p_load(
  tidyverse,   # dplyr, tidyr, stringr
  janitor,     # clean_names()
  readxl,      # leer el archivo limpio en Excel
  here         # rutas reproducibles
)
```

Se parte del **conjunto de datos limpio** que produjo la lección anterior y del **catálogo de metadatos**
de los centros educativos. Cada centro se identifica con su `codigo`, que será la llave para combinar
ambas tablas.

```r
# Encuesta ya limpia (salida de la lección de limpieza)
df <- read_excel(here("Datos", "Datos limpios", "encuesta_limpia.xlsx")) %>% clean_names()

# Catálogo oficial de centros educativos
meta <- read_csv(here("Datos", "centros_metadatos.csv")) %>% clean_names()

glimpse(meta)
#> Rows: 10
#> Columns: 6
#> $ codigo       <chr> "00-01-0001-43", "00-01-0123-45", ...
#> $ nombre_oficial <chr> "Centro educativo 01", "Centro educativo 02", ...
#> $ sector       <chr> "Oficial", "Oficial", "Privado", ...
#> $ nivel        <chr> "Primaria", "Básico", "Diversificado", ...
#> $ jornada      <chr> "Matutina", "Vespertina", "Matutina", ...
#> $ area_oficial <chr> "Urbana", "Urbana", "Urbana", ...
```

---

## Bloque 1 — Reestructuración con `tidyr`

Las preguntas de casillas múltiples (las de "marque todas las que apliquen", frecuentes en formularios en
línea) guardan varias respuestas en una sola celda, unidas por un delimitador. La variable
`otras_dificultades` tiene este formato (por ejemplo, "Falta de comunicación; Recursos insuficientes").

Desde la versión 1.3 de **tidyr** (enero de 2024), las funciones para separar son `separate_wider_delim()` y
`separate_longer_delim()`. Reemplazan a las antiguas `separate()` y `separate_rows()`, que quedaron en
estado *superseded* (siguen funcionando, pero ya no se recomiendan para código nuevo).

**A filas, con `separate_longer_delim()`** — genera una fila por cada respuesta. Es la forma indicada para
contar la frecuencia de cada dificultad:

```r
df %>%
  separate_longer_delim(otras_dificultades, delim = ";") %>%
  mutate(otras_dificultades = str_squish(otras_dificultades)) %>%
  count(otras_dificultades, sort = TRUE)
```

El `str_squish()` es necesario porque el delimitador venía con un espacio ("; "), y sin limpiarlo quedarían
valores como " Recursos insuficientes" con un espacio inicial que los contaría como categorías distintas.

**A columnas, con `separate_wider_delim()`** — crea una columna por cada respuesta. Útil cuando se quiere una
variable indicadora por opción. Como las filas tienen distinta cantidad de respuestas, se indica con
`too_few` y `too_many` cómo manejar los casos disparejos:

```r
df %>%
  separate_wider_delim(
    otras_dificultades,
    delim = ";",
    names = c("dificultad_1", "dificultad_2", "dificultad_3"),
    too_few  = "align_start",   # si hay menos partes, rellena con NA
    too_many = "merge",         # si hay más, junta el sobrante en la última
    cols_remove = FALSE         # conserva la columna original
  )
```

En resumen: `longer` reparte en **filas** (ideal para conteos y frecuencias); `wider` reparte en **columnas**
(ideal para crear variables separadas).

---

## Bloque 2 — Combinar tablas con *joins*

Un *join* trae columnas de una segunda tabla y las pega a la primera, **emparejando las filas por una llave
común** (aquí, `codigo`). La idea central: la encuesta dice *quién respondió y qué respondió*; el catálogo
dice *cómo es cada centro* (sector, nivel, jornada). El *join* combina ambas para tener todo en una sola
tabla.

Lo que distingue a los tipos de *join* es **qué filas se conservan** cuando una llave no encuentra pareja en
la otra tabla.

### 2.1 `left_join`: conservar todas las filas de la encuesta

`left_join()` mantiene **todas** las filas de la tabla de la izquierda (la encuesta) y le agrega las
columnas del catálogo. Cuando un centro de la encuesta no aparece en el catálogo, sus columnas nuevas
quedan en `NA`.

```r
df_unido <- df %>%
  left_join(meta, by = join_by(codigo))

df_unido %>%
  select(codigo, establecimiento, sector, nivel, jornada) %>%
  head()
```

> La sintaxis `by = join_by(codigo)` es la forma actual (dplyr 1.1+). La forma clásica `by = "codigo"` sigue
> funcionando igual. Si la llave tuviera nombres distintos en cada tabla, se escribe
> `join_by(codigo == codigo_centro)`.

Esta es la opción por defecto en la mayoría de los análisis: se quiere conservar a todos los participantes y
enriquecerlos con la información del catálogo, sin perder a nadie.

### 2.2 `inner_join`: conservar solo lo que casa en ambas

`inner_join()` mantiene **únicamente** las filas cuya llave existe en las dos tablas. Si un centro está en
la encuesta pero no en el catálogo (o al revés), esa fila se descarta.

```r
df %>%
  inner_join(meta, by = join_by(codigo)) %>%
  nrow()
```

Conviene usarlo con cuidado: a diferencia de `left_join()`, **puede reducir el número de filas sin avisar**.
Por eso es buena práctica comparar el `nrow()` antes y después, igual que se contaban las exclusiones en la
lección de limpieza.

### 2.3 `anti_join`: detectar lo que NO casa

`anti_join()` es distinto a los anteriores: **no agrega columnas**. Devuelve las filas de la izquierda que
**no** tienen pareja en la derecha. Es una herramienta de control de calidad: sirve para encontrar los
desajustes entre las dos tablas.

Funciona en las dos direcciones, y cada una responde una pregunta diferente.

**Centros de la encuesta que no están en el catálogo:**

```r
df %>%
  anti_join(meta, by = join_by(codigo)) %>%
  distinct(codigo, establecimiento)
#> # A tibble: 1 × 2
#>   codigo        establecimiento
#>   <chr>         <chr>
#> 1 00-01-0456-43 Centro educativo 09
```

Esto delata un código que aparece en las respuestas pero no en el catálogo oficial: puede ser un error de
digitación del código, o un centro que no estaba registrado. Hay que revisarlo.

**Centros del catálogo de los que no se recibió ninguna respuesta:**

```r
meta %>%
  anti_join(df, by = join_by(codigo)) %>%
  select(codigo, nombre_oficial)
#> # A tibble: 2 × 2
#>   codigo        nombre_oficial
#>   <chr>         <chr>
#> 1 00-12-0500-41 Centro educativo 10
#> 2 00-12-0033-44 Centro educativo 11
```

Esto identifica centros que existen en el catálogo pero que no participaron en la encuesta, un dato útil para
medir cobertura o planificar seguimiento.

### 2.4 Resumen de los tipos de *join*

| Función        | Qué filas conserva                                          | Uso típico                                   |
|----------------|------------------------------------------------------------|----------------------------------------------|
| `left_join()`  | Todas las de la izquierda; agrega columnas de la derecha    | Enriquecer la encuesta sin perder casos      |
| `inner_join()` | Solo las que casan en ambas tablas                          | Quedarse únicamente con casos completos      |
| `anti_join()`  | Las de la izquierda **sin** pareja (no agrega columnas)     | Detectar desajustes y problemas de cobertura |
| `full_join()`  | Todas las de ambas tablas (rellena con `NA` lo que falta)   | Conservarlo absolutamente todo               |
| `right_join()` | Todas las de la derecha                                     | Poco usado; equivale a un `left_join` al revés |

### 2.5 Un uso del *join* para validar

Como el catálogo trae el área oficial de cada centro (`area_oficial`) y la encuesta trae el área que reportó
la persona (`area`), el *join* permite confrontarlas y encontrar discrepancias. Esto conecta la combinación
de tablas con la validación de la lección anterior: una fuente externa sirve para verificar lo reportado.

```r
df %>%
  left_join(meta, by = join_by(codigo)) %>%
  filter(area != area_oficial) %>%
  select(codigo, establecimiento, area, area_oficial)
```

---

## Bloque 3 — Apilar tablas con `bind_rows` y `bind_cols`

Mientras que los *joins* combinan tablas **a lo ancho** (agregando columnas según una llave), los `bind_*`
las pegan de forma directa: `bind_rows()` apila por filas y `bind_cols()` pega por columnas.

### 3.1 `bind_rows`: apilar filas (a lo largo)

`bind_rows()` pone una tabla debajo de otra. Es lo que se usa para juntar varias rondas de recolección, o
los archivos de distintas regiones, en una sola base. Empareja las columnas **por nombre**, así que el orden
de las columnas no importa, y si a una tabla le falta una columna que la otra sí tiene, la rellena con `NA`.

```r
ronda_1 <- tibble(
  codigo = c("00-01-0001-43", "00-09-0301-44"),
  nota   = c(85, 90)
)

ronda_2 <- tibble(
  codigo = c("00-08-0077-43"),
  nota   = c(78)
)

bind_rows(ronda_1, ronda_2)
#> # A tibble: 3 × 2
#>   codigo         nota
#>   <chr>         <dbl>
#> 1 00-01-0001-43    85
#> 2 00-09-0301-44    90
#> 3 00-08-0077-43    78
```

El argumento `.id` agrega una columna que indica de qué tabla vino cada fila, muy útil para no perder de
vista el origen tras apilar:

```r
bind_rows(ronda_1 = ronda_1, ronda_2 = ronda_2, .id = "ronda")
#> # A tibble: 3 × 3
#>   ronda    codigo         nota
#>   <chr>    <chr>         <dbl>
#> 1 ronda_1  00-01-0001-43    85
#> 2 ronda_1  00-09-0301-44    90
#> 3 ronda_2  00-08-0077-43    78
```

### 3.2 `bind_cols`: pegar columnas (a lo ancho)

`bind_cols()` pega columnas de otra tabla al lado de las actuales. A diferencia de un *join*, **no usa
ninguna llave**: une las filas por su **posición** (la primera con la primera, la segunda con la segunda, y
así). Esto lo hace rápido pero peligroso.

```r
tabla_a <- tibble(codigo = c("00-01-0001-43", "00-09-0301-44"))
tabla_b <- tibble(jornada = c("Matutina", "Vespertina"))

bind_cols(tabla_a, tabla_b)
#> # A tibble: 2 × 2
#>   codigo        jornada
#>   <chr>         <chr>
#> 1 00-01-0001-43 Matutina
#> 2 00-09-0301-44 Vespertina
```

> **Advertencia importante.** `bind_cols()` solo es seguro si las dos tablas tienen exactamente las mismas
> filas, en el mismo orden. Si una está ordenada distinto, pega los datos a la fila equivocada sin dar ningún
> error, y el resultado queda mal de forma silenciosa. Por eso, **siempre que exista una llave (como
> `codigo`), es preferible un *join* antes que un `bind_cols()`**: el *join* empareja por la llave, no por la
> posición, y avisa de lo que no casa. `bind_cols()` se reserva para cuando se tiene la certeza de que las
> filas están alineadas (por ejemplo, columnas calculadas a partir de la misma tabla).

---

## Síntesis

Esta lección amplió el trabajo de una sola tabla hacia datos repartidos en varias piezas:

1. **Reestructurar** con `tidyr`: `separate_longer_delim()` (a filas, para conteos) y `separate_wider_delim()`
   (a columnas, para variables separadas).
2. **Combinar** con *joins*: `left_join()` para enriquecer sin perder casos, `inner_join()` para quedarse
   solo con lo que casa, y `anti_join()` (en ambas direcciones) para detectar desajustes de cobertura y
   calidad.
3. **Apilar** con `bind_rows()` (rondas o regiones, por nombre de columna) y `bind_cols()` (por posición, con
   la advertencia de preferir un *join* cuando hay llave).

La regla práctica que conviene recordar: cuando dos tablas se relacionan por una llave, **usar un *join***; los
`bind_*` son para juntar piezas que ya se sabe que corresponden fila a fila.

> El siguiente paso natural, una vez que los datos están en una sola tabla bien formada, es empezar a
> **interrogarlos** para responder preguntas de análisis (consultas con `filter()` y `str_detect()`,
> búsquedas puntuales, etc.). Eso se trata en la lección de exploración.
