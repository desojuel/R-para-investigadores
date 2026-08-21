# Documentos reproducibles: generar Word y PDF con Quarto

Esta lección enseña a producir informes en Word y PDF donde el texto, el código y los resultados viven en un
mismo archivo, de modo que las tablas, los gráficos y hasta las cifras del texto se generen solos y siempre
estén actualizados. Se asume que ya se sabe manipular datos y producir tablas y gráficos en R; el foco está en
llevar todo eso a un documento terminado sin transcribir nada a mano.

## Recorrido de la lección

1. **La idea** de un documento reproducible y qué significa "renderizar".
2. **La instalación** (Windows y Mac), con las advertencias necesarias.
3. **La anatomía** de un archivo Quarto: sus tres zonas.
4. **El encabezado YAML**: metadatos y formato de salida.
5. **Markdown**: dar formato al texto.
6. **Los bloques de código**: ejecutar R dentro del documento y controlar qué se muestra.
7. **Tablas con formato**: `kable`, `gt` y `flextable`.
8. **Vincular scripts externos**: no repetir funciones ni análisis en cada documento.
9. **Cómo renderizar** el documento.
10. **Errores comunes** y cómo leerlos.
11. **Un flujo de trabajo recomendado**.

---

## 1. La idea: un solo archivo, y qué significa renderizar

Copiar y pegar resultados a mano es frágil: se cometen errores de transcripción y, en cuanto los datos cambian,
el documento queda desactualizado. Un **documento reproducible** resuelve esto con una idea simple: **un solo
archivo contiene el texto, el código y los resultados**. Ese archivo no es el documento final, sino una receta.

**Renderizar** es el proceso de convertir esa receta en el documento terminado. Al renderizar, el programa lee
el archivo fuente, **ejecuta el código** que contiene, **inserta los resultados** (tablas, gráficos, números)
en el lugar correspondiente y produce el documento final en el formato pedido (un Word o un PDF). Si los datos
cambian, se vuelve a renderizar y todo se actualiza solo. La palabra aparecerá a lo largo de la lección siempre
con este significado: pasar del archivo fuente al documento terminado.

La herramienta que se usa es **Quarto**, un sistema de publicación técnica. Los archivos de Quarto tienen
extensión `.qmd`. Para más detalles y una guía de primeros pasos, la documentación oficial está en
`https://quarto.org/docs/get-started/hello/rstudio.html`.

---

## 2. La instalación

Conviene resolver la instalación antes que nada. Hacen falta pocas cosas, y para generar Word incluso menos de
lo que suele creerse.

### Qué se necesita

1. **R** (el lenguaje) y **RStudio** (el entorno de trabajo).
2. **Quarto**, el sistema que renderiza el documento.
3. **LaTeX**, y esto **solo si se quiere generar PDF** (para Word no hace falta).

> **La advertencia que más frustración ahorra: Word no necesita LaTeX.** Generar un documento de Word (`docx`)
> no requiere LaTeX en absoluto. LaTeX solo interviene en el PDF. Quien solo necesite Word puede saltarse por
> completo esa parte. Muchas personas intentan instalar LaTeX creyendo que es obligatorio y se atascan sin
> necesidad.

### Quarto ya suele venir con RStudio

Las versiones recientes de RStudio **incluyen Quarto**, de modo que, si se tiene RStudio actualizado, es muy
probable que no haya que instalar nada más. Para confirmarlo, se abre una **terminal** y se escribe:

```bash
quarto --version
```

En RStudio, la terminal es la pestaña **Terminal**, que aparece junto a la consola (menú Tools, luego Terminal,
o la pestaña "Terminal" en el panel inferior). Si el comando devuelve un número de versión, Quarto está listo y
no hay que instalar nada.

Si no estuviera instalado, se descarga desde `quarto.org` y se ejecuta el instalador correspondiente al sistema
operativo. Conviene saber que **Quarto no es exclusivo de RStudio**: funciona también desde la línea de
comandos o desde otros editores como VS Code; RStudio es solo la vía más cómoda para empezar.

### LaTeX, solo para PDF (Windows y Mac)

Si se quiere generar PDF, hace falta una instalación de LaTeX. Para principiantes, la mejor opción en cualquier
sistema es **tinytex**, una distribución mínima pensada justamente para esto: ocupa poco, no pide permisos de
administrador y se instala con un solo comando. Desde la terminal:

```bash
quarto install tinytex
```

(Alternativamente, desde la consola de R: `tinytex::install_tinytex()`, tras instalar el paquete `tinytex`.)

Conviene **evitar** las distribuciones completas y pesadas (MiKTeX o TeX Live completos en Windows, MacTeX en
Mac): ocupan varios gigabytes, tardan mucho y son mucho más de lo necesario para generar informes.

> **Advertencias por sistema operativo.**
>
> **Windows:**
>
> - La terminal puede ser la pestaña **Terminal** de RStudio, o bien PowerShell o el Símbolo del sistema.
> - **Cuidado con las rutas que contienen tildes, eñes o espacios.** Si el nombre de usuario de Windows tiene
>   acentos (por ejemplo, `C:\Usuarios\José\...`) o el proyecto está en una carpeta con espacios, la generación
>   de PDF con LaTeX puede fallar con errores difíciles de entender. Conviene guardar los proyectos en rutas
>   simples, sin acentos ni espacios (por ejemplo, `C:\proyectos\informe`).
> - Si el proyecto está en una carpeta sincronizada con OneDrive, a veces la sincronización interfiere mientras
>   se renderiza; en caso de problemas, conviene trabajar en una carpeta local.
>
> **Mac:**
>
> - `tinytex` detecta automáticamente si el procesador es Apple Silicon (M1, M2, M3) o Intel y descarga la
>   versión correcta.
> - Si tras instalar Quarto la terminal no lo reconoce ("command not found"), suele ser un problema de PATH;
>   reiniciar la terminal o la sesión lo resuelve. Trabajar desde RStudio evita este inconveniente.
>
> **Ambos:** para el PDF, Quarto usa por defecto un motor (`xelatex`) que maneja bien los caracteres Unicode,
> así que las tildes, las eñes y los signos de apertura (¿ ¡) se procesan sin configuración adicional.

### Comprobar que todo está listo

Antes de intentar el primer documento, conviene verificar la instalación con el comando de diagnóstico de
Quarto, que revisa R, Pandoc y LaTeX y reporta qué falta. En la terminal:

```bash
quarto check
```

---

## 3. La anatomía de un archivo `.qmd`

Un archivo Quarto se compone de tres zonas:

1. El **encabezado YAML**: los metadatos del documento (título, autor, formato de salida), entre tres guiones
   al inicio y al final.
2. El **texto en Markdown**: el contenido escrito, con su formato.
3. Los **bloques de código** (o *chunks*): fragmentos de R que se ejecutan al renderizar.

Un archivo mínimo completo se ve así:

````
---
title: "Análisis del desempeño en lectura"
author: "Nombre del autor"
format: docx
---

## Introducción

Este informe analiza el desempeño en lectura de una muestra de graduandos.

```{r}
library(tidyverse)
datos <- read_csv("datos.csv")
mean(datos$measure_lect)
```

El promedio anterior resume el nivel general del grupo.
````

Las tres zonas se distinguen a simple vista: el YAML arriba entre los guiones, el texto normal, y el bloque de
código entre las líneas de tres acentos graves con `{r}`.

---

## 4. El encabezado YAML

El **YAML** es un pequeño bloque de configuración al inicio del archivo, entre dos líneas de tres guiones
(`---`). Define cómo será el documento antes de entrar al contenido.

```yaml
---
title: "Análisis del desempeño en lectura"
subtitle: "Muestra de graduandos, ciclo anual"
author: "Nombre del autor"
date: today
format: docx
---
```

> **Advertencia importante sobre el YAML.** El YAML es **sensible a la indentación** (los espacios al inicio de
> cada línea tienen significado) y a los dos puntos. Un espacio de más, una tabulación en lugar de espacios, o
> un dos puntos sin espacio después, hacen que el documento no se renderice. Es la causa más frecuente de
> errores al empezar. Conviene indentar siempre con **espacios** (nunca con la tecla de tabulación).

### El campo `format`: elegir la salida

El campo `format` decide qué tipo de documento se produce:

```yaml
format: docx     # documento de Word
```

```yaml
format: pdf      # documento PDF
```

Para pasar de un formato a otro basta cambiar esa línea. También se pueden declarar varios a la vez, y Quarto
generará uno por cada uno:

```yaml
format:
  docx: default
  pdf: default
```

(Nótese la indentación: `docx` y `pdf` van sangrados bajo `format`, y llevan un valor tras los dos puntos.)

### Opciones útiles

Las más habituales son la tabla de contenido y la numeración de secciones:

```yaml
format:
  docx:
    toc: true               # incluir tabla de contenido
    number-sections: true   # numerar los títulos automáticamente
  pdf:
    toc: true
    number-sections: true
```

El campo `date: today` inserta la fecha de generación automáticamente; también existe `date: last-modified`.

---

## 5. Markdown: dar formato al texto

El texto se escribe en **Markdown**, un lenguaje sencillo donde el formato se indica con símbolos en lugar de
menús. Conviene aclarar que Markdown **no es propio de Quarto ni de RStudio**: es un formato universal, usado en
GitHub, en foros, en blocs de notas, en aplicaciones de mensajería y en incontables herramientas. Lo que se
aprende aquí sirve en cualquiera de esos espacios.

### Títulos y subtítulos

Los títulos se marcan con el símbolo **numeral** (`#`) al inicio de la línea. La cantidad de numerales define el
nivel jerárquico, que a su vez determina la estructura del documento y su tabla de contenido:

```markdown
# Título de primer nivel (sección principal)

## Título de segundo nivel (subsección)

### Título de tercer nivel

#### Título de cuarto nivel
```

La jerarquía importa: un `##` es una subsección del `#` que lo precede. Si se activó `number-sections: true`,
Quarto numera los títulos según esa jerarquía (1, 1.1, 1.1.1).

### Énfasis, listas y enlaces

Para poner texto en **negrita** se rodea con **dos asteriscos** a cada lado; para *cursiva*, con **un asterisco**
a cada lado:

```markdown
Texto en **negrita** (dos asteriscos) y texto en *cursiva* (un asterisco).

Lista con viñetas:

- Primer elemento
- Segundo elemento
  - Subelemento (sangrado con dos espacios)

Lista numerada:

1. Primer paso
2. Segundo paso

Un [enlace a un sitio](https://quarto.org).

Una imagen: ![Descripción de la imagen](ruta/imagen.png)
```

### Ecuaciones

Las fórmulas se escriben en notación LaTeX, entre signos de dólar: dólares simples para una ecuación dentro del
texto, dólares dobles para una ecuación en su propia línea:

```markdown
La media se denota $\bar{x}$ dentro del texto.

$$y = \beta_0 + \beta_1 x + \varepsilon$$
```

> Las ecuaciones se ven perfectas en PDF. En Word funcionan, pero pueden requerir ajustes; con muchas fórmulas
> complejas, el PDF da mejores resultados.

---

## 6. Los bloques de código

Aquí está el corazón de la reproducibilidad: los **bloques de código** (*chunks*), fragmentos de R que se
ejecutan al renderizar y cuyos resultados se insertan en el documento. Un bloque se abre con tres acentos
graves y `{r}`, y se cierra con tres acentos graves:

````
```{r}
library(tidyverse)
datos <- read_csv("datos.csv")
summary(datos$measure_lect)
```
````

### Nombrar los bloques

Después de la `r` se le puede dar un **nombre** al bloque. Esto parece un detalle menor, pero en un informe con
muchos bloques resulta muy útil: al renderizar, Quarto informa el progreso y los errores **por nombre**, de modo
que un bloque con nombre se localiza de inmediato, mientras que uno sin nombre aparece como un número anónimo
difícil de rastrear. La recomendación es nombrarlos siempre, con etiquetas descriptivas:

````
```{r}
#| label: carga-datos

datos <- read_csv("datos.csv")
```
````

(Los nombres deben ser únicos dentro del documento y conviene que no lleven espacios.)

### Controlar qué se muestra: las opciones de bloque

Casi nunca se quiere mostrar todo. En un informe formal suele interesar el resultado, pero no el código que lo
produjo. Eso se controla con **opciones de bloque**.

> **Sobre las dos formas de escribir las opciones.** Si ya se ha trabajado con R Markdown, se recordará que las
> opciones se escribían en la misma línea de apertura, separadas por comas: `{r, echo=FALSE, warning=FALSE}`.
> **Esa forma clásica sigue siendo válida en Quarto**, así que no es un error usarla. Quarto introdujo además
> una forma nueva, con líneas que empiezan por `#|` (numeral y barra vertical) dentro del bloque, que resulta
> más cómoda cuando hay muchas opciones y es coherente con el estilo del YAML. Ambas funcionan; en esta lección
> se usa la nueva, pero la de comas no ha desaparecido.

Con la forma nueva:

````
```{r}
#| label: modelo-regresion
#| echo: false        # oculta el código, muestra solo el resultado
#| warning: false     # oculta las advertencias de R
#| message: false     # oculta los mensajes (como los de carga de paquetes)

modelo <- lm(measure_lect ~ measure_mate, data = datos)
summary(modelo)
```
````

Las opciones más usadas:

- `echo: false` oculta el código (útil para informes dirigidos a lectores no técnicos).
- `eval: false` muestra el código pero **no** lo ejecuta (útil para enseñar sintaxis).
- `message: false` y `warning: false` ocultan los mensajes y advertencias que R imprime.
- `include: false` ejecuta el código pero no muestra nada (útil para el bloque de preparación).
- `fig-cap: "Texto"` añade un pie a una figura.

### El bloque de preparación: una pieza clave

**Este es uno de los elementos más importantes de todo el documento.** Casi todo informe empieza con un
**bloque de preparación** (por convención llamado `setup`), que se ejecuta una sola vez al inicio y deja listo
todo lo que el resto del documento necesitará: carga los paquetes, lee los datos y fija las opciones generales.
Concentrar esto en un único bloque evita repetir `library()` y lecturas en cada sección, y hace que el
documento sea fácil de mantener: si algo hay que cambiar, se cambia en un solo lugar.

````
```{r}
#| label: setup
#| include: false

library(tidyverse)
library(flextable)

# Fija opciones para TODOS los bloques del documento
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)

datos <- read_csv("datos.csv")
```
````

La opción `include: false` es la que hace que este bloque trabaje "entre bastidores": ejecuta todo, pero no
muestra ni el código ni ningún resultado. Las mismas opciones globales pueden fijarse también desde el YAML, con
el campo `execute`:

```yaml
execute:
  echo: false
  warning: false
  message: false
```

### Código en línea: cifras automáticas dentro del texto

Un valor calculado puede incrustarse **dentro de una frase**, con lo que hasta las cifras del texto corrido se
actualizan solas. Se escribe con un acento grave, la letra `r`, la expresión, y otro acento grave:

```markdown
El promedio de lectura fue de `r round(mean(datos$measure_lect), 2)` puntos.
```

Al renderizar, esa expresión se sustituye por el número calculado. Es una de las razones de fondo para trabajar
así: se elimina toda transcripción manual.

### La lógica del ambiente propio

Un punto conceptual importante: al renderizar, Quarto ejecuta el documento en una **sesión de R nueva y
aislada**, que no ve nada de lo que haya en la sesión interactiva donde se está trabajando. Es como si el
documento se ejecutara en una computadora recién encendida.

La consecuencia es que **todo lo que el documento necesita debe estar dentro del propio documento** (o cargarse
desde él): los paquetes, la lectura de los datos, las funciones. Si una función se definió en la consola pero no
en el documento, al renderizar dará error, porque ese ambiente limpio no la conoce. Esa misma lógica es la que
garantiza la reproducibilidad: si el documento se renderiza en cualquier otra máquina, dará el mismo resultado,
porque no depende de nada externo escondido en la sesión.

---

## 7. Tablas con formato: `kable`, `gt` y `flextable`

Una tabla escrita a mano en Markdown sirve para datos fijos, pero lo habitual es generar la tabla a partir de un
resultado de R, dentro de un bloque de código. Hay tres paquetes principales, con perfiles distintos. Conviene
conocerlos porque la elección afecta bastante el resultado, sobre todo en Word.

**`knitr::kable()`: la más simple.** Viene con `knitr`, no requiere instalar nada y produce una tabla básica y
correcta en cualquier formato. Es la opción rápida cuando no se necesita mucho formato.

```r
library(knitr)

datos %>%
  group_by(area) %>%
  summarise(media = mean(measure_lect), de = sd(measure_lect)) %>%
  kable(digits = 2, caption = "Desempeño en lectura por área")
```

**`gt`: la más expresiva, sobre todo para HTML y PDF.** Ofrece una gramática rica para construir tablas muy
pulidas (títulos, notas al pie, formato por celda, agrupaciones). Brilla en HTML y PDF; su soporte para Word ha
mejorado, pero históricamente ha sido menos completo que en los otros formatos.

```r
library(gt)

datos %>%
  group_by(area) %>%
  summarise(media = mean(measure_lect), de = sd(measure_lect)) %>%
  gt() %>%
  fmt_number(columns = c(media, de), decimals = 2) %>%
  tab_header(title = "Desempeño en lectura por área")
```

**`flextable`: la mejor para Word.** Fue diseñada pensando en Word y PowerPoint, y produce **tablas nativas de
Word** con control total del formato (bordes, tipografías, combinación de celdas, alineación). Cuando el destino
del informe es un `.docx`, es la opción recomendada, porque el resultado se integra en el documento como una
tabla de Word editable y con el formato que se le indique.

```r
library(flextable)

tabla <- datos %>%
  group_by(area) %>%
  summarise(media = mean(measure_lect), de = sd(measure_lect)) %>%
  flextable() %>%
  colformat_double(digits = 2) %>%
  set_header_labels(area = "Área", media = "Media", de = "Desviación") %>%
  autofit()

tabla
```

**Alineación de la tabla en la página.** `flextable` distingue dos tipos de alineación. La de los **contenidos**
(dentro de las celdas) se controla con `align()`; la de la **tabla completa** respecto de la página (a la
izquierda, centrada o a la derecha) se controla con la opción de bloque `ft.align`, muy útil para que la tabla
quede centrada en el informe:

````
```{r}
#| ft.align: center

tabla %>%
  align(align = "center", part = "all")   # centra el contenido de las celdas
```
````

### Operaciones esenciales de `flextable`

Como `flextable` es la opción recomendada para Word, conviene conocer sus operaciones más útiles. Todas se
encadenan con el pipe sobre la tabla, y la lógica es siempre la misma: cada función modifica un aspecto y
devuelve la tabla, lista para la siguiente modificación.

**Convertir un objeto en flextable: `as_flextable()`.** Muchos objetos de R (resúmenes, modelos, tablas de
otros paquetes) tienen un método `as_flextable()` que los transforma directamente en una tabla con formato, sin
armarla a mano. Es el punto de partida cuando ya se tiene el objeto:

```r
# A partir de un data frame, flextable() basta; para otros objetos, as_flextable()
resumen <- datos %>%
  group_by(area) %>%
  summarise(media = mean(measure_lect), de = sd(measure_lect))

ft <- flextable(resumen)
```

**Ajustar el ancho: `autofit()` y `width()`.** `autofit()` calcula automáticamente el ancho de cada columna
según su contenido, y suele ser suficiente. Cuando se necesita un control fino, `width()` fija el ancho de una
columna concreta:

```r
ft %>% autofit()                          # ancho automático
ft %>% width(j = "media", width = 1.5)    # ancho fijo (en pulgadas) para una columna
```

**Versión compacta: `set_table_properties(layout = "autofit")` y el argumento `compact`.** Para tablas densas,
algunos constructores aceptan `compact = TRUE`, que reduce el espaciado entre filas y produce una tabla más
apretada. Como alternativa general, las propiedades de la tabla se ajustan con `set_table_properties()`:

```r
# En objetos que lo admiten (por ejemplo, ciertos as_flextable):
as_flextable(modelo, compact = TRUE)

# Ajuste general del diseño y del ancho relativo a la página:
ft %>% set_table_properties(layout = "autofit", width = 1)
```

**Alinear: `align()`.** Controla la alineación del contenido de las celdas. El argumento `part` decide sobre
qué zona actúa: `"header"` (los títulos de columna), `"body"` (los datos) o `"all"` (ambas):

```r
ft %>% align(align = "center", part = "all")     # todo centrado
ft %>% align(align = "right", part = "body")     # solo los datos, a la derecha
```

**Poner en negrita: `bold()`.** Resalta texto, típicamente los encabezados o alguna fila destacada:

```r
ft %>% bold(part = "header")     # encabezados en negrita
```

### El ajuste por celda: los argumentos `i` y `j`

Aquí está la parte más potente y la que más se malentiende. Casi todas las funciones de formato de `flextable`
aceptan dos argumentos, `i` y `j`, que **seleccionan a qué celdas se aplica el cambio**:

- `i` selecciona **filas** (la letra recuerda a "índice" de fila).
- `j` selecciona **columnas**.

Si se omiten, el cambio se aplica a toda la tabla. Si se indican, el cambio se limita a esa intersección de
filas y columnas. Con ejemplos concretos sobre la tabla de desempeño por área:

```r
# Negrita solo en la columna "media" (todas sus filas)
ft %>% bold(j = "media")

# Negrita solo en la primera fila (todas sus columnas)
ft %>% bold(i = 1)

# Fondo de color solo en la celda de la fila 2, columna "de"
ft %>% bg(i = 2, j = "de", bg = "#FFF2CC")

# Selección por CONDICIÓN: resaltar las filas donde la media supera 0.20
ft %>% bold(i = ~ media > 0.20, j = "media")
```

Esa última forma, con `~` (una fórmula), es especialmente útil: en lugar de números de fila fijos, selecciona
las filas que **cumplen una condición** sobre los datos, de modo que el resaltado se ajusta solo si los datos
cambian. Es la manera de destacar automáticamente, por ejemplo, los grupos que superan cierto umbral.

### Integrar la tabla en el flujo del documento

Para que la tabla se comporte como un elemento del informe (con su pie, su numeración y su ancho controlado),
se combinan tres cosas.

**Pie de tabla y numeración automática.** En el bloque de código, la opción `tbl-cap` añade un pie (o título)
de tabla, y Quarto se encarga de **numerarla automáticamente** ("Tabla 1", "Tabla 2") y de permitir
referenciarla en el texto. Además, dentro de `flextable`, `add_footer_lines()` agrega notas al pie de la propia
tabla (por ejemplo, la fuente de los datos):

````
```{r}
#| label: tbl-desempeno
#| tbl-cap: "Desempeño en lectura por área"

resumen %>%
  flextable() %>%
  colformat_double(digits = 2) %>%
  set_header_labels(area = "Área", media = "Media", de = "Desviación") %>%
  add_footer_lines("Nota. Elaboración propia a partir de la muestra de graduandos.") %>%
  autofit()
```
````

Con un `label` que empieza por `tbl-`, se puede referenciar la tabla en el texto con `@tbl-desempeno`, y Quarto
insertará el número correcto ("como muestra la Tabla 1..."), actualizándolo solo si se reordenan las tablas.

**Ancho ajustado a la página en Word.** En Word conviene que la tabla no se desborde del margen. La combinación
más robusta es `set_table_properties()` con anchura relativa, que adapta la tabla al ancho disponible:

```r
resumen %>%
  flextable() %>%
  set_table_properties(layout = "autofit", width = 1) %>%   # ocupa el 100% del ancho útil
  align(align = "center", part = "all")
```

**En resumen:** para un informe rápido en cualquier formato, `kable`; para tablas muy elaboradas en PDF o HTML,
`gt`; y para informes en Word con formato cuidado, `flextable`. Como en estas lecciones el destino habitual es
Word, `flextable` suele ser la elección más segura, y con `autofit()`, `align()`, `bold()`, la selección por
`i`/`j` y la integración con `tbl-cap` se cubre casi todo lo que un informe necesita.

---

## 8. Vincular scripts externos

Poner todas las funciones y el código de preparación dentro de cada documento lo vuelve largo y difícil de
mantener. La solución es guardar ese código en archivos `.R` aparte y **vincularlos** desde el documento. Hay
dos formas complementarias.

### Opción A: `source()` para cargar funciones

Si se tiene un archivo con funciones propias (por ejemplo, `funciones.R`), se cargan en el bloque de preparación
con `source()`, igual que en un script normal:

````
```{r}
#| label: setup
#| include: false

library(tidyverse)
library(here)

# Carga todas las funciones definidas en el archivo externo
source(here("R", "funciones.R"))

datos <- read_csv(here("Datos", "datos.csv"))
```
````

A partir de ese punto, todas las funciones de `funciones.R` quedan disponibles sin haberlas pegado. Se editan en
un solo lugar y todos los documentos que las usan se benefician. Construir las rutas con `here()` es importante
(se explica por qué en la sección de errores).

### Opción B: `read_chunk()` para traer trozos de código

A veces no se quiere cargar funciones, sino **traer al documento fragmentos de análisis** que viven en un script
externo, para mostrarlos o ejecutarlos donde se desee. Para eso sirve `knitr::read_chunk()`.

Primero, en el script externo (por ejemplo, `analisis.R`), se etiquetan los trozos con un comentario de cuatro
guiones:

```r
# archivo: analisis.R

## ---- carga-datos ----
datos <- read_csv(here("Datos", "datos.csv"))

## ---- modelo-regresion ----
modelo <- lm(measure_lect ~ measure_mate, data = datos)
summary(modelo)
```

Después, en el documento `.qmd`, se lee ese script una vez en el bloque de preparación, y luego se "llaman" los
trozos por su etiqueta desde bloques vacíos:

````
```{r}
#| label: setup
#| include: false
library(tidyverse)
library(here)
knitr::read_chunk(here("R", "analisis.R"))
```

Se cargan los datos:

```{r}
#| label: carga-datos
```

Y se ajusta el modelo:

```{r}
#| label: modelo-regresion
```
````

Los bloques cuyo `label` coincide con una etiqueta del script se llenan automáticamente con el código
correspondiente. Así, el análisis vive en un `.R` reutilizable (que puede ejecutarse por sí solo) y el documento
solo lo invoca por partes.

### Cuál usar

`source()` sirve para **cargar** funciones o preparar el entorno (ejecuta el código sin mostrarlo).
`read_chunk()` sirve para **mostrar y ejecutar** fragmentos de análisis en puntos concretos del documento. Es
común usar ambos: `source()` para las funciones y la lectura de datos, y `read_chunk()` para el análisis
principal.

---

## 9. Cómo renderizar el documento

Renderizar (producir el documento final a partir del `.qmd`) se puede hacer de dos formas.

**Desde RStudio:** al abrir un archivo `.qmd`, aparece un botón **Render** en la parte superior del editor. Al
pulsarlo, RStudio renderiza con el formato declarado en el YAML y abre el resultado.

**Desde la terminal:** situándose en la carpeta del archivo, se ejecuta:

```bash
quarto render informe.qmd
```

Esto genera el documento en el mismo directorio (`informe.docx` o `informe.pdf`, según el YAML). Para forzar un
formato concreto:

```bash
quarto render informe.qmd --to pdf
quarto render informe.qmd --to docx
```

El archivo resultante queda junto al `.qmd`, listo para abrir, compartir o enviar.

---

## 10. Errores comunes y cómo leerlos

Los tropiezos al empezar casi siempre son uno de estos:

**El YAML mal indentado.** Un espacio de más, una tabulación o un dos puntos sin espacio después rompen el
documento. Si el error aparece nada más renderizar y menciona el YAML o "parsing", revisar la indentación con
espacios.

**Pedir PDF sin LaTeX instalado.** Si al renderizar a PDF aparece un error que menciona `latex`, `xelatex` o
"tlmgr", falta LaTeX. Se instala con `quarto install tinytex` en la terminal. El Word no da este error.

**Un paquete no instalado en el ambiente limpio.** Como el documento se renderiza en una sesión nueva, un
`library(paquete)` fallará si ese paquete no está instalado en el sistema (no basta con haberlo cargado antes en
la consola). El error dirá "there is no package called...". Se resuelve con `install.packages()`.

**Rutas rotas.** Una ruta relativa como `read_csv("datos.csv")` puede funcionar en la consola y fallar al
renderizar, porque el punto de partida es distinto. Por eso conviene construir **todas** las rutas con `here()`,
que las ancla a la raíz del proyecto. El error típico es "cannot open file" o "No such file or directory". En
Windows, este problema se agrava si la ruta del proyecto contiene tildes, eñes o espacios (véase la sección de
instalación).

**Caracteres especiales.** Guardar siempre el archivo en codificación **UTF-8** (es lo predeterminado en
RStudio). Con el motor `xelatex` que Quarto usa para PDF, las tildes y eñes no dan problemas.

---

## 11. Un flujo de trabajo recomendado

Una organización que funciona bien, dentro de un proyecto de RStudio (lo que hace que `here()` funcione):

```
mi-proyecto/
  mi-proyecto.Rproj
  Datos/
    datos.csv
  R/
    funciones.R      (las funciones propias)
    analisis.R       (el análisis, con trozos etiquetados)
  informe.qmd        (el documento)
```

El documento `informe.qmd`, en su bloque de preparación, carga las funciones con `source()`, lee los datos con
rutas construidas por `here()` y trae el análisis con `read_chunk()`. El texto se escribe en Markdown, los
resultados se generan con bloques de código, las tablas con `flextable`, y las cifras del texto corrido se
insertan con código en línea.

Dos principios cierran la lección. Primero, **todo lo que el documento necesita vive con él** (o en scripts que
él invoca explícitamente), nunca en una sesión escondida; eso es lo que lo hace reproducible. Segundo, para
quien solo necesita Word, **la instalación es mínima** (R, RStudio y Quarto, que suele venir incluido); LaTeX es
un asunto exclusivo del PDF, y con `tinytex` deja de ser un obstáculo.