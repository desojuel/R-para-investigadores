# Funciones

## ¿Qué es una función?

Una función es una instrucción reutilizable que recibe datos de entrada, realiza una operación y devuelve un resultado.

En R, casi todo lo que hacemos implica funciones:

- Mostrar datos
- Calcular promedios
- Leer archivos
- Crear gráficos
- Transformar texto
- Obtener ayuda

## Estructura básica de una función

Una función normalmente tiene la siguiente estructura: 

nombre_funcion(argumentos)

por ejemplo: 

sqrt(25)

sqrt es el nombre de la función
25 es el argumento
El resultado es: 5

## Algunas funciones de base R

**Base R** se refiere al conjunto de funciones, estructuras y herramientas que vienen incluidas automáticamente al instalar R, sin necesidad de instalar paquetes adicionales. 

### Ejemplos con vectores simples

| Función | ¿Qué hace? | Ejemplo |
|---|---|---|
| `c()` | Crea vectores combinando valores | `c(1,2,3,4)` |
| `length()` | Cuenta elementos de un vector | `length(c(1,2,3))` |
| `sum()` | Suma valores | `sum(c(1,2,3))` |
| `mean()` | Calcula promedio | `mean(c(1,2,3))` |
| `max()` | Valor máximo | `max(c(1,2,3))` |
| `min()` | Valor mínimo | `min(c(1,2,3))` |
| `sort()` | Ordena valores | `sort(c(3,1,2))` |
| `rep()` | Repite valores | `rep(5, 3)` |
| `seq()` | Genera secuencias | `seq(1,10)` |
| `round()` | Redondea números | `round(c(1.234, 5.678), 2)` |
| `unique()` | Elimina valores repetidos | `unique(c(1,1,2,3))` |
| `table()` | Frecuencias de valores | `table(c("a","b","a"))` |
| `is.na()` | Detecta valores faltantes | `is.na(c(1, NA, 3))` |

### Ejemplos con conjunto de datos mtcars (dataset de base R)

| Función | ¿Qué hace? | Ejemplo |
|---|---|---|
| `summary()` | Resumen estadístico del dataset | `summary(mtcars)` |
| `str()` | Muestra la estructura del dataset | `str(mtcars)` |
| `head()` | Muestra las primeras filas | `head(mtcars)` |
| `tail()` | Muestra las últimas filas | `tail(mtcars)` |
| `dim()` | Dimensiones (filas y columnas) | `dim(mtcars)` |
| `nrow()` | Número de filas | `nrow(mtcars)` |
| `ncol()` | Número de columnas | `ncol(mtcars)` |
| `names()` | Nombres de variables | `names(mtcars)` |
| `colnames()` | Nombres de columnas | `colnames(mtcars)` |
| `rownames()` | Nombres de filas | `rownames(mtcars)` |
| `help()` | Abre ayuda de una función | `help(summary)` |
| `?` | Ayuda rápida de una función | `?summary` |
| `ls()` | Muestra objetos en el entorno | `ls()` |


##  Aclaración sobre los ejemplos (vectores vs. datos como `mtcars`)

Las dos tablas anteriores no significan que las funciones “solo funcionen” con vectores simples o que “solo funcionen” con datasets como `mtcars`.

En realidad:

- Muchas funciones pueden trabajar **tanto con vectores como con columnas de datasets**
- Por ejemplo, `mean()`, `sum()` o `max()` funcionan igual con:
  - un vector creado con `c()`
  - o una columna de `mtcars` como `mtcars$mpg`

Ejemplo:

mean(c(1,2,3))
mean(mtcars$mpg)

## Aclaración conceptual: Base R y otros paquetes (ej. dplyr)

Las funciones de Base R no están limitadas a un uso aislado y pueden combinarse sin problema con funciones provenientes de otros paquetes como los del tidyverse u otros ecosistemas de R. En la práctica, esto es común en análisis de datos, donde se mezclan funciones para aprovechar distintas capacidades.

Lo importante es tener en cuenta que estas combinaciones pueden implicar diferencias en el tipo de objeto que se está utilizando (por ejemplo, data frames vs tibbles), así como posibles conflictos de nombres entre funciones de distintos paquetes. Por esta razón, en algunos casos es necesario especificar explícitamente el paquete al que pertenece una función para evitar ambigüedades y asegurar que se ejecute la versión correcta.
