# Análisis multivariado

## Recorrido de la lección

Las lecciones anteriores modelaron la relación entre **dos** variables. En la realidad, casi ningún fenómeno
educativo, psicológico o social depende de una sola causa: el desempeño de un estudiante se relaciona a la vez
con su nivel en otras materias, el entorno familiar, las condiciones del centro y muchos factores más. El
análisis multivariado considera **varios predictores a la vez**, lo que permite algo que el análisis de dos
variables no puede: aislar el efecto de cada uno **manteniendo constantes los demás**.

Antes de la lista, conviene precisar tres términos que se repetirán constantemente.

**Qué es un modelo (en esta lección).** La palabra "modelo" es amplia en estadística: en sentido general
designa cualquier descripción matemática de cómo se supone que se generaron los datos, y en ese sentido incluso
una prueba t lleva un modelo implícito. En esta lección, sin embargo, "modelo" se usa en un sentido más
concreto: un **modelo de regresión**, es decir, una **ecuación que describe cómo se relaciona una variable de
interés (la respuesta) con una o más variables que se usan para explicarla o predecirla (los predictores)**. No
pretende ser un retrato perfecto de la realidad, sino una representación simplificada y útil que resume esas
relaciones en unos pocos números. "Ajustar un modelo" es estimar esos números a partir de los datos;
"interpretar el modelo" es leer qué dicen sobre las relaciones.

**Qué es un coeficiente.** Es cada uno de esos números que el modelo estima: el valor que acompaña a un
predictor en la ecuación. Un coeficiente cuantifica **cuánto cambia la respuesta por cada unidad que aumenta
ese predictor**. Cuando el predictor es numérico, su coeficiente es la **pendiente** (la misma idea de la
regresión simple: cuántos puntos sube o baja la respuesta por cada punto que sube el predictor). Cada vez que
más adelante se hable de "el coeficiente de una variable", se está hablando de ese número y de esa
interpretación.

**Qué es un predictor.** Cualquier variable que se usa para explicar o anticipar la respuesta. En un modelo
puede haber uno o muchos.

Con eso, el recorrido es:

1. **Los modelos lineales generalizados**: el marco común que unifica los tres modelos de la lección.
2. **Regresión lineal múltiple**: la respuesta es un puntaje numérico (o un puntaje de escala) y hay varios
   predictores.
3. **Regresión logística**: la respuesta es binaria (logro / no logro).
4. **Regresión ordinal**: la respuesta es una única categoría ordenada con pocos niveles (bajo, medio, alto).

Se trabaja sobre la muestra de graduandos (ciclo anual). La idea que atraviesa las tres es el **control
estadístico**: qué significa estimar el efecto de una variable "manteniendo las demás constantes", y por qué
eso cambia (a veces radicalmente) las conclusiones respecto de mirar cada relación por separado.

> Esta lección da por conocidos los contenidos de la lección de correlación y regresión: el ajuste de un
> modelo con `lm()`, la lectura de coeficientes, R², los intervalos de confianza y la comprobación de
> supuestos sobre los residuos. Aquí se extienden a varios predictores.

---

## 1. Preparación

```r
pacman::p_load(
  tidyverse,    # manipulación y gráficos
  janitor,      # clean_names()
  broom,        # modelos en formato de tabla ordenada
  performance,  # diagnóstico de supuestos y comparación de modelos
  car,          # VIF y diagnósticos
  ordinal,      # regresión ordinal (clm)
  report,       # reporte automático en formato APA
  here
)

datos <- read_csv(
  here("Datos", "muestra_graduandos_anual.csv"),
  na = c("", "NA", ".")
) %>%
  clean_names()

datos <- datos %>%
  mutate(
    measure_mate      = as.numeric(measure_mate),
    measure_lect      = as.numeric(measure_lect),
    lectura_horas     = as.numeric(lectura_horas),
    escolaridad_madre = as.numeric(fm_grado_alcanzo_mama_reco),
    area              = factor(area),
    logro_mate        = factor(logro_mate, levels = c(0, 1),
                               labels = c("No logro", "Logro"))
  )
```

Conviene detenerse en lo que hace este bloque `mutate()`, porque ajusta el **tipo** de cada variable, y de eso
depende que los modelos la traten correctamente:

- `as.numeric(...)` convierte a número las columnas que se usarán como cantidades (los puntajes, las horas, la
  escolaridad). Si por algún código de texto quedaron como caracteres, esta conversión las vuelve numéricas.
- `factor(area)` convierte `area` en un **factor**: el tipo de dato que R reserva para las variables
  categóricas. Un factor guarda las categorías como un conjunto de **niveles** con nombre (aquí, "Urbana" y
  "Rural"). Declarar una variable como factor es lo que permite que R la trate como categórica en un modelo (y
  no como si sus códigos fueran cantidades).
- `factor(logro_mate, levels = c(0, 1), labels = c("No logro", "Logro"))` hace lo mismo, pero además **pone
  etiquetas legibles** a los códigos: el 0 pasa a leerse "No logro" y el 1, "Logro". Se conserva así la
  convención de la fuente de datos, que codifica el logro como una condición que se alcanza o no.

Las variables que se usan en la lección: `measure_lect` y `measure_mate` (desempeño en lectura y matemática, en
una escala continua centrada cerca de cero), `lectura_horas` (horas de lectura, 0 a 4), `escolaridad_madre`
(grado alcanzado por la madre, 1 a 4), `area` (urbana o rural) y `logro_mate` (si se alcanzó el nivel de logro
en matemática).

---

## 2. Los modelos lineales generalizados: el marco común

Los tres modelos de esta lección (lineal, logístico y ordinal) suelen presentarse como técnicas separadas, pero
en realidad son variantes de una misma estructura, llamada **modelo lineal generalizado** (GLM, por sus siglas
en inglés). Entender ese marco común hace que las tres partes dejen de parecer recetas sueltas.

Todo GLM tiene tres piezas:

1. **El predictor lineal.** Es la combinación de los predictores en una suma ponderada:
   $\beta_0 + \beta_1 x_1 + \beta_2 x_2 + \dots$. Esta parte es idéntica en los tres modelos.
2. **La distribución de la respuesta.** Describe cómo varían los datos: normal para un puntaje continuo,
   binomial para un resultado de sí/no, y así según el tipo de variable.
3. **La función de enlace.** Es la "traducción" entre el predictor lineal (que puede dar cualquier número, de
   menos infinito a más infinito) y lo que se quiere predecir (que a veces está restringido, como una
   probabilidad, que solo puede ir de 0 a 1).

### Qué significa "lineal" aquí (y qué no significa)

El nombre "modelo lineal generalizado" confunde, porque parece decir que la relación es una recta o que la
distribución es normal, y no es ninguna de las dos cosas. "Lineal" se refiere **únicamente** a que los
predictores se combinan de forma lineal entre sí (esa suma ponderada del predictor lineal). No se refiere ni a
la forma de la relación con la respuesta ni a la distribución de los datos.

El caso de la regresión logística lo deja claro. El modelo es lineal en los *log-odds* (el predictor lineal), y
sin embargo la relación entre los predictores y la **probabilidad** del resultado es una **curva** en forma de
S, no una recta. Las dos afirmaciones son ciertas a la vez porque se refieren a escalas distintas: lineal en la
escala interna del modelo, curvo en la escala de la probabilidad observada. Igualmente, la distribución
binomial no tiene nada de "lineal": describe la variación de un resultado de dos categorías. En resumen: en un
GLM lo lineal es **cómo se combinan los predictores entre sí**, no cómo se relaciona el resultado con ellos ni
cómo se distribuyen los datos.

> **Un tropiezo de nombres.** Los "modelos lineales generalizados" (GLM) no son lo mismo que el "modelo lineal
> general", que es otro nombre para la regresión y el ANOVA clásicos (respuesta continua y normal). Los nombres
> son casi idénticos y designan cosas distintas; conviene no confundirlos.

### El mapa de la familia

Cada tipo de respuesta tiene su combinación de distribución y enlace. Los tres modelos de la lección son solo
una parte de la familia:

| Tipo de respuesta                         | Modelo                     | Distribución       | Enlace           | En R |
|-------------------------------------------|----------------------------|--------------------|------------------|------|
| Numérica continua (o puntaje de escala)   | Regresión lineal           | Normal             | Identidad        | `lm()` |
| Binaria (sí/no)                           | Regresión logística        | Binomial           | Logit            | `glm(family = binomial)` |
| Ordinal (categorías ordenadas)            | Regresión ordinal          | (extensión del marco) | Logit acumulativo | `ordinal::clm()` |
| Conteo (número de veces)                  | Regresión de Poisson       | Poisson            | Logaritmo        | `glm(family = poisson)` |
| Conteo con sobredispersión                | Binomial negativa          | Binomial negativa  | Logaritmo        | `MASS::glm.nb()` |
| Categórica sin orden (3+ categorías)      | Regresión multinomial      | Multinomial        | Logit generalizado | `nnet::multinom()` |

Esta lección desarrolla las tres primeras filas. Las demás no se abordan, pero conviene conocerlas: la
**regresión de Poisson** modela conteos (número de ausencias, de repitencias), frecuentes en educación; la
**binomial negativa** ajusta conteos cuya varianza supera a la media (algo habitual en datos reales); y la
**regresión multinomial** trata respuestas categóricas de más de dos opciones sin orden (por ejemplo, elegir
entre tres ramas de carrera). La regresión ordinal, en rigor, es una **extensión** del marco GLM más que un GLM
en su forma más estricta, pero pertenece a la misma familia conceptual.

La ventaja de ver el marco común es práctica: explica por qué la logística se ajusta con
`glm(family = binomial)` (se está declarando la distribución), por qué sus coeficientes se exponencian (para
deshacer el enlace logit y volver a una escala interpretable), y por qué la regresión lineal es simplemente el
caso más sencillo, con distribución normal y enlace que no transforma nada.

---

# Parte I — Regresión lineal múltiple

## 3. La idea central: control estadístico

La regresión múltiple extiende la recta a varios predictores. La ecuación pasa de una pendiente a varias:

$$y = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + \dots + \beta_k x_k + \varepsilon$$

Lo esencial no es que haya más términos, sino **cómo cambia la interpretación de cada coeficiente**. En la
regresión simple, la pendiente de $x_1$ recogía todo el efecto de esa variable. En la múltiple, cada
coeficiente mide el efecto de su variable **manteniendo constantes todas las demás del modelo**. Es lo que se
llama **control estadístico**: el coeficiente responde a la pregunta "si dos estudiantes se diferencian en
$x_1$ pero son iguales en todas las otras predictoras, ¿cuánto se espera que difieran en $y$?".

### Una aclaración necesaria: los predictores no "interactúan" por defecto

Aquí conviene desactivar una confusión frecuente. Podría pensarse que, al meter varias variables juntas, el
modelo las hace "interactuar" entre sí, de modo que la respuesta se explica por una especie de mezcla
combinada de todas. **No es así, salvo que se pida explícitamente.**

El modelo de la ecuación anterior es **aditivo**: suma los efectos. Cada predictor aporta su parte de forma
**independiente** de las demás, y el efecto total es la suma de esas partes. El coeficiente de la matemática es
el mismo sin importar el valor de la escolaridad materna o del área; el de la escolaridad materna es el mismo
sin importar la matemática. Por eso "aislar el efecto" es literal: el modelo estima la contribución de cada
variable **como si las otras estuvieran fijas**, no las deja fundirse.

Que el efecto de una variable **dependa** del valor de otra (que la matemática pese distinto en el área urbana
que en la rural, por ejemplo) es una situación distinta llamada **interacción**, y solo ocurre en el modelo si
se agrega expresamente un término para ella. Mientras no se haga, el modelo supone que no hay interacción. Las
interacciones se tratan en el apartado 9.

---

## 4. Ajustar e interpretar el modelo

Se modela el desempeño en lectura a partir de cuatro predictores: matemática, horas de lectura, escolaridad de
la madre y área. La sintaxis de `lm()` suma los predictores con `+`.

```r
modelo <- lm(measure_lect ~ measure_mate + lectura_horas + escolaridad_madre + area,
             data = datos)
summary(modelo)
#>
#> Coefficients:
#>                    Estimate Std. Error t value Pr(>|t|)
#> (Intercept)       -0.11168    0.03673   -3.04  0.00239 **
#> measure_mate       0.41543    0.01318   31.53  < 2e-16 ***
#> lectura_horas     -0.01512    0.01156   -1.31  0.19075
#> escolaridad_madre  0.15423    0.01281   12.04  < 2e-16 ***
#> areaRural         -0.09446    0.03475   -2.72  0.00666 **
#>
#> Residual standard error: 0.702 on 2713 degrees of freedom
#> Multiple R-squared:  0.3259,  Adjusted R-squared:  0.3249
#> F-statistic: 327.9 on 4 and 2713 DF,  p-value: < 2.2e-16
```

### Cómo se leen los coeficientes numéricos

**`measure_mate` (0.415).** Manteniendo constantes las horas de lectura, la escolaridad de la madre y el área,
por cada punto adicional de matemática el desempeño en lectura aumenta en promedio 0.415 puntos. Es la
pendiente de la matemática (su coeficiente), y es el predictor más fuerte y significativo (p < .001).

**`escolaridad_madre` (0.154).** A igualdad de las demás variables, cada nivel adicional de escolaridad de la
madre se asocia con 0.154 puntos más de lectura. Significativo (p < .001): aporta información propia.

### Cómo se leen los coeficientes de una variable categórica

La variable `area` no es numérica, así que no puede tener una "pendiente" en el sentido usual. R la maneja
mediante un procedimiento llamado **codificación indicadora** (en inglés, *dummy coding*; también se le dice
"variables ficticias" o "variables indicadoras"). Conviene entenderlo porque aparece siempre que hay un
predictor categórico.

La idea: una variable categórica con dos categorías se convierte en una **variable indicadora** que vale 1 si
el caso pertenece a una categoría y 0 si pertenece a la otra. La categoría que queda representada por el 0 se
llama **categoría de referencia** (o base), y no recibe coeficiente propio: queda absorbida en el intercepto.
El coeficiente de la otra categoría mide entonces **la diferencia respecto de esa referencia**. Si una variable
tuviera tres categorías, se crearían dos indicadoras (siempre una menos que el número de categorías), cada una
comparada con la misma referencia.

**`areaRural` (−0.094).** El nombre del coeficiente indica cuál categoría **no** es la referencia: aquí
"Urbana" es la referencia y "Rural" es la que se compara. El coeficiente se lee así: a igualdad del resto,
"aumentar" de la referencia a esta categoría (es decir, **ser de área rural en lugar de urbana**) se asocia con
0.094 puntos **menos** de lectura. Para una variable indicadora, "aumentar en una unidad" significa simplemente
pasar de la categoría de referencia a la otra. Es significativo (p = .007).

> **Cómo saber y cambiar cuál es la referencia.** Por defecto, R toma como referencia el primer nivel del
> factor en **orden alfabético**. Como "Rural" precede a "Urbana", la referencia sería "Rural" y el coeficiente
> se llamaría `areaUrbana`. Para fijar "Urbana" como referencia (y obtener el coeficiente `areaRural` que
> aparece arriba) se reordenan los niveles antes de ajustar:
> ```r
> datos <- datos %>% mutate(area = fct_relevel(area, "Urbana"))
> ```
> Elegir la referencia con criterio (por ejemplo, el grupo más numeroso o el de comparación natural) hace que
> los coeficientes se lean de la forma más útil.

**`lectura_horas` (−0.015).** A igualdad de las demás variables, las horas de lectura **no** predicen el
desempeño en lectura (p = .191, no significativo). Este resultado, que parece contraintuitivo, se examina en el
apartado 5.

### Los indicadores globales del modelo

**R² (0.326).** Los cuatro predictores explican en conjunto el 33 % de la varianza del desempeño en lectura.
Para dimensionarlo dentro de esta misma lección, conviene compararlo con un modelo que use solo la matemática,
ajustado sobre los mismos casos:

```r
# Modelo reducido, solo con matemática, sobre el mismo conjunto de datos
lm(measure_lect ~ measure_mate, data = datos) %>%
  broom::glance() %>%
  select(r.squared)
#>  r.squared = 0.287
```

La matemática sola explica el 28.7 % de la varianza; añadir las otras tres variables lo sube al 32.6 %. La
ganancia es real aunque modesta: la mayor parte de la capacidad explicativa la aporta la matemática.

**R² ajustado (0.325).** El R² ordinario tiene un defecto: **siempre sube al añadir predictores**, aunque sean
completamente inútiles, porque cualquier variable, por azar, captura algo de la respuesta en la muestra. Eso lo
vuelve engañoso para juzgar si vale la pena incluir una variable. El **R² ajustado** corrige ese defecto:
descuenta una penalización por cada predictor añadido, de modo que solo aumenta si la variable aporta más de lo
que costaría incluirla por azar. Cuando el R² ajustado queda muy cerca del R² ordinario (aquí, 0.325 frente a
0.326), es señal de que los predictores incluidos son genuinamente informativos y no están "inflando"
artificialmente el ajuste. Si hubiera muchas variables inútiles, el ajustado caería bastante por debajo del
ordinario.

**El estadístico F.** Este contraste responde una pregunta **distinta** de la de los coeficientes
individuales, y la diferencia es importante:

- Cada **coeficiente** (con su valor p) responde: *¿esta variable en particular aporta algo propio, una vez
  descontadas las demás?* Es la lógica de aislar efectos.
- El **estadístico F** responde: *¿el conjunto de predictores, tomado como un todo, explica la respuesta mejor
  que no tener modelo alguno (mejor que predecir simplemente el promedio general para todos)?* Es una pregunta
  sobre el modelo completo, no sobre cada pieza.

Su hipótesis nula es que **todos** los coeficientes valen cero a la vez (que ninguna variable aporta nada, que
el modelo entero es inútil). Aquí se rechaza (p < .001): el conjunto de predictores sí explica el desempeño en
lectura. Las dos lecturas son complementarias: la F dice que el equipo funciona; los valores p individuales
dicen qué jugadores están cargando el peso. Puede ocurrir que la F sea significativa y aun así alguna variable
individual no lo sea, como pasa aquí con las horas de lectura.

```r
# Coeficientes con intervalos de confianza, en formato ordenado
broom::tidy(modelo, conf.int = TRUE)
```

---

## 5. Por qué el control cambia las conclusiones (y cómo interpretarlas)

El caso de `lectura_horas` ilustra el fenómeno más importante del análisis multivariado, y también un punto de
interpretación que va más allá de la estadística.

### El fenómeno estadístico: confusión y efecto único

El efecto de una variable puede cambiar (aparecer, desaparecer o incluso invertir su signo) según qué otras
variables estén en el modelo. Tiene dos caras:

**Confusión.** Cuando dos predictores están asociados entre sí y con la respuesta, la relación simple de uno
puede deberse en realidad al otro. El control lo revela: si al añadir un segundo predictor el efecto del
primero se reduce o desaparece, su relación aparente estaba "prestada" del segundo.

**Efecto único.** El coeficiente en el modelo múltiple representa la contribución **propia** de cada variable,
la que ninguna otra del modelo explica. Un predictor sobrevive al control cuando aporta información que las
demás no tienen.

Se ve comparando el efecto de la escolaridad materna sola y dentro del modelo completo:

```r
# Efecto de la escolaridad materna, SIN controlar nada
lm(measure_lect ~ escolaridad_madre, data = datos) %>% broom::tidy()
#>  escolaridad_madre  estimate = 0.218

# Efecto DENTRO del modelo con todos los predictores
#  escolaridad_madre  estimate = 0.154  (visto en el apartado 4)
```

El efecto se reduce de 0.218 a 0.154 al controlar por matemática y las demás variables: cerca de un tercio de
su relación aparente con la lectura era compartida con el desempeño en matemática (los estudiantes con madres
de mayor escolaridad tienden también a puntuar más alto en matemática). Lo que queda, 0.154, es su aporte
propio.

### El momento de interpretar: qué se puede y qué no se puede concluir

El hallazgo de que las horas de lectura **no** predicen el desempeño en lectura (al controlar por las demás
variables) es un buen momento para detenerse, porque es justo donde el análisis deja de ser un procedimiento
mecánico y empieza a exigir juicio.

La tentación es leer el resultado como "leer más no mejora la lectura". **Esa conclusión no se sostiene**, y
confundirla sería un error con consecuencias prácticas serias (imagínese esa frase citada para justificar
recortar programas de lectura). Un coeficiente no significativo **no demuestra la ausencia de efecto**; puede
deberse a muchas causas ajenas a que el efecto no exista:

- **La medición.** "Horas de lectura" está registrado en apenas cinco categorías gruesas y probablemente por
  autoreporte. Una medida tan burda tiene poca capacidad de captar una relación real aunque exista.
- **La confusión inversa.** Es posible que el efecto de leer ya esté "contenido" en el desempeño en matemática
  o en la escolaridad materna, con los que la lectura se asocia; al controlarlos, se le resta a las horas de
  lectura un crédito que quizá le correspondía en parte.
- **La causalidad inversa.** Tal vez no es que leer más mejore el desempeño, sino que quienes ya leen bien
  tienden a leer más: la flecha podría ir en la otra dirección.
- **El rango restringido.** Si casi todos los estudiantes reportan valores parecidos, hay poca variación con
  la cual detectar un efecto.

La lección de fondo es que **la estadística no se hace por sí misma**. Un coeficiente es el comienzo de la
interpretación, no su final. El número dice qué pasó en estos datos, bajo este modelo; explicar **por qué** y
qué implica exige volver al fenómeno, a cómo se midió y a la teoría. Reportar "las horas de lectura no fueron
significativas (p = .191)" es correcto; añadir "por lo tanto leer no sirve" es una traición a los datos. El
valor de hacer estadística está en informar decisiones con honestidad, no en producir veredictos.

### Causalidad: alcance explicativo, no prueba de causa

Un modelo como este suele describirse como un análisis de **alcance explicativo** (busca explicar una variable
a partir de otras), y encaja con ese lenguaje habitual en la investigación. Pero **explicar en sentido
estadístico no equivale a establecer una causa**. El modelo describe asociaciones ajustadas por las variables
**incluidas**; nada garantiza que no exista una variable no medida que explique la relación (el nivel
socioeconómico, la calidad del centro, la motivación).

¿Solo un diseño experimental vuelve causal una afirmación? El experimento (con asignación al azar) es la vía
más limpia, porque distribuye equitativamente incluso las variables no medidas. Pero no es la única. Existe un
campo entero, la **inferencia causal**, dedicado a estimar efectos causales a partir de datos observacionales,
mediante supuestos explícitos y herramientas como los grafos causales, las variables instrumentales, la
regresión discontinua o el emparejamiento. Ese campo (asociado a autores como Pearl o Rubin) permite, bajo
condiciones exigentes y declaradas, acercarse a conclusiones causales sin experimento. La advertencia
pertinente es doble: la regresión múltiple por sí sola **no** es inferencia causal (no basta con "controlar
variables" para reclamar causa), y ese terreno más avanzado existe y tiene respuestas, aunque exceda esta
lección.

> **Un riesgo técnico que conviene nombrar: la circularidad.** Un error grave, y a veces sutil, es usar como
> predictor una variable que es en sí misma una **transformación de la respuesta**. Por ejemplo, predecir
> `logro_mate` (que se deriva de `measure_mate`, marcando quién superó cierto umbral) usando `measure_mate`
> como predictor: el modelo "acertaría" casi perfectamente, pero no diría nada, porque estaría explicando una
> variable consigo misma. Por eso en esta lección los ejemplos se eligen con cuidado para evitarlo: el logro en
> matemática se predice a partir de la **lectura** (no de la matemática de la que se deriva), y el nivel de
> lectura se predice a partir de la **matemática** (no de la medida de lectura de la que proviene). Al armar un
> modelo, conviene verificar siempre que los predictores no sean versiones disfrazadas de la respuesta.

---

## 6. Supuestos específicos del modelo múltiple

Los supuestos LINE de la regresión simple (linealidad, independencia, normalidad de los residuos,
homocedasticidad) siguen vigentes y se comprueban igual, sobre los residuos:

```r
performance::check_model(modelo)
```

La regresión múltiple añade un supuesto propio: la **ausencia de multicolinealidad**.

### 6.1 Multicolinealidad

Hay multicolinealidad cuando dos o más predictores están muy correlacionados **entre sí**. El problema no es
que el modelo falle, sino que se vuelve incapaz de separar sus efectos: si dos variables suben y bajan casi
juntas, el modelo no puede decidir a cuál atribuir el efecto, y sus coeficientes se vuelven inestables (con
errores estándar inflados, de modo que pierden significancia aunque la relación exista).

Se diagnostica con el **factor de inflación de la varianza** (VIF), que mide cuánto se infla la varianza de
cada coeficiente por su correlación con los demás predictores:

```r
car::vif(modelo)
#>      measure_mate     lectura_horas escolaridad_madre              area
#>              1.03              1.00              1.03              1.01
```

Interpretación de referencia: un VIF de 1 indica ausencia total de colinealidad; valores por encima de 5
señalan un problema moderado, y por encima de 10, uno serio. Aquí todos los VIF rondan 1, de modo que no hay
multicolinealidad: los predictores aportan información independiente.

> Cuando el VIF es alto, las soluciones habituales son eliminar una de las variables redundantes, combinarlas
> en un índice, o usar métodos regularizados (regresión *ridge* o *lasso*).

---

## 7. Comparar modelos

Con varios predictores surge la pregunta de cuál modelo es mejor: ¿vale la pena incluir una variable
determinada? Hay tres herramientas complementarias.

**El R² ajustado.** Como se explicó, penaliza por el número de predictores y solo sube si la variable añadida
aporta lo suficiente. Es la primera señal para comparar modelos con distinto número de variables.

**La prueba F para modelos anidados.** Dos modelos están **anidados** cuando uno contiene a todos los
predictores del otro más alguno adicional. La función `anova()` compara los dos y contrasta si el modelo más
grande explica significativamente más varianza que el pequeño.

> Conviene aclarar el nombre, para evitar una confusión. "Análisis de varianza" (ANOVA) no designa una única
> prueba, sino un **principio general**: descomponer la variabilidad total en partes atribuibles a distintas
> fuentes. Ese principio sirve tanto para comparar las medias de varios grupos como, aquí, para comparar la
> varianza que dos modelos dejan sin explicar. Por eso la misma función `anova()` se usa en ambos contextos:
> en los dos casos está repartiendo variabilidad y preguntando si una fuente (un grupo, un predictor extra)
> explica una porción significativa.

```r
modelo_sin  <- lm(measure_lect ~ measure_mate + escolaridad_madre + area, data = datos)
modelo_con  <- lm(measure_lect ~ measure_mate + escolaridad_madre + area + lectura_horas, data = datos)

anova(modelo_sin, modelo_con)
#>   Res.Df    RSS Df Sum of Sq      F Pr(>F)
#> 1   2714 1337.6
#> 2   2713 1336.8  1   0.84573  1.716 0.1908
```

El valor p (0.191) coincide con el del coeficiente de `lectura_horas`: añadir esa variable no mejora
significativamente el modelo, de modo que conviene dejarla fuera por parsimonia.

**El AIC (criterio de información de Akaike).** En vez de tratarlo como un número que "conviene que sea bajo",
vale la pena entender qué equilibra, porque su lógica es valiosa. Un modelo con más predictores **siempre**
ajusta mejor los datos de la muestra, pero corre el riesgo de ajustar también el **ruido** propio de esa
muestra (lo que se llama sobreajuste), y eso perjudica sus predicciones sobre datos nuevos. El AIC estima la
calidad predictiva esperada del modelo combinando dos términos en tensión: premia el buen ajuste, pero
**penaliza cada parámetro adicional**. Así, un modelo con AIC menor es el que se espera que prediga mejor
**fuera de la muestra**, no simplemente el que ajusta más. El valor absoluto del AIC no significa nada por sí
mismo; solo importan las **diferencias** entre modelos calculados sobre los mismos datos.

```r
AIC(modelo_sin, modelo_con)
#>            df      AIC
#> modelo_sin  5 5999.9
#> modelo_con  6 6000.2
```

El modelo sin `lectura_horas` tiene un AIC ligeramente menor, lo que confirma la misma conclusión: esa variable
no aporta, y el modelo más simple es preferible.

---

## 8. Coeficientes estandarizados: comparar la fuerza de los predictores

Antes de calcularlos conviene aclarar **cuándo** se usan, porque no son un paso rutinario. Lo habitual es
ajustar el modelo y leer sus coeficientes en las **unidades originales** de cada variable, que son las
interpretables ("0.42 puntos de lectura por cada punto de matemática"). La estandarización es un paso
**adicional y posterior**, que se hace **solo cuando el objetivo es comparar la fuerza relativa** de
predictores medidos en escalas distintas. No sustituye al modelo original; se calcula sobre el mismo modelo con
otro fin.

El problema que resuelve: los coeficientes crudos están en las unidades de cada variable, así que no son
comparables entre sí (0.42 de matemática y 0.15 de escolaridad materna no significan que uno sea "casi tres
veces" el otro, porque las escalas difieren). Al estandarizar, se expresan todos en desviaciones estándar,
poniendo las variables en la misma escala.

```r
# Estandarizar las variables numéricas y reajustar el mismo modelo
datos %>%
  mutate(across(c(measure_lect, measure_mate, lectura_horas, escolaridad_madre), scale)) %>%
  lm(measure_lect ~ measure_mate + lectura_horas + escolaridad_madre + area, data = .) %>%
  broom::tidy()
#>  measure_mate       0.504
#>  escolaridad_madre  0.193
#>  lectura_horas     -0.021
#>  areaRural         -0.043
```

Ahora sí son comparables: el desempeño en matemática (beta = 0.50) tiene un efecto sobre la lectura unas dos
veces y media mayor que la escolaridad de la madre (beta = 0.19), que es el segundo predictor más importante.
Los coeficientes crudos responden "¿cuánto cambia la respuesta por unidad de esta variable?"; los
estandarizados responden "¿cuál predictor pesa más?". Ambos salen del mismo modelo, según qué se quiera saber.

---

## 9. Interacciones: cuando el efecto de una variable depende de otra

Hasta aquí el modelo ha sido aditivo: se supuso que el efecto de cada predictor es el mismo para todos. Una
**interacción** (o **moderación**) ocurre cuando el efecto de una variable **cambia según el valor de otra**.
Por ejemplo: ¿el efecto de la matemática sobre la lectura es igual en el área urbana que en la rural, o difiere?

### El centrado, antes de aplicarlo

Cuando una interacción incluye una variable numérica, es una práctica recomendada **centrarla** antes: restarle
su media, de modo que sus valores queden expresados como distancias respecto del promedio (los valores por
encima de la media quedan positivos; los de abajo, negativos; el promedio queda en 0).

Se centra por dos razones. La primera es de interpretación: en un modelo con interacción, el coeficiente
"principal" de una variable representa su efecto **cuando la otra vale 0**. Si 0 no es un valor con sentido
(como un puntaje de 0 en una escala centrada, o algo aún más artificial en otras escalas), ese coeficiente se
vuelve difícil de interpretar. Al centrar, el 0 pasa a ser la media, que sí es un punto de referencia
significativo. La segunda razón es técnica: centrar reduce la correlación artificial entre la variable y su
propio término de interacción, lo que estabiliza el modelo.

```r
# Centrar la matemática (restarle su media) ANTES de construir la interacción
datos <- datos %>%
  mutate(mate_c = measure_mate - mean(measure_mate, na.rm = TRUE))

modelo_int <- lm(measure_lect ~ mate_c * area, data = datos)
summary(modelo_int)
#>                  Estimate  Pr(>|t|)
#> (Intercept)       0.30366   < 2e-16 ***
#> mate_c            0.44434   < 2e-16 ***
#> areaRural        -0.12420   0.000506 ***
#> mate_c:areaRural -0.02542   0.4750
```

El operador `*` en la fórmula incluye automáticamente las dos variables por separado **y** su producto. El
término clave es ese producto, `mate_c:areaRural`: es la interacción.

### Cómo se lee la interacción

Conviene recordar qué es una **pendiente**: es cuánto cambia la respuesta por cada unidad que sube un
predictor numérico. Aquí, la pendiente de la matemática (0.444) indica que, en el área de referencia (urbana),
cada punto de matemática se asocia con 0.444 puntos más de lectura.

El coeficiente de la interacción indica **cuánto cambia esa pendiente al pasar de un área a otra**. Vale
−0.025: en el área rural, la pendiente de la matemática sería 0.444 − 0.025 = 0.419, apenas distinta. Y su
valor p (0.475) dice que ese cambio **no** es significativo: la relación entre matemática y lectura es
esencialmente la misma en ambas áreas, de modo que **no hay moderación**. Si el coeficiente hubiera sido
significativo, indicaría que el efecto de la matemática depende del área.

**Cómo reportarlo.** Se ajustó un modelo de regresión múltiple para predecir el desempeño en lectura a partir
de matemática, escolaridad materna y área, F(4, 2713) = 327.9, p < .001, R² = .33. El desempeño en matemática
fue el predictor más fuerte (β = 0.50, p < .001), seguido de la escolaridad de la madre (β = 0.19, p < .001).
Las horas de lectura no predijeron el desempeño al controlar por las demás variables (p = .191). La interacción
entre matemática y área no fue significativa (p = .475).

---

# Parte II — Regresión logística

## 10. Cuándo la respuesta es binaria

La regresión lineal no sirve cuando la variable a predecir es **binaria** (dos categorías: logro / no logro,
aprueba / no aprueba). Ajustar una recta a una variable de dos valores produce predicciones imposibles
(probabilidades menores que 0 o mayores que 1) y viola los supuestos. La **regresión logística** resuelve esto
modelando no el valor, sino la **probabilidad** de que ocurra el resultado, y garantizando que esa probabilidad
quede siempre entre 0 y 1.

Se modela el logro en matemática (`logro_mate`, que ya viene en los datos como "Logro" / "No logro") a partir
del desempeño en lectura, la escolaridad de la madre y el área.

```r
modelo_log <- glm(logro_mate ~ measure_lect + escolaridad_madre + area,
                  data = datos, family = binomial)
summary(modelo_log)
```

El modelo se ajusta con `glm()` (modelo lineal **generalizado**) y el argumento `family = binomial`, que
declara que la respuesta sigue una distribución binomial. Como se vio en el apartado 2, eso, junto con el
enlace logit, es lo que convierte la regresión lineal en logística.

## 11. Por qué el modelo trabaja en escala logarítmica

Este es el punto que más cuesta, así que conviene desarrollarlo. Una probabilidad está atrapada entre 0 y 1,
pero el predictor lineal ($\beta_0 + \beta_1 x_1 + \dots$) puede dar cualquier número, de menos infinito a más
infinito. No se pueden igualar directamente: harían falta predicciones imposibles. La regresión logística
resuelve el desajuste en dos pasos.

**Primer paso: de probabilidad a momio.** Un **momio** (en inglés, *odds*) expresa cuán probable es un
resultado como un **cociente entre lo favorable y lo desfavorable**, no como un porcentaje:

$$\text{momio} = \frac{p}{1 - p}$$

Si de cada 5 estudiantes 1 alcanza el logro y 4 no, la probabilidad es 1/5 = 0.20, pero el momio es 1 a 4
(0.25): el resultado es cuatro veces más probable que no ocurra a que ocurra. El momio ya no está limitado
arriba (puede crecer sin tope), aunque sigue sin poder ser negativo.

**Segundo paso: del momio a su logaritmo.** Al tomar el logaritmo del momio (el **log-odds** o *logit*), se
obtiene un número que sí puede ir de menos infinito a más infinito: los momios menores que 1 dan logaritmos
negativos, el momio de 1 da 0, y los mayores dan positivos. Ahora sí, ese log-odds se puede igualar al
predictor lineal sin contradicciones. Esa es la **función de enlace logit**: la traducción que hace calzar la
probabilidad con la parte lineal del modelo.

La consecuencia práctica: los coeficientes que devuelve `glm()` están en la escala de los **log-odds**, que no
es interpretable a simple vista. Para volver a una escala legible se **exponencian** (con `exp()`, que deshace
el logaritmo), y el resultado son **razones de momios**.

## 12. Interpretar con razones de momios

```r
# Razones de momios con sus intervalos de confianza
exp(cbind(OR = coef(modelo_log), confint(modelo_log)))
#>                          OR   2.5 %  97.5 %
#> (Intercept)           0.064   0.048   0.085
#> measure_lect          3.925   3.398   4.534
#> escolaridad_madre     1.090   0.980   1.211
#> areaRural             1.174   0.870   1.586

# En formato ordenado con broom
broom::tidy(modelo_log, exponentiate = TRUE, conf.int = TRUE)
```

Una **razón de momios** (*odds ratio*) indica por cuánto se **multiplica** el momio del resultado cuando el
predictor aumenta en una unidad. Conviene verlo con números concretos, porque "aumenta los momios" es abstracto.

**`measure_lect` (OR = 3.93), con un ejemplo concreto.** En estos datos, el momio base de alcanzar el logro es
de aproximadamente 0.18, es decir, alrededor de **1 a 5.5** (por cada estudiante que lo alcanza, unos 5.5 no lo
alcanzan). La razón de momios de 3.93 significa que, manteniendo constantes la escolaridad materna y el área,
**cada punto adicional de lectura multiplica ese momio por 3.93**: pasaría de 0.18 a 0.18 × 3.93 ≈ 0.71, es
decir, de "1 a 5.5" a algo cercano a **1 a 1.4**. Dos puntos adicionales lo multiplicarían dos veces
(0.18 × 3.93 × 3.93 ≈ 2.8, ya por encima de 1 a 1). Un punto más de lectura casi cuadruplica los momios de
lograr el nivel: es un efecto fuerte.

**Cómo se lee la significancia en el intervalo.** El intervalo de la razón de momios de `measure_lect` es
[3.40, 4.53]. Para una razón de momios, el valor que indica "ausencia de efecto" es el **1**, no el 0 (porque
multiplicar un momio por 1 lo deja igual: sin cambio). La regla es entonces: si el intervalo de confianza
**no incluye el 1**, el efecto es significativo (se descarta el "sin efecto"); si lo **incluye**, no lo es.
Aquí el intervalo va de 3.40 a 4.53, entero por encima de 1, de modo que el efecto es significativo. Es la
misma lógica que un intervalo para una diferencia que incluye o no el 0, trasladada a la escala de cocientes,
donde el punto neutro es el 1.

**`escolaridad_madre` (OR = 1.09).** A igualdad del resto, cada nivel adicional multiplicaría el momio por 1.09
(un aumento del 9 %), pero el intervalo [0.98, 1.21] **incluye el 1**: no se puede descartar que el efecto sea
nulo una vez controlada la lectura, de modo que no es significativo.

**`areaRural` (OR = 1.17).** Tampoco es significativo (el intervalo [0.87, 1.59] cruza el 1).

La regla general: una razón de momios de 1 significa ausencia de efecto; mayor que 1, que la predictora
multiplica al alza los momios del resultado; menor que 1, que los reduce (por ejemplo, 0.5 los reduce a la
mitad).

## 13. Evaluar el ajuste

La regresión logística no tiene un R² como el de la regresión lineal. Se usan sustitutos y medidas de
clasificación.

**Pseudo-R².** El de McFadden es el más común; sus valores son más bajos que los de un R² normal (valores de
0.2 a 0.4 ya indican buen ajuste).

```r
performance::r2_mcfadden(modelo_log)
#>  McFadden's R2: 0.220
```

**Capacidad de clasificación.** Un modelo logístico entrega, para cada estudiante, una probabilidad estimada de
alcanzar el logro. Si se fija un umbral (por ejemplo, 0.5) se puede convertir esa probabilidad en una
predicción de categoría (logro / no logro) y contar qué proporción de casos se clasifica correctamente. Pero
ese porcentaje no se lee solo: hay que compararlo con una **línea base**, que es lo que se acertaría con la
estrategia más tonta posible, la de **predecir siempre la categoría más frecuente** sin mirar ningún predictor.

```r
datos %>%
  mutate(prob = predict(modelo_log, type = "response"),
         pred = if_else(prob >= 0.5, "Logro", "No logro")) %>%
  summarise(exactitud = mean(pred == logro_mate, na.rm = TRUE))
#>  0.875
```

El modelo clasifica bien al 87.5 % de los casos. Pero como el 84.7 % de los estudiantes **no** alcanzó el
logro, un modelo que ignorara todo y dijera siempre "No logro" ya acertaría el 84.7 % por pura frecuencia. La
mejora real del modelo sobre esa línea base es de menos de tres puntos: existe, pero es modesta, y reportarla
en ese contexto evita exagerar la utilidad del modelo. Para una evaluación más completa se usan la curva ROC y
el área bajo ella (`pROC::roc()`).

**Cómo reportarlo.** Se ajustó una regresión logística para predecir el logro en matemática a partir del
desempeño en lectura, la escolaridad materna y el área (pseudo-R² de McFadden = .22). El desempeño en lectura
fue el único predictor significativo: cada punto adicional multiplicó los momios de alcanzar el logro por 3.93
(IC 95 % [3.40, 4.53], p < .001). Ni la escolaridad materna ni el área tuvieron efecto significativo al
controlar por la lectura.

---

# Parte III — Regresión ordinal

## 14. Cuándo la respuesta es una categoría ordenada

La tercera situación es que la respuesta sea **ordinal**: una única variable con categorías ordenadas pero
pocas. Conviene precisar la frontera, porque se presta a confusión:

- Si la respuesta es un **puntaje construido sumando muchos ítems** (una escala Likert sumada), tiene muchos
  valores y se trata como cuasi-continuo: corresponde la **regresión lineal** de la Parte I. La suma
  transforma la variable, y rechazar la vía lineal "porque los ítems son ordinales" es un error.
- Si la respuesta es **un solo indicador ordinal con pocas categorías**, es cuando corresponde la **regresión
  ordinal**, tema de esta parte.

El ejemplo usa la variable `desempeno_lect`. En estos datos, además de la medida continua de lectura
(`measure_lect`), la fuente reporta el desempeño clasificado en **cuatro niveles ordenados** (1 = el más bajo a
4 = el más alto), obtenidos al agrupar la medida continua en bandas de logro. Es el formato típico de estas
evaluaciones: una medida continua y, junto a ella, una clasificación en niveles de desempeño. Ese indicador de
cuatro niveles es un caso genuino de variable ordinal con pocas categorías.

Aplicarle regresión lineal obligaría a tratar sus niveles como si estuvieran a distancias iguales (a suponer
que el salto de "nivel 1" a "nivel 2" vale lo mismo que el de "nivel 3" a "nivel 4"), lo que rara vez es
cierto. La regresión ordinal, o modelo de **enlace acumulativo** (`clm`, de *cumulative link model*), modela en
cambio la **probabilidad de estar en cada categoría o por debajo de ella**, respetando el orden sin inventar
distancias.

Se modela el nivel de desempeño en lectura a partir del desempeño en matemática y la escolaridad de la madre.

> **Nota sobre la circularidad (retomando el apartado 5).** El nivel `desempeno_lect` se deriva de
> `measure_lect`, así que usar `measure_lect` para predecirlo sería circular (se explicaría la variable con una
> versión de sí misma). Por eso se predice a partir de la **matemática** y la escolaridad materna, que son
> variables distintas.

```r
# La respuesta debe ser un factor ORDENADO
datos <- datos %>%
  mutate(desempeno_lect = factor(desempeno_lect, ordered = TRUE))

modelo_ord <- ordinal::clm(desempeno_lect ~ measure_mate + escolaridad_madre,
                           data = datos)
summary(modelo_ord)
```

## 15. Interpretar el modelo ordinal

La salida tiene dos partes: los **coeficientes** de las predictoras y los **umbrales** (los cortes entre
categorías consecutivas).

**Los coeficientes** se interpretan, igual que en la logística, con razones de momios (se exponencian, porque
el modelo también trabaja en escala logarítmica). La diferencia es que aquí el "resultado" es estar en una
categoría **más alta**:

```r
exp(coef(modelo_ord))
#>  measure_mate       escolaridad_madre
#>         2.80                    1.41
```

**`measure_mate` (OR = 2.80).** Manteniendo constante la escolaridad de la madre, cada punto adicional de
matemática multiplica por 2.80 los momios de ubicarse en un nivel de desempeño en lectura **más alto** (frente
a los niveles inferiores). Es un efecto fuerte y significativo.

**`escolaridad_madre` (OR = 1.41).** A igualdad de matemática, cada nivel adicional de escolaridad materna
multiplica por 1.41 los momios de estar en un nivel de lectura superior. También significativo.

**Los umbrales** separan las categorías (entre nivel 1 y 2, entre 2 y 3, entre 3 y 4). Rara vez se interpretan
de forma sustantiva; son el equivalente ordinal de tener varios interceptos, uno por cada corte.

## 16. El supuesto propio: odds proporcionales

El modelo `clm` asume que el efecto de cada predictor es **el mismo en todos los cortes** entre categorías (que
el paso de "nivel 1" a "nivel 2 o más" se rige por el mismo coeficiente que el de "hasta nivel 3" a "nivel 4").
Es un supuesto fuerte, llamado de **odds proporcionales**, y conviene verificarlo:

```r
nominal_test(modelo_ord)
```

Si la prueba resulta significativa para alguna variable, ese supuesto se viola para ella, y `clm()` permite
relajarlo solo para esa variable con el argumento `nominal`:

```r
# Ejemplo: permitir que el efecto del área varíe entre cortes
clm(desempeno_lect ~ measure_mate, nominal = ~ area, data = datos)
```

**Cómo reportarlo.** Se ajustó un modelo de regresión ordinal (enlace logístico acumulativo) para predecir el
nivel de desempeño en lectura a partir de la matemática y la escolaridad materna. Ambos predictores fueron
significativos: cada punto de matemática multiplicó por 2.80 los momios de ubicarse en un nivel superior
(p < .001), y cada nivel de escolaridad materna, por 1.41 (p < .001). La prueba de odds proporcionales no
detectó violación del supuesto.

---

## 17. Reportar los resultados

El paquete `report` funciona con los tres tipos de modelo:

```r
lm(measure_lect ~ measure_mate + escolaridad_madre + area, data = datos) %>% report()
glm(logro_mate ~ measure_lect + area, data = datos, family = binomial) %>% report()
```

Y `broom::tidy(modelo, exponentiate = TRUE, conf.int = TRUE)` entrega los coeficientes (o razones de momios)
como tabla lista para dar formato con `flextable` o `apaTables`.

---

## 18. Síntesis

Las tres partes comparten una misma lógica, la de los modelos lineales generalizados: combinan los predictores
en una suma ponderada y la conectan con la respuesta mediante una función de enlace y una distribución
adecuadas al tipo de variable. Se distinguen por esa respuesta:

1. **Regresión lineal múltiple**, para respuestas numéricas o puntajes de escala. Su aporte central es el
   **control estadístico**: cada coeficiente es el efecto propio de una variable manteniendo las demás
   constantes, lo que revela confusiones y efectos únicos. Añade el supuesto de ausencia de multicolinealidad
   (VIF) y herramientas para comparar modelos (R² ajustado, prueba F anidada, AIC), estandarizar coeficientes
   e incluir interacciones.
2. **Regresión logística**, para respuestas binarias. Modela probabilidades mediante `glm(family = binomial)`,
   trabaja en escala de log-odds y se interpreta con razones de momios.
3. **Regresión ordinal** (`clm`), para respuestas de un solo indicador ordinal. Modela probabilidades
   acumuladas, se interpreta con razones de momios y asume odds proporcionales (verificable).

Dos ideas transversales cierran la secuencia. La primera: la elección del modelo se decide por la **naturaleza
de la variable respuesta** y la comprobación de los supuestos, nunca por el resultado buscado. La segunda, y
más importante: el modelo entrega números, pero **interpretarlos es un acto de juicio**, no un trámite. Un
coeficiente no significativo no prueba que no haya efecto; un control estadístico no vuelve causal una
relación; y la estadística no se hace por sí misma, sino para informar con honestidad una pregunta que la
precede.