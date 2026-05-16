# Los Scripts de R

## 1. ¿Qué es un script?

Un script de R es un archivo de texto donde escribimos y guardamos código para poder reutilizarlo, modificarlo y ejecutarlo cuando queramos.

A diferencia de la consola, el script sí conserva el trabajo. Esto permite:

- Guardar análisis y procesos.
- Editar código fácilmente.
- Compartir código con otras personas.
- Reproducir análisis en el futuro.
- Mantener un flujo de trabajo organizado.

Los scripts normalmente tienen la extensión `.R`.

---

## 2. Escribir código en el script

En RStudio, el script se escribe en el panel superior izquierdo llamado **Source** o editor de scripts.

El código no se ejecuta automáticamente al escribirlo. Primero debe enviarse a la consola.

### Ejemplo

# Esto está escrito en el script
x <- c(10, 20, 30)

mean(x)

---

## 2.1 Ejecutar código desde el script

La forma más común de trabajar mientras escribes código es ejecutar solo una línea o una selección.

| Forma | Uso |
|---|---|
| Ctrl + Enter | Ejecuta la línea actual o el código seleccionado |
| Botón Run | Ejecuta código seleccionado |

Ejemplo:

x <- 1:10  
mean(x)

Puedes colocar el cursor sobre mean(x) y ejecutarlo con Ctrl + Enter.

---

## 2.2 Ejecutar todo el script: Source

Cuando quieres correr el archivo completo, puedes usar el botón Source.

Source ejecuta todas las líneas del script automáticamente.

Internamente, RStudio hace algo equivalente a:

source("mi_script.R")

---

## 2.3 Diferencia entre Run y Source

| Acción | Qué hace |
|---|---|
| Run o Ctrl + Enter | Ejecuta solo la línea o selección |
| Source | Ejecuta todo el script completo |

Ejemplo:

x <- 10  
y <- 20  
x + y  

Si usas Run, puedes ejecutar solo una línea.  
Si usas Source, se ejecuta todo el bloque completo.

---

## 2.4 Source with Echo

RStudio también ofrece Source with Echo, que ejecuta todo el script mostrando cada línea en la consola antes de ejecutarla.

Esto ayuda a:

- Ver el flujo completo del script
- Depurar errores
- Entender scripts largos

---

## 2.5 ¿Cuándo usar cada uno?

| Situación | Recomendación |
|---|---|
| Probar una línea rápida | Run |
| Depurar código paso a paso | Run |
| Ejecutar todo el análisis | Source |
| Verificar script completo | Source |

---

## 3. Buenas prácticas en el uso de scripts

Escribir scripts organizados hace que el código sea más fácil de leer, corregir y reutilizar.

---

## 3.1 Títulos y subtítulos en scripts (índice del script)

En RStudio, los títulos no solo organizan visualmente el código: también crean un índice navegable del script (Document Outline).

Esto se logra con comentarios especiales:

# Título ----

---

## 3.1.1 Cómo funciona el índice (Document Outline)

Cuando usas:

# Carga de datos ----  
# Limpieza de datos ----  
# Modelos ----  

RStudio genera automáticamente un índice del script que permite:

- Navegar entre secciones
- Ver la estructura general del análisis
- Acceder rápidamente a partes del código

---

## 3.1.2 Ejemplo de estructura con índice

# Carga de datos ----

datos <- read.csv("archivo.csv")

# Limpieza de datos ----

datos <- na.omit(datos)

# Análisis descriptivo ----

summary(datos)

---

## 3.1.3 Jerarquía de subtítulos

También puedes crear niveles:

# Análisis general ----

## Estadística descriptiva ----

## Modelos ----

Esto ayuda a organizar el script en secciones y subsecciones.

---

## 3.2 Uso de comentarios

Los comentarios sirven para explicar el código. Todo lo que empieza con # no se ejecuta.

# Crear vector de edades
edades <- c(20, 25, 30)

# Calcular promedio
mean(edades)

---

## 3.3 Longitud manejable

Un script demasiado largo es difícil de mantener.

Mala práctica:

# todo en un solo archivo

Mejor práctica:

01_carga.R  
02_limpieza.R  
03_analisis.R  
04_resultados.R  

---

## 3.4 Buenas prácticas generales

---

## 3.4.1 Procesos independientes

Cada script debe cumplir una función clara:

importar_datos.R  
limpiar_datos.R  
modelo.R  
graficos.R  

---

## 3.4.2 Trabajo en proyectos

Estructura recomendada:

proyecto/  
├── datos/  
├── scripts/  
├── graficos/  
└── resultados/  

---

## 3.4.3 Balance entre comentarios y código claro

Menos claro:

x <- c(1,2,3)

Más claro:

edades_estudiantes <- c(1,2,3)

---

## 4. Guardar scripts

## 4.1 Guardar por primera vez

- File → Save  
- Elegir ubicación  
- Nombrar archivo `.R`

Ejemplo:

analisis_datos.R  

---

## 4.2 Buenas prácticas al guardar

| Buena práctica | Ejemplo |
|---|---|
| Nombres descriptivos | limpieza_datos.R |
| Sin espacios | modelo_final.R |
| Uso de guiones bajos | analisis_exploratorio.R |
| Numeración | 01_importar.R |

---

## 4.3 Guardar frecuentemente

| Atajo | Acción |
|---|---|
| Ctrl + S | Guardar script |

---

> La consola sirve para experimentar; los scripts sirven para construir análisis reproducibles, organizados y permanentes.

