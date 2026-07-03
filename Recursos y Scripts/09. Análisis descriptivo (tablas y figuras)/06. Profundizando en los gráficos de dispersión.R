# Gráficos de dispersión


pacman::p_load(here,
               tidyverse,
               googlesheets4,
               ggthemes
)

# leer datos

gs4_deauth()

df <- read_sheet("https://docs.google.com/spreadsheets/d/1dhxgz1Jol5K__KKvygWqw2fqd0eJ-uYABtsSMy1FpEA/edit?usp=sharing") %>% 
  clean_names()




# simple ----

ggplot(df, #solo esto crea una hoja en blanco
       aes(autorregulacion,
           empatia
       ))+#esto agrega los axis y sus nombres, pero no datos
  geom_point() # geom_ es para las diferentes figuras geométricas para cada figura, point es para los scatterplots

# Agregar color ----

ggplot(data = df, #solo esto crea una hoja en blanco
       mapping = aes(autorregulacion,
                     empatia,
                     color = genero))+#esto agrega los axis y sus nombres, pero no datos
  geom_point() # geom_ es para las diferentes figuras geométricas para cada figura, point es para los scatterplots


# línea de ajuste ----

ggplot(data = df, #solo esto crea una hoja en blanco
       mapping = aes(autorregulacion,
                     empatia))+#esto agrega los axis y sus nombres, pero no datos
  geom_point(mapping = aes(color=genero)) + # geom_ es para las diferentes figuras geométricas para cada figura, point es para los scatterplots
  geom_smooth(method = lm)


# Geometría distinta según genero

# different geom point shapes by species
ggplot(data = df, #solo esto crea una hoja en blanco
       mapping = aes(autorregulacion,
                     empatia))+#esto agrega los axis y sus nombres, pero no datos
  geom_point(mapping = aes(color=area, shape = genero)) + # geom_ es para las diferentes figuras geométricas para cada figura, point es para los scatterplots
  geom_smooth(method = lm)

# Cambiar etiquetas

# change labels
ggplot(data = df, #solo esto crea una hoja en blanco
       mapping = aes(autorregulacion,
                     empatia))+#esto agrega los axis y sus nombres, pero no datos
  geom_point(mapping = aes(color=area, shape = genero)) + # geom_ es para las diferentes figuras geométricas para cada figura, point es para los scatterplots
  geom_smooth(method = lm) +
  labs(title="Relación entre autorregulación y empatía",
       subtitle="Ejemplo de gráfico de dispersión",
       x = "Autorregulación",
       y = "Empatía",
       color = "Área",
       shape= "Género")+
  scale_color_colorblind() #esto es para que los colores sean adecuados para personas daltónicas
