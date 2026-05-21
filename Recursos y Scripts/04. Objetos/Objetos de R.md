# Objetos en R

## 1. ¿Qué es un objeto?

Prácticamente todo lo que se crea en R es un objeto. Un número, un conjunto de datos, un resultado estadístico, un gráfico, una función: todos son objetos. Un objeto es simplemente un espacio en la memoria de la computadora al que se le asigna un nombre y un contenido. El nombre permite referirse al contenido más adelante sin tener que volver a escribirlo o calcularlo.

Cuando se escribe una expresión en la consola, R la evalúa e imprime el resultado, pero ese resultado se pierde inmediatamente. La utilidad de los objetos es precisamente que permiten guardar resultados para reutilizarlos después.

```r
# Esto calcula el logaritmo natural de 50, pero el resultado se pierde
log(50)
## [1] 3.912023

# Esto guarda el resultado en un objeto llamado "resultado"
resultado <- log(50)

# Ahora se puede usar ese objeto en cualquier momento
resultado
## [1] 3.912023
```

Un objeto tiene al menos dos propiedades fundamentales: un **nombre** y un **valor**. Pero además, dependiendo del tipo de objeto, puede tener otras propiedades como su modo (el tipo de dato que contiene), su longitud, sus dimensiones, sus nombres de fila o columna, entre otras. La función `str()` es una de las más útiles para examinar la estructura de cualquier objeto.

```r
temperaturas <- c(18.5, 22.3, 19.1, 25.0, 21.7)
str(temperaturas)
##  num [1:5] 18.5 22.3 19.1 25 21.7
```

La salida de `str()` indica que `temperaturas` es un vector numérico (`num`) con 5 elementos (`[1:5]`), y muestra los valores.

---

## 2. Asignación a objetos

Para crear un objeto se utiliza el **operador de asignación** `<-`, que se lee como "recibe" o "obtiene". La forma general es:

```r
nombre <- valor
```

Esto significa: "el objeto `nombre` recibe `valor`".

```r
n_participantes <- 120
saludo <- "Buenos días"
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
altura <- 1.72
grupo.experimental <- c(12, 15, 9)
ingreso_2023 <- 45000

# Nombres NO válidos
# 1altura <- 1.72          # comienza con número
# mi ingreso <- 45000     # contiene espacio
# resultado! <- 100       # contiene carácter especial
```

### Sobrescritura de objetos

Si se asigna un nuevo valor a un nombre que ya existe, R reemplaza el valor anterior sin avisar.

```r
precio <- 50
precio
## [1] 50

precio <- 75
precio
## [1] 75
```

Esto es algo que requiere atención, porque no hay advertencia ni confirmación.

### Modificar un objeto requiere reasignarlo

Un punto que suele causar confusión: realizar una operación con un objeto no cambia el objeto a menos que se reasigne el resultado.

```r
contador <- 10
contador + 5
## [1] 15

contador
## [1] 10    # contador sigue siendo 10, porque no se reasignó
```

Para que el cambio se conserve:

```r
contador <- contador + 5
contador
## [1] 15
```

---

## 3. Sensibilidad a mayúsculas y minúsculas (*case sensitivity*)

R distingue entre mayúsculas y minúsculas. Esto significa que `x`, `X`, `miDato`, `MiDato` y `MIDATO` son todos objetos completamente diferentes.

```r
pais <- "Guatemala"
Pais <- "México"
PAIS <- "Colombia"

pais
## [1] "Guatemala"
Pais
## [1] "México"
PAIS
## [1] "Colombia"
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
mode(7.5)
## [1] "numeric"

mode("Guatemala")
## [1] "character"

mode(FALSE)
## [1] "logical"
```

Hay otros modos como `integer` (enteros explícitos), `complex` (números complejos) y `function`, pero los tres anteriores son los más frecuentes en el trabajo cotidiano.

### ¿Por qué importan los tipos de datos?

Porque determinan qué operaciones se pueden realizar. No se puede calcular la media de texto, ni concatenar números como si fueran cadenas de caracteres sin antes convertirlos.

```r
mean(c(20, 30))
## [1] 25

mean(c("20", "30"))
## Warning: argument is not numeric or logical, returning NA
```

### Coerción: convertir entre tipos

R tiene funciones de la forma `as.tipo()` para convertir un objeto de un tipo a otro. Esto se llama **coerción**.

```r
as.numeric(TRUE)
## [1] 1

as.character(150)
## [1] "150"

as.logical(0)
## [1] FALSE
```

Hay que tener cuidado: si la conversión no tiene sentido, R produce valores `NA` (datos faltantes) con una advertencia.

```r
as.numeric("café")
## Warning: NAs introduced by coercion
## [1] NA
```

### Vectores con tipos mezclados

Un vector solo puede contener un tipo de dato. Si se mezclan tipos, R convierte todo al tipo más general, siguiendo la jerarquía: `logical` → `numeric` → `character`.

```r
c("rojo", 5, TRUE)
## [1] "rojo" "5"    "TRUE"    # Todo se convirtió a character

c(TRUE, 42, FALSE)
## [1]  1 42  0               # Los lógicos se convirtieron a numéricos
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
c(c(10, 20), c(30, 40))
## [1] 10 20 30 40
```

No se obtuvo un vector que contiene dos vectores, sino un solo vector de cuatro elementos. Esto es lo que significa ser atómico: los elementos no tienen estructura interna.

Se puede verificar si un objeto es atómico con `is.atomic()`:

```r
notas <- c(85, 92, 78)
is.atomic(notas)
## [1] TRUE

m <- matrix(1:6, nrow = 2)
is.atomic(m)
## [1] TRUE

region <- factor(c("norte", "sur", "norte"))
is.atomic(region)
## [1] TRUE
```

### Objetos recursivos

Un objeto recursivo es aquel que puede contener otros objetos dentro de sí, incluyendo objetos del mismo tipo. Son "recursivos" porque su estructura puede anidarse: una lista puede contener otra lista, que a su vez contiene otra lista.

Los objetos recursivos en R son:

- **Listas**
- **Data frames** (que son un caso especial de lista)
- **Tibbles** (que heredan de data frame)

```r
registro <- list(
  valores = c(5, 10, 15),
  info = list(fuente = "encuesta", fecha = "2025-03")
)

is.atomic(registro)
## [1] FALSE

is.recursive(registro)
## [1] TRUE
```

Un data frame es recursivo porque internamente es una lista de vectores:

```r
df <- data.frame(ciudad = c("Lima", "Bogotá"), poblacion = c(10, 8))

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
c(c(10, 20), c(30, 40))
## [1] 10 20 30 40

# Recursivo: se concatena
c(list(ciudad = "Lima"), list(pais = "Perú"))
## $ciudad
## [1] "Lima"
##
## $pais
## [1] "Perú"
```

**Segundo ejemplo: `is.vector()` no pregunta lo que parece.** La función `is.vector()` no pregunta "¿es esto un vector?" en el sentido coloquial. Pregunta algo más estricto: "¿es esto un vector atómico que no tiene atributos más allá de `names`?". Por eso un factor devuelve `FALSE` aunque sea una secuencia de datos, y un data frame también devuelve `FALSE`:

```r
x <- c(5, 10, 15)
is.vector(x)
## [1] TRUE

region <- factor(c("norte", "sur"))
is.vector(region)
## [1] FALSE       # Tiene atributos extra (class, levels)

is.atomic(region)
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
temperatura <- 22.5
length(temperatura)
## [1] 1

# Un vector con múltiples elementos
lluvias_mm <- c(120, 85, 200, 45, 310)
ciudades <- c("Lima", "Bogotá", "Quito", "Santiago")
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
rep("control", times = 4)
## [1] "control" "control" "control" "control"
```

Los vectores tienen una propiedad importante: su **longitud**, que se obtiene con `length()`.

```r
length(lluvias_mm)
## [1] 5
```

Para acceder a elementos específicos de un vector, se usan corchetes `[ ]` con el índice de la posición deseada:

```r
lluvias_mm[1]       # Primer elemento
## [1] 120

lluvias_mm[c(2, 4)] # Segundo y cuarto
## [1] 85 45

lluvias_mm[-3]      # Todos menos el tercero
## [1] 120  85  45 310
```

Los elementos de un vector pueden tener nombres:

```r
cafe <- c(tipo = "arábica", origen = "Antigua", altitud_m = "1500")
cafe["origen"]
## origen
## "Antigua"
```

### 6.2. Matrices

Una matriz es un vector con dos dimensiones: filas y columnas. Al igual que los vectores, una matriz solo puede contener un tipo de dato.

```r
ventas <- matrix(data = c(150, 200, 180, 220, 170, 250),
                 nrow = 3, ncol = 2)
ventas
##      [,1] [,2]
## [1,]  150  220
## [2,]  200  170
## [3,]  180  250
```

Por defecto, `matrix()` llena los datos por columna. Si se desea llenar por fila, se usa `byrow = TRUE`.

También se pueden crear matrices combinando vectores con `cbind()` (unir como columnas) o `rbind()` (unir como filas):

```r
enero <- c(30, 28, 35)
febrero <- c(25, 22, 30)
cbind(enero, febrero)
##      enero febrero
## [1,]    30      25
## [2,]    28      22
## [3,]    35      30
```

Para acceder a elementos de una matriz se usan dos índices separados por coma: `[fila, columna]`. Si se omite uno de los dos, se obtienen todas las filas o todas las columnas.

```r
ventas[2, 1]    # Fila 2, columna 1
## [1] 200

ventas[1, ]     # Fila 1, todas las columnas
## [1] 150 220

ventas[, 2]     # Todas las filas, columna 2
## [1] 220 170 250
```

Las funciones `nrow()`, `ncol()` y `dim()` permiten consultar las dimensiones de una matriz.

### 6.3. Arrays

Un array es una generalización de la matriz a más de dos dimensiones. Se puede pensar como un cubo (o hipercubo) de datos.

```r
inventario <- array(
  data = 1:24,
  dim = c(4, 3, 2),
  dimnames = list(
    trimestre = paste0("Q", 1:4),
    producto = c("café", "té", "chocolate"),
    año = c("2024", "2025")
  )
)
```

Esto crea un array de 4 trimestres × 3 productos × 2 años. Para acceder a elementos, se necesitan tres índices:

```r
inventario["Q1", "café", "2025"]  # Por nombre
inventario[1, 1, 2]               # Por posición
```

Al igual que los vectores y las matrices, los arrays solo pueden contener un tipo de dato.

### 6.4. Listas

Una lista es una colección de objetos que pueden ser de distintos tipos y distintas longitudes. Si un vector es un contenedor con compartimentos iguales, una lista es un archivador con cajones de distintos tamaños, donde cada cajón puede guardar cualquier cosa: vectores, matrices, otras listas, funciones, etc.

```r
experimento <- list(
  participantes = 45,
  grupos = c("control", "tratamiento"),
  resultados = matrix(c(82, 91, 78, 88), nrow = 2)
)

str(experimento)
## List of 3
##  $ participantes: num 45
##  $ grupos       : chr [1:2] "control" "tratamiento"
##  $ resultados   : num [1:2, 1:2] 82 91 78 88
```

Para acceder a los elementos de una lista se usan dobles corchetes `[[ ]]` o el operador `$`:

```r
experimento[[1]]            # Primer elemento (el número 45)
experimento$grupos          # Elemento llamado "grupos"
experimento[["resultados"]] # Elemento llamado "resultados"
```

Las listas son importantes porque muchas funciones de R devuelven sus resultados como listas. Por ejemplo, cuando se ejecuta una prueba estadística, el resultado es un objeto tipo lista que contiene el estadístico de prueba, el valor p, los intervalos de confianza, etc.

### 6.5. Data frames

Un data frame es el tipo de objeto más utilizado para almacenar datos tabulares. Es técnicamente una lista de vectores de la misma longitud, donde cada vector representa una columna (variable) del conjunto de datos. A diferencia de una matriz, un data frame puede contener columnas de distintos tipos.

```r
cafeteria <- data.frame(
  bebida = c("espresso", "latte", "americano", "mocha"),
  precio = c(15, 25, 18, 30),
  disponible = c(TRUE, TRUE, FALSE, TRUE),
  stringsAsFactors = FALSE
)

cafeteria
##      bebida precio disponible
## 1  espresso     15       TRUE
## 2     latte     25       TRUE
## 3 americano     18      FALSE
## 4     mocha     30       TRUE
```

El argumento `stringsAsFactors = FALSE` evita que R convierta automáticamente las columnas de texto en factores, lo cual puede causar comportamientos inesperados.

Para acceder a una columna se usa el operador `$`:

```r
cafeteria$precio
## [1] 15 25 18 30

mean(cafeteria$precio)
## [1] 22
```

Las funciones más útiles para explorar un data frame son:

```r
head(cafeteria)       # Primeras filas
str(cafeteria)        # Estructura
names(cafeteria)      # Nombres de las columnas
nrow(cafeteria)       # Número de filas
ncol(cafeteria)       # Número de columnas
summary(cafeteria)    # Resumen estadístico
```

Se pueden agregar nuevas columnas con facilidad:

```r
cafeteria$tamaño <- c("S", "M", "M", "L")
```

Y se puede filtrar el data frame usando indexación lógica o la función `subset()`:

```r
# Solo bebidas con precio mayor a 20
cafeteria[cafeteria$precio > 20, ]

# Equivalente con subset()
subset(cafeteria, precio > 20)
```

### 6.6. Funciones

Las funciones también son objetos en R. Esto significa que se pueden asignar a un nombre, pasar como argumento a otras funciones e incluso almacenar dentro de listas.

```r
convertir_km <- function(millas) {
  millas * 1.60934
}

convertir_km(10)
## [1] 16.0934

mode(convertir_km)
## [1] "function"
```

Aunque la creación de funciones se trata en detalle en temas posteriores, es importante saber desde ahora que en R las funciones no son algo separado de los objetos: son un tipo más de objeto.

### 6.7. Factores

Un factor es un tipo de objeto diseñado para representar variables categóricas, es decir, variables que solo pueden tomar un conjunto finito de valores (llamados **niveles**). Internamente, R almacena los factores como números enteros, pero los muestra con sus etiquetas.

```r
estaciones <- factor(c("verano", "invierno", "verano", "otoño", "invierno"))
estaciones
## [1] verano   invierno verano   otoño    invierno
## Levels: invierno otoño verano

str(estaciones)
##  Factor w/ 3 levels "invierno","otoño",..: 3 1 3 2 1
```

Los factores son relevantes para análisis estadísticos (ANOVA, regresiones con variables categóricas) y para controlar el orden de las categorías en gráficos. Sin embargo, pueden causar problemas cuando se confunden con caracteres, por lo que es importante saber distinguirlos.

### 6.8. Objetos generados por paquetes y funciones

Los tipos de objetos que se describieron hasta ahora (vectores, matrices, listas, data frames, etc.) son los bloques fundamentales de R. Pero en la práctica, al usar paquetes y funciones especializadas, se generan objetos con clases propias que internamente están construidos sobre esos mismos bloques, generalmente listas.

**Resultados de funciones estadísticas.** Cuando se ejecuta una regresión lineal con `lm()`, una prueba t con `t.test()` o un análisis de varianza con `aov()`, R no devuelve un número ni una tabla: devuelve un objeto con su propia clase. Ese objeto es, internamente, una lista que contiene múltiples piezas de información (coeficientes, residuos, valores p, intervalos de confianza, etc.), y su clase determina cómo lo muestran funciones como `print()`, `summary()` o `plot()`.

```r
modelo <- lm(dist ~ speed, data = cars)
class(modelo)
## [1] "lm"

typeof(modelo)
## [1] "list"
```

El objeto `modelo` es de clase `"lm"`, pero su tipo interno es una lista. Lo mismo ocurre con los resultados de `t.test()` (clase `"htest"`), `aov()` (clase `"aov"`) y muchas otras funciones. No es necesario memorizar cada clase; lo importante es saber que estos objetos son listas disfrazadas, y que se puede explorar su contenido con `str()` y acceder a sus componentes con `$` o `[[]]`.

**Gráficos.** En R base, funciones como `plot()`, `hist()` o `boxplot()` generan gráficos como un efecto secundario (dibujan en el dispositivo gráfico), pero algunas también devuelven objetos invisiblemente. Por ejemplo, `hist()` devuelve un objeto de clase `"histogram"` que contiene los puntos de corte, los conteos y las densidades. En el ecosistema de `ggplot2`, los gráficos son explícitamente objetos: se pueden asignar a un nombre, modificar después y combinar.

```r
library(ggplot2)
mi_grafico <- ggplot(cars, aes(x = speed, y = dist)) + geom_point()
class(mi_grafico)
## [1] "gg"     "ggplot"
```

El objeto `mi_grafico` no se dibuja hasta que se imprime (escribiendo su nombre o llamando `print()`). Esto permite construir gráficos por partes, guardarlos para después o pasarlos a funciones que los modifiquen.

**Objetos de paquetes especializados.** Algunos paquetes definen sus propias clases para representar estructuras que no encajan cómodamente en los tipos base. Un ejemplo es el paquete `flextable`, que crea objetos de clase `"flextable"` para representar tablas con formato listas para exportar a Word, PowerPoint o HTML. Internamente, un objeto `flextable` es una lista S3 con atributos que describen el contenido, el formato de cada celda, los bordes, las fuentes, etc. Pero desde la perspectiva del usuario, se comporta como una tabla visual que se puede personalizar con funciones propias del paquete.

El punto clave es que el concepto de objeto en R no se limita a vectores y data frames. Todo lo que se genera en R — un modelo, un gráfico, una tabla formateada — es un objeto con una clase, y esa clase determina su comportamiento. La función `str()` sigue siendo la herramienta más confiable para abrir cualquiera de estos objetos y entender qué hay adentro.

---

## 7. ¿Cuándo se usa cada tipo de objeto?

### Vectores

Son el objeto más utilizado. Representan cualquier serie de datos de un solo tipo: una columna de edades, una serie de mediciones, una secuencia de respuestas verdadero/falso. Las operaciones aritméticas y lógicas se aplican elemento por elemento de forma automática (lo que R llama **vectorización**), lo que los hace extremadamente eficientes.

```r
precios_usd <- c(12, 8.5, 15, 22)
tipo_cambio <- 7.85
precios_gtq <- precios_usd * tipo_cambio
precios_gtq
## [1]  94.20  66.73 117.75 172.70
```

Todo en R se construye sobre vectores. Una matriz es un vector con dimensiones. Una columna de un data frame es un vector. Entender vectores es entender la base de R.

### Factores

Se usan cuando una variable tiene un número finito de categorías y ese carácter categórico importa para el análisis. Son esenciales para análisis estadísticos como ANOVA o regresión con variables categóricas, y para controlar el orden de las categorías en gráficos (por ejemplo, que "Bajo" aparezca antes que "Medio" y "Alto", no en orden alfabético).

```r
satisfaccion <- factor(
  c("alta", "baja", "media", "alta"),
  levels = c("baja", "media", "alta")
)
satisfaccion
## [1] alta  baja  media alta
## Levels: baja media alta
```

Si los datos son puramente texto y no se necesitan niveles fijos, un vector de caracteres es suficiente. Los factores agregan valor cuando el análisis o la visualización requieren que R trate los datos como categorías.

### Matrices

Se usan principalmente en álgebra lineal y en cálculos que requieren operaciones matemáticas sobre tablas numéricas homogéneas: multiplicación de matrices, transposiciones, descomposiciones, correlaciones. Muchos modelos estadísticos internamente trabajan con matrices.

```r
# Matriz de distancias (en km) entre tres ciudades
distancias <- matrix(
  c(0, 330, 470, 330, 0, 580, 470, 580, 0),
  nrow = 3,
  dimnames = list(
    c("Guatemala", "SanSalvador", "Tegucigalpa"),
    c("Guatemala", "SanSalvador", "Tegucigalpa")
  )
)
distancias
##             Guatemala SanSalvador Tegucigalpa
## Guatemala           0         330         470
## SanSalvador       330           0         580
## Tegucigalpa       470         580           0
```

También son útiles cuando los datos son una grilla numérica pura (como una tabla de distancias, una imagen en escala de grises o una matriz de covarianza). Si los datos tienen columnas de distintos tipos, lo que se necesita es un data frame.

### Data frames

Es el formato estándar para almacenar datos tabulares en R, equivalente a una hoja de cálculo. Cada columna puede ser de un tipo diferente (números, texto, lógicos, factores), lo cual los hace ideales para prácticamente cualquier conjunto de datos del mundo real: encuestas, registros médicos, datos experimentales, datos económicos.

```r
estudiantes <- data.frame(
  id = 1:4,
  nombre = c("María", "José", "Lucía", "Carlos"),
  nota_final = c(88, 72, 95, 61),
  aprobado = c(TRUE, TRUE, TRUE, FALSE),
  stringsAsFactors = FALSE
)
```

La mayoría de las funciones de importación de datos (`read.csv()`, `read.table()`, `read_excel()`) devuelven data frames, y la mayoría de las funciones de análisis esperan recibir data frames. Es el tipo de objeto con el que más se interactúa en la práctica.

### Listas

Las listas son el contenedor más flexible de R. Se usan cuando se necesita agrupar objetos heterogéneos que no encajan en una tabla rectangular. El caso de uso más importante es que **la mayoría de las funciones estadísticas devuelven listas**:

```r
muestra_a <- c(23, 27, 25, 22, 28)
muestra_b <- c(30, 35, 32, 29, 33)
prueba <- t.test(muestra_a, muestra_b)
class(prueba)
## [1] "htest"

# El resultado contiene múltiples piezas de información
prueba$p.value
prueba$conf.int
prueba$estimate
```

Otros usos comunes incluyen almacenar configuraciones de un modelo, agrupar múltiples tablas de datos relacionadas, o guardar los resultados de una simulación donde cada iteración produce objetos de distinto tipo.

### Arrays

Los arrays son la generalización de las matrices a más de dos dimensiones. En la práctica cotidiana de análisis de datos son menos frecuentes, pero aparecen en contextos donde los datos tienen una estructura tridimensional (o superior) natural. Por ejemplo, datos de ventas organizados por mes × producto × sucursal, mediciones climáticas por estación × variable × año, o imágenes a color representadas como alto × ancho × canal RGB.

```r
# Mediciones de temperatura: 3 meses × 2 estaciones × 2 años
clima <- array(
  data = c(18, 22, 25, 15, 19, 23, 20, 24, 27, 17, 21, 25),
  dim = c(3, 2, 2),
  dimnames = list(
    mes = c("enero", "febrero", "marzo"),
    estacion = c("central", "norte"),
    año = c("2024", "2025")
  )
)

# Temperatura de febrero en la estación norte, 2025
clima["febrero", "norte", "2025"]
```

Si los datos pueden organizarse bien en una tabla de dos dimensiones, una matriz o un data frame son preferibles por ser más simples de manipular.

---

## 8. Diferencia entre matrices, tablas, data frames y tibbles

Estos tipos de objetos pueden parecer similares porque todos muestran datos organizados en filas y columnas. Pero tienen diferencias importantes en su estructura, sus restricciones y su propósito.

### Matriz (`matrix`)

Es un vector con dimensiones. Solo puede contener **un tipo de dato** (generalmente numérico). No tiene concepto de "variables" o "observaciones"; simplemente es una grilla de valores. Se usa para operaciones matemáticas.

```r
m <- matrix(c(10, 20, 30, 40, 50, 60), nrow = 2, ncol = 3)
m
##      [,1] [,2] [,3]
## [1,]   10   30   50
## [2,]   20   40   60

class(m)
## [1] "matrix" "array"
```

### Data frame (`data.frame`)

Es una lista de vectores de la misma longitud. Cada columna puede ser de un **tipo diferente**. Tiene nombres de columnas (variables) y nombres de filas (observaciones). Es el formato estándar para datos estadísticos en R base.

```r
df <- data.frame(
  municipio = c("Mixco", "Villa Nueva"),
  poblacion_miles = c(500, 600)
)
df
##     municipio poblacion_miles
## 1       Mixco             500
## 2 Villa Nueva             600

class(df)
## [1] "data.frame"
```

### Tibble (`tbl_df`)

Un tibble es una versión moderna del data frame, introducida por el paquete `tibble` y adoptada como estándar en el ecosistema **tidyverse**. Internamente sigue siendo un data frame (hereda su clase), pero con comportamientos más predecibles y una impresión en consola más informativa.

```r
library(tibble)

tb <- tibble(
  municipio = c("Mixco", "Villa Nueva"),
  poblacion_miles = c(500, 600)
)
tb
## # A tibble: 2 × 2
##   municipio   poblacion_miles
##   <chr>                 <dbl>
## 1 Mixco                   500
## 2 Villa Nueva             600

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
df[, "poblacion_miles"]
## [1] 500 600

# Con tibble, una sola columna devuelve otro tibble
tb[, "poblacion_miles"]
## # A tibble: 2 × 1
##   poblacion_miles
##             <dbl>
## 1             500
## 2             600

# Para obtener un vector desde un tibble, se usa $ o [[
tb$poblacion_miles
## [1] 500 600
```

En la práctica, quien trabaja con tidyverse trabaja con tibbles todo el tiempo (las funciones `read_csv()`, `select()`, `filter()`, `mutate()` y demás devuelven tibbles). Quien trabaja con R base trabaja con data frames. Ambos son compatibles entre sí: casi cualquier función que acepta un data frame acepta un tibble, y se puede convertir entre ellos con `as_tibble()` y `as.data.frame()`.

### Tabla (`table`)

Una tabla es el resultado de la función `table()`, que cuenta frecuencias. Es un tipo de array especializado en conteos. No se usa para almacenar datos crudos, sino para resumir datos categóricos.

```r
transporte <- c("bus", "carro", "bus", "moto", "carro", "bus")
conteo <- table(transporte)
conteo
## transporte
##   bus carro  moto
##     3     2     1

class(conteo)
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
as.data.frame(conteo)
##   transporte Freq
## 1        bus    3
## 2      carro    2
## 3       moto    1
```

De la misma forma, si se trabaja en tidyverse y se recibe un data frame clásico, se puede convertir con `as_tibble()`:

```r
as_tibble(df)
## # A tibble: 2 × 2
##   municipio   poblacion_miles
##   <chr>                 <dbl>
## 1 Mixco                   500
## 2 Villa Nueva             600
```

---

## 9. Resumen visual de los tipos de objetos

| Tipo | Dimensiones | Tipos de dato | Ejemplo de creación |
|------|-------------|---------------|---------------------|
| Vector | 1 | Un solo tipo | `c(10, 20, 30)` |
| Matriz | 2 (filas × columnas) | Un solo tipo | `matrix(1:6, nrow=2)` |
| Array | n (n dimensiones) | Un solo tipo | `array(1:24, dim=c(3,4,2))` |
| Lista | 1 (jerárquica) | Mixtos | `list(a=1, b="hola")` |
| Data frame | 2 (filas × columnas) | Mixtos por columna | `data.frame(x=1:3, y=c("a","b","c"))` |
| Tibble | 2 (filas × columnas) | Mixtos por columna | `tibble(x=1:3, y=c("a","b","c"))` |
| Factor | 1 | Categórico | `factor(c("a","b","a"))` |
| Función | — | — | `function(x) x+1` |

---

## 10. Inspeccionar objetos: `mode()`, `class()`, `typeof()` y el sistema de objetos de R

### `mode()`, `class()` y `typeof()`

Estas tres funciones responden preguntas distintas sobre un objeto. Parecen redundantes, pero cada una opera en un nivel diferente.

`typeof()` es la más técnica. Responde **cómo almacena R los datos a nivel del motor interno (el lenguaje C que está debajo de R)**. Devuelve el tipo de dato tal como lo ve la implementación: `"double"` para números decimales, `"integer"` para enteros, `"character"` para texto, `"logical"` para valores lógicos, `"list"` para listas, `"closure"` para funciones definidas por el usuario, etc.

`mode()` es una versión simplificada de `typeof()`. Agrupa varios tipos internos bajo etiquetas más generales. Por ejemplo, `typeof()` distingue entre `"double"` e `"integer"`, pero `mode()` llama a ambos `"numeric"`. Es una función que viene heredada del lenguaje S y se mantiene por compatibilidad, pero en la práctica es la menos informativa de las tres.

`class()` responde una pregunta completamente diferente: **cómo se comporta el objeto cuando se le aplican funciones**. La clase es lo que determina qué versión de `print()`, `summary()` o `plot()` se usa. Un objeto puede almacenarse internamente como una lista (`typeof()` devuelve `"list"`), pero si su clase es `"data.frame"`, R lo trata como una tabla de datos.

```r
# Un vector numérico simple
x <- c(3.14, 2.72)
typeof(x)    # "double"   → el motor interno ve números de punto flotante
mode(x)      # "numeric"  → S simplifica: es numérico
class(x)     # "numeric"  → se comporta como numérico

# Un factor
region <- factor(c("norte", "sur", "norte"))
typeof(region)   # "integer"   → internamente es un vector de enteros
mode(region)     # "numeric"   → S dice: son números
class(region)    # "factor"    → pero se comporta como variable categórica

# Un data frame
df <- data.frame(ciudad = c("Lima", "Quito"), altitud = c(154, 2850))
typeof(df)   # "list"         → internamente es una lista
mode(df)     # "list"         → S confirma: es una lista
class(df)    # "data.frame"   → pero se comporta como tabla de datos

# Un modelo lineal
modelo <- lm(dist ~ speed, data = cars)
typeof(modelo)   # "list"     → internamente es una lista
mode(modelo)     # "list"     → S confirma: es una lista
class(modelo)    # "lm"       → pero se comporta como modelo lineal
```

El patrón que emerge es claro: `typeof()` y `mode()` miran hacia adentro (cómo se almacenan los datos), mientras que `class()` mira hacia afuera (cómo se comporta el objeto). Para el trabajo cotidiano, `class()` es casi siempre la más relevante, porque determina qué se puede hacer con el objeto. `typeof()` es útil cuando se necesita entender exactamente qué hay debajo (por ejemplo, para entender por qué un cálculo produce un resultado inesperado por precisión numérica). `mode()` rara vez aporta información que las otras dos no den.

| Función | Nivel | Pregunta | `factor` | `data.frame` | `lm()` |
|---------|-------|----------|----------|-------------|--------|
| `typeof()` | Motor interno (C) | ¿Cómo se almacena en memoria? | `"integer"` | `"list"` | `"list"` |
| `mode()` | Lenguaje S (simplificado) | ¿Qué tipo general de dato es? | `"numeric"` | `"list"` | `"list"` |
| `class()` | Comportamiento en R | ¿Cómo se comporta con funciones? | `"factor"` | `"data.frame"` | `"lm"` |

### R, S y los sistemas de objetos

R no nació de cero. Es una implementación del lenguaje **S**, desarrollado en los laboratorios Bell (AT&T) a partir de los años 70 por John Chambers y colaboradores. El lenguaje S pasó por varias versiones, y dos de ellas dejaron huella en cómo R maneja los objetos hoy.

**S3** es el sistema de objetos más antiguo y más simple. Viene de la versión 3 del lenguaje S. En este sistema, un objeto es simplemente una estructura de datos (un vector, una lista, etc.) con un atributo llamado `class` pegado encima. No hay definiciones formales ni validación: si se le asigna la clase `"data.frame"` a una lista, R confía en que esa lista tiene la estructura correcta. Cuando se llama a una función como `print(x)`, R revisa la clase de `x` y busca una versión especializada de `print` para esa clase (por ejemplo, `print.data.frame` o `print.factor`). Este mecanismo se llama **despacho de métodos** (*method dispatch*).

La gran mayoría de los objetos que se usan en el día a día en R son objetos S3: vectores, data frames, factores, resultados de `lm()`, de `t.test()`, etc.

**S4** es un sistema más formal y estricto, introducido en la versión 4 del lenguaje S. Requiere definiciones explícitas de las clases (qué campos tiene, de qué tipo es cada uno) y valida que los objetos cumplan con esa definición. Los objetos S4 usan `@` en lugar de `$` para acceder a sus componentes, y se encuentran principalmente en paquetes especializados como los del proyecto Bioconductor (bioinformática).

Para efectos prácticos en un curso introductorio, casi todo lo que se encuentra es S3. Pero es útil saber que el sistema existe, porque explica cosas como por qué `print()` produce resultados tan diferentes según el tipo de objeto que recibe: no es una sola función, sino muchas funciones especializadas que R selecciona automáticamente según la clase del objeto.

```r
# print() se comporta distinto según la clase
dias <- c(15, 22, 8, 30)
print(dias)
## [1] 15 22  8 30

temperaturas <- matrix(c(18, 22, 20, 25, 19, 23), nrow = 2)
print(temperaturas)
##      [,1] [,2] [,3]
## [1,]   18   20   19
## [2,]   22   25   23

# Detrás de escena, R está llamando print.default() para dias
# y print.matrix() para temperaturas
```

### Herramientas para inspeccionar objetos

| Función | Qué devuelve |
|---------|-------------|
| `str()` | Estructura del objeto: tipo, dimensiones, primeros valores |
| `class()` | La clase del objeto (`vector`, `matrix`, `data.frame`, etc.) |
| `typeof()` | El tipo interno exacto (`integer`, `double`, `character`, etc.) |
| `mode()` | El modo de almacenamiento heredado de S (`numeric`, `character`, `list`, etc.) |
| `length()` | Número de elementos |
| `dim()` | Dimensiones (para matrices, arrays y data frames) |
| `names()` | Nombres de los elementos o columnas |
| `head()` | Primeras filas de un objeto tabular |
| `summary()` | Resumen estadístico |

De todas estas, `str()` es probablemente la más versátil. Ante la duda sobre cualquier objeto, `str()` es el primer recurso.

```r
str(cafeteria)
## 'data.frame':	4 obs. of  4 variables:
##  $ bebida    : chr  "espresso" "latte" "americano" "mocha"
##  $ precio    : num  15 25 18 30
##  $ disponible: logi  TRUE TRUE FALSE TRUE
##  $ tamaño    : chr  "S" "M" "M" "L"
```

---

## 11. Herencia y pertenencia de clases

### Herencia (*inheritance*)

En R, las clases pueden tener relaciones jerárquicas: una clase puede **heredar** de otra. Esto significa que un objeto de una clase más específica también es, al mismo tiempo, un objeto de la clase más general de la que hereda. Lo que hereda no es solo un nombre: hereda comportamientos. Si existe una función definida para la clase general y no existe una versión específica para la clase particular, R usa la versión general.

El ejemplo más claro es el tibble:

```r
library(tibble)
tb <- tibble(producto = c("café", "té"), precio = c(25, 18))

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
mi_tabla <- data.frame(a = 1:3)

is.data.frame(mi_tabla)
## [1] TRUE

is.matrix(mi_tabla)
## [1] FALSE

is.list(mi_tabla)
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
depto <- factor(c("Guatemala", "Sacatepéquez", "Guatemala"))

is.vector(depto)
## [1] FALSE

is.atomic(depto)
## [1] TRUE
```

La regla práctica es: `class()` indica cómo se comporta un objeto, `is.*()` e `inherits()` permiten verificar esa pertenencia antes de actuar, y la herencia garantiza que los objetos más específicos no pierdan la funcionalidad de sus clases ancestras.