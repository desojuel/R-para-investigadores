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

# Tabla simple ----

## con janitor ---- 

tabla_simple_janitor <- df %>% 
  mutate(area = factor(area, levels = c("Urbana", "Rural"))) %>%
  tabyl(area) %>% 
  adorn_totals("row") %>% 
  adorn_pct_formatting(digits = 2) %>% 
  mutate(f = comma(n)) %>% 
  select(Área = area, 
         f, 
         `%` = percent)
  
### pasar a flextable ---- 

flextable(tabla_simple_janitor) %>%
  bold(part = "header") %>%
  align(j = 2:3, align = "center", part = "header") %>%
  align(j = 2:3, align = "right", part = "body") %>%
  fontsize(size = 9, part = "all") %>%
  width(j = 1, width = 0.5) %>%
  width(j = 2:3, width = 0.5)

# Tabla de resumen estadístico ----

tabla_resumen <- df %>% 
  summarise(
    Media = round(mean(autorregulacion, na.rm = TRUE), 3),
    Mediana = round(median(autorregulacion, na.rm = TRUE), 3),
    `Desviación estándar` = round(sd(autorregulacion, na.rm = TRUE), 3),
    Mínimo = min(autorregulacion, na.rm = TRUE),
    Máximo = max(autorregulacion, na.rm = TRUE),
    Rango = (Máximo - Mínimo)
  ) |> 
  pivot_longer(cols = everything(), names_to = "Estadístico", values_to = "Valor")

## flextable

flextable(tabla_resumen) %>%
  bold(part = "header") %>%
  align(j = 2, align = "center", part = "header") %>%
  align(j = 2, align = "right", part = "body") %>%
  fontsize(size = 9, part = "all") %>%
  width(j = 1, width = 1.5) %>%
  width(j = 2, width = 0.5)

# Tabla cruzada ----


tabla_cruzada <- df %>% 
  rename("Área" = area) %>% 
  crosstable(
    rangos_autorregulacion,
    by = "Área",
    total = "both"
  ) %>% 
rename(`Rangos autorregulación` = variable)  %>% select(-c(.id,label))
  
  
## pasar a flextable

flextable(tabla_cruzada) |>
  add_header_row(values = c("Rangos autorregulación", "Área", "Total"),
                 colwidths = c(1, 2, 1)) |>
  merge_v(part = "header") |>
  align(j = 2:4, align = "center", part = "header") |>
  align(j = 2:4, align = "right", part = "body") |>
  bold(part = "header") |>
  fontsize(size = 9, part = "all") |>
  autofit()

# Tablas simples para datos con variables con delimitadores ----
    
df_delim <- read_excel(here("Datos", "Datos limpios", "encuesta_limpia.xlsx")) %>% 
  clean_names()

tabla_simple_delim <- df_delim |> 
  select(otras_dificultades) |> 
  separate_longer_delim(otras_dificultades, delim = "; ") |> 
  dplyr::count("Otras dificultades" = otras_dificultades, sort = F, name = "f") |>
  dplyr::mutate(`%` = scales::percent(f/nrow(df_delim), accuracy = 0.01)) |>
  dplyr::arrange(desc(f)) 

## flextable

flextable(tabla_simple_delim) %>%
  bold(part = "header") %>%
  align(j = 2:3, align = "center", part = "header") %>%
  align(j = 2:3, align = "right", part = "body") %>%
  fontsize(size = 9, part = "all") %>%
  width(j = 1, width = 1.5) %>%
  width(j = 2:3, width = 0.5)

# exportar

write_xlsx(tabla_simple_delim, here("Datos","Exportar tablas","tabla_simple_delim.xlsx"))

write_xlsx(tabla_simple_janitor, here("Datos","Exportar tablas","tabla_simple_janitor.xlsx"))

## tablas en una misma hoja

tablas <- list(
  tabla_simple_delim   = tabla_simple_delim,
  tabla_simple_janitor = tabla_simple_janitor
)

write_xlsx(tablas, here("Datos", "Exportar tablas", "tablas_unidas.xlsx"))

## talbas renombradas en una misma hoja

write_xlsx(
  list(
    "Simple delim"   = tabla_simple_delim,
    "Simple janitor" = tabla_simple_janitor
  ),
  here("Datos", "Exportar tablas", "tablas_renombradas.xlsx")
)
