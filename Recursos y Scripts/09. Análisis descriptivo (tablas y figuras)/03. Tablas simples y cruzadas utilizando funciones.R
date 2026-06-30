pacman::p_load(here,
               readxl,
               tidyverse,
               janitor,
               writexl,
               santoku,
               googlesheets4,
               scales,
               crosstable,
               flextable)

# activar funciones personalizadas

source(here("Recursos y Scripts", "09. Análisis descriptivo (tablas y figuras)","02. Funciones para tablas y flextables.R"))


# lectura
gs4_deauth()

df <- read_sheet("https://docs.google.com/spreadsheets/d/1dhxgz1Jol5K__KKvygWqw2fqd0eJ-uYABtsSMy1FpEA/edit?usp=sharing") %>% 
  clean_names()



# crear rangos para una variable cuantitativa ----

quantile(df$autorregulacion)

df <- df %>% 
  mutate(
    rangos_autorregulacion = chop_quantiles(
      autorregulacion,
      probs = c(.25,
                .50,
                .75
      ),
      left = F,
      raw = T
    )
  )

df <- df %>% 
  mutate(
    rangos_autorregulacion = chop_quantiles(
      autorregulacion,
      probs = c("10 a 27" = .0,
                "28 a 31" = .25,
                "32 a 34" = .50,
                "35 a 40" = .75
      ),
      left = T,
      raw = T
    )
  )

# tablas

# Tabla simple ----

tabla_rangos <- make_freq_table(df, 
                rangos_autorregulacion, 
                "Rangos autorregulación",
                  levels_order = c("10 a 27", "28 a 31", "32 a 34", "35 a 40")
)

crear_flextable(tabla_rangos)
  
tabla_area <- make_freq_table(df, 
                area, 
                "Área", 
                levels_order = c("Urbana", "Rural"))

crear_flextable(tabla_area)

# Tabla de resumen estadístico

tabla_resumen_autorregulacion <- tabla_resumen(df, autorregulacion)

crear_flextable_resumen(tabla_resumen_autorregulacion)

# Tabla delimitadores

df_delim <- read_excel(here("Datos", "Datos limpios", "encuesta_limpia.xlsx")) %>% 
  clean_names()

tabla_delim <- select_multiple(df_delim, 
                otras_dificultades,
                "Otras dificultades",
                "; ")

crear_flextable(tabla_delim)

# tablas cruzadas

tablas_cruzadas_autorregulacion <- tabla_cruzada(df, 
              rangos_autorregulacion,
              area,
              "Rangos autorregulación") # etiqueta de filas

flextable_cruzada(tablas_cruzadas_autorregulacion,
                 "Área") #agregar etiqueta de columnas
