pacman::p_load(here,
               tidyverse,
               janitor,
               googlesheets4,
               readxl,
               haven)

# Tres formas de abrir un archivo ----

## 1. Desde un archivo en la computadora ----

### Excel ----
graduandos2025_excel <- read_xlsx(here("Datos/2025-Grad-Internet.xlsx"))

### CSV ----
graduandos2025_csv <- read_csv(here("Datos/2025-Grad-Internet.csv"))

### SPSS ----
graduandos2025_sav <- read_sav(here("Datos/2025-Grad-Internet.sav"))

## 2. Desde Google Sheets ----
muestra_erce_2019_gsheets <- read_sheet("https://docs.google.com/spreadsheets/d/1dhxgz1Jol5K__KKvygWqw2fqd0eJ-uYABtsSMy1FpEA/edit?usp=sharing")

## 3. Desde una página web ----
temp <- tempfile()

download.file("https://edu.mineduc.gob.gt/digeduca/apps/Bases_de_Datos_Evaluaciones/navegador/2025/documents/2025-Grad-Internet.zip",
              temp)

graduandos2025_web <- read_sav(unzip(temp), user_na = T)