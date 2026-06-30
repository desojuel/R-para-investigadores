# tablas ----

## tablas simples ----

make_freq_table <- function(data, var, label, levels_order = NULL) {
  var <- enquo(var)
  
  data <- data %>%
    mutate(!!var := if_else(is.na(!!var), "Sin información", as.character(!!var)))
  
  if (!is.null(levels_order)) {
    data <- data %>%
      mutate(!!var := factor(!!var, levels = levels_order, ordered = TRUE))
  }
  
  data %>%
    tabyl(!!var, show_na = FALSE) %>%
    {
      if (is.null(levels_order)) dplyr::arrange(., desc(n)) else dplyr::arrange(., !!var)
    } %>%
    adorn_totals("row") %>%
    mutate(
      f   = scales::comma(n),
      `%` = scales::percent(percent, accuracy = 0.01),
      `%` = if_else(`%` == "100.00%", "100%", `%`)
    ) %>%
    select(!!label := !!var, f, `%`)
}

## tabla de resumen  ----

tabla_resumen <- function(df, var) {
  # Función auxiliar para formatear los valores numéricos
  format_value <- function(x) {
    if (is.numeric(x)) {
      rounded_x <- round(x, 3)
      if (rounded_x == as.integer(rounded_x)) {
        return(as.character(as.integer(rounded_x)))
      } else {
        return(sub("\\.?0+$", "", as.character(rounded_x)))
      }
    }
    return(as.character(x))
  }
  
  # Evaluar la variable pasada como símbolo
  var <- rlang::ensym(var)
  
  df |> 
    summarise(
      Media = round(mean(!!var, na.rm = TRUE), 3),
      Mediana = round(median(!!var, na.rm = TRUE), 3),
      `Desviación estándar` = round(sd(!!var, na.rm = TRUE), 3),
      Mínimo = min(!!var, na.rm = TRUE),
      Máximo = max(!!var, na.rm = TRUE),
      Rango = (Máximo - Mínimo)
    ) |> 
    pivot_longer(cols = everything(), names_to = "Estadístico", values_to = "Valor") |> 
    mutate(Valor = sapply(Valor, format_value))
}

## tablas para delimitadores ----
 
select_multiple <- function(df, var, label, delim) {
  var <- enquo(var)
  df %>%
    select(!!var) %>%
    separate_longer_delim(!!var, delim = delim) %>%
    mutate(!!var := str_trim(!!var)) %>%
    dplyr::count(!!label := !!var, sort = FALSE, name = "f") %>%
    mutate(`%` = scales::percent(f / nrow(df), accuracy = 0.01)) %>%
    arrange(desc(f))
}

## crosstable ----

tabla_cruzada <- function(df, var_fila, var_columna, etiqueta_fila) {
  var_columna <- rlang::as_name(rlang::ensym(var_columna))
  
  df %>%
    crosstable(
      {{ var_fila }},
      by = !!var_columna,
      total = "both"
    ) %>%
    select(-any_of(c(".id", "label"))) %>%
    rename(!!etiqueta_fila := variable)
}

# flextalbes ----

## tabla simple ----
crear_flextable <- function(objeto) {
  flextable(objeto) %>%
    bold(part = "header") %>%
    align(j = 2:3, align = "center", part = "header") %>%
    align(j = 2:3, align = "right", part = "body") %>%
    fontsize(size = 9, part = "all") %>%
    width(j = 1, width = 2) %>%
    width(j = 2:3, width = 0.5)
}

## tabla de resumen ----

crear_flextable_resumen <- function(objeto) {
  flextable(objeto) %>%
    bold(part = "header") %>%
    align(j = 2, align = "center", part = "header") %>%
    align(j = 2, align = "right", part = "body") %>%
    fontsize(size = 9, part = "all") %>%
    width(j = 1, width = 2) %>%
    width(j = 2, width = 0.5)
}


## crosstable ----

flextable_cruzada <- function(tabla, etiqueta_columna) {
  n_cols    <- ncol(tabla)
  n_niveles <- n_cols - 2
  etiqueta_fila <- names(tabla)[1]
  
  flextable(tabla) %>%
    add_header_row(
      values    = c(etiqueta_fila, etiqueta_columna, "Total"),
      colwidths = c(1, n_niveles, 1)
    ) %>%
    merge_v(part = "header") %>%
    align(j = 2:n_cols, align = "center", part = "header") %>%
    align(j = 2:n_cols, align = "right", part = "body") %>%
    bold(part = "header") %>%
    fontsize(size = 9, part = "all") %>%
    autofit()
}

