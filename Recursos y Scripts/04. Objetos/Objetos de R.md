# Objetos en R

## 1. ¿Qué es un objeto?

Prácticamente todo lo que se crea en R es un objeto. Un número, un conjunto de datos, un resultado estadístico, un gráfico, una función: todos son objetos. Se puede pensar en un objeto como una caja con un nombre en la etiqueta y un contenido adentro. El nombre permite referirse al contenido más adelante sin tener que volver a escribirlo o calcularlo.

Cuando se escribe una expresión en la consola, R la evalúa e imprime el resultado, pero ese resultado se pierde. La utilidad de los objetos es precisamente que permiten guardar resultados para usarlos después.

```r
# Esto calcula la raíz cuadrada de 100, pero el resultado se pierde
sqrt(100)
## [1] 10

# Esto guarda el resultado en un objeto llamado "resultado"
resultado <- sqrt(100)

# Ahora se puede usar ese objeto en cualquier momento
resultado
## [1] 10
```

Un objeto tiene al menos dos propiedades fundamentales: un **nombre** y un **valor**. Pero además, dependiendo del tipo de objeto, puede tener otras propiedades como su modo (el tipo de dato que contiene), su longitud, sus dimensiones, sus nombres de fila o columna, entre otras. La función `str()` es una de las más útiles para examinar la estructura de cualquier objeto.

```r
x <- c(4, 67, 23, 4, 10, 35)
str(x)
##  num [1:6] 4 67 23 4 10 35
```

La salida de `str()` indica que `x` es un vector numérico (`num`) con 6 elementos (`[1:6]`), y muestra los valores.

---

## 2. Asignación a objetos

Para crear un objeto se utiliza el **operador de asignación** `<-`, que se lee como "recibe" o "obtiene". La forma general es:

```r
nombre <- valor
```

Esto significa: "el objeto `nombre` recibe `valor`".

```r
x <- 5
mi_texto <- "Hola mundo"
```

Aunque R también permite usar `=` para asignar, la convención en la comunidad de R es usar `<-` porque hace explícita la dirección de la asignación: el nombre está a la izquierda y el valor a la derecha. En RStudio, el atajo de teclado **Alt + -** (guion) inserta `<-` automáticamente.

### Cuidado con los espacios

Es importante no dejar espacio entre `<` y `-`, porque R interpreta `< -` (con espacio) como una pregunta lógica, no como una asignación:

```r
x <- 5    # Asignación: x recibe el valor 5
x < -5    # Pregunta lógica: ¿x es menor que -5? Resultado: FALSE
```

### Reglas para nombrar objetos

Los nombres de objetos deben cumplir ciertas reglas:

- No pueden comenzar con un número (`1x` no es válido, pero `x1` sí lo es).
- No pueden contener espacios (`mi variable` no es válido; se puede usar `mi_variable` o `mi.variable`).
- No pueden contener caracteres especiales como `!`, `@`, `#`, etc. (se permiten `.` y `_`).
- Conviene que sean cortos pero descriptivos. Un nombre como `a` es fácil de escribir pero difícil de recordar; un nombre como `promedio_ventas_anuales_region_norte` es descriptivo pero tedioso de escribir.

```r
# Nombres válidos
edad <- 32
grupo.control <- c(5, 8, 12)
total_2024 <- 1500

# Nombres NO válidos
# 1edad <- 32          # comienza con número
# mi variable <- 32   # contiene espacio
# total! <- 32        # contiene carácter especial
```

### Sobrescritura de objetos

Si se asigna un nuevo valor a un nombre que ya existe, R reemplaza el valor anterior sin avisar.

```r
x <- 10
x
## [1] 10

x <- 99
x
## [1] 99
```

Esto es algo que requiere atención, porque no hay advertencia ni confirmación.

### Modificar un objeto requiere reasignarlo

Un punto que suele causar confusión: realizar una operación con un objeto no cambia el objeto a menos que se reasigne el resultado.

```r
z <- 0
z + 1
## [1] 1

z
## [1] 0    # z sigue siendo 0, porque no se reasignó
```

Para que el cambio se conserve:

```r
z <- z + 1
z
## [1] 1
```

---

## 3. Sensibilidad a mayúsculas y minúsculas (*case sensitivity*)

R distingue entre mayúsculas y minúsculas. Esto significa que `x`, `X`, `miDato`, `MiDato` y `MIDATO` son todos objetos completamente diferentes.

```r
edad <- 25
Edad <- 30
EDAD <- 35

edad
## [1] 25
Edad
## [1] 30
EDAD
## [1] 35
```

Esto aplica tanto a nombres de objetos como a nombres de funciones. Si una función se llama `data.frame()`, escribir `Data.Frame()` o `data.Frame()` producirá un error. Si se obtiene un error inesperado, una de las primeras cosas que conviene verificar es que los nombres estén escritos exactamente como deben estar.

---

## 4. Tipos de datos (modos)

Antes de hablar de los tipos de objetos, es necesario entender los tipos de datos que R puede almacenar. El tipo de dato se conoce como el **modo** (*mode*) del objeto, y se puede consultar con la función `mode()` o con `str()`.

Los tipos de datos más comunes son:

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| `numeric` | Números (enteros o decimales) | `42`, `3.14` |
| `character` | Texto (cadenas de caracteres) | `"hola"`, `"R"` |
| `logical` | Valores lógicos | `TRUE`, `FALSE` |

```r
mode(42)
## [1] "numeric"

mode("hola")
## [1] "character"

mode(TRUE)
## [1] "logical"
```

Hay otros modos como `integer` (enteros explícitos), `complex` (números complejos) y `function`, pero los tres anteriores son los más frecuentes en el trabajo cotidiano.

### ¿Por qué importan los tipos de datos?

Porque determinan qué operaciones se pueden realizar. No se puede calcular la media de texto, ni concatenar números como si fueran cadenas de caracteres sin antes convertirlos.

```r
mean(c(1, 10))
## [1] 5.5

mean(c("1", "10"))
## Warning: argument is not numeric or logical, returning NA
```

### Coerción: convertir entre tipos

R tiene funciones de la forma `as.tipo()` para convertir un objeto de un tipo a otro. Esto se llama **coerción**.

```r
as.numeric(TRUE)
## [1] 1

as.character(42)
## [1] "42"

as.logical(0)
## [1] FALSE
```

Hay que tener cuidado: si la conversión no tiene sentido, R produce valores `NA` (datos faltantes) con una advertencia.

```r
as.numeric("perro")
## Warning: NAs introduced by coercion
## [1] NA
```

### Vectores con tipos mezclados

Un vector solo puede contener un tipo de dato. Si se mezclan tipos, R convierte todo al tipo más general, siguiendo la jerarquía: `logical` → `numeric` → `character`.

```r
c("a", 1, TRUE)
## [1] "a"    "1"    "TRUE"    # Todo se convirtió a character

c(FALSE, 10, TRUE)
## [1]  0 10  1               # Los lógicos se convirtieron a numéricos
```

---

## 5. Objetos atómicos y objetos recursivos

Antes de recorrer los distintos tipos de objetos en R, conviene entender una distinción fundamental que organiza toda la clasificación: la diferencia entre objetos **atómicos** y objetos **recursivos**.

### Objetos atómicos

Un objeto atómico es aquel cuyos elementos son todos del mismo tipo y no pueden descomponerse en subestructuras más pequeñas. "Atómico" viene de la misma idea que en química: son las unidades indivisibles del lenguaje. Si se intenta meter elementos de distintos tipos, R los convierte todos a un tipo común (la coerción que se describió anteriormente).

Los objetos atómicos en R son:

- **Vectores** (el tipo atómico por excelencia)
- **Matrices** (vectores con atributo de dimensión)
- **Arrays** (vectores con atributo de dimensión múltiple)
- **Factores** (vectores de enteros con atributo de niveles)

Todos estos comparten una propiedad: no se puede poner un vector dentro de otro vector. Si se intenta, R simplemente aplana todo en una sola secuencia:

```r
c(c(1, 2), c(3, 4))
## [1] 1 2 3 4
```

No se obtuvo un vector que contiene dos vectores, sino un solo vector de cuatro elementos. Esto es lo que significa ser atómico: los elementos no tienen estructura interna.

Se puede verificar si un objeto es atómico con `is.atomic()`:

```r
x <- c(10, 20, 30)
is.atomic(x)
## [1] TRUE

m <- matrix(1:6, nrow = 2)
is.atomic(m)
## [1] TRUE

f <- factor(c("a", "b", "a"))
is.atomic(f)
## [1] TRUE
```

### Objetos recursivos

Un objeto recursivo es aquel que puede contener otros objetos dentro de sí, incluyendo objetos del mismo tipo. Son "recursivos" porque su estructura puede anidarse: una lista puede contener otra lista, que a su vez contiene otra lista.

Los objetos recursivos en R son:

- **Listas**
- **Data frames** (que son un caso especial de lista)
- **Tibbles** (que heredan de data frame)

```r
mi_lista <- list(
  numeros = c(1, 2, 3),
  otra_lista = list(a = "hola", b = TRUE)
)

is.atomic(mi_lista)
## [1] FALSE

is.recursive(mi_lista)
## [1] TRUE
```

Un data frame es recursivo porque internamente es una lista de vectores:

```r
df <- data.frame(x = 1:3, y = c("a", "b", "c"))

is.atomic(df)
## [1] FALSE

is.recursive(df)
## [1] TRUE
```

### ¿Por qué importa esta distinción?

Porque aclara comportamientos de R que de otro modo parecen arbitrarios. Dos ejemplos concretos:

**Primer ejemplo: `c()` se comporta distinto según el tipo de objeto.** Con objetos atómicos, `c()` aplana todo. Con listas, `c()` concatena sin aplanar:

```r
# Atómico: se aplana
c(c(1, 2), c(3, 4))
## [1] 1 2 3 4

# Recursivo: se concatena
c(list(a = 1), list(b = 2))
## $a
## [1] 1
##
## $b
## [1] 2
```

**Segundo ejemplo: `is.vector()` no pregunta lo que parece.** La función `is.vector()` no pregunta "¿es esto un vector?" en el sentido coloquial. Pregunta algo más estricto: "¿es esto un vector atómico que no tiene atributos más allá de `names`?". Por eso un factor devuelve `FALSE` aunque sea una secuencia de datos, y un data frame también devuelve `FALSE`:

```r
x <- c(1, 2, 3)
is.vector(x)
## [1] TRUE

f <- factor(c("a", "b"))
is.vector(f)
## [1] FALSE       # Tiene atributos extra (class, levels)

is.atomic(f)
## [1] TRUE        # Pero sí es atómico
```

`is.atomic()` es la pregunta más fundamental: ¿todos los elementos son del mismo tipo y no hay subestructuras? `is.vector()` es más restrictiva y menos intuitiva, por lo que en la práctica `is.atomic()` y `class()` suelen ser más útiles para entender qué tipo de objeto se tiene.

### Esquema general

```
Objetos en R
├── Atómicos (un solo tipo de dato, sin subestructura)
│   ├── Vector
│   ├── Matriz (vector + dimensiones)
│   ├── Array (vector + dimensiones múltiples)
│   └── Factor (vector de enteros + niveles)
│
└── Recursivos (pueden contener otros objetos)
    ├── Lista
    ├── Data frame (lista de vectores de igual longitud)
    └── Tibble (data frame moderno, tidyverse)
```

Esta distinción no es algo que se necesite recordar constantemente en el trabajo diario, pero es la lógica que está detrás de gran parte del comportamiento de R. Cuando algo se comporta de forma inesperada, preguntarse "¿estoy trabajando con algo atómico o con algo recursivo?" suele orientar hacia la respuesta.

---

## 6. Tipos de objetos

R tiene varios tipos de objetos que permiten organizar datos de distintas formas. Se pueden pensar como contenedores con diferentes estructuras.

### 6.1. Vectores

El vector es el tipo de objeto más básico y fundamental en R. Es una secuencia ordenada de elementos, todos del mismo tipo. Incluso un solo número en R es, técnicamente, un vector de longitud 1.

```r
# Un escalar es un vector de longitud 1
x <- 5
length(x)
## [1] 1

# Un vector con múltiples elementos
edades <- c(25, 30, 22, 41)
nombres <- c("Ana", "Luis", "Carla", "Pedro")
```

La función `c()` (de *concatenar* o *combinar*) es la forma más directa de crear un vector. Existen otras formas útiles:

```r
# Secuencia con el operador :
1:10
## [1]  1  2  3  4  5  6  7  8  9 10

# Secuencia con más control
seq(from = 0, to = 1, by = 0.25)
## [1] 0.00 0.25 0.50 0.75 1.00

# Repetición
rep("A", times = 4)
## [1] "A" "A" "A" "A"
```

Los vectores tienen una propiedad importante: su **longitud**, que se obtiene con `length()`.

```r
length(edades)
## [1] 4
```

Para acceder a elementos específicos de un vector, se usan corchetes `[ ]` con el índice de la posición deseada:

```r
edades[1]       # Primer elemento
## [1] 25

edades[c(1, 3)] # Primero y tercero
## [1] 25 22

edades[-2]      # Todos menos el segundo
## [1] 25 22 41
```

Los elementos de un vector pueden tener nombres:

```r
zapato <- c(marca = "Nike", talla = "10", modelo = "Pegasus")
zapato["marca"]
## marca
## "Nike"
```

### 6.2. Matrices

Una matriz es un vector con dos dimensiones: filas y columnas. Al igual que los vectores, una matriz solo puede contener un tipo de dato.

```r
mi_matriz <- matrix(data = 1:12, nrow = 3, ncol = 4)
mi_matriz
##      [,1] [,2] [,3] [,4]
## [1,]    1    4    7   10
## [2,]    2    5    8   11
## [3,]    3    6    9   12
```

Por defecto, `matrix()` llena los datos por columna. Si se desea llenar por fila, se usa `byrow = TRUE`.

También se pueden crear matrices combinando vectores con `cbind()` (unir como columnas) o `rbind()` (unir como filas):

```r
x <- 1:3
y <- 4:6
cbind(x, y)
##      x y
## [1,] 1 4
## [2,] 2 5
## [3,] 3 6
```

Para acceder a elementos de una matriz se usan dos índices separados por coma: `[fila, columna]`. Si se omite uno de los dos, se obtienen todas las filas o todas las columnas.

```r
mi_matriz[2, 3]    # Fila 2, columna 3
## [1] 8

mi_matriz[1, ]     # Fila 1, todas las columnas
## [1]  1  4  7 10

mi_matriz[, 2]     # Todas las filas, columna 2
## [1] 4 5 6
```

Las funciones `nrow()`, `ncol()` y `dim()` permiten consultar las dimensiones de una matriz.

### 6.3. Arrays

Un array es una generalización de la matriz a más de dos dimensiones. Se puede pensar como un cubo (o hipercubo) de datos.

```r
mi_array <- array(
  data = 1:24,
  dim = c(3, 4, 2),
  dimnames = list(
    fila = c("f1", "f2", "f3"),
    columna = c("c1", "c2", "c3", "c4"),
    capa = c("capa1", "capa2")
  )
)
```

Esto crea un array de 3 filas × 4 columnas × 2 capas. Para acceder a elementos, se necesitan tres índices:

```r
mi_array["f1", "c2", "capa1"]  # Por nombre
mi_array[1, 2, 1]              # Por posición
```

Al igual que los vectores y las matrices, los arrays solo pueden contener un tipo de dato.

### 6.4. Listas

Una lista es una colección de objetos que pueden ser de distintos tipos y distintas longitudes. Si un vector es una caja que contiene elementos del mismo tipo, una lista es un carrito de supermercado que puede contener cajas de todo tipo: vectores, matrices, otras listas, funciones, etc.

```r
mi_lista <- list(
  numeros = c(1, 2, 3),
  texto = "hola",
  matriz = matrix(1:4, nrow = 2)
)

str(mi_lista)
## List of 3
##  $ numeros: num [1:3] 1 2 3
##  $ texto  : chr "hola"
##  $ matriz : int [1:2, 1:2] 1 2 3 4
```

Para acceder a los elementos de una lista se usan dobles corchetes `[[ ]]` o el operador `$`:

```r
mi_lista[[1]]         # Primer elemento (el vector numérico)
mi_lista$texto        # Elemento llamado "texto"
mi_lista[["matriz"]]  # Elemento llamado "matriz"
```

Las listas son importantes porque muchas funciones de R devuelven sus resultados como listas. Por ejemplo, cuando se ejecuta una prueba estadística, el resultado es un objeto tipo lista que contiene el estadístico de prueba, el valor p, los intervalos de confianza, etc.

### 6.5. Data frames

Un data frame es el tipo de objeto más utilizado para almacenar datos tabulares. Es técnicamente una lista de vectores de la misma longitud, donde cada vector representa una columna (variable) del conjunto de datos. A diferencia de una matriz, un data frame puede contener columnas de distintos tipos.

```r
encuesta <- data.frame(
  id = 1:5,
  sexo = c("m", "m", "f", "f", "m"),
  edad = c(24, 25, 42, 56, 22),
  stringsAsFactors = FALSE
)

encuesta
##   id sexo edad
## 1  1    m   24
## 2  2    m   25
## 3  3    f   42
## 4  4    f   56
## 5  5    m   22
```

El argumento `stringsAsFactors = FALSE` evita que R convierta automáticamente las columnas de texto en factores, lo cual puede causar comportamientos inesperados.

Para acceder a una columna se usa el operador `$`:

```r
encuesta$edad
## [1] 24 25 42 56 22

mean(encuesta$edad)
## [1] 33.8
```

Las funciones más útiles para explorar un data frame son:

```r
head(encuesta)       # Primeras filas
str(encuesta)        # Estructura
names(encuesta)      # Nombres de las columnas
nrow(encuesta)       # Número de filas
ncol(encuesta)       # Número de columnas
summary(encuesta)    # Resumen estadístico
```

Se pueden agregar nuevas columnas con facilidad:

```r
encuesta$grupo <- c("A", "B", "A", "B", "A")
```

Y se puede filtrar el data frame usando indexación lógica o la función `subset()`:

```r
# Solo participantes mayores de 30
encuesta[encuesta$edad > 30, ]

# Equivalente con subset()
subset(encuesta, edad > 30)
```

### 6.6. Funciones

Las funciones también son objetos en R. Esto significa que se pueden asignar a un nombre, pasar como argumento a otras funciones e incluso almacenar dentro de listas.

```r
mi_funcion <- function(x) {
  x * 2
}

mi_funcion(5)
## [1] 10

mode(mi_funcion)
## [1] "function"
```

Aunque la creación de funciones se trata en detalle en temas posteriores, es importante saber desde ahora que en R las funciones no son algo separado de los objetos: son un tipo más de objeto.

### 6.7. Factores

Un factor es un tipo de objeto diseñado para representar variables categóricas, es decir, variables que solo pueden tomar un conjunto finito de valores (llamados **niveles**). Internamente, R almacena los factores como números enteros, pero los muestra con sus etiquetas.

```r
colores <- factor(c("rojo", "azul", "rojo", "verde", "azul"))
colores
## [1] rojo  azul  rojo  verde azul
## Levels: azul rojo verde

str(colores)
##  Factor w/ 3 levels "azul","rojo",..: 2 1 2 3 1
```

Los factores son relevantes para análisis estadísticos (ANOVA, regresiones con variables categóricas) y para controlar el orden de las categorías en gráficos. Sin embargo, pueden causar problemas cuando se confunden con caracteres, por lo que es importante saber distinguirlos.

---

## 7. ¿Cuándo se usa cada tipo de objeto?

### Vectores

Son el objeto más utilizado. Representan cualquier serie de datos de un solo tipo: una columna de edades, una lista de nombres, una secuencia de respuestas verdadero/falso. Las operaciones aritméticas y lógicas se aplican elemento por elemento de forma automática (lo que R llama **vectorización**), lo que los hace extremadamente eficientes.

```r
precios <- c(100, 200, 150, 300)
precios * 1.12   # Aplicar IVA a todos los precios de una vez
## [1] 112.0 224.0 168.0 336.0
```

Todo en R se construye sobre vectores. Una matriz es un vector con dimensiones. Una columna de un data frame es un vector. Entender vectores es entender la base de R.

### Factores

Se usan cuando una variable tiene un número finito de categorías y ese carácter categórico importa para el análisis. Son esenciales para análisis estadísticos como ANOVA o regresión con variables categóricas, y para controlar el orden de las categorías en gráficos (por ejemplo, que "Bajo" aparezca antes que "Medio" y "Alto", no en orden alfabético).

```r
nivel <- factor(c("Alto", "Bajo", "Medio", "Alto"),
                levels = c("Bajo", "Medio", "Alto"))
nivel
## [1] Alto  Bajo  Medio Alto
## Levels: Bajo Medio Alto
```

Si los datos son puramente texto y no se necesitan niveles fijos, un vector de caracteres es suficiente. Los factores agregan valor cuando el análisis o la visualización requieren que R trate los datos como categorías.

### Matrices

Se usan principalmente en álgebra lineal y en cálculos que requieren operaciones matemáticas sobre tablas numéricas homogéneas: multiplicación de matrices, transposiciones, descomposiciones, correlaciones. Muchos modelos estadísticos internamente trabajan con matrices.

```r
# Matriz de correlación
datos <- matrix(c(1, 0.8, 0.8, 1), nrow = 2,
                dimnames = list(c("X", "Y"), c("X", "Y")))
datos
##     X   Y
## X 1.0 0.8
## Y 0.8 1.0
```

También son útiles cuando los datos son una grilla numérica pura (como una tabla de distancias entre ciudades, o los píxeles de una imagen en escala de grises). Si los datos tienen columnas de distintos tipos, lo que se necesita es un data frame.

### Data frames

Es el formato estándar para almacenar datos tabulares en R, equivalente a una hoja de cálculo. Cada columna puede ser de un tipo diferente (números, texto, lógicos, factores), lo cual los hace ideales para prácticamente cualquier conjunto de datos del mundo real: encuestas, registros médicos, datos experimentales, datos económicos.

```r
pacientes <- data.frame(
  id = 1:4,
  nombre = c("Ana", "Luis", "Carla", "Pedro"),
  edad = c(34, 28, 45, 52),
  fumador = c(FALSE, TRUE, FALSE, TRUE),
  stringsAsFactors = FALSE
)
```

La mayoría de las funciones de importación de datos (`read.csv()`, `read.table()`, `read_excel()`) devuelven data frames, y la mayoría de las funciones de análisis esperan recibir data frames. Es el tipo de objeto con el que más se interactúa en la práctica.

### Listas

Las listas son el contenedor más flexible de R. Se usan cuando se necesita agrupar objetos heterogéneos que no encajan en una tabla rectangular. El caso de uso más importante es que **la mayoría de las funciones estadísticas devuelven listas**:

```r
resultado <- t.test(c(5, 8, 6, 7), mu = 5)
class(resultado)
## [1] "htest"

str(resultado)
# Contiene: estadístico t, valor p, intervalo de confianza,
# media muestral, hipótesis, etc.

resultado$p.value
## [1] 0.05797
```

Otros usos comunes incluyen almacenar resultados de simulaciones, agrupar múltiples data frames o matrices relacionados, y construir estructuras de datos complejas.

### Arrays

Los arrays son la generalización de las matrices a más de dos dimensiones. En la práctica cotidiana de análisis de datos son menos frecuentes, pero aparecen en contextos donde los datos tienen una estructura tridimensional (o superior) natural. Por ejemplo, datos demográficos organizados por año × grupo de edad × sexo, o imágenes a color (alto × ancho × canal RGB), o resultados de simulaciones repetidas con múltiples parámetros.

```r
# Datos de ventas: 4 trimestres × 3 productos × 2 años
ventas <- array(
  data = sample(100:500, 24),
  dim = c(4, 3, 2),
  dimnames = list(
    trimestre = paste0("Q", 1:4),
    producto = c("A", "B", "C"),
    anio = c("2024", "2025")
  )
)

# Ventas del producto B en 2025
ventas[, "B", "2025"]
```

Si los datos pueden organizarse bien en una tabla de dos dimensiones, una matriz o un data frame son preferibles por ser más simples de manipular.

---

## 8. Diferencia entre matrices, tablas, data frames y tibbles

Estos tipos de objetos pueden parecer similares porque todos muestran datos organizados en filas y columnas. Pero tienen diferencias importantes en su estructura, sus restricciones y su propósito.

### Matriz (`matrix`)

Es un vector con dimensiones. Solo puede contener **un tipo de dato** (generalmente numérico). No tiene concepto de "variables" o "observaciones"; simplemente es una grilla de valores. Se usa para operaciones matemáticas.

```r
m <- matrix(1:6, nrow = 2, ncol = 3)
m
##      [,1] [,2] [,3]
## [1,]    1    3    5
## [2,]    2    4    6

class(m)
## [1] "matrix" "array"
```

### Data frame (`data.frame`)

Es una lista de vectores de la misma longitud. Cada columna puede ser de un **tipo diferente**. Tiene nombres de columnas (variables) y nombres de filas (observaciones). Es el formato estándar para datos estadísticos en R base.

```r
df <- data.frame(nombre = c("Ana", "Luis"), edad = c(30, 25))
df
##   nombre edad
## 1    Ana   30
## 2   Luis   25

class(df)
## [1] "data.frame"
```

### Tibble (`tbl_df`)

Un tibble es una versión moderna del data frame, introducida por el paquete `tibble` y adoptada como estándar en el ecosistema **tidyverse**. Internamente sigue siendo un data frame (hereda su clase), pero con comportamientos más predecibles y una impresión en consola más informativa.

```r
library(tibble)

tb <- tibble(nombre = c("Ana", "Luis"), edad = c(30, 25))
tb
## # A tibble: 2 × 2
##   nombre  edad
##   <chr>  <dbl>
## 1 Ana       30
## 2 Luis      25

class(tb)
## [1] "tbl_df"     "tbl"        "data.frame"
```

Las diferencias principales con un data frame clásico son:

- **Impresión más limpia**: solo muestra las primeras 10 filas y las columnas que caben en la pantalla, y debajo de cada nombre de columna indica el tipo de dato (`<chr>`, `<dbl>`, `<int>`, etc.).
- **No convierte texto a factores**: un tibble nunca convierte automáticamente las columnas de texto en factores (en versiones antiguas de R, `data.frame()` lo hacía por defecto).
- **No usa nombres de fila**: los tibbles desalientan el uso de `rownames()`. Si los datos tienen un identificador, se espera que sea una columna explícita.
- **Subconjunto más estricto**: al extraer una sola columna con `[`, un tibble devuelve otro tibble, no un vector. Esto evita comportamientos inesperados, pero puede sorprender a quienes vienen de data frames clásicos.

```r
# Con data frame, una sola columna devuelve un vector
df[, "edad"]
## [1] 30 25

# Con tibble, una sola columna devuelve otro tibble
tb[, "edad"]
## # A tibble: 2 × 1
##    edad
##   <dbl>
## 1    30
## 2    25

# Para obtener un vector desde un tibble, se usa $ o [[
tb$edad
## [1] 30 25
```

En la práctica, quien trabaja con tidyverse trabaja con tibbles todo el tiempo (las funciones `read_csv()`, `select()`, `filter()`, `mutate()` y demás devuelven tibbles). Quien trabaja con R base trabaja con data frames. Ambos son compatibles entre sí: casi cualquier función que acepta un data frame acepta un tibble, y se puede convertir entre ellos con `as_tibble()` y `as.data.frame()`.

### Tabla (`table`)

Una tabla es el resultado de la función `table()`, que cuenta frecuencias. Es un tipo de array especializado en conteos. No se usa para almacenar datos crudos, sino para resumir datos categóricos.

```r
colores <- c("rojo", "azul", "rojo", "verde", "azul", "rojo")
t <- table(colores)
t
## colores
##  azul  rojo verde
##     2     3     1

class(t)
## [1] "table"
```

### Comparación resumida

| Característica | `matrix` | `data.frame` | `tibble` | `table` |
|---------------|----------|-------------|----------|---------|
| Tipos de dato | Un solo tipo | Mixtos por columna | Mixtos por columna | Enteros (conteos) |
| Propósito principal | Cálculo matemático | Almacenar datos tabulares | Almacenar datos tabulares (tidyverse) | Resumir frecuencias |
| Columnas con nombre | Opcional | Sí, siempre | Sí, siempre | Sí (los niveles) |
| Nombres de fila | Opcional | Sí | No (desalentado) | Depende de dimensiones |
| Texto a factor automático | No aplica | Sí (en versiones < 4.0) | Nunca | No aplica |
| Muestra tipo de columna | No | No | Sí (`<chr>`, `<dbl>`, etc.) | No |
| Se crea con | `matrix()`, `cbind()` | `data.frame()`, `read.csv()` | `tibble()`, `read_csv()` | `table()` |
| Paquete | R base | R base | `tibble` / tidyverse | R base |
| Acceso a datos | `[fila, col]` | `$col`, `[fila, col]` | `$col`, `[fila, col]` | `[nombre]`, `[fila, col]` |

Un error frecuente es confundir una tabla de frecuencias (resultado de `table()`) con un data frame. Si se necesita manipular una tabla como si fuera un data frame, se puede convertir con `as.data.frame()`:

```r
as.data.frame(t)
##   colores Freq
## 1    azul    2
## 2    rojo    3
## 3   verde    1
```

De la misma forma, si se trabaja en tidyverse y se recibe un data frame clásico, se puede convertir con `as_tibble()`:

```r
as_tibble(df)
## # A tibble: 2 × 2
##   nombre  edad
##   <chr>  <dbl>
## 1 Ana       30
## 2 Luis      25
```

---

## 9. Resumen visual de los tipos de objetos

| Tipo | Dimensiones | Tipos de dato | Ejemplo de creación |
|------|-------------|---------------|---------------------|
| Vector | 1 | Un solo tipo | `c(1, 2, 3)` |
| Matriz | 2 (filas × columnas) | Un solo tipo | `matrix(1:6, nrow=2)` |
| Array | n (n dimensiones) | Un solo tipo | `array(1:24, dim=c(3,4,2))` |
| Lista | 1 (jerárquica) | Mixtos | `list(a=1, b="hola")` |
| Data frame | 2 (filas × columnas) | Mixtos por columna | `data.frame(x=1:3, y=c("a","b","c"))` |
| Tibble | 2 (filas × columnas) | Mixtos por columna | `tibble(x=1:3, y=c("a","b","c"))` |
| Factor | 1 | Categórico | `factor(c("a","b","a"))` |
| Función | — | — | `function(x) x+1` |

---

## 10. Inspeccionar objetos: `mode()`, `class()` y el sistema de objetos de R

### `mode()` vs `class()`

Estas dos funciones responden preguntas distintas sobre un objeto. `mode()` responde **cómo almacena R los datos internamente**, mientras que `class()` responde **cómo se comporta el objeto cuando se le aplican funciones**.

```r
x <- factor(c("rojo", "azul", "rojo"))

mode(x)
## [1] "numeric"

class(x)
## [1] "factor"
```

Este ejemplo es revelador: un factor se almacena internamente como números enteros (cada nivel es un número), pero su clase es `"factor"`, lo cual determina que funciones como `print()`, `summary()` o `plot()` lo traten como una variable categórica y no como una serie de números.

Otro ejemplo:

```r
mi_df <- data.frame(a = 1:3, b = c("x", "y", "z"))

mode(mi_df)
## [1] "list"

class(mi_df)
## [1] "data.frame"
```

Un data frame se almacena como una lista (porque es una colección de vectores), pero su clase es `"data.frame"`, y eso es lo que hace que funciones como `head()`, `summary()` o `subset()` sepan cómo trabajar con él.

En resumen:

| Función | Pregunta que responde | Ejemplo con un factor |
|---------|----------------------|----------------------|
| `mode()` | ¿Cómo se almacenan los datos? | `"numeric"` |
| `class()` | ¿Cómo se comporta el objeto? | `"factor"` |
| `typeof()` | ¿Cuál es el tipo interno exacto? | `"integer"` |

Para el trabajo cotidiano, `class()` suele ser más informativa que `mode()`, porque indica cómo otras funciones van a interpretar el objeto. `str()` combina ambas perspectivas en una sola salida y sigue siendo la herramienta más completa.

### R, S y los sistemas de objetos

R no nació de cero. Es una implementación del lenguaje **S**, desarrollado en los laboratorios Bell (AT&T) a partir de los años 70 por John Chambers y colaboradores. El lenguaje S pasó por varias versiones, y dos de ellas dejaron huella en cómo R maneja los objetos hoy.

**S3** es el sistema de objetos más antiguo y más simple. Viene de la versión 3 del lenguaje S. En este sistema, un objeto es simplemente una estructura de datos (un vector, una lista, etc.) con un atributo llamado `class` pegado encima. No hay definiciones formales ni validación: si se le asigna la clase `"data.frame"` a una lista, R confía en que esa lista tiene la estructura correcta. Cuando se llama a una función como `print(x)`, R revisa la clase de `x` y busca una versión especializada de `print` para esa clase (por ejemplo, `print.data.frame` o `print.factor`). Este mecanismo se llama **despacho de métodos** (*method dispatch*).

La gran mayoría de los objetos que se usan en el día a día en R son objetos S3: vectores, data frames, factores, resultados de `lm()`, de `t.test()`, etc.

**S4** es un sistema más formal y estricto, introducido en la versión 4 del lenguaje S. Requiere definiciones explícitas de las clases (qué campos tiene, de qué tipo es cada uno) y valida que los objetos cumplan con esa definición. Los objetos S4 usan `@` en lugar de `$` para acceder a sus componentes, y se encuentran principalmente en paquetes especializados como los del proyecto Bioconductor (bioinformática).

Para efectos prácticos en un curso introductorio, casi todo lo que se encuentra es S3. Pero es útil saber que el sistema existe, porque explica cosas como por qué `print()` produce resultados tan diferentes según el tipo de objeto que recibe: no es una sola función, sino muchas funciones especializadas que R selecciona automáticamente según la clase del objeto.

```r
# print() se comporta distinto según la clase
x <- 1:5
print(x)
## [1] 1 2 3 4 5

y <- matrix(1:6, nrow = 2)
print(y)
##      [,1] [,2] [,3]
## [1,]    1    3    5
## [2,]    2    4    6

# Detrás de escena, R está llamando print.default() para x
# y print.matrix() para y
```

### Herramientas para inspeccionar objetos

| Función | Qué devuelve |
|---------|-------------|
| `str()` | Estructura del objeto: tipo, dimensiones, primeros valores |
| `class()` | La clase del objeto (`vector`, `matrix`, `data.frame`, etc.) |
| `mode()` | El modo de almacenamiento (`numeric`, `character`, `logical`, etc.) |
| `typeof()` | El tipo interno exacto (`integer`, `double`, `character`, etc.) |
| `length()` | Número de elementos |
| `dim()` | Dimensiones (para matrices, arrays y data frames) |
| `names()` | Nombres de los elementos o columnas |
| `head()` | Primeras filas de un objeto tabular |
| `summary()` | Resumen estadístico |

De todas estas, `str()` es probablemente la más versátil. Ante la duda sobre cualquier objeto, `str()` es el primer recurso.

```r
str(encuesta)
## 'data.frame':	5 obs. of  4 variables:
##  $ id   : int  1 2 3 4 5
##  $ sexo : chr  "m" "m" "f" "f" ...
##  $ edad : num  24 25 42 56 22
##  $ grupo: chr  "A" "B" "A" "B" ...
```

---

## 11. Herencia y pertenencia de clases

### Herencia (*inheritance*)

En R, las clases pueden tener relaciones jerárquicas: una clase puede **heredar** de otra. Esto significa que un objeto de una clase más específica también es, al mismo tiempo, un objeto de la clase más general de la que hereda. Lo que hereda no es solo un nombre: hereda comportamientos. Si existe una función definida para la clase general y no existe una versión específica para la clase particular, R usa la versión general.

El ejemplo más claro es el tibble:

```r
library(tibble)
tb <- tibble(x = 1:3, y = c("a", "b", "c"))

class(tb)
## [1] "tbl_df"     "tbl"        "data.frame"
```

La salida de `class()` muestra tres clases, ordenadas de la más específica a la más general. Esto significa que `tb` es un objeto de clase `tbl_df`, que hereda de `tbl`, que a su vez hereda de `data.frame`. En la práctica, esto implica que cualquier función que funcione con un data frame también funciona con un tibble, porque un tibble *es* un data frame (además de ser otras cosas). Si una función tiene una versión especializada para tibbles, R usa esa versión; si no la tiene, busca hacia arriba en la jerarquía hasta encontrar una que sirva.

Otro ejemplo es la matriz:

```r
m <- matrix(1:6, nrow = 2)
class(m)
## [1] "matrix" "array"
```

Una matriz hereda de array. Toda matriz es un array (de dos dimensiones), pero no todo array es una matriz (un array puede tener tres o más dimensiones).

La herencia también explica por qué los resultados de funciones estadísticas funcionan con `print()`, `summary()` y `plot()` sin necesidad de escribir versiones nuevas de esas funciones para cada tipo de resultado. Un objeto de clase `"lm"` (modelo lineal) tiene su propia versión de `summary()`, llamada `summary.lm()`. Si se creara una clase `"lm_especial"` que hereda de `"lm"` pero no define su propio `summary()`, R usaría `summary.lm()` automáticamente.

Se puede visualizar la cadena de herencia como una escalera: R empieza buscando en el escalón más específico y va subiendo hasta encontrar lo que necesita.

```
tbl_df
  └── tbl
       └── data.frame
            └── (comportamiento por defecto)
```

### Pertenencia (*membership*)

Verificar si un objeto pertenece a una clase determinada es una operación frecuente, especialmente cuando se escribe código que necesita comportarse de forma diferente según el tipo de entrada. R ofrece varias formas de hacer esta verificación.

Las funciones de la familia `is.*()` son las más directas:

```r
x <- data.frame(a = 1:3)

is.data.frame(x)
## [1] TRUE

is.matrix(x)
## [1] FALSE

is.list(x)
## [1] TRUE
```

El último resultado es revelador: un data frame **es** una lista (porque internamente se almacena como una lista de vectores). La función `is.list()` responde sobre la estructura interna, no sobre la clase visible.

La función `inherits()` es más precisa cuando se quiere preguntar si un objeto pertenece a una clase específica o a alguna de sus clases ancestras:

```r
library(tibble)
tb <- tibble(x = 1:3)

inherits(tb, "tbl_df")
## [1] TRUE

inherits(tb, "data.frame")
## [1] TRUE

inherits(tb, "matrix")
## [1] FALSE
```

La diferencia entre `is.data.frame()` e `inherits(x, "data.frame")` es sutil en la mayoría de los casos, pero `inherits()` es más general: funciona con cualquier nombre de clase, mientras que las funciones `is.*()` solo existen para las clases más comunes.

### ¿Por qué importa esto?

Entender herencia y pertenencia ayuda a resolver confusiones frecuentes:

- ¿Por qué `subset()` funciona con un tibble si nunca se mencionan los tibbles en la documentación de `subset()`? Porque un tibble hereda de data frame, y `subset()` está definida para data frames.
- ¿Por qué `is.list()` devuelve `TRUE` para un data frame? Porque un data frame es, internamente, una lista. La pertenencia a una clase no excluye la pertenencia a otra.
- ¿Por qué `is.vector()` devuelve `FALSE` para un factor, aunque un factor parece un vector? Porque un factor tiene atributos adicionales (niveles y clase) que hacen que `is.vector()` —que verifica si el objeto es un vector *puro* sin atributos extra— devuelva `FALSE`. Sin embargo, `is.atomic()` devuelve `TRUE`, porque los datos subyacentes sí son atómicos.

```r
f <- factor(c("a", "b", "a"))

is.vector(f)
## [1] FALSE

is.atomic(f)
## [1] TRUE
```

La regla práctica es: `class()` indica cómo se comporta un objeto, `is.*()` e `inherits()` permiten verificar esa pertenencia antes de actuar, y la herencia garantiza que los objetos más específicos no pierdan la funcionalidad de sus clases ancestras.