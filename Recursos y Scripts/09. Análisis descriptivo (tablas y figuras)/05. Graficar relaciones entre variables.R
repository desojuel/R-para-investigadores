pacman::p_load(here,
               tidyverse,
               googlesheets4,
               ggthemes
)

# leer datos

gs4_deauth()

df <- read_sheet("https://docs.google.com/spreadsheets/d/1dhxgz1Jol5K__KKvygWqw2fqd0eJ-uYABtsSMy1FpEA/edit?usp=sharing") %>% 
  clean_names()


# Visualizar relaciones

## Una variable numérica y una variable categórica con un diagrama de cajas

ggplot(df,
       aes(area, #primero va la categórica
           autorregulacion))+
  geom_boxplot() +
  labs(y="Autorregulación",
       x="Área")

## Una variable numérica y una categórica con una gráfica de densidad

ggplot(df,
       aes(autorregulacion, color=
             area))+
  geom_density(linewidth=0.75) + 
  labs(color = NULL,
       x = "Autorregulación",
       y = "Densidad")

## Una variable numérica y una categórica con una gráfica de densidad (filling)

ggplot(df,
       aes(autorregulacion, color=
             area, fill=area))+
  geom_density(alpha=0.5) + #qué tan transparente
  labs(color = NULL,
       fill = NULL,
       x = "Autorregulación",
       y = "Densidad",
       title = "Densidad de la autorregulación según área")

# Dos variables categóricas ----

#Se puede usar gráfico de barras apiladas para visualizar la relación entre dos variables categóricas

ggplot(df, 
       aes(x=area, fill=genero))+
  geom_bar() + 
  labs(fill = NULL,
       x = "Área",
       y = "Frecuencia",
       title = "Área según género") +
  theme(plot.title = element_text(hjust = 0.5))


# Dos variables numéricas ----

ggplot(df, aes(autorregulacion, empatia))+
  geom_point()

# Tres o más variables ----

ggplot(df, aes(autorregulacion, empatia))+
  geom_point(aes(color=area, shape = genero))

#facet para que no se vea tan desordenado + ggthemes

ggplot(df, aes(autorregulacion, empatia))+
geom_point(aes(color=area))+
  scale_color_few() +   # paleta a juego con theme_few()
  theme_few() # o cualquier otro tema de ggthemes




