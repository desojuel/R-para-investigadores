# Limpieza y validación de datos en educación

Esta lección recorre, de principio a fin, el proceso de depurar una base de datos de investigación
educativa: desde la encuesta cruda tal como sale de la plataforma de recolección hasta un conjunto de
datos limpio, documentado y listo para analizar. El hilo conductor es una encuesta aplicada a docentes y
directores de centros educativos guatemaltecos sobre el clima escolar y la convivencia en el centro
educativo.

La depuración no es un trámite menor. En las oficinas estadísticas se estima que entre el 10 % y el 30 %
del trabajo de producir una estadística se dedica a validar y limpiar datos. Limpiar consiste, en el
fondo, en convertir el conocimiento del dominio en reglas explícitas y verificar si los datos las cumplen.
No validar equivale a asumir, a ciegas, que todo lo registrado es correcto.

Un principio atraviesa toda la lección: **contar antes y después de cada filtro**. Cada vez que se elimina
un registro debe quedar constancia de por qué se eliminó y cuántos quedaron. Al final, ese recuento se
convierte en una tabla de exclusiones que distingue cada motivo de descarte y permite responder con
números la pregunta inevitable: "¿de cuántos casos partieron y con cuántos se quedaron?".

El orden del flujo es deliberado: **primero corregir, luego depurar, después validar y finalmente
exportar**. Se corrige antes de depurar porque arreglar tipos y valores suele ser sencillo y evita errores
aguas abajo. Por ejemplo, no se puede filtrar a quienes tienen menos de 18 años si la edad fue leída como
texto: hay que corregir el tipo primero.

---

## 0. Preparación del entorno

Las librerías se cargan con `pacman::p_load()`, que instala lo que falte y carga todo en una sola
instrucción.

```r
# install.packages("pacman")  # solo la primera vez
pacman::p_load(
  tidyverse,   # dplyr, tidyr, stringr, readr, forcats, ggplot2
  janitor,     # clean_names(), tabyl()
  naniar,      # exploración de datos faltantes
  validate,    # reglas de validación
  writexl,     # exportar a Excel
  here         # rutas reproducibles dentro del proyecto
)
```

### Lectura de datos

Se carga la encuesta cruda y, de una vez, se estandarizan los nombres de columna a `snake_case` con
`clean_names()`.

```r
df <- read_csv(here("Datos", "encuesta_cruda.csv")) %>% clean_names()
```

### Corregir nombres de variables

Las plataformas de formularios suelen exportar nombres de columna largos y poco claros. Antes de empezar a
trabajar, conviene renombrarlos a versiones cortas. `rename()` usa la sintaxis `nombre_nuevo = nombre_viejo`
y deja intactas las columnas que no se mencionan.

```r
df <- df %>%
  rename(
    establecimiento    = nombredelestablecimiento,
    respeto            = x1_respeto,
    participacion      = x2_participacion,
    conflictos         = x3_conflictos,
    pertenencia        = x4_pertenencia,
    otras_dificultades = x334_que_factores_afectan_la_convivencia_en_el_centro_educativo,
    nota               = nota_evaluacion
  )
```

### Contador maestro y bitácora de exclusiones

Antes de tocar nada se fija el número inicial de registros y se abre la **bitácora**, una tabla que irá
creciendo con cada filtro.

```r
n_inicial <- nrow(df)

bitacora <- tibble(
  etapa            = "Registros iniciales",
  motivo_exclusion = NA_character_,
  n_excluidos      = 0L,
  n_restante       = n_inicial
)

n_inicial
#> [1] 30
```

---

## Bloque 1 — Corregir tipos y valores

Este bloque arregla problemas de medición y captura. **No elimina filas**: solo deja los datos en
condiciones para poder depurarlos después.

### 1.1 Variable numérica leída como texto

Al importar, conviene revisar que cada variable tenga el tipo correcto. La edad debería ser numérica, pero
basta con que una sola respuesta venga escrita como "20 años" para que R lea toda la columna como texto
(`character`).

```r
class(df$edad)
#> [1] "character"
```

`parse_number()` de **readr** extrae el componente numérico y descarta el texto sobrante.

```r
df <- df %>%
  mutate(edad = parse_number(edad))
```

Si la edad hubiera quedado como texto, el filtro por edad del Bloque 2 sería imposible: este es el motivo
de corregir antes de depurar.

### 1.2 Anonimización de identificadores directos

La columna `nombre` identifica directamente a la persona y no debe conservarse. Se sustituye su contenido
por `NA`.

```r
# con R base
df["nombre"] <- NA          # equivalente: df$nombre <- NA

# con dplyr
df <- df %>%
  mutate(nombre = NA_character_)
```

Conviene anonimizar temprano, para que ninguna salida intermedia exponga datos personales.

### 1.3 Corrección puntual de errores con R base

Algunos errores son puntuales: un valor concreto en un registro identificable. Para estos casos, la
indexación con corchetes de R base es la herramienta más precisa, porque permite operar sobre una celda
específica sin tocar el resto. Conviene empezar con una exploración.

```r
df %>% count(area)   # exploración previa

# Corregir un error de digitación puntual
df$area[df$area == "Urbanaa"] <- "Urbana"

# Corregir un NA puntual del que se conoce el valor verdadero
df$area[df$codigo == "00-11-0099-41"] <- "Rural"
```

La regla práctica: R base directo para errores muy puntuales; recodificación sistemática (Bloque 3) para
patrones que se repiten.

---

## Bloque 2 — Depurar el universo de casos

Aquí se decide quién entra al análisis. Cada filtro elimina registros, y cada eliminación se anota en la
bitácora con su motivo. El patrón se repite en los cuatro pasos: se guarda el `n` previo, se filtra y se
registra cuántos se fueron.

### 2.1 Consentimiento informado

Quienes no consintieron participar deben salir.

```r
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
```

### 2.2 Limpieza por fecha (registros de prueba)

Durante la fase de pruebas del formulario se generan registros ficticios anteriores a la fecha oficial de
inicio de recolección. Primero conviene verificar que `start` sea de tipo `POSIXct`; si no lo es, se
transforma.

```r
# class(df$start)  # verificar el tipo; si no es POSIXct, descomentar la línea siguiente
# df <- df %>% mutate(start = as.POSIXct(start))

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
```

### 2.3 No respuesta excesiva

Se elimina a quien dejó sin contestar más de un porcentaje (modificable) del bloque de preguntas
sustantivas. El umbral se define como una constante para poder ajustarlo con facilidad.

El primer paso es identificar el bloque de preguntas. `match()` localiza una columna por su nombre y
devuelve su posición, de modo que un rango entre dos nombres selecciona todo el bloque intermedio. Hay dos
maneras de expresar ese bloque, y conviene distinguirlas porque devuelven cosas distintas:

```r
umbral_no_respuesta <- 0.30   # se modifica aquí si se quiere otro corte

# (A) NOMBRES de columnas: names(df)[ ... ] devuelve un vector de CARACTERES
vars_preguntas <- names(df)[
  match("respeto", names(df)):match("otras_dificultades", names(df))
]
vars_preguntas
#> [1] "respeto" "participacion" "conflictos" "pertenencia" "otras_dificultades"

# (B) ÍNDICES de columnas: el c(match:match, ...) devuelve un vector de POSICIONES (enteros)
rango_vars <- c(
  match("respeto", names(df)):match("pertenencia", names(df)),
  match("otras_dificultades", names(df)):match("otras_dificultades", names(df))
)
rango_vars
#> [1] 15 16 17 18 19
```

La diferencia es solo el corchete `names(df)[...]`: en `(A)` traduce las posiciones a **nombres**
(character); en `(B)` el rango se queda en **posiciones** (integer). La forma `(A)` por nombre encaja con
`all_of()`. La estructura de dos segmentos con `c()` de `(B)` solo es necesaria cuando las preguntas están
realmente repartidas en dos bloques separados del archivo; en esta lección las preguntas son contiguas, así
que basta con la forma `(A)`.

> Conviene verificar siempre qué columnas quedaron seleccionadas con `names(df)[rango_vars]` antes de
> usarlas, para asegurarse de que solo entraron preguntas y ninguna columna de identificación o de
> municipio (esas están casi vacías por los saltos del formulario e inflarían artificialmente la no
> respuesta).

Con el bloque definido, se calcula la proporción de `NA` por fila y se filtra. La expresión
`is.na(across(all_of(vars_preguntas)))` produce una matriz lógica (una celda por respuesta faltante), y
`rowMeans()` la convierte en la proporción de faltantes de cada persona.

```r
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
```

### 2.4 Fuera del rango de edad

El criterio de inclusión es tener 18 años o más. Este filtro solo es posible ahora porque la edad se
convirtió a numérica en el Bloque 1.

```r
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
```

### 2.5 Tabla de exclusiones

La bitácora ya contiene, paso a paso, cuántos registros se descartaron y por qué. Para tener el total en la
misma tabla, se agrega una fila final de totales. El total de excluidos se calcula antes, sobre las filas de
detalle ya registradas.

```r
total_excluidos <- sum(bitacora$n_excluidos, na.rm = TRUE)

bitacora <- bitacora %>%
  add_row(
    etapa            = "TOTAL",
    motivo_exclusion = "Total de registros excluidos",
    n_excluidos      = total_excluidos,
    n_restante       = nrow(df)
  )

bitacora
#> # A tibble: 6 × 4
#>   etapa                    motivo_exclusion                                     n_excluidos n_restante
#>   <chr>                    <chr>                                                      <int>      <int>
#> 1 Registros iniciales      NA                                                             0         30
#> 2 Filtro de consentimiento Sin consentimiento informado                                   3         27
#> 3 Filtro por fecha         Registro de prueba (previo al inicio de recolección)           2         25
#> 4 Filtro por no respuesta  No respondió > 30% del bloque de preguntas                     3         22
#> 5 Filtro por edad          Fuera del rango de edad (criterio de inclusión: 18+)           3         19
#> 6 TOTAL                    Total de registros excluidos                                  11         19
```

> Al incluir la fila TOTAL en la misma tabla, la columna `n_excluidos` ya no suma verticalmente de forma
> limpia (el total queda incluido en sí mismo). Si se va a sumar de nuevo en algún cálculo posterior,
> conviene excluir la fila `etapa == "TOTAL"` o calcular el total siempre a partir de las filas de detalle.

---

## Bloque 3 — Recodificación y categorías

No todo lo que se hace en esta etapa es "limpieza" en sentido estricto. Conviene distinguir dos cosas que a
menudo se confunden:

- **Limpieza:** corrige errores reales de los datos (inconsistencias de captura, escritura, estructura).
  Sin esta corrección, los datos están equivocados.
- **Decisión de análisis:** cambios que el investigador considera necesarios para el análisis, pero que no
  corrigen ningún error. Agrupar categorías o reordenar niveles para una tabla son elecciones, no arreglos.

Cada técnica de este bloque se marca con una de las dos etiquetas.

### 3.1 `case_match`, `case_when` e `if_else`

#### `case_match`  ·  *Limpieza*

La variable `sexo` llegó con valores inconsistentes ("M", "Masculino", "F", "Femenino"). Unificarlos es
limpieza: corrige una inconsistencia de captura. `case_match()` es la herramienta indicada cuando se trata
de **mapear valores viejos a valores nuevos** (reemplaza al antiguo `recode()`).

```r
df %>% count(sexo)   # explorar la variable

df <- df %>%
  mutate(sexo = case_match(sexo,
    c("M", "Masculino", "masculino") ~ "Masculino",
    c("F", "Femenino",  "femenino")  ~ "Femenino"
  ))
```

#### `case_when`  ·  *Decisión de análisis*

Crear grupos de edad no corrige ningún error: es una elección para facilitar tablas posteriores.
`case_when()` se usa cuando hay **varias reglas** evaluadas en orden.

```r
df <- df %>%
  mutate(grupo_edad = case_when(
    edad < 30 ~ "18 a 29",
    edad < 45 ~ "30 a 44",
    TRUE      ~ "45 o más"
  ))
```

#### `if_else`  ·  *Limpieza o decisión, según el caso*

`if_else()` es para **una sola condición binaria**. Sirve, por ejemplo, para sobreescribir un valor
erróneo sin tocar el resto de la columna: la propia columna va en el `else`, de modo que solo cambian las
filas que cumplen la condición.

```r
# Corregir una nota fuera de rango: si supera 100, ponerla en NA; si no, conservarla
df <- df %>%
  mutate(nota = if_else(nota > 100, NA_real_, nota))
```

Un detalle: `if_else()` es estricta con los tipos, así que para poner un faltante en una columna numérica
se usa `NA_real_` (no `NA` a secas); para una columna de texto sería `NA_character_`.

**Diferencia entre `case_when()` e `if_else()`.** Se usa `case_when()` cuando hay **múltiples reglas**
evaluadas en orden:

```r
grupo = case_when(
  a > 10 ~ "grande",
  a > 5  ~ "mediano",
  a > 0  ~ "pequeño",
  TRUE   ~ "cero o menos"
)
```

Cuando la lógica solo distingue entre dos casos (se cumple la condición o no), `if_else()` es la opción
correcta: es más clara y corta que un `case_when()` con una sola condición más el `TRUE`. `case_when()`
conviene cuando hay tres o más resultados posibles.

### 3.2 `grepl` para recodificar texto  ·  *Limpieza*

El departamento llegó con variantes de escritura ("Solola", "Sololá", "SOLOLÁ", "guatemala",
"QUETZALTENANGO"). Normalizarlo es limpieza. `grepl()` detecta un patrón de texto y devuelve `TRUE`/`FALSE`,
lo que permite usarlo dentro de `case_when()` sin enumerar cada variante.

```r
df %>% count(departamento)

df <- df %>%
  mutate(departamento = case_when(
    grepl("solol",    departamento, ignore.case = TRUE) ~ "Sololá",
    grepl("quetzal",  departamento, ignore.case = TRUE) ~ "Quetzaltenango",
    grepl("totonic",  departamento, ignore.case = TRUE) ~ "Totonicapán",
    grepl("guatemal", departamento, ignore.case = TRUE) ~ "Guatemala",
    TRUE ~ departamento
  ))
```

El argumento `ignore.case = TRUE` y un fragmento corto del patrón ("solol") capturan todas las variantes de
mayúsculas, minúsculas y acentos de una sola vez.

### 3.3 `fct_relevel` para ordenar niveles  ·  *Decisión de análisis*

Las respuestas tipo Likert ("Nada", "Poco", "Algo", "Bastante", "Mucho") son ordinales, pero R, por
defecto, las ordena alfabéticamente. Fijar el orden correcto no corrige ningún dato: es una decisión que
prepara las tablas y gráficos. Asegurar este orden durante la limpieza evita repetirlo en cada análisis.

```r
niveles_likert <- c("Nada", "Poco", "Algo", "Bastante", "Mucho")

df <- df %>%
  mutate(across(
    c(respeto, participacion, conflictos, pertenencia),
    ~ factor(.x, levels = niveles_likert)
  ))
```

Cuando una variable ya es factor y solo se quiere adelantar o reordenar algunos niveles, `fct_relevel()` es
más cómodo:

```r
df <- df %>%
  mutate(area = fct_relevel(area, "Urbana", "Rural"))

levels(df$area)
#> [1] "Urbana" "Rural"
```

### 3.4 `coalesce` para unir columnas con saltos de formulario  ·  *Limpieza estructural*

Los formularios con lógica de saltos generan un problema típico: por ejemplo, para asegurar que cada
municipio corresponda a su departamento, el formulario crea una columna de municipio por departamento (en el
caso real, las 22 columnas de los 22 departamentos). Cada persona llena solo una; las demás quedan en `NA`.
El resultado es un conjunto de columnas que en realidad representan una sola variable.

`coalesce()` toma el primer valor no faltante de varias columnas y las une en una sola:

```r
df <- df %>%
  mutate(municipio = coalesce(
    municipio_guatemala,
    municipio_solola,
    municipio_quetzaltenango,
    municipio_totonicapan
  ))
```

Para las 22 columnas reales, escribirlas una por una es impráctico. La versión escalable usa `reduce()`,
que aplica `coalesce()` de forma acumulada sobre todas las columnas que empiezan con `municipio_`:

```r
df <- df %>%
  mutate(municipio = reduce(across(starts_with("municipio_")), coalesce))
```

Una vez unificada la variable, las columnas de origen pueden descartarse.

---

## Bloque 4 — Datos faltantes y validación de reglas

### 4.1 Explorar faltantes con `naniar`

Antes de decidir qué hacer con los `NA`, conviene verlos. El paquete **naniar** resume y visualiza los
patrones de datos faltantes.

```r
df %>% miss_var_summary()   # tabla de faltantes por variable

gg_miss_var(df)             # gráfico de barras de faltantes por variable
vis_miss(df)                # mapa visual de toda la matriz de datos
```

> **Decisión importante sobre los `NA` en las tablas.** Algunas funciones, como `janitor::tabyl()`, manejan
> los faltantes automáticamente: muestran una fila para `NA` y ofrecen tanto el porcentaje sobre el total
> como el `valid_percent` (que excluye los `NA`).

```r
df %>% tabyl(area)
```

> Pero en muchos otros casos (sobre todo al construir tablas o gráficos finales) el `NA` no aparece como una
> categoría con nombre, y eso puede ocultar información relevante (por ejemplo, "no contestó" puede ser un
> dato en sí mismo). En esos casos la decisión correcta es **transformar explícitamente el `NA` en una
> categoría con nombre**, como "Sin información", para que se refleje en la tabla:

```r
df %>%
  mutate(participacion = replace_na(as.character(participacion), "Sin información")) %>%
  tabyl(participacion)
```

> No es una decisión automática: depende de si el faltante debe mostrarse o no en el resultado. Lo importante
> es tomarla de forma consciente y no dejar que la función decida por uno.

### 4.2 Identificar inconsistencias con `validate`

El paquete **validate** permite escribir las reglas de dominio del estudio de forma explícita, confrontarlas
con los datos y obtener un resumen de cuántos registros pasan, fallan o resultan `NA` por cada regla. Las
reglas se definen por separado de los datos, de modo que el mismo conjunto puede reutilizarse en otra ronda
de la encuesta.

Las reglas se definen dentro de `validator()`, separadas por comas, y cada una lleva un nombre opcional:

```r
reglas <- validator(
  edad_valida   = edad >= 18 & edad <= 100,
  nota_en_rango = nota >= 0 & nota <= 100,
  muni_si_gt    = if (departamento == "Guatemala") !is.na(municipio)
)

resultado <- confront(df, reglas)
summary(resultado)
```

**La lectura del resumen orienta las decisiones de limpieza:**

- `edad_valida` no debería tener fallos: el filtro por edad del Bloque 2 funcionó.
- `nota_en_rango` marca las notas fuera del rango plausible (hay una de 150 y una de −5). Estos valores deben
  investigarse antes de corregirlos o marcarlos como faltantes.
- `muni_si_gt` marca a alguien de Guatemala sin municipio, lo que delata un error de lógica de saltos.
  Conviene recuperar el dato de la fuente original si es posible.

Como se ve en el ejemplo, las reglas tienen un nombre, seguido del signo "=". La parte importante es lo que
va a la derecha del "=": una expresión de R que, evaluada sobre cada fila, devuelve `TRUE` (se cumple la
regla) o `FALSE` (falla la regla).

**Los cuatro tipos de regla más comunes**

1. **Rango o límite de una variable**, la más simple. Se afirma que un valor cae dentro de lo plausible. El
`&` significa "y" (deben cumplirse ambas); el `|` significaría "o".

```r
edad_valida    = edad >= 18,                    # la edad nunca es menor a 18
edad_plausible = edad >= 18 & edad <= 100,      # combina dos condiciones con &
nota_en_rango  = nota >= 0 & nota <= 100        # la nota está entre 0 y 100
```

2. **Pertenencia a un conjunto de valores permitidos**, útil para categóricas. El operador `%in%` verifica
que el valor esté en una lista válida. Falla en cualquier fila cuyo `sexo` no sea exactamente uno de esos
valores (por ejemplo, una "M" sin normalizar).

```r
sexo_valido = sexo %in% c("Masculino", "Femenino"),
area_valida = area %in% c("Urbana", "Rural")
```

3. **Relación entre dos o más variables**, donde se afirma algo que conecta columnas.

```r
fechas_coherentes = fecha_fin >= fecha_inicio,        # el fin nunca es antes del inicio
suma_correcta     = hombres + mujeres == total        # las partes suman el total
```

4. **Regla condicional ("si... entonces...")**, con `if (condición) consecuencia`. Solo exige la
consecuencia cuando se cumple la condición.

```r
muni_si_gt = if (departamento == "Guatemala") !is.na(municipio)
```

Se lee: "si el departamento es Guatemala, entonces el municipio no debe estar vacío". En las filas donde la
condición no se cumple (no es Guatemala), la regla pasa automáticamente.

**La clave para escribirlas: piensa en positivo.** El error más común es escribir la regla pensando en el
problema ("quiero encontrar las notas mayores a 100"). `validate` espera lo contrario: se escribe la
condición sana. En todos los casos se describe el estado correcto, no el error; `validate` se encarga de
marcar dónde no se cumple.

**Cómo leer el resultado.** El resumen tiene una fila por regla con columnas clave:

- `passes`: cuántas filas la cumplen.
- `fails`: cuántas la violan (ahí están los problemas).
- `nNA`: cuántas no se pudieron evaluar porque había un `NA` de por medio.

Para ver exactamente qué registros fallan una regla:

```r
violating(df, resultado["nota_en_rango"])
```

La decisión de qué hacer con cada inconsistencia (corregir, imputar o eliminar) es del investigador;
`validate` solo las pone sobre la mesa de forma sistemática.

---

## Bloque 5 — Exportar el conjunto de datos limpio

Concluida la depuración, se guarda el resultado. Con **writexl** se exporta a Excel: un archivo con los datos
limpios y otro con la bitácora de exclusiones, de modo que quede documentada la trazabilidad del proceso.

```r
write_xlsx(df, here("Datos", "Datos limpios", "encuesta_limpia.xlsx"))

write_xlsx(bitacora, here("Datos", "Datos limpios", "bitacora de limpieza.xlsx"))
```

Con esto, el proyecto cuenta con un archivo limpio, reproducible y acompañado del registro de cómo se pasó
de 30 registros iniciales a 19 casos válidos.

> Los procesos de **combinación de bases** (joins, `bind_rows`, `bind_cols`) y de **reestructuración**
> (`separate_longer_delim`, `separate_wider_delim`) se tratan en la lección de reestructuración y combinación
> de datos, que parte del archivo `encuesta_limpia.xlsx` producido aquí.
