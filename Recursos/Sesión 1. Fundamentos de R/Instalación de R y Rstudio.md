# Instalación

## Paso 1: [Instalar base R](https://cran.rstudio.com/)

## Paso 2: [Instalar RStudio](https://posit.co/download/rstudio-desktop/#download)

## Paso 3 (solo para usuarios de Windows): [Instalar RTools parte 1](https://cran.rstudio.com/bin/windows/Rtools/rtools45/rtools.html)

## Paso 4 (solo para usuarios de Windows): Instalar RTools parte 2

- Correr este código en la consola de R: 

  write('PATH="${RTOOLS40_HOME}\\usr\\bin;${PATH}"',
        file = "~/.Renviron",
        append = TRUE)
