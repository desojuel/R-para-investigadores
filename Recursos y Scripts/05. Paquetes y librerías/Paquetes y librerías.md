## Paquetes y librerías

R viene con un conjunto de funciones incorporadas (lo que se conoce como R base), pero su verdadero poder está en los **paquetes**: extensiones creadas por la comunidad que agregan funciones especializadas. Existen más de 20,000 paquetes disponibles en CRAN (el repositorio oficial de R), cubriendo desde estadística básica hasta aprendizaje automático, visualización de datos, análisis de texto y mucho más. Además de estos, hay muchos otros disponibles en Github.

### Paquetes

Un paquete es un conjunto organizado de funciones, datos y documentación que extiende las capacidades de R. Cuando se dice "instalar un paquete", lo que ocurre es que R descarga ese conjunto de archivos desde CRAN (o desde otra fuente) y lo guarda en el disco duro de la computadora. La instalación se hace una sola vez.

```r
install.packages("tidyverse")
```

Internamente, los paquetes quedan almacenados en una carpeta del sistema. Se puede consultar dónde están guardados con:

```r
.libPaths()
## [1] "C:/Users/usuario/AppData/Local/R/win-library/4.4"
## [2] "C:/Program Files/R/R-4.4.0/library"
```

La primera ruta es la biblioteca personal del usuario; la segunda es la biblioteca del sistema que viene con la instalación de R.

### Librerías

En R, el término "librería" se usa coloquialmente como sinónimo de paquete, pero técnicamente se refiere a la carpeta donde se almacenan los paquetes instalados (las rutas que devuelve `.libPaths()`). La función `library()` lo que hace es cargar un paquete ya instalado en la sesión actual de R, es decir, hace que sus funciones estén disponibles para usar.

```r
library(tidyverse)
```

Sin `library()`, las funciones del paquete no están accesibles aunque el paquete esté instalado en el disco duro. Es como tener una app instalada en el celular pero sin abrirla: está ahí, pero no se puede usar hasta que se abra.

### Instalar vs. cargar

Esta es la confusión más común entre principiantes. La diferencia es fundamental:

- `install.packages()` → se hace **una sola vez**. Descarga el paquete de internet y lo guarda en el disco duro.
- `library()` → se hace **cada vez** que se inicia una sesión de R. Activa el paquete para poder usar sus funciones.

La analogía más clara: `install.packages()` es como instalar una app en el celular (se hace una vez), y `library()` es como abrir la app cada vez que se quiere usar.

**Buena práctica:** no poner `install.packages()` dentro de los scripts de análisis. Si alguien más ejecuta el script, le reinstalaría paquetes innecesariamente. La instalación se hace una vez desde la consola. En los scripts solo van las llamadas a `library()`.

Es decir, un script de análisis debería empezar así:

```r
library(tidyverse)
library(janitor)
library(readxl)
```

Y **no** así:

```r
install.packages("tidyverse")   # NO poner esto en un script
install.packages("janitor")     # NO poner esto en un script
```

### help

Cada paquete incluye documentación. Una vez cargado un paquete, se puede consultar la ayuda de cualquiera de sus funciones de varias formas:

```r
# Con la función help()
help(clean_names)

# Con el signo de interrogación (atajo)
?clean_names

# Buscar por término (cuando no se recuerda el nombre exacto).
# Los dos signos de interrogación buscan en todos los paquetes instalados,
# no solo en los que están cargados.
??clean_names

# Ver toda la documentación disponible de un paquete completo
help(package = "janitor")

# Ver una lista de todas las funciones que contiene un paquete
ls("package:janitor")

# Acceder a las viñetas (guías detalladas que algunos paquetes incluyen)
vignette(package = "tidyverse")
vignette("dplyr")
```

### Pacman

`pacman` es un paquete que simplifica la gestión de otros paquetes. Su función estrella es `p_load()`, que combina instalar y cargar en un solo paso: si el paquete ya está instalado, solo lo carga; si no está instalado, lo instala primero y luego lo carga.

Primero hay que instalar pacman (una sola vez):

```r
install.packages("pacman")
```

Luego, en lugar de escribir varias líneas de `library()`, se usa:

```r
pacman::p_load(tidyverse, janitor, readxl, writexl, haven, here, psych)
```

Esa sola línea reemplaza tanto la instalación como la carga de todos los paquetes listados. La notación `pacman::p_load()` usa los dos puntos dobles (`::`) para llamar a la función `p_load()` directamente del paquete pacman sin necesidad de haberlo cargado con `library()` antes. Esta notación se explica con más detalle en la sección de conflictos.

### Listado de paquetes y librerías útiles

A continuación se presentan algunos paquetes especialmente útiles para el análisis de datos en ciencias sociales y educación. Cada uno cumple un rol distinto dentro del flujo de trabajo.

#### tidyverse

`tidyverse` no es un solo paquete, sino una colección de paquetes diseñados para trabajar juntos bajo una misma filosofía de análisis de datos. Al cargar tidyverse se cargan simultáneamente los paquetes principales: `ggplot2` (visualización), `dplyr` (manipulación de datos), `tidyr` (ordenar datos), `readr` (importar archivos de texto), `purrr` (programación funcional), `tibble` (tablas modernas), `stringr` (manejo de texto) y `forcats` (factores).

Es el ecosistema más popular del mundo de R y, en la práctica, la mayoría de flujos de trabajo modernos giran alrededor de tidyverse.

#### janitor

`janitor` facilita la limpieza de datos. Su función más conocida es `clean_names()`, que estandariza los nombres de las columnas: los convierte a minúsculas, reemplaza espacios y caracteres especiales por guiones bajos, y elimina acentos. Esto es especialmente útil cuando se importan datos desde Excel, donde los nombres de columna suelen tener espacios, mayúsculas mezcladas y caracteres como paréntesis o tildes.

También incluye `tabyl()`, que genera tablas de frecuencia con porcentajes, y funciones para detectar y eliminar filas o columnas vacías.

#### readxl

`readxl` permite leer archivos de Excel (`.xls` y `.xlsx`) directamente en R. No requiere que Excel esté instalado en la computadora. Permite elegir qué hoja leer, qué rango de celdas importar, y ver la lista de hojas de un archivo antes de abrirlo.

#### writexl

`writexl` es el complemento de readxl: permite guardar data frames como archivos de Excel (`.xlsx`). También permite guardar múltiples tablas en hojas separadas dentro de un mismo archivo. Es liviano, rápido y no tiene dependencias externas.

#### haven

`haven` permite leer y escribir archivos de otros programas estadísticos: SPSS (`.sav`), Stata (`.dta`) y SAS (`.sas7bdat`). Es el puente natural para investigadores y estudiantes que vienen de esos programas, que siguen siendo muy utilizados en ciencias sociales y educación. Además, haven preserva las etiquetas de variables y valores que estos programas usan, algo que otros paquetes de importación no hacen.

La diferencia con readxl es clara: readxl lee archivos de Excel, haven lee archivos de software estadístico. Ambos importan datos a R, pero desde fuentes distintas.

#### here

`here` resuelve uno de los problemas más frustrantes para principiantes: las rutas de archivos. En lugar de escribir rutas absolutas que solo funcionan en una computadora específica (como `"C:/Users/daniel/Documentos/proyecto/datos/encuesta.xlsx"`), `here()` construye rutas relativas a partir de la raíz del proyecto de RStudio.

Esto es especialmente útil cuando se comparten proyectos entre colaboradores o se trabaja en diferentes computadoras: el código funciona sin necesidad de cambiar las rutas manualmente.

#### psych

`psych` es un paquete orientado a psicometría y ciencias del comportamiento, creado por William Revelle. Su función más popular es `describe()`, que genera resúmenes estadísticos más completos que el `summary()` de R base: incluye media, desviación estándar, mediana, asimetría (skew), curtosis y error estándar, entre otros.

También incluye herramientas para análisis factorial, cálculo del alfa de Cronbach (consistencia interna de escalas y cuestionarios), matrices de correlación con valores p, y visualizaciones de relaciones entre variables. Es prácticamente estándar en investigación en psicología, educación y ciencias sociales.

### Conflictos entre paquetes

Cuando se cargan varios paquetes, puede ocurrir que dos o más tengan funciones con el mismo nombre. A esto se le llama un **conflicto**. R no genera un error: simplemente usa la función del último paquete cargado, lo cual puede producir resultados inesperados sin ningún aviso.

El caso más común involucra la función `filter()`. Existe en el paquete `stats` (que viene con R base) y en `dplyr` (parte de tidyverse). Al cargar tidyverse, R muestra este aviso:

dplyr::filter() masks stats::filter()
dplyr::lag()    masks stats::lag()

Esto significa que `filter()` de dplyr "tapa" a `filter()` de stats. A partir de ese momento, cuando se escribe `filter()`, R usa la versión de dplyr.

La solución es la notación de dos puntos dobles (`::`), que le dice a R exactamente de cuál paquete tomar la función:

```r
stats::filter()    # usa la versión de stats
dplyr::filter()    # usa la versión de dplyr
```

Esta notación también permite usar una función de un paquete instalado sin necesidad de cargarlo con `library()`, como ya se mostró con `pacman::p_load()`.

**Nota sobre los mensajes al cargar paquetes:** cuando R muestra mensajes al ejecutar `library()`, no es un error. Esos mensajes informativos indican qué versiones se cargaron y qué conflictos se detectaron. Es normal y esperado, especialmente con tidyverse, que carga varios paquetes a la vez. Entender que esos mensajes son informativos (y no errores) evita mucha confusión innecesaria.

---

### Instalar y cargar los paquetes desde los scripts

Todo script de análisis comienza con la activación de las librerías que se van a utilizar. Es lo primero que se escribe y lo primero que se ejecuta. Existen tres formas comunes de manejar la instalación y carga de paquetes:

**Forma 1 — Instalar en la consola, cargar en el script.** Los paquetes se instalan escribiendo `install.packages()` directamente en la consola (una sola vez), y en el script solo se colocan las llamadas a `library()`:

```r
library(tidyverse)
library(janitor)
library(readxl)
library(writexl)
library(haven)
library(here)
library(psych)
```

Esta forma mantiene el script limpio, pero requiere recordar que los paquetes deben instalarse por separado antes de ejecutarlo por primera vez.

**Forma 2 — Instalar y cargar desde el mismo script.** Algunas personas prefieren dejar las líneas de instalación dentro del script para tener todo en un solo lugar. La primera vez se ejecutan normalmente. Una vez instalados, se comentan con `#` para que no se reinstalen cada vez que se ejecuta el script:

```r
# install.packages("tidyverse")
# install.packages("janitor")
# install.packages("readxl")
# install.packages("writexl")
# install.packages("haven")
# install.packages("here")
# install.packages("psych")

library(tidyverse)
library(janitor)
library(readxl)
library(writexl)
library(haven)
library(here)
library(psych)
```

Esta forma es práctica como recordatorio personal, pero deja líneas comentadas que ensucian el script y que hay que gestionar manualmente.

**Forma 3 (recomendada) — Usar pacman.** Se instala `pacman` una sola vez desde la consola:

```r
install.packages("pacman")
```

Y a partir de ahí, en cualquier script, una sola línea se encarga de todo: si el paquete ya está instalado, lo carga; si no está instalado, lo instala primero y luego lo carga:

```r
pacman::p_load(tidyverse, janitor, readxl, writexl, haven, here, psych)
```

No hay que preocuparse por si un paquete ya fue instalado o no, no hay líneas comentadas, y el script funciona tanto en una computadora donde los paquetes ya existen como en una donde se ejecuta por primera vez.