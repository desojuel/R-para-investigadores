# Pruebas de diferencias y asociación

## Recorrido de la lección

Esta lección tiene un enfoque **procedimental**: el objetivo no es desarrollar la teoría detrás de cada
prueba, sino entender qué se está decidiendo, comprobar los supuestos, ejecutar las pruebas en R, leer su
resultado y reportarlo. El recorrido es el siguiente:

1. **Los datos**: de dónde salen, qué variables se comparan y por qué se trabaja con una muestra.
2. **Qué significa que una prueba "asuma" algo**: la idea de supuesto, desmitificada.
3. **Las dos familias de pruebas** (paramétricas y no paramétricas) y el problema del nivel de medición en
   educación y psicología.
4. **Comprobación de supuestos** entendida como un proceso de decisión con varias fuentes de evidencia.
5. **Las pruebas**: dos grupos independientes, dos medidas del mismo grupo, tres o más grupos, y asociación
   entre variables categóricas.
6. **Intervalos de confianza** y su interpretación correcta.
7. **Análisis con el diseño muestral** (`survey` y `srvyr`).
8. **Reporte en formato APA**.

---

## 1. Los datos

### 1.1 Por qué se trabaja con una muestra

Las pruebas de esta lección responden siempre a la misma pregunta de fondo: *la diferencia observada entre
estos grupos, ¿puede explicarse por el azar del muestreo, o es lo bastante grande para sostener que existe
también en la población?* Esa pregunta solo tiene sentido cuando se observa una **parte** de la población.

Conviene decirlo con claridad: **si se cuenta con los datos de toda la población, estas pruebas no son
necesarias para comparar grupos**. Si se tienen los puntajes de todos los graduandos del país, la diferencia
entre el área urbana y la rural simplemente **es** la que se observa; no hay incertidumbre de muestreo que
estimar y no hay nada que inferir. En ese caso se describe la diferencia y se valora su magnitud (el tamaño
del efecto), que es lo que informa si importa en términos prácticos.

Aquí se trabaja con una muestra con fines didácticos, extraída de la base completa de graduandos.

### 1.2 Cómo se construyó la muestra

El procedimiento fue el siguiente:

- **Población de referencia:** graduandos del ciclo anual con información completa en las variables de
  estratificación. N = 151,192.
- **Tipo de muestreo:** estratificado proporcional. Se definieron los estratos combinando siete variables
  (región, departamento, sector, área, jornada, rama y sexo), lo que produjo 1,768 estratos.
- **Tamaño de muestra:** se calculó a partir de la precisión deseada, no de forma arbitraria. Con un margen
  de error de ±2 %, un nivel de confianza del 95 %, la proporción más conservadora (p = 0.5) y corrección
  por población finita, la fórmula arroja n = 2,364.
- **Cobertura de estratos:** se impuso la condición de incluir **al menos un caso por estrato**, para que
  ningún estrato quedara sin representación. Como muchos estratos son pequeños, esa condición elevó el
  tamaño final a **n = 3,257**.
- **Variable de pesos:** al apartarse de la proporcionalidad estricta (por el mínimo de un caso por
  estrato), cada caso deja de representar a la misma cantidad de graduandos. Por eso el archivo incluye la
  variable **`peso`**, calculada como el tamaño del estrato en la población dividido entre el número de
  casos muestreados en ese estrato (`N_estrato / n_estrato`). Indica cuántos graduandos representa cada
  caso. La suma de todos los pesos reproduce exactamente la población: 151,192. El archivo incluye además
  `estrato`, `N_estrato`, `n_estrato` y `prob_seleccion`.

Los pesos se retoman en el bloque 9, donde se muestra cómo incorporarlos al análisis.

### 1.3 Las variables que se van a comparar

Antes de entrar a las pruebas conviene conocer las variables, porque los ejemplos las usan repetidamente.

**Variables de resultado (numéricas):**

| Variable       | Qué mide                                                            |
|----------------|---------------------------------------------------------------------|
| `measure_mate` | Medida de desempeño en matemática, en una escala continua centrada cerca de cero (los valores positivos indican mejor desempeño) |
| `measure_lect` | Medida de desempeño en lectura, en la misma escala                  |

**Variables de agrupación (categóricas):**

| Variable         | Categorías                                                | Uso en la lección |
|------------------|-----------------------------------------------------------|-------------------|
| `area`           | Urbana (2,540 casos) y Rural (717)                        | Comparar **dos grupos independientes** |
| `rama_abstracta` | Bachillerato (1,900), Perito (888), Magisterio (282), Secretariado (187). Es la **rama de la carrera de diversificado** que cursó el estudiante, es decir, el tipo de formación del último nivel de educación media | Comparar **más de dos grupos** |
| `logro_mate`     | Sí / No. Indica si el estudiante **alcanzó el nivel de logro** esperado en matemática | **Asociación** entre categóricas |
| `sector`, `jornada`, `region`, `sexo` | Varias categorías                    | Disponibles para practicar |

**Un segundo conjunto de datos, para las pruebas pareadas.** El archivo de graduandos contiene mediciones de
personas distintas, de modo que no permite ilustrar las pruebas de medidas repetidas. Para eso se usa un
conjunto **ficticio** que simula un estudio pre-post: 60 estudiantes universitarios evaluados en vocabulario
científico **antes y después** de participar en un programa de fortalecimiento.

| Variable       | Qué contiene                                              |
|----------------|-----------------------------------------------------------|
| `id`           | Identificador del estudiante                              |
| `carrera`      | Psicología, Educación o Biología                          |
| `vocab_pre`    | Puntaje de vocabulario científico antes del programa (0 a 50) |
| `vocab_post`   | Puntaje de vocabulario científico después del programa    |
| `criterio_pre` / `criterio_post` | Si alcanzó el criterio de 30 puntos (0 = no, 1 = sí) antes y después |

Lo esencial de este diseño es que **cada estudiante aparece dos veces**: sus dos puntajes están vinculados
porque provienen de la misma persona. Esa dependencia es justamente lo que obliga a usar pruebas pareadas.

---

## 2. Preparación del entorno y lectura de datos

```r
pacman::p_load(
  tidyverse,    # manipulación y gráficos
  janitor,      # clean_names(), tabyl()
  rstatix,      # pruebas y tamaños de efecto en formato ordenado
  effectsize,   # tamaños de efecto (eta cuadrado, d de Cohen)
  car,          # leveneTest()
  nortest,      # pruebas de normalidad alternativas
  survey,       # análisis con diseño muestral complejo
  srvyr,        # interfaz tidyverse para survey
  report,       # reporte automático en formato APA
  here
)
```

Al leer el archivo conviene declarar de una vez los códigos que representan datos faltantes. Varias columnas
usan un punto (`"."`) para indicar ausencia de dato, y si no se declara, R lee toda la columna como texto.
El argumento `na` de `read_csv()` resuelve el problema desde la lectura:

```r
datos <- read_csv(
  here("Datos", "muestra_graduandos_anual.csv"),
  na = c("", "NA", ".")          # el punto se interpreta como dato faltante
) %>%
  clean_names()
```

Si el archivo ya se leyó sin esa declaración, la conversión posterior se hace con
`mutate(variable = na_if(variable, "."))` antes de cambiar el tipo.

```r
datos <- datos %>%
  mutate(
    measure_mate   = as.numeric(measure_mate),
    measure_lect   = as.numeric(measure_lect),
    area           = factor(area),
    rama_abstracta = factor(rama_abstracta),
    logro_mate     = factor(logro_mate, levels = c(0, 1), labels = c("No", "Sí"))
  )

# Conjunto pareado (estudio pre-post de vocabulario)
vocab <- read_csv(here("Datos", "vocabulario_pre_post.csv")) %>%
  clean_names()
```

---

## 3. ¿Qué significa que una prueba "asuma" algo?

Decir que "la prueba t asume normalidad" suena a que la prueba tuviera creencias. La idea es más concreta y
conviene desarmarla, porque de ella depende todo el bloque de supuestos.

Una prueba estadística hace dos cosas. Primero, **resume los datos en un solo número** (el estadístico de
prueba): la t, la F, la chi-cuadrado. Segundo, **convierte ese número en un valor p**. Ese segundo paso es el
que introduce los supuestos.

Para saber si un valor de t = 2.56 es sorprendente, hace falta saber **cómo se comportaría ese número si la
hipótesis nula fuera cierta**: qué valores tomaría, con qué frecuencia, si en la población no hubiera ninguna
diferencia y solo actuara el azar del muestreo. Esa referencia se llama **distribución nula**, y no se observa:
se deduce matemáticamente. La deducción exige partir de ciertas condiciones sobre cómo se generaron los datos.

Entonces, **"la prueba asume X" significa: "la fórmula que produce el valor p fue deducida suponiendo que X es
cierto"**. No hay creencia; hay una cadena matemática que solo es válida bajo esas condiciones.

La consecuencia práctica es la que importa. Si el supuesto no se cumple, la distribución de referencia deja de
corresponder a la realidad y **el valor p deja de significar lo que dice significar**. Un procedimiento
declarado al 5 % podría estar equivocándose en realidad un 12 % de las veces. El riesgo no es que "la prueba
se enoje", sino que la probabilidad de error que se cree estar controlando sea otra.

De ahí surge un concepto central: una prueba es **robusta** frente a un supuesto cuando, aunque ese supuesto se
incumpla moderadamente, la tasa real de error se mantiene cerca de la declarada. Los supuestos no funcionan
como interruptores de encendido y apagado: se incumplen en grados, y lo que interesa es si el incumplimiento
es lo bastante severo para desviar el valor p de su significado. Por eso la comprobación de supuestos no puede
reducirse a mirar si un valor p bajó de 0.05.

---

## 4. Las dos familias de pruebas

### 4.1 Paramétricas y no paramétricas

Las **pruebas paramétricas** (t de Student, Welch, ANOVA) estiman parámetros de la población, típicamente la
media, y su distribución nula se dedujo suponiendo que los errores del modelo se distribuyen de forma
aproximadamente normal, que las varianzas son comparables entre grupos y que las observaciones son
independientes. Cuando esas condiciones se sostienen, son las pruebas más **potentes** disponibles, es decir,
las que tienen mayor capacidad de detectar un efecto real si existe.

Las **pruebas no paramétricas** (U de Mann-Whitney, Wilcoxon, Kruskal-Wallis) no suponen una forma particular
de la distribución. En lugar de operar sobre los valores crudos, los sustituyen por **rangos** (las posiciones
ordenadas de los datos) y trabajan con esas posiciones.

Conviene aclarar de entrada un punto que suele malentenderse: **no paramétrica no significa "sin supuestos"**.
Significa que no se supone una distribución concreta. Estas pruebas conservan el supuesto de independencia y,
para poder interpretarse en términos de medianas, requieren que las distribuciones de los grupos tengan formas
comparables. Cambiar de familia no elimina supuestos: los sustituye por otros.

### 4.2 El problema del nivel de medición en educación y psicología

Este punto merece un tratamiento explícito, porque en investigación educativa y psicológica es la situación
habitual y no la excepción.

La taxonomía clásica distingue variables **nominales** (categorías sin orden), **ordinales** (categorías
ordenadas, pero sin distancias iguales entre ellas), **de intervalo** (distancias iguales, cero arbitrario) y
**de razón** (distancias iguales y cero absoluto). La regla tradicional dice que la media requiere al menos
nivel de intervalo, porque promediar supone que la distancia entre 1 y 2 es la misma que entre 4 y 5.

El problema es que la mayoría de los instrumentos de estas disciplinas producen datos que caen en una **zona
gris**. Un ítem tipo Likert ("Nada, Poco, Algo, Bastante, Mucho") es estrictamente ordinal: nada garantiza que
el salto de "Nada" a "Poco" equivalga al de "Bastante" a "Mucho". Sin embargo, en la práctica se suman los
ítems, se calcula la media, se aplica una prueba t y con frecuencia se termina tratando el resultado como si
fuera de razón.

Qué cambia realmente en el contexto de decisión:

**El riesgo principal no es el valor p, sino la interpretación.** Numerosos estudios de simulación muestran que
las pruebas paramétricas aplicadas a puntajes ordinales conservan bastante bien su tasa de error, sobre todo
cuando se trata de **puntajes de escala** (la suma o el promedio de muchos ítems), que se aproximan a una
variable continua. Lo que no se sostiene es afirmar que "el grupo A superó al grupo B en 0.4 puntos" como si
esos 0.4 puntos tuvieran un significado métrico constante a lo largo de la escala.

**La distinción entre ítem y escala es decisiva.** Un **ítem individual** con cuatro o cinco categorías es
claramente ordinal: su media es difícil de interpretar y la vía no paramétrica (o un modelo ordinal) es más
defendible. Un **puntaje de escala** construido con quince o veinte ítems tiene muchos valores posibles, su
distribución se aproxima a la continua y el tratamiento paramétrico es ampliamente aceptado.

**Las pruebas de rangos tampoco son neutrales aquí.** Con pocas categorías se producen muchísimos **empates**
(observaciones con el mismo valor), y las pruebas basadas en rangos requieren correcciones para manejarlos, lo
que reduce su potencia. En estos datos, por ejemplo, la variable `desempeño_mate` tiene cuatro niveles para
3,257 casos: hay miles de empates. Recurrir a Mann-Whitney no resuelve el problema del nivel de medición, solo
lo desplaza.

**La alternativa de fondo son los modelos ordinales.** Cuando la naturaleza ordinal es central para la
pregunta, existen modelos que la tratan explícitamente, sin forzar ni la media ni los rangos: los modelos de
regresión ordinal (`ordinal::clm()`, `MASS::polr()`) modelan la probabilidad de caer en cada categoría o por
debajo de ella. Son la respuesta más honesta cuando la variable es un ítem ordinal con pocas categorías.

**Guía práctica.** Explicitar siempre qué se está suponiendo sobre el nivel de medición; preferir el
tratamiento paramétrico para puntajes de escala con muchos valores; preferir modelos ordinales o pruebas de
rangos para ítems individuales con pocas categorías; y, ante la duda, **ejecutar ambas vías y verificar si la
conclusión cambia**. Si coinciden, el debate sobre el nivel de medición no altera lo que se puede afirmar.

### 4.3 Esquema de decisión

| ¿Qué se compara?                           | Vía paramétrica                     | Vía no paramétrica          |
|--------------------------------------------|-------------------------------------|------------------------------|
| Dos grupos independientes                  | t de Welch (o t de Student clásica) | U de Mann-Whitney            |
| Dos medidas del mismo grupo (pareadas)     | t de Student pareada                | Wilcoxon (rangos con signo)  |
| Tres o más grupos                          | ANOVA (o ANOVA de Welch)            | Kruskal-Wallis               |
| Asociación entre dos variables categóricas | (no aplica)                         | Chi-cuadrado / Fisher exacta |

---

## 5. Comprobación de supuestos

En la práctica circula una regla simplificada que conviene desactivar desde el principio: *"si Shapiro-Wilk
sale significativo, se pasa directamente a la prueba no paramétrica"*. Esa regla convierte una decisión
compleja en un interruptor automático accionado por un solo valor p, y en muestras grandes conduce
sistemáticamente a la elección equivocada. El apartado 5.5 la examina en detalle.

La comprobación de supuestos se entiende mejor como un **proceso de decisión alimentado por varias fuentes de
evidencia**, ninguna de las cuales manda por sí sola: el diseño del estudio, las pruebas formales, el
diagnóstico gráfico, los estadísticos de forma, el tamaño de muestra y la convergencia entre métodos distintos.

### 5.1 Qué es un residuo

El supuesto de normalidad recae sobre los **errores del modelo**, y en la práctica se examinan los
**residuos**. Conviene hacer concreta esa expresión, porque "la parte que el modelo no explica" suena abstracta.

Toda prueba de comparación de grupos lleva implícito un **modelo**, es decir, una regla de predicción. En un
ANOVA que compara `measure_mate` entre ramas, el modelo es sencillo: **la mejor predicción para cualquier
estudiante es el promedio de su propio grupo**. Si el promedio de bachillerato es 0.28, el modelo predice 0.28
para todos los estudiantes de bachillerato.

El **residuo** de una persona es simplemente la diferencia entre lo que obtuvo y lo que el modelo predijo para
ella:

$$\text{residuo} = \text{valor observado} - \text{valor predicho por el modelo}$$

Por ejemplo, un estudiante de bachillerato con `measure_mate` = 1.50 tiene un residuo de 1.50 − 0.28 = 1.22:
está 1.22 puntos por encima de lo que el modelo esperaba para alguien de su grupo. Otro con 0.10 tiene un
residuo de 0.10 − 0.28 = −0.18. Cada persona tiene el suyo, y en conjunto forman una nueva variable.

Esa variable de residuos es la que se examina. Contiene todo lo que el modelo no captó: diferencias
individuales, variables no incluidas, error de medición. En R se obtienen así:

```r
modelo <- aov(measure_mate ~ rama_abstracta, data = datos)

residuos <- residuals(modelo)   # un residuo por cada caso
head(residuos)
```

### 5.2 Dónde recae el supuesto en cada prueba

Precisar **qué** debe ser normal es donde más confusión se acumula. La respuesta varía según la prueba:

| Prueba                            | El supuesto de normalidad recae sobre                                        |
|-----------------------------------|------------------------------------------------------------------------------|
| t de una muestra                  | La variable (aquí el modelo predice la media general, así que residuo y variable centrada coinciden) |
| t independiente / Welch / ANOVA   | Los **residuos**: las desviaciones de cada caso respecto de la media de **su grupo** |
| **t pareada / Wilcoxon pareado**  | Las **diferencias** entre las dos mediciones de cada persona, **no** cada variable por separado |
| Regresión                         | Los residuos del modelo ajustado                                              |
| Mann-Whitney / Kruskal-Wallis     | No hay supuesto de normalidad; sí de independencia y de formas comparables    |
| Chi-cuadrado                      | No hay supuesto de normalidad; sí de frecuencias esperadas suficientes        |

**Por qué examinar la variable en bruto puede engañar.** Si dos grupos tienen medias muy distintas, la
distribución conjunta de la variable puede verse bimodal o asimétrica aunque dentro de cada grupo sea
perfectamente normal. En ese caso, evaluar la variable completa señalaría un problema que no existe. A la
inversa, una variable que en conjunto parece razonable puede esconder asimetrías dentro de los grupos.

En estos datos ambas mediciones casi coinciden:

```r
shapiro.test(datos$measure_mate)      # variable en bruto
#>  W = 0.8148, p-value < 2.2e-16

shapiro.test(residuals(modelo))       # residuos del modelo
#>  W = 0.8151, p-value < 2.2e-16
```

La coincidencia (W = 0.8148 frente a W = 0.8151) tiene una explicación. Los residuos se obtienen restando a
cada caso la media de su grupo; si las medias de los grupos son muy parecidas entre sí, esa resta apenas
modifica la forma de la distribución. Aquí la rama de la carrera explica solo el 1 % de la varianza
(η² = .01), es decir, **el efecto es muy pequeño**: las cuatro ramas tienen promedios que difieren poco
(entre −0.03 y 0.28) en comparación con la enorme dispersión dentro de cada una.

Un **efecto grande** sería lo contrario: grupos con promedios muy separados en relación con su dispersión
interna (por ejemplo, un grupo con media 20 y otro con media 60, ambos con desviación estándar de 5). En ese
caso, la variable en bruto se vería claramente bimodal (dos montículos separados) mientras que los residuos
podrían ser perfectamente normales. Evaluar la variable completa daría una alarma falsa. **Por eso la cifra que
debe guiar la decisión es siempre la de los residuos**, aunque en este ejemplo particular ambas coincidan.

### 5.3 El caso pareado: el supuesto recae sobre las diferencias

Este punto suele resultar contraintuitivo, así que conviene detenerse.

**Por qué es así.** La prueba t pareada no es realmente una prueba "de dos variables". Es una prueba de **una
sola variable**: la diferencia. El procedimiento consiste en calcular, para cada persona, la resta entre sus
dos mediciones, y luego preguntarse si el promedio de esas restas es distinto de cero. La fórmula lo muestra:

$$t = \frac{\bar{d}}{s_d / \sqrt{n}}$$

donde $\bar{d}$ es la media de las diferencias y $s_d$ su desviación estándar. **Las dos variables originales
no aparecen por ningún lado en la fórmula.** Una vez calculada la resta, el procedimiento las olvida. Por eso
la distribución que importa es únicamente la de esas diferencias: es la única que entra en el cálculo del valor
p. En términos del apartado 3, la distribución nula de esa t se dedujo suponiendo que **las diferencias** son
aproximadamente normales, no las variables de origen.

**Por qué no es un tecnicismo.** Dos variables muy asimétricas pueden producir diferencias perfectamente
normales. Esto ocurre de manera natural en los diseños pre-post: si cada persona tiene un nivel base propio (unas
parten muy alto, otras muy bajo, lo que genera asimetría en ambas mediciones) y el programa produce en todas un
incremento parecido, ese nivel base **se cancela al restar**. Lo que queda es solo el cambio, que suele
distribuirse de forma simétrica.

El conjunto de vocabulario lo muestra con claridad:

```r
vocab <- vocab %>%
  mutate(diferencia = vocab_post - vocab_pre)

shapiro.test(vocab$vocab_pre)
#>  W = 0.8338, p-value = 1.045e-06     <- RECHAZA la normalidad

shapiro.test(vocab$vocab_post)
#>  W = 0.9694, p-value = 0.1357        <- no rechaza

shapiro.test(vocab$diferencia)
#>  W = 0.9834, p-value = 0.5896        <- no rechaza
```

Aplicando el atajo habitual ("`vocab_pre` no es normal, luego Wilcoxon") se abandonaría la prueba t pareada
**sin ninguna razón válida**, porque el supuesto que esa prueba necesita se cumple de sobra: las diferencias
tienen una asimetría de 0.01 (prácticamente perfecta). La distribución de `vocab_pre` es irrelevante para esta
decisión.

Puede verse también en los estadísticos de forma:

```r
vocab %>%
  summarise(
    asim_pre = skewness(vocab_pre),
    asim_post = skewness(vocab_post),
    asim_dif = skewness(diferencia)
  )
#>   asim_pre asim_post asim_dif
#> 1     1.77      0.55     0.01
```

Y en el gráfico, que conviene hacer siempre sobre la **diferencia**:

```r
ggplot(vocab, aes(sample = diferencia)) +
  stat_qq() + stat_qq_line(color = "red") +
  labs(title = "Q-Q de las diferencias (post menos pre)")

ggplot(vocab, aes(x = diferencia)) +
  geom_histogram(bins = 12, fill = "grey80", color = "white") +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Distribución del cambio individual", x = "Cambio (post − pre)")
```

**Regla para recordar:** en cualquier prueba de medidas repetidas, se crea primero la variable de diferencias y
todo el diagnóstico se hace sobre ella. Las variables originales se describen (medias, desviaciones), pero no
se someten a la prueba de normalidad para decidir.

### 5.4 Herramientas para evaluar la normalidad

#### Shapiro-Wilk

Plantea como hipótesis nula que **la variable se distribuye normalmente en la población**. Aquí la lógica está
invertida respecto a lo habitual: "no rechazar" es la situación deseable. Es, en general, la prueba más
potente para detectar desviaciones de la normalidad, y es la opción por defecto en la mayoría de los contextos.

```r
shapiro.test(vocab$diferencia)
#>  W = 0.9834, p-value = 0.5896
```

**Por qué el límite de 5000 observaciones.** El valor p de esta prueba no se obtiene de una fórmula cerrada,
sino de una **aproximación numérica** desarrollada y validada para tamaños de muestra de hasta 5,000 casos.
Fuera de ese rango la aproximación deja de ser confiable, de modo que la implementación de R directamente se
detiene con un error en lugar de devolver un número dudoso. A esa razón técnica se suma una práctica: con
decenas de miles de casos la prueba detecta desviaciones tan minúsculas que su resultado deja de ser
informativo. Con muestras mayores se trabaja con una submuestra aleatoria o, preferiblemente, se decide con
los gráficos y los estadísticos de forma.

#### Kolmogorov-Smirnov y su corrección de Lilliefors

La prueba de Kolmogorov-Smirnov es más general: compara la distribución acumulada observada con **cualquier**
distribución teórica, y mide la máxima distancia vertical entre ambas. Puede usarse para contrastar contra una
normal, una exponencial, una uniforme, o para comparar dos muestras entre sí.

Tiene, sin embargo, una limitación crucial cuando se usa para normalidad: **la distribución teórica debe
especificarse por completo de antemano**, con su media y su desviación estándar conocidas. Si esos parámetros
se estiman a partir de los mismos datos (que es lo que todo el mundo hace), la prueba se vuelve **demasiado
conservadora**: rechaza menos de lo que debería y deja pasar desviaciones reales.

Estos datos lo ilustran de forma contundente:

```r
# Uso incorrecto (frecuente): parámetros estimados de los propios datos
ks.test(vocab$vocab_pre, "pnorm", mean(vocab$vocab_pre), sd(vocab$vocab_pre))
#>  D = 0.1350, p-value = 0.2046      <- NO rechaza (conclusión equivocada)

# Corrección de Lilliefors: KS ajustado para parámetros estimados
nortest::lillie.test(vocab$vocab_pre)
#>  D = 0.1350, p-value = 0.01248     <- sí rechaza

shapiro.test(vocab$vocab_pre)
#>  W = 0.8338, p-value = 1.045e-06   <- rechaza con claridad
```

La variable `vocab_pre` es marcadamente asimétrica (asimetría de 1.77), y aun así el uso ingenuo de KS no
detecta el problema. Shapiro-Wilk lo detecta con contundencia y Lilliefors, que es KS corregido para este
escenario, también.

#### Otras pruebas disponibles

| Prueba              | Función en R              | Característica                                            |
|---------------------|---------------------------|-----------------------------------------------------------|
| Shapiro-Wilk        | `shapiro.test()`          | La más potente en general; límite de 5,000 casos          |
| Lilliefors          | `nortest::lillie.test()`  | KS corregido para parámetros estimados                    |
| Anderson-Darling    | `nortest::ad.test()`      | Da más peso a las **colas**; útil si preocupan los extremos |
| Jarque-Bera         | `tseries::jarque.bera.test()` | Basada en asimetría y curtosis; frecuente en economía |
| Kolmogorov-Smirnov  | `ks.test()`               | General (cualquier distribución, o dos muestras); inadecuada para normalidad con parámetros estimados |

En la práctica, **Shapiro-Wilk es suficiente como prueba formal**, y Anderson-Darling resulta un complemento
útil cuando el interés está en las colas. Ninguna sustituye al diagnóstico gráfico.

#### Diagnóstico gráfico y estadísticos de forma

El **gráfico Q-Q** compara los cuantiles observados con los de una distribución normal: si los puntos se
alinean sobre la diagonal hay normalidad, y las desviaciones en los extremos indican colas pesadas o asimetría.
A diferencia del valor p, muestra la **magnitud** de la desviación, que es lo que realmente importa.

```r
ggplot(data.frame(residuos = residuals(modelo)), aes(sample = residuos)) +
  stat_qq() +
  stat_qq_line(color = "red") +
  labs(title = "Gráfico Q-Q de los residuos",
       x = "Cuantiles teóricos", y = "Cuantiles observados")
```

La **asimetría** indica si la distribución se inclina hacia un lado (0 es simétrica) y la **curtosis**, si
tiene colas más pesadas que la normal (0 en la escala de exceso de curtosis). Como referencia práctica, valores
fuera del rango de −2 a 2 señalan desviaciones apreciables.

```r
datos %>%
  summarise(
    asimetria = skewness(measure_mate, na.rm = TRUE),
    curtosis  = kurtosis(measure_mate, na.rm = TRUE)
  )
#>   asimetria curtosis
#> 1      1.98     5.80
```

R ofrece además cuatro gráficos de diagnóstico en una sola instrucción:

```r
par(mfrow = c(2, 2))
plot(modelo)
par(mfrow = c(1, 1))
```

El primer panel (residuos contra valores ajustados) sirve para juzgar la homocedasticidad; el segundo es el
Q-Q de los residuos; el tercero muestra la dispersión de los residuos estandarizados; el cuarto identifica
observaciones influyentes.

### 5.5 El mito: "si no es normal, directo a no paramétrica"

Con `measure_mate`, Shapiro-Wilk rechaza con contundencia. Según el atajo habitual, tocaría abandonar la t y el
ANOVA. Esa conclusión es precipitada, por cuatro razones.

**Primera: Shapiro-Wilk depende del tamaño de muestra de una forma perversa.** Su potencia crece con n. Con
3,257 casos detecta desviaciones tan pequeñas que resultan irrelevantes para la validez de la prueba; con 20
casos no detecta ni desviaciones graves. El resultado es paradójico: la prueba tiende a "aprobar" la normalidad
justamente cuando más se necesita (muestras pequeñas, donde el teorema central del límite no protege) y a
rechazarla cuando menos importa (muestras grandes, donde sí protege). Un valor p diminuto informa sobre la
**certeza** de que existe alguna desviación, no sobre su **tamaño**.

**Segunda: la t y el ANOVA no requieren que la variable sea normal, sino que lo sea la distribución del
estadístico.** Esta es la distinción decisiva y conviene desarrollarla.

Como se explicó en el apartado 3, el valor p se calcula comparando el estadístico observado contra su
distribución nula. Para la prueba t, esa distribución nula depende de cómo se comporta la **media muestral**,
no de cómo se comportan los datos individuales. Y aquí entra el **teorema central del límite**: sin importar
cuán asimétrica sea la variable original, la distribución de las medias de muestras sucesivas se aproxima a la
normal conforme crece el tamaño de muestra. Es decir, aunque los datos no sean normales, el ingrediente que la
fórmula necesita sí lo es, siempre que n sea suficiente.

Puede verse por simulación con estos mismos datos:

```r
set.seed(7)
x <- na.omit(datos$measure_mate)

simular <- function(n, reps = 5000) {
  replicate(reps, mean(sample(x, n, replace = TRUE)))
}

skewness(x)                 # asimetría de la variable original
#> [1] 1.98
skewness(simular(30))       # asimetría de las medias con n = 30
#> [1] 0.30
skewness(simular(100))      # con n = 100
#> [1] 0.16
skewness(simular(717))      # con n = 717 (el grupo más pequeño de la comparación)
#> [1] 0.04
```

La variable tiene una asimetría de 1.98, pero la distribución de sus medias con n = 30 ya baja a 0.30, y con
n = 717 es prácticamente simétrica (0.04).

> **Aclaración importante: esta simulación es didáctica, no un paso del análisis.** No se ejecuta antes de cada
> prueba. Se muestra una vez, para *ver* el teorema en acción y entender por qué el resultado de Shapiro-Wilk
> no basta para decidir. En el trabajo cotidiano, lo que se hace es apoyarse en el teorema y valorar si el
> tamaño de muestra es suficiente. Como orientación práctica (heurística, no ley): con asimetría moderada,
> unos 30 casos por grupo suelen bastar; con asimetría pronunciada conviene contar con 100 o más; con menos
> de 20 casos y desviaciones claras, la protección del teorema es débil y la vía no paramétrica gana terreno.
> El teorema tampoco protege frente a observaciones extremadamente influyentes ni frente a la falta de
> independencia.

Por qué esto es tan relevante: cambia por completo la respuesta a la pregunta "¿mi prueba t es válida?".
Desacopla dos cosas que el atajo confunde: **que la variable no sea normal** y **que la prueba no sea válida**.
Con muestras grandes, lo primero puede ser cierto sin que lo segundo lo sea.

**Tercera: la alternativa no paramétrica responde una pregunta distinta.** La U de Mann-Whitney no contrasta
diferencias de medias: contrasta si una observación tomada al azar de un grupo tiende a superar a una del otro.
Solo puede leerse en términos de medianas cuando las distribuciones tienen formas comparables. Al cambiar de
prueba cambia el parámetro estimado y cambia la afirmación que puede escribirse. No es un sustituto neutral.

**Cuarta: existen más de dos opciones.** El dilema no se agota entre "t de Student" y "Mann-Whitney". Conviene
precisar qué hace cada alternativa, porque no todas son sustitutos equivalentes:

| Alternativa                  | ¿De qué habla?                        | Qué resuelve                                        |
|------------------------------|---------------------------------------|-----------------------------------------------------|
| **t de Welch**               | Diferencia de **medias**              | Varianzas desiguales entre grupos                   |
| **Prueba de permutación**    | Diferencia de **medias** (la misma)   | Construye la distribución nula barajando los datos observados, sin suponer normalidad |
| **Bootstrap**                | Diferencia de **medias** (la misma)   | Construye el intervalo de confianza por remuestreo, sin suponer normalidad |
| **Medias recortadas (Yuen)** | Diferencia de medias **recortadas**   | Reduce la influencia de valores extremos            |
| **Mann-Whitney**             | **Rangos** (dominancia estocástica)   | No supone forma; cambia el parámetro                |

La respuesta a la pregunta implícita es que sí: **permutación y bootstrap siguen hablando de diferencias de
medias**, exactamente el mismo parámetro que la prueba t. Lo que reemplazan no es el parámetro, sino el
**mecanismo para obtener el valor p o el intervalo**: en lugar de deducirlo de una fórmula que exige
normalidad, lo construyen a partir de los propios datos. Por eso son sustitutos mucho más cercanos a la t que
Mann-Whitney, que sí cambia la pregunta.

**Cómo se resuelve entonces: triangulando.** La vía sólida consiste en contrastar la conclusión con métodos que
descansan en supuestos diferentes. Si convergen, la decisión no depende del supuesto discutido.

```r
# 1. Prueba paramétrica (Welch)
t.test(measure_mate ~ area, data = datos)
#>  t = 2.56, df = 1297.1, p-value = 0.0105

# 2. Prueba de permutación (no supone ninguna distribución)
set.seed(7)
u <- datos$measure_mate[datos$area == "Urbana"]
r <- datos$measure_mate[datos$area == "Rural"]
obs <- mean(u) - mean(r)

permutadas <- replicate(10000, {
  mezcla <- sample(c(u, r))
  mean(mezcla[1:length(u)]) - mean(mezcla[-(1:length(u))])
})
mean(abs(permutadas) >= abs(obs))
#> [1] 0.017

# 3. Intervalo de confianza por bootstrap
set.seed(7)
boot_dif <- replicate(5000, {
  mean(sample(u, length(u), replace = TRUE)) - mean(sample(r, length(r), replace = TRUE))
})
quantile(boot_dif, c(0.025, 0.975))
#>     2.5%    97.5%
#>   0.0238   0.1883

# 4. Prueba no paramétrica
wilcox.test(measure_mate ~ area, data = datos)
#>  p-value = 0.0197
```

Los cuatro procedimientos coinciden: la diferencia entre áreas es pequeña pero distinta de cero (p entre .010
y .020, con un intervalo bootstrap de [0.024, 0.188] que excluye el cero y que es prácticamente idéntico al de
la prueba t). La violación de la normalidad, en este caso, no compromete la conclusión.

**En resumen.** El incumplimiento de la normalidad es una señal para investigar, no una orden automática de
cambiar de prueba. La pregunta correcta no es "¿se rechazó Shapiro-Wilk?", sino "¿es la desviación lo bastante
severa, dado este tamaño de muestra y este diseño, para amenazar la validez de la inferencia?".

### 5.6 Homocedasticidad (igualdad de varianzas)

El término se descompone en dos partes: *homo* (igual) y *cedasticidad* (dispersión). El supuesto afirma que
**la variabilidad de la variable de resultado es parecida en todos los grupos que se comparan**. No se refiere
a que los grupos tengan promedios similares (eso es justamente lo que la prueba está evaluando), sino a que
estén igual de dispersos alrededor de su propio promedio.

**Por qué importa.** La prueba t clásica y el ANOVA no estiman la variabilidad de cada grupo por separado:
**la combinan en una sola estimación** (la varianza agrupada), suponiendo que todos comparten la misma
dispersión de fondo. Esa cifra única entra en el denominador del estadístico y determina el error estándar, es
decir, cuánta variación se considera atribuible al azar.

Si los grupos difieren realmente en dispersión, esa estimación combinada no describe bien a ninguno: resulta
demasiado grande para el grupo homogéneo y demasiado pequeña para el disperso. El error estándar queda mal
calculado y, con él, el estadístico y el valor p. El problema se agrava cuando los tamaños de grupo son
desiguales: si el grupo pequeño es además el más disperso, la prueba tiende a declarar significancia con
demasiada facilidad; en la situación inversa, se vuelve excesivamente conservadora.

**Cómo se comprueba.** La **prueba de Levene** es la más usada. Su hipótesis nula es que las varianzas son
iguales entre grupos, de modo que, como con la normalidad, "no rechazar" es lo deseable. Funciona
transformando cada dato en su distancia absoluta respecto de la mediana de su grupo y comparando esas
distancias con un ANOVA: si un grupo está más disperso, sus distancias serán sistemáticamente mayores.

```r
leveneTest(measure_mate ~ area, data = datos)
#>         Df F value Pr(>F)
#> group    1  2.0616 0.1511
#>       3255

leveneTest(measure_mate ~ rama_abstracta, data = datos)
#>         Df F value Pr(>F)
#> group    3  2.0752 0.1014
#>       3253
```

En ambos casos el valor p supera 0.05, de modo que **el supuesto de homocedasticidad se cumple**. La versión en
formato ordenado es `datos %>% levene_test(measure_mate ~ rama_abstracta)`.

Existe también la prueba de Bartlett, pero conviene usarla con cautela: es muy sensible a la falta de
normalidad, de modo que puede rechazar por ese motivo y no por diferencias reales de varianza:

```r
bartlett.test(measure_mate ~ rama_abstracta, data = datos)
#>  Bartlett's K-squared = 13.75, df = 3, p-value = 0.003267
```

Bartlett rechaza (p = .003) mientras Levene no (p = .101). Como la variable no es normal, la lectura confiable
es la de Levene, que es robusta ante ese incumplimiento. Es otro ejemplo de por qué una sola prueba no basta.

Al diagnóstico numérico conviene sumar el gráfico de residuos contra valores ajustados: si la nube mantiene un
ancho parecido a lo largo del eje horizontal hay homocedasticidad; si se abre como un embudo, no.

```r
ggplot(data.frame(ajustados = fitted(modelo), residuos = residuals(modelo)),
       aes(x = ajustados, y = residuos)) +
  geom_point(alpha = 0.3) +
  geom_hline(yintercept = 0, color = "red") +
  labs(title = "Residuos contra valores ajustados")
```

> **Qué hacer si no se cumple.** La respuesta no es abandonar la vía paramétrica, sino usar la versión que no
> agrupa las varianzas: la **prueba de Welch** para dos grupos (opción por defecto de `t.test()`) y el
> **ANOVA de Welch** para varios (`oneway.test(..., var.equal = FALSE)`). Ambas estiman la variabilidad de
> cada grupo por separado y ajustan los grados de libertad en consecuencia.

### 5.7 Valores atípicos

Los valores extremos afectan sobre todo a las pruebas paramétricas, porque la media y la varianza son sensibles
a ellos. Se identifican con el criterio del rango intercuartílico: son atípicos los valores que caen a más de
1.5 rangos intercuartílicos de los cuartiles, y extremos los que superan 3 rangos.

```r
datos %>% identify_outliers(measure_mate) %>% count(is.extreme)
#>   is.extreme   n
#> 1      FALSE 175
#> 2       TRUE 105

ggplot(datos, aes(y = measure_mate)) +
  geom_boxplot() +
  labs(title = "Valores atípicos en measure_mate")
```

Se detectan 280 valores atípicos (8.6 % de los casos), de los cuales 105 son extremos.

Identificar valores atípicos no implica eliminarlos: solo deben descartarse si se comprueba que son errores de
captura. Cuando son valores legítimos (como aquí, donde reflejan desempeños genuinamente altos), la alternativa
razonable es verificar su influencia repitiendo el análisis sin ellos y comprobando si la conclusión cambia.

### 5.8 Independencia de las observaciones

La independencia no se comprueba con una prueba, sino que se deriva del **diseño**: cada persona debe aportar
una sola observación y su respuesta no debe depender de la de otra. En diseños de medidas repetidas, las dos
mediciones del mismo individuo no son independientes entre sí, y por eso existen versiones pareadas de las
pruebas.

Es el supuesto más importante de todos, porque ninguna prueba (paramétrica o no) lo sustituye, y su
incumplimiento no se corrige cambiando de familia. En esta muestra el diseño es estratificado, lo que introduce
una estructura que se aborda en el bloque 9.

### 5.9 Frecuencias esperadas (supuesto de chi-cuadrado)

Chi-cuadrado tiene su propio supuesto: las **frecuencias esperadas** de cada casilla deben ser suficientes (la
regla habitual pide que todas superen 5). Las frecuencias esperadas son las que habría en cada casilla si las
dos variables fueran completamente independientes.

```r
tabla <- table(datos$area, datos$logro_mate)
chisq.test(tabla)$expected
#>              No       Sí
#>   Rural   612.0    105.0
#>   Urbana 2168.0    372.0
```

La frecuencia esperada mínima es 105, muy por encima de 5, de modo que el supuesto se cumple. Cuando alguna
casilla queda por debajo, se agrupan categorías o se recurre a la prueba exacta de Fisher (apartado 8.2).

### 5.10 La decisión, con toda la evidencia sobre la mesa

Reuniendo las fuentes de evidencia para `measure_mate`:

| Fuente de evidencia            | Resultado                                              |
|--------------------------------|--------------------------------------------------------|
| Shapiro-Wilk (residuos)        | Rechaza la normalidad (p < .001)                       |
| Asimetría y curtosis           | 1.98 y 5.80: desviación real, de asimetría a la derecha|
| Tamaño de muestra              | 717 y 2,540 por grupo: el teorema central del límite protege |
| Homocedasticidad (Levene)      | Se cumple (p = .151 y p = .101)                        |
| Valores atípicos               | 8.6 %, legítimos (no son errores de captura)           |
| Convergencia entre métodos     | t, permutación, bootstrap y Mann-Whitney coinciden     |

La conclusión razonable no es "la normalidad falló, luego no paramétrica", sino que **la vía paramétrica es
defendible** en este caso, y que la no paramétrica sirve como comprobación de robustez. En un estudio real se
reportaría una de las dos justificando la elección; en esta lección se muestran ambas con fines de aprendizaje,
porque comparar sus resultados en los mismos datos hace visible cuándo coinciden y cuándo no.

---

## 6. Dos grupos independientes

**El ejemplo.** Se compara el desempeño en matemática (`measure_mate`) entre estudiantes de centros educativos
del **área urbana** (2,540 casos) y del **área rural** (717 casos). Son dos grupos independientes: cada
estudiante pertenece a uno solo de ellos y las observaciones no están vinculadas entre sí. La pregunta es si
el desempeño promedio difiere según el área.

```r
datos %>%
  group_by(area) %>%
  summarise(n = n(), media = mean(measure_mate), de = sd(measure_mate), mediana = median(measure_mate))
```

### 6.1 t de Welch (paramétrica, opción recomendada)

Compara la **media** de una variable numérica entre dos grupos. La hipótesis nula es que las dos poblaciones
tienen la misma media (μ₁ = μ₂).

R aplica por defecto la **prueba de Welch**, que estima la variabilidad de cada grupo por separado en lugar de
agruparlas. Es la opción más segura y sigue siendo válida aunque las varianzas sean iguales, por lo que no hay
razón para cambiarla:

```r
t.test(measure_mate ~ area, data = datos)
#>
#>  Welch Two Sample t-test
#>
#> data:  measure_mate by area
#> t = 2.56, df = 1297.1, p-value = 0.0105
#> alternative hypothesis: true difference in means is not equal to 0
#> 95 percent confidence interval:
#>  0.0251  0.1891
#> sample estimates:
#>  mean in group Urbana   mean in group Rural
#>                  0.27                  0.16
```

Los grados de libertad fraccionarios (1297.1 en vez de 3255) son la marca característica de Welch: son el
ajuste que compensa la posible desigualdad de varianzas.

Si se quisiera la versión clásica de Student, que sí agrupa las varianzas, se indica `var.equal = TRUE`:

```r
t.test(measure_mate ~ area, data = datos, var.equal = TRUE)
```

El tamaño del efecto se obtiene con la d de Cohen, que expresa la diferencia en unidades de desviación
estándar:

```r
datos %>% cohens_d(measure_mate ~ area, ci = TRUE)
#>   .y.          group1 group2 effsize    n1    n2 magnitude
#>   measure_mate Rural  Urbana    0.10   717  2540 negligible
```

### 6.2 El intervalo de confianza y cómo interpretarlo

La salida incluye un **intervalo de confianza al 95 %** para la diferencia de medias: [0.025, 0.189]. Conviene
detenerse en él, porque suele ser más informativo que el valor p y su interpretación se malentiende con
frecuencia.

**Qué es.** Un rango de valores **compatibles con los datos observados** para el parámetro de interés (aquí, la
diferencia real entre las medias poblacionales). El procedimiento que lo construye tiene la propiedad de que,
si el estudio se repitiera muchas veces, el 95 % de los intervalos así calculados contendrían el valor
verdadero.

**Qué no es.** No significa que haya un 95 % de probabilidad de que el valor verdadero esté dentro de **este**
intervalo concreto. En el enfoque frecuentista, el parámetro poblacional es un valor fijo (aunque desconocido):
o está dentro o no está. Lo que tiene la propiedad del 95 % es el **procedimiento**, no cada intervalo
particular. Es una distinción sutil, pero conviene enunciarla con cuidado en un reporte.

**Cómo se lee en la práctica.** Tres lecturas complementarias:

- **Decisión.** Si el intervalo **excluye el cero** (como aquí, donde va de 0.025 a 0.189), la diferencia es
  significativa al nivel correspondiente. Contiene la misma información que el valor p, pero expresada en la
  escala de la variable.
- **Magnitud.** Indica el rango plausible del efecto. Aquí, la diferencia entre áreas estaría entre 0.03 y 0.19
  puntos: en la escala de esta medida, un efecto pequeño en cualquier punto del intervalo. Esto es lo que un
  valor p por sí solo nunca comunica.
- **Precisión.** Un intervalo estrecho señala una estimación precisa; uno amplio, mucha incertidumbre. Un
  resultado no significativo con un intervalo muy ancho ([−5, +6], por ejemplo) no dice "no hay efecto", sino
  "no se sabe": es compatible tanto con un efecto grande positivo como negativo.

Esa última lectura es la más valiosa, porque distingue dos situaciones que el valor p confunde: **evidencia de
ausencia de efecto** (intervalo estrecho alrededor del cero) y **ausencia de evidencia** (intervalo ancho).

Por defecto R usa el 95 %; puede modificarse con `conf.level`:

```r
t.test(measure_mate ~ area, data = datos, conf.level = 0.99)
```

**Cómo reportarlo.** Se comparó el puntaje de matemática entre estudiantes de área urbana (M = 0.27, SD = 1.10)
y rural (M = 0.16, SD = 0.96) mediante una prueba t de Welch. La diferencia fue estadísticamente significativa,
t(1297.1) = 2.56, p = .011, IC 95 % [0.025, 0.189], con un tamaño de efecto insignificante (d = 0.10).

Este resultado ilustra una idea central: con muestras grandes, diferencias muy pequeñas alcanzan significancia
estadística. Por eso el tamaño del efecto y el intervalo deben reportarse siempre junto al valor p.

### 6.3 U de Mann-Whitney (no paramétrica)

Compara rangos en lugar de medias. La hipótesis nula es que las dos poblaciones tienen la misma distribución;
la lectura en términos de medianas exige que las formas sean comparables (aquí lo son: las desviaciones
estándar son 1.10 y 0.96, y las asimetrías 2.02 y 1.67).

```r
wilcox.test(measure_mate ~ area, data = datos, conf.int = TRUE)
#>
#>  Wilcoxon rank sum test with continuity correction
#>
#> W = 962424, p-value = 0.0197
#> 95 percent confidence interval:  (desplazamiento estimado)
#> sample estimates:
#>  difference in location  ~0.10

datos %>% wilcox_effsize(measure_mate ~ area)
```

El argumento `conf.int = TRUE` devuelve un intervalo de confianza para el **desplazamiento** entre las dos
distribuciones (el estimador de Hodges-Lehmann, que es la mediana de todas las diferencias posibles entre pares
de observaciones de ambos grupos). Se interpreta igual que cualquier intervalo, pero referido a ese parámetro y
no a la diferencia de medias.

**Cómo reportarlo.** Se empleó la prueba U de Mann-Whitney para comparar los puntajes de matemática entre área
urbana (Mdn = −0.03) y rural (Mdn = −0.06). La diferencia fue significativa, U = 962424, p = .020, con un tamaño
de efecto insignificante (r = .04).

---

## 7. Dos medidas del mismo grupo (pareadas)

**El ejemplo.** Se usa el conjunto ficticio de vocabulario científico: 60 estudiantes universitarios evaluados
**antes** (`vocab_pre`) y **después** (`vocab_post`) de participar en un programa de fortalecimiento. Los dos
puntajes de cada persona están vinculados, de modo que no puede tratarse como si fueran dos grupos
independientes: hay que trabajar sobre el **cambio individual**.

```r
vocab <- vocab %>%
  mutate(diferencia = vocab_post - vocab_pre)

vocab %>%
  summarise(
    m_pre  = mean(vocab_pre),  de_pre  = sd(vocab_pre),
    m_post = mean(vocab_post), de_post = sd(vocab_post),
    m_dif  = mean(diferencia), de_dif  = sd(diferencia)
  )
#>   m_pre de_pre m_post de_post m_dif de_dif
#> 1 26.87   6.49  31.38    6.71  4.51   3.13
```

Como se explicó en 5.3, el diagnóstico de normalidad se hace **sobre la diferencia**, que aquí es
prácticamente simétrica (W = 0.9834, p = .590), de modo que la prueba t pareada es plenamente válida pese a que
`vocab_pre` no sea normal.

### 7.1 t de Student pareada (paramétrica)

La hipótesis nula es que la media de las diferencias es cero, lo que equivale a decir que las dos medias son
iguales. El argumento clave es `paired = TRUE`.

```r
t.test(vocab$vocab_post, vocab$vocab_pre, paired = TRUE)
#>
#>  Paired t-test
#>
#> t = 11.18, df = 59, p-value < 2.2e-16
#> 95 percent confidence interval:
#>  3.70  5.32
#> sample estimates:
#> mean difference
#>            4.51

vocab %>% cohens_d(vocab_post ~ vocab_pre, paired = TRUE)
#>  effsize = 1.44 (large)
```

El intervalo [3.70, 5.32] se lee así: el incremento promedio en vocabulario atribuible al periodo del programa
se sitúa, de forma compatible con los datos, entre 3.7 y 5.3 puntos. Como no incluye el cero, el cambio es
significativo; y como el rango es estrecho y está lejos del cero, la estimación es además precisa.

**Cómo reportarlo.** Se condujo una prueba t para muestras pareadas para comparar el vocabulario científico
antes (M = 26.87, SD = 6.49) y después (M = 31.38, SD = 6.71) del programa. El incremento fue estadísticamente
significativo, t(59) = 11.18, p < .001, IC 95 % [3.70, 5.32], con un tamaño de efecto grande (d = 1.44).

> **Nota sobre el diseño.** Un diseño pre-post de un solo grupo no permite atribuir el cambio al programa: sin
> grupo de comparación, el incremento podría deberse a la maduración, a la exposición a otros cursos o al efecto
> de haber realizado la prueba antes. La prueba responde si hubo cambio, no si el programa lo causó.

### 7.2 Wilcoxon de rangos con signo (no paramétrica)

Versión no paramétrica para dos mediciones del mismo grupo. Trabaja con los rangos de las diferencias absolutas
y sus signos, de modo que evalúa si las diferencias se reparten de forma equilibrada alrededor de cero.

```r
wilcox.test(vocab$vocab_post, vocab$vocab_pre, paired = TRUE, conf.int = TRUE)
#>
#>  Wilcoxon signed rank test with continuity correction
#>
#> V = 30, p-value = 1.09e-10
```

**Cómo reportarlo.** Se aplicó la prueba de rangos con signo de Wilcoxon para comparar el vocabulario antes
(Mdn = 25.20) y después (Mdn = 31.10) del programa. El incremento fue significativo, V = 30, p < .001.

Aquí las dos pruebas coinciden por completo, lo que era esperable: las diferencias son simétricas y no hay
valores extremos que las separen.

> Cuando la variable pareada es **categórica** (por ejemplo, si el estudiante alcanzó o no el criterio antes y
> después), la prueba adecuada es la de **McNemar** (`mcnemar.test()`), que examina si los cambios en un
> sentido superan a los del sentido contrario.

---

## 8. Tres o más grupos

**El ejemplo.** Se comparan los puntajes de matemática entre las cuatro **ramas de la carrera de diversificado**
(`rama_abstracta`): bachillerato (1,900 casos), perito (888), magisterio (282) y secretariado (187). La pregunta
es si el desempeño promedio difiere según el tipo de formación cursada.

```r
datos %>%
  group_by(rama_abstracta) %>%
  summarise(n = n(), media = mean(measure_mate), de = sd(measure_mate))
```

### 8.1 ANOVA de un factor (paramétrica)

La hipótesis nula es que todas las medias poblacionales son iguales (μ₁ = μ₂ = … = μₖ). El ANOVA las evalúa
todas a la vez con un solo contraste, lo que evita el error de acumular pruebas t por separado (que inflaría la
probabilidad de encontrar diferencias por azar).

```r
modelo <- aov(measure_mate ~ rama_abstracta, data = datos)
summary(modelo)
#>                  Df Sum Sq Mean Sq F value   Pr(>F)
#> rama_abstracta    3     25   8.363   7.281 7.3e-05 ***
#> Residuals      3253   3736   1.148

eta_squared(modelo)
#> Parameter      | Eta2 |       95% CI
#> rama_abstracta | 0.01 | [0.00, 1.00]
```

**Versión de Welch para varios grupos.** Cuando las varianzas no son iguales, el equivalente del ANOVA que no
las agrupa es:

```r
oneway.test(measure_mate ~ rama_abstracta, data = datos, var.equal = FALSE)
#>  One-way analysis of means (not assuming equal variances)
#>  F = 9.05, num df = 3.0, denom df = 609.8, p-value = 7.2e-06
```

Los grados de libertad del denominador aparecen ajustados (609.8), igual que en la t de Welch.

**Comparaciones post hoc.** Un resultado significativo indica que **al menos** un grupo difiere, sin precisar
cuál. Para localizarlo se usan comparaciones de Tukey, que además entregan un **intervalo de confianza para cada
diferencia por pares**, ajustado por comparaciones múltiples:

```r
TukeyHSD(modelo)
#>   diff        lwr        upr     p adj
#> ... una fila por cada par de ramas, con su intervalo

datos %>% tukey_hsd(measure_mate ~ rama_abstracta)
```

Los pares cuyo intervalo excluye el cero son los que difieren significativamente.

**Cómo reportarlo.** Un ANOVA de un factor mostró diferencias significativas en el puntaje de matemática entre
las cuatro ramas, F(3, 3253) = 7.28, p < .001, η² = .01. Las pruebas post hoc de Tukey identifican entre qué
ramas se dan las diferencias (bachillerato M = 0.28 y perito M = 0.27 frente a secretariado M = −0.03 y
magisterio M = 0.08).

### 8.2 Kruskal-Wallis (no paramétrica)

Extiende la lógica de Mann-Whitney a más de dos grupos. La hipótesis nula es que la distribución de la variable
es igual en todos ellos.

```r
kruskal.test(measure_mate ~ rama_abstracta, data = datos)
#>
#>  Kruskal-Wallis rank sum test
#>
#> Kruskal-Wallis chi-squared = 37.47, df = 3, p-value = 3.7e-08
```

Igual que el ANOVA, requiere comparaciones post hoc. La prueba de Dunn con ajuste de Bonferroni es la habitual:

```r
datos %>% dunn_test(measure_mate ~ rama_abstracta, p.adjust.method = "bonferroni")
```

**Cómo reportarlo.** Se utilizó la prueba de Kruskal-Wallis para comparar los puntajes de matemática entre las
cuatro ramas. Se encontraron diferencias significativas, H(3) = 37.47, p < .001. Las comparaciones por pares
(prueba de Dunn con ajuste de Bonferroni) localizan las diferencias entre ramas específicas.

---

## 9. Asociación entre dos variables categóricas

**El ejemplo.** Se examina si el **logro en matemática** (`logro_mate`: si el estudiante alcanzó o no el nivel
esperado) se relaciona con el **área** del centro educativo. Ambas son categóricas, de modo que la pregunta no
es sobre promedios sino sobre **proporciones**: ¿la proporción de estudiantes que alcanzan el logro es distinta
en el área urbana y en la rural?

### 9.1 Chi-cuadrado de independencia

La hipótesis nula es que las dos variables son **independientes**: conocer la categoría de una no aporta
información sobre la otra.

```r
tabla <- table(datos$area, datos$logro_mate)
tabla
#>           No   Sí
#>   Rural   620   97
#>   Urbana 2160  380

# Porcentajes por fila, más informativos que las frecuencias
datos %>% tabyl(area, logro_mate) %>% adorn_percentages("row") %>% adorn_pct_formatting()

chisq.test(tabla)
#>
#>  Pearson's Chi-squared test with Yates' continuity correction
#>
#> X-squared = 0.81, df = 1, p-value = 0.369

datos %>% cramer_v(area, logro_mate)
#> [1] 0.016
```

**Intervalo de confianza para la diferencia de proporciones.** Con una tabla de 2 × 2, `prop.test()` entrega
directamente el intervalo, que resulta más interpretable que el estadístico chi-cuadrado:

```r
prop.test(table(datos$area, datos$logro_mate))
#>  95 percent confidence interval:
#>  -0.0143  0.0429      (en proporciones; equivale a -1.4 a +4.3 puntos porcentuales)
```

El intervalo va de −1.4 a +4.3 puntos porcentuales e **incluye el cero**, coherente con el resultado no
significativo. Su lectura es informativa: los datos son compatibles con que el área rural tenga hasta 1.4
puntos más de logro o hasta 4.3 puntos menos. La incertidumbre es apreciable, de modo que lo correcto es decir
que no se detectó asociación, no que se demostró su ausencia.

**Cómo reportarlo.** Se aplicó la prueba de chi-cuadrado de independencia para examinar la relación entre el
área y el logro en matemática. La asociación no fue significativa, χ²(1, N = 3257) = 0.81, p = .369,
V de Cramér = .02, IC 95 % para la diferencia de proporciones [−1.4, 4.3] puntos porcentuales.

### 9.2 Prueba exacta de Fisher

Cuando alguna frecuencia esperada queda por debajo de 5, la aproximación en la que se apoya chi-cuadrado deja
de ser confiable. La **prueba exacta de Fisher** calcula la probabilidad exacta de obtener una tabla al menos
tan desigual como la observada, sin recurrir a ninguna aproximación, de modo que es válida con frecuencias
pequeñas.

Se ilustra con el conjunto de vocabulario, donde los grupos son reducidos. Se examina si alcanzar el criterio
antes del programa se relaciona con estudiar Biología:

```r
tabla_v <- table(vocab$carrera == "Biología", vocab$criterio_pre)
tabla_v
#>         0  1
#>   FALSE 37  9
#>   TRUE  10  4

chisq.test(tabla_v)$expected
#>  frecuencia esperada mínima = 3.03   <- por debajo de 5

fisher.test(tabla_v)
#>
#>  Fisher's Exact Test for Count Data
#>
#> p-value = 0.4779
#> alternative hypothesis: true odds ratio is not equal to 1
#> 95 percent confidence interval:  (razón de momios)
#> sample estimates:
#> odds ratio  1.64
```

La frecuencia esperada mínima es 3.03, por debajo del umbral, de modo que Fisher es la prueba indicada. Devuelve
además la **razón de momios** (*odds ratio*) con su intervalo de confianza: un valor de 1 indica ausencia de
asociación, y el intervalo permite juzgar la precisión de la estimación.

**Cómo reportarlo.** Se aplicó la prueba exacta de Fisher, dado que la frecuencia esperada mínima fue inferior a
5. No se encontró asociación significativa entre la carrera y el logro del criterio inicial, p = .478,
OR = 1.64.

> Fisher fue diseñada para tablas de 2 × 2, aunque R la extiende a tablas mayores. Con tablas grandes y muchas
> casillas escasas, la alternativa habitual es simular el valor p:
> `chisq.test(tabla, simulate.p.value = TRUE)`.

---

## 10. Análisis con el diseño muestral: `survey` y `srvyr`

Todas las pruebas anteriores tratan a la muestra como si cada caso valiera lo mismo. Eso es adecuado con fines
didácticos, pero la muestra fue extraída con un **diseño estratificado**, y cada caso trae la variable `peso`
que indica cuántos graduandos de la población representa. Cuando el objetivo es estimar valores de la población
(medias, proporciones, totales), ignorar los pesos produce estimaciones sesgadas.

### 10.1 Declarar el diseño

```r
options(survey.lonely.psu = "adjust")   # ver la nota más abajo

diseno <- datos %>%
  as_survey_design(
    strata  = estrato,      # variable que identifica el estrato
    weights = peso,         # peso de diseño de cada caso
    fpc     = n_estrato_pob # tamaño del estrato en la población (columna N_estrato)
  )
```

> **Nota indispensable sobre estratos con un solo caso.** En esta muestra, 1,399 estratos aportan un único caso.
> El paquete `survey` no puede calcular la varianza dentro de un estrato con una sola observación y se detiene
> con un error ("stratum with only one PSU"). La instrucción `options(survey.lonely.psu = "adjust")` resuelve la
> situación centrando esos estratos en la media general, que es la alternativa recomendada. Es un problema
> frecuente cuando se estratifica por muchas variables a la vez y conviene anticiparlo.

### 10.2 Estimaciones ponderadas

```r
diseno %>%
  summarise(media = survey_mean(measure_mate, vartype = "ci", na.rm = TRUE))

diseno %>%
  group_by(area) %>%
  summarise(media = survey_mean(measure_mate, vartype = "ci", na.rm = TRUE))

diseno %>%
  group_by(logro_mate) %>%
  summarise(prop = survey_prop(vartype = "ci"))
```

La comparación entre las estimaciones ponderadas y las simples muestra por qué importa el diseño:

| Estimación                          | Sin ponderar | Ponderada |
|-------------------------------------|--------------|-----------|
| Media de `measure_mate`             | 0.24         | 0.30      |
| Media en área urbana                | 0.27         | 0.31      |
| Media en área rural                 | 0.16         | 0.27      |
| Porcentaje con logro en matemática  | 14.65 %      | 16.03 %   |

Las diferencias no son triviales: la proporción de logro se subestima en más de un punto porcentual al ignorar
los pesos. Ocurre porque el diseño garantizó al menos un caso por estrato, lo que sobrerrepresenta a los
estratos pequeños en la muestra sin ponderar.

### 10.3 Pruebas con el diseño incorporado

```r
# Diferencia de medias entre dos grupos (equivalente a la prueba t)
svyttest(measure_mate ~ area, design = diseno)

# Asociación entre dos variables categóricas (equivalente a chi-cuadrado)
svychisq(~ area + logro_mate, design = diseno)

# Comparación de más de dos grupos mediante un modelo lineal
modelo_svy <- svyglm(measure_mate ~ rama_abstracta, design = diseno)
summary(modelo_svy)

# Alternativa basada en rangos
svyranktest(measure_mate ~ area, design = diseno)
```

Estas versiones tienden a producir valores p mayores y **intervalos de confianza más anchos** que sus
equivalentes sin ponderar, porque incorporan la incertidumbre añadida por el diseño. Cuando el propósito es
hacer inferencia sobre la población, estas son las pruebas apropiadas.

---

## 11. Reportar los resultados en formato APA

El paquete **report** genera automáticamente la redacción con formato APA a partir del objeto de la prueba.

```r
t.test(measure_mate ~ area, data = datos) %>% report()

aov(measure_mate ~ rama_abstracta, data = datos) %>% report()

chisq.test(tabla) %>% report()

t.test(vocab$vocab_post, vocab$vocab_pre, paired = TRUE) %>% report()
```

La salida es un párrafo redactado que incluye el estadístico, los grados de libertad, el valor p, el intervalo
de confianza y el tamaño del efecto con su interpretación. Sirve como borrador: conviene revisarlo, traducirlo y
adaptarlo al estilo del documento, pero evita errores al copiar cifras.

Para obtener solo la tabla de resultados:

```r
report_table(t.test(measure_mate ~ area, data = datos))
```

Otras opciones según el tipo de salida que se necesite:

- **`rstatix`**: devuelve los resultados como tibbles ordenados, fáciles de exportar o de convertir en tabla
  con `flextable`.
- **`apaTables`**: genera tablas de ANOVA, correlaciones y regresiones en archivos con formato APA.
- **`papaja`**: su función `apa_print()` produce fragmentos de texto y tablas para documentos en R Markdown o
  Quarto con plantilla APA.

Como estos paquetes se actualizan con frecuencia, conviene verificar la documentación de la versión instalada
antes de usarlos en un documento definitivo.

---

## 12. Criterios de interpretación

Una regla de decisión común a todas las pruebas anteriores:

- Si el valor p es **menor o igual a 0.05**, la decisión es **rechazar** la hipótesis nula; se dice que la
  prueba fue "significativa".
- Si el valor p es **mayor a 0.05**, la decisión es **no rechazar** la hipótesis nula.

Cuatro advertencias atraviesan toda la lección:

**No rechazar no equivale a demostrar la igualdad.** Un resultado no significativo puede reflejar ausencia de
efecto o falta de potencia para detectarlo. El intervalo de confianza permite distinguir ambas situaciones: si
es estrecho y rodea al cero, hay evidencia de que el efecto es despreciable; si es ancho, sencillamente no se
sabe.

**La significancia estadística no equivale a importancia práctica.** Con muestras grandes, diferencias mínimas
alcanzan significancia (como ocurrió con el área). Por eso se reportan siempre el **tamaño del efecto** y el
**intervalo de confianza** junto al valor p.

**La elección entre vía paramétrica y no paramétrica se resuelve antes de ver los resultados de la prueba de
interés**, a partir del diseño del estudio y de la comprobación de supuestos. Elegir la prueba en función de
cuál arroja el resultado deseado invalida la inferencia.

**Ningún supuesto se evalúa con un solo valor p.** La comprobación es un proceso que integra pruebas formales,
gráficos, estadísticos de forma, tamaño de muestra y convergencia entre métodos. Y conviene recordar el punto
de partida: si se dispone de los datos de toda la población, estas pruebas no son necesarias para comparar
grupos, porque no hay incertidumbre de muestreo que estimar.