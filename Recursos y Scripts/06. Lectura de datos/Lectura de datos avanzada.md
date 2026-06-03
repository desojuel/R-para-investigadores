## Lectura de datos: opciones avanzadas

Esta sección profundiza en las opciones que ofrecen las funciones de lectura para manejar situaciones que aparecen con frecuencia en datos reales: valores perdidos mal codificados, encabezados con basura, columnas con tipos incorrectos, archivos con separadores distintos a la coma, y más.

Para los ejemplos de esta sección se utilizan tres fuentes de datos. La primera es un archivo CSV de estudiantes disponible en línea como parte del libro R for Data Science, que se puede leer directamente desde su URL:

```r
estudiantes <- read_csv("https://pos.it/r4ds-students-csv")
estudiantes
```

La segunda es un conjunto de archivos ficticios con datos de educación superior, ubicados en la carpeta **Datos/Lectura avanzada de datos** del repositorio.

Y la tercera son los datos de Graduandos de 2025 del Ministerio de Educación de Guatemala.

### Parámetros útiles de `read_csv()`

La función `read_csv()` tiene varios argumentos que permiten controlar cómo se importan los datos. En su forma más simple solo necesita la ruta al archivo (o una URL), pero los datos reales rara vez son tan limpios.

#### Definir qué se considera un valor perdido (`na`)

Por defecto, `read_csv()` solo reconoce celdas vacías y la cadena `"NA"` como valores perdidos. Pero al inspeccionar el archivo de estudiantes, se puede ver que algunos valores perdidos están codificados como `"N/A"` y otros como celdas vacías. Si no se le indica a R, `"N/A"` se lee como texto en lugar de como valor perdido.

El argumento `na` permite especificar cuáles cadenas deben tratarse como `NA` durante la lectura:

```r
estudiantes <- read_csv("https://pos.it/r4ds-students-csv",
                        na = c("N/A", ""))
```

Todo lo que se liste en el vector `na` será convertido a `NA` al momento de importar. Es uno de los argumentos más importantes en la práctica, porque un valor perdido mal codificado puede hacer que toda una columna numérica se lea como texto. Por ejemplo, si la columna `age` contiene un `"N/A"` que no fue declarado como valor perdido, toda la columna se importa como texto en lugar de como número.

El archivo de notas de seminario tiene el mismo problema con más variantes: valores perdidos codificados como `"N/A"`, como `"."` y como celdas vacías. Para leerlo correctamente hay que declarar las tres formas:

```r
notas <- read_csv(here("Datos","Lectura avanzada de datos","notas_seminario.csv"),
                  skip = 3,
                  comment = "#",
                  na = c("N/A", ".", ""))
```

Este ejemplo combina varios argumentos a la vez, que se explican a continuación.

#### Saltar líneas al inicio (`skip`)

Algunos archivos tienen líneas de metadatos o encabezados extra antes de los datos reales. El archivo `notas_seminario.csv` es un ejemplo: las primeras tres líneas contienen el nombre del reporte, la universidad y la fecha de generación. Los datos empiezan recién en la cuarta línea.

El argumento `skip` indica cuántas líneas ignorar antes de empezar a leer:

```r
notas <- read_csv(here("Datos","Lectura avanzada de datos","notas_seminario.csv"),
                  skip = 3)
```

Sin `skip = 3`, R intentaría usar `"Reporte de notas - Seminario de Investigación Educativa"` como la primera fila de datos, produciendo resultados incorrectos. Esto es común en archivos exportados desde sistemas institucionales, donde las primeras líneas contienen información administrativa.

#### Ignorar comentarios (`comment`)

El archivo de notas también contiene una línea que comienza con `#` (una nota sobre los estudiantes que no completaron la evaluación). El argumento `comment` le indica a R que ignore todas las líneas que comiencen con ese carácter:

```r
notas <- read_csv(here("Datos","Lectura avanzada de datos","notas_seminario.csv"),
                  skip = 3,
                  comment = "#")
```

#### Archivos sin encabezados (`col_names`)

El archivo `asistencia.csv` no tiene nombres de columna: solo contiene datos de carnet, fecha y un indicador de asistencia (1/0), sin una primera fila de encabezados.

Si se lee sin indicarle a R, la primera fila de datos se interpreta como nombres de columna:

```r
# Lectura incorrecta: la primera fila se usa como encabezado
asistencia <- read_csv(here("Datos","Lectura avanzada de datos","asistencia.csv"),
                       col_names = FALSE))
```

Con `col_names = FALSE`, R asigna nombres automáticos (`X1`, `X2`, `X3`):


Y se pueden asignar nombres directamente pasando un vector:

```r
asistencia <- read_csv(here("Datos","Lectura avanzada de datos","asistencia.csv"),
                       col_names = c("carnet", "fecha", "presente"))
```

### Otras funciones de lectura de texto

`read_csv()` asume que las columnas están separadas por comas, pero no todos los archivos de texto siguen esa convención. Existen variantes para los formatos más comunes:

`read_csv2()` lee archivos separados por punto y coma (`;`). Esta función es especialmente relevante en Latinoamérica y Europa, donde la coma se usa como separador decimal. En esos contextos, el separador de columnas no puede ser una coma, así que se usa punto y coma. Es muy común encontrar este formato en archivos exportados desde Excel configurado en español.

`read_tsv()` lee archivos separados por tabulaciones. Este formato aparece con frecuencia en datos exportados desde bases de datos.

`read_delim()` es la versión más general: lee archivos con cualquier delimitador. Si no se especifica cuál, intenta adivinarlo automáticamente. El archivo `inscripciones.txt` está separado por pipes (`|`), un formato que a veces aparece en datos exportados desde sistemas administrativos:

```r
inscripciones <- read_delim(here("Datos", "Lectura avanzada de datos", "inscripciones.txt"),
                            delim = "|")
```

Todas estas funciones aceptan los mismos argumentos que `read_csv()` (`na`, `skip`, `col_names`, etc.), porque todas pertenecen al paquete `readr` (parte de tidyverse).

### Tipos de columna

Cuando `read_csv()` (o cualquier función de `readr`) lee un archivo, intenta adivinar el tipo de cada columna examinando los primeros 1,000 valores. La mayoría de las veces acierta, pero a veces no, y es necesario intervenir.

#### Especificar tipos manualmente con `col_types`

El argumento `col_types` permite indicar explícitamente qué tipo debe tener cada columna:

```r

notas <- read_csv(here("Datos", "Lectura avanzada de datos", "inscripciones.txt","notas_seminario.csv"),
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
```

Aquí se fuerza `carnet` a texto (porque es un identificador, no un número que tenga sentido sumar o promediar) y las columnas de notas a numérico.

Los tipos disponibles más comunes son:

- `col_double()` — números decimales
- `col_integer()` — números enteros (ocupan la mitad de memoria que `col_double()`)
- `col_character()` — texto (útil para columnas que son identificadores numéricos pero que no tiene sentido sumar o promediar, como carnets o códigos de establecimiento)
- `col_logical()` — valores lógicos (`TRUE`/`FALSE`)
- `col_factor()` — factores (variables categóricas)
- `col_date()` y `col_datetime()` — fechas y fechas con hora
- `col_number()` — numérico permisivo, ignora caracteres no numéricos (útil para monedas como `"Q1,500.00"`)
- `col_skip()` — omite la columna por completo (útil para acelerar la lectura cuando solo se necesitan algunas columnas de un archivo grande)

### Valores perdidos y detección de tipos

#### Cómo adivina R los tipos de columna

`readr` examina los primeros 1,000 valores de cada columna para decidir su tipo. Si los primeros 1,000 valores de una columna son números, la clasifica como numérica. Si hay texto mezclado, la clasifica como texto. Esto funciona bien en la mayoría de los casos, pero falla cuando los datos problemáticos aparecen después de la fila 1,000.

#### El problema y la solución: `guess_max`

En archivos grandes, es posible que las primeras 1,000 filas de una columna contengan solo números, pero más adelante aparezcan valores de texto o de otro tipo. Cuando esto ocurre, `readr` ya clasificó la columna como numérica y produce errores o advertencias al encontrar datos que no encajan.

El archivo de graduandos 2025 del Ministerio de Educación es un buen ejemplo de archivo grande donde esto puede suceder. El argumento `guess_max` aumenta el número de filas que se examinan para adivinar los tipos:

```r
graduandos2025 <- read_xlsx(here("Datos","2025-Grad-Internet.xlsx"),
                            guess_max = 3000)
```

En este caso, se le indica a `read_xlsx()` que examine las primeras 3,000 filas en lugar de las primeras 1,000 para decidir el tipo de cada columna. `guess_max` funciona tanto en las funciones de `readr` (`read_csv()`, `read_csv2()`, etc.) como en `read_xlsx()` de readxl. Aumentar este valor hace que la lectura sea un poco más lenta, pero reduce significativamente los errores de clasificación de tipos en archivos grandes o con datos inconsistentes.

#### Diagnóstico de problemas con `problems()`

Cuando `readr` encuentra valores que no coinciden con el tipo que adivinó para una columna, no siempre genera un error visible. La función `problems()` permite ver exactamente qué falló:

```r
notas_problemas <- read_csv(here("Recursos/Sesión 1. Fundamentos de R/Datos/Lectura avanzada de datos/notas_seminario.csv"),
                            skip = 3,
                            comment = "#")
problems(notas_problemas)
```

Al leer el archivo de notas sin declarar `"."` ni `"N/A"` como valores perdidos, las columnas de notas se leen como texto porque contienen esos valores no numéricos. `problems()` devuelve una tabla con la fila, la columna, el tipo esperado y el valor real que causó el problema. Es la herramienta de diagnóstico más útil cuando los datos no se importan correctamente.
