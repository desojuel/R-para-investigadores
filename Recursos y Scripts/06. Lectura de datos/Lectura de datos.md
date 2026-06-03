## Importar datos en R

El script "Lectura de datos.R" muestra tres formas de traer datos a R, que cubren los escenarios más comunes en investigación y análisis de datos: abrir archivos que están en la computadora, conectarse a una hoja de Google Sheets, y descargar archivos directamente desde una página web.

Los datos que se utilizan a lo largo de este ejemplo son los resultados de la **Evaluación de Graduandos 2025** del Ministerio de Educación de Guatemala, publicados por DIGEDUCA y disponibles de forma pública. Se eligieron  porque están disponibles en múltiples formatos (Excel, CSV, SPSS y en línea), lo que permite demostrar cada forma de importación con los mismos datos.

El único archivo que difiere es el relacionado a la importación desde Google Sheets, que es una muestra de los datos de Guatemala en ERCE 2019 seleccionado solo algunas variables.

### Preparación

El script comienza cargando las librerías necesarias con `pacman::p_load()`:

```r
pacman::p_load(here,
               tidyverse,
               janitor,
               googlesheets4,
               readxl,
               haven)
```

Se incorpora aquí un paquete nuevo: `googlesheets4`, que permite leer hojas de cálculo directamente desde Google Sheets.

### 1. Desde archivos locales

El repositorio de GitHub **r-para-investigadores** contiene una carpeta llamada **Datos** con los archivos necesarios para estos ejercicios. Al clonar o descargar el repositorio, esa carpeta queda disponible de manera local. La función `here()` construye la ruta hacia esos archivos sin necesidad de escribir la dirección completa del disco duro, solo se indica la carpeta y el nombre del archivo dentro del proyecto.

Desde esa carpeta se pueden abrir los mismos datos en tres formatos distintos, cada uno con su función y paquete correspondiente:

```r
# Excel (.xlsx) — con readxl
graduandos2025_excel <- read_xlsx(here("Datos/2025-Grad-Internet.xlsx"))

# CSV (.csv) — con readr (parte de tidyverse)
graduandos2025_csv <- read_csv(here("Datos/2025-Grad-Internet.csv"))

# SPSS (.sav) — con haven
graduandos2025_sav <- read_sav(here("Datos/2025-Grad-Internet.sav"))
```

Las tres líneas producen el mismo resultado: un data frame (o tibble) con los datos de graduandos cargados en R. Lo que cambia es el formato de origen y la función que se usa para leerlo.

### 2. Desde Google Sheets

Cuando los datos están alojados en una hoja de Google Sheets, se puede leer directamente desde R proporcionando la URL del documento. No es necesario descargar el archivo primero:

```r
gs4_deauth() 

muestra_erce_2019_gsheets <- read_sheet("https://docs.google.com/spreadsheets/d/1dhxgz1Jol5K__KKvygWqw2fqd0eJ-uYABtsSMy1FpEA/edit?usp=sharing")
```

La primera vez que se ejecuta `read_sheet()`, R puede solicitar autorización para acceder a Google Sheets a través del navegador. Este es un paso normal y solo ocurre una vez por sesión.

### 3. Desde una página web

Cuando los datos están publicados en un sitio web (como el portal de DIGEDUCA del Ministerio de Educación), se pueden descargar directamente desde R sin necesidad de abrir un navegador. En este caso, el archivo está comprimido en formato `.zip`, por lo que el proceso tiene un paso adicional: descargar el archivo a una ubicación temporal, descomprimirlo y luego leerlo:

```r
temp <- tempfile()
temp_dir <- tempdir()

download.file("https://edu.mineduc.gob.gt/digeduca/apps/Bases_de_Datos_Evaluaciones/navegador/2025/documents/2025-Grad-Internet.zip",
              temp)

graduandos2025_web <- read_sav(
  unzip(temp_zip, exdir = temp_dir),
  user_na = TRUE
)
```

`tempfile()` reserva una ruta en la carpeta temporal del sistema para almacenar el .zip descargado. `tempdir()` apunta al directorio temporal de la sesión, donde `unzip()` extrae el contenido sin tocar el directorio de trabajo. `read_sav()` lee el archivo SPSS resultante directamente desde esa ubicación. Al cerrar la sesión de R, ambas ubicaciones temporales se eliminan automáticamente.

Los datos de graduandos 2025 utilizados en este ejemplo son datos reales y públicos, disponibles en el sitio de DIGEDUCA: `https://edu.mineduc.gob.gt/digeduca/apps/Bases_de_Datos_Evaluaciones/`