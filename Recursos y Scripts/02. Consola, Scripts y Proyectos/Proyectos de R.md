# El uso de proyectos de R

Los proyectos en RStudio permiten organizar archivos, datos y scripts relacionados con un mismo proceso de análisis en un solo espacio de trabajo. Utilizar proyectos ayuda a mantener ordenados los recursos, facilita el trabajo colaborativo y evita problemas relacionados con rutas de archivos, objetos cargados o configuraciones mezcladas entre distintos análisis.

Un proyecto en RStudio es una carpeta asociada a un archivo con extensión .Rproj, el cual almacena configuraciones del entorno de trabajo del proyecto.

Ejemplo:

analisis_investigacion.Rproj

Cuando se abre este archivo, RStudio:

- Carga automáticamente el proyecto.
- Cambia el directorio de trabajo al de la carpeta del proyecto.
- Muestra el nombre del proyecto en la barra superior de RStudio.
- Mantiene organizados los archivos relacionados con ese proceso.

## Diferencia entre un proyecto y un script

Un script únicamente almacena código.
Un proyecto organiza:

- scripts,
- datos,
- gráficos,
- documentos,
- configuraciones,
- y el directorio de trabajo.

# Dónde crear y guardar proyectos

- Dar clic en el ícono de crear proyecto (representado por un cubo con la letra “R” en su interior, ubicado en la barra superior de RStudio).

Se puede guardar en: 

- Directorio nuevo: crea una carpeta nueva para iniciar un proyecto desde cero de forma organizada y separada de otros procesos.
- Directorio existente: utiliza una carpeta que ya contiene archivos, datos o scripts y la convierte en un proyecto de RStudio.
- Control de versiones: crea o vincula el proyecto a sistemas como Git para facilitar el trabajo colaborativo, el control de cambios y la integración con plataformas como GitHub.

## Diferencia entre abrir RStudio normalmente y abrir un proyecto

## Abrir un proyecto desde otro proyecto

Si ya existe un proyecto abierto en RStudio y se abre otro proyecto desde:

File > Open Project

o desde el menú de proyectos de RStudio:

el proyecto actual se cierra, y RStudio cambia completamente al nuevo proyecto.

Esto significa que solamente queda un proyecto activo dentro de esa ventana de RStudio.

# Abrir proyectos desde el taskbar o acceso directo

Si se abre un proyecto de RStudio nuevamente desde el taskbar, menú de inicio o acceso directo del sistema operativo:

se crea una nueva ventana independiente de RStudio, cada ventana puede tener un proyecto distinto, y es posible cambiar entre proyectos moviéndose entre ventanas.

Esto permite trabajar simultáneamente en varios proyectos sin cerrar los demás.

# El espacio de trabajo (Working Directory o WD)

El Working Directory (WD) es la carpeta principal desde la cual R busca y guarda archivos.

Cuando se trabaja con proyectos:

el WD normalmente corresponde automáticamente a la carpeta del proyecto,
lo que evita problemas con rutas de archivos.

Trabajar correctamente con el WD y proyectos permite:

- reproducir análisis,
- compartir proyectos con otras personas,
- evitar errores de rutas,
- y mantener procesos organizados.

# Pestañas activas

RStudio permite mantener múltiples archivos abiertos mediante pestañas.

Ejemplos:

- scripts .R
- documentos .Rmd (documentos con sistema de marcadores desde R)
- archivos .csv
- notebooks (archivos que generan código pero que tienen echo del código que los generó)
- otros documentos de texto (como los md)

5.6 Guardar el proyecto

# Guardar un proyecto implica guardar:

los scripts,
documentos,
configuraciones,
y demás archivos asociados.
Importante

*Guardar un script NO significa guardar todo el proyecto.*

Por ello es importante:

guardar frecuentemente los scripts,
verificar los archivos del proyecto,
y mantener organizada la carpeta del proyecto.

# Un proyecto por proceso

Se recomienda utilizar un proyecto independiente para cada proceso de análisis.

Evitar mezclar proyectos

No es recomendable mezclar en un mismo proyecto:

- investigaciones distintas,
- análisis no relacionados,
- bases de datos de diferentes procesos,
- o productos de distinta naturaleza.

