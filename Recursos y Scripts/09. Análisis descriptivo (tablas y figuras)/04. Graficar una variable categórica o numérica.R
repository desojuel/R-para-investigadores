pacman::p_load(here,
               tidyverse,
               googlesheets4,
               ggthemes
               )

# leer datos

gs4_deauth()

df <- read_sheet("https://docs.google.com/spreadsheets/d/1dhxgz1Jol5K__KKvygWqw2fqd0eJ-uYABtsSMy1FpEA/edit?usp=sharing") %>% 
  clean_names()


# gráfico de barras para variables categóricas ----

ggplot(df,
       aes(area))+
  geom_bar() + 
  labs(y = "Frecuencia",
       x = "Área")

# gráfico de barras en el eje y axis

ggplot(df,
       aes(y=fct_infreq(area))) +
  geom_bar() +
  labs(y = "Área",
       x = "Frecuencia")

# gráfico de barras ordenado de mayor a menor
ggplot(df,
       aes(fct_infreq(area)))+ #primero convierte en factor
  geom_bar() +
  labs(y = "Frecuencia",
       x = "Área")

# Añadir colores en gráfico de barras

ggplot(df,
       aes(fct_infreq(area)))+ #primero convierte en factor
  geom_bar(fill="red", color = "blue") + #fill adentro y color los bordes
  labs(y = "Frecuencia",
       x = "Área")

## cada categoría con su color 

ggplot(df,
       aes(x = fct_infreq(area), fill = area)) +
  geom_bar(color = "black") +
  labs(y = "Frecuencia",
       x = "Área",
       fill = NULL)

# histograma para variables numéricas

ggplot(df,
       aes(autorregulacion)) +
  geom_histogram(binwidth = 5) + 
  labs(x = "Autorregulación",
       y = "Frecuencia")

# grafico de densidad

ggplot(df,
       aes(autorregulacion))+
  geom_density() +
  labs(title = "Gráfico de densidad") + 
  labs(x = "Autorregulación",
       y = "Densidad")
