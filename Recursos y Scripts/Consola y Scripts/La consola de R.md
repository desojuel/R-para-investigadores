# La Consola de R 

## 1. ¿Qué es la consola?

La consola es la ventana interactiva donde R **interpreta** y **ejecuta** las instrucciones que le escribimos. Es el canal directo de comunicación entre tú y R.

Cuando abres R o RStudio, la consola aparece lista para recibir comandos. Todo lo que escribas ahí se evalúa inmediatamente al presionar `Enter`.

La consola no guarda el trabajo. Todo lo que se escribe en la consola de R es temporal. Cuando se cierra R, los comandos ejecutados y los resultados desaparecen.

---

## 2. Operaciones en la consola

La consola puede ejecutar operaciones aritméticas, lógicas y de asignación de forma directa:

```r
# Aritméticas
2 + 2
10 / 3
5 ^ 2

# Lógicas
3 > 2
10 == 10
TRUE & FALSE

# Asignación
x <- 42
nombre <- "Hola mundo"
```
---

## 3. El prompt `>` 

### El prompt `>`

El símbolo `>` al inicio de la línea significa que R **está listo** para recibir un nuevo comando.

```
> 2 + 2
[1] 4
>
```

---

## 4. Resultados en la consola

Cuando R ejecuta un comando, imprime el resultado precedido por un índice entre corchetes que indica la **posición del primer elemento** en esa línea.

```
> 100 + 50
[1] 150
```
El `[1]` significa que `150` es el primer (y único) elemento del resultado. En vectores más largos verás varios índices:

```
> 1:30
 [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
[16] 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
```

Aquí `[16]` indica que el `16` es el elemento número 16 del vector.

---

### 5. El signo `+`

Si R muestra `+` en lugar de `>`, significa que tu comando **está incompleto** y R espera que lo termines. Esto ocurre cuando falta cerrar un paréntesis, una comilla o una llave.

```
> sum(1, 2,
+    3)
[1] 6
```

Si te quedas atrapado en un `+` y no sabes cómo completar el comando, presiona `Esc` para cancelar y volver al prompt `>`.

---

## 6. Flechas arriba ⬆️ y abajo ⬇️

Las flechas del teclado te permiten **navegar por el historial de comandos** que ya ejecutaste:

- **⬆️ Arriba**: recupera el comando anterior.
- **⬇️ Abajo**: avanza al comando siguiente (más reciente).

Esto es extremadamente útil para re-ejecutar o modificar algo que acabas de escribir sin tener que tipearlo de nuevo.

### Ejemplo

```
> mean(c(10, 20, 30))        # Ejecutas esto
[1] 20

> # Presionas ⬆️ y aparece automáticamente:
> mean(c(10, 20, 30))        # Ahora puedes editarlo antes de ejecutar

> # Lo modificas a:
> mean(c(10, 20, 30, 40))
[1] 25
```

Puedes presionar ⬆️ varias veces seguidas para ir más atrás en el historial.

---

## 6. Atajos de teclado en la consola

Tres atajos esenciales para moverte rápido dentro de la línea de comandos:

| Atajo | Acción |
|---|---|
| `Ctrl + L` | **Limpia** la pantalla de la consola (el historial se conserva, solo se limpia lo visual) |
| `Ctrl + A` | Mueve el cursor al **inicio** de la línea |
| `Ctrl + E` | Mueve el cursor al **final** de la línea |

### Ejemplo

Imagina que escribiste un comando largo y necesitas corregir algo al inicio:

```
> resultados <- mean(c(10, 20, 30, 40, 50, 60, 70))
                                                    ^ cursor aquí
```

1. Presionas `Ctrl + A` → el cursor salta al inicio, justo antes de `resultados`.
2. Corriges el nombre de la variable.
3. Presionas `Ctrl + E` → el cursor vuelve al final para seguir escribiendo o ejecutar.

Y cuando tu consola se llena de resultados anteriores y quieres empezar visualmente limpio, `Ctrl + L` despeja todo sin borrar tu historial ni tus variables.

---

## 7. Detener un proceso en ejecución

Si un proceso tarda demasiado o entraste en un loop infinito, puedes detenerlo con:

```
Esc       (en RStudio)
Ctrl + C  (en la terminal / consola de R)
```

### Ejemplo

```r
# Proceso que tarda mucho
x <- rnorm(1e10)   # Intentar generar 10 mil millones de números

# Si ves que tarda demasiado o se come toda la memoria:
# → Esc o Ctrl + C para detenerlo
# → También se puede presionar el signo de STOP que aparece en la esquina superior derecha de la consola
```

Después de interrumpir, RStudio vuelve al estado normal y puedes seguir trabajando.

---

## 8. Warnings, errores y mensajes

R se comunica contigo de tres formas distintas cuando algo requiere tu atención. Es importante distinguirlas:

### ❌ Errores (`Error`)

El comando **no se pudo ejecutar**. Algo está mal y R se detuvo. Debes corregirlo.

```r
> log("hola")
Error in log("hola") : non-numeric argument to mathematical function

> mean(datos)
Error in mean(datos) : object 'datos' not found
```

### ⚠️ Advertencias (`Warning`)

El comando **sí se ejecutó**, pero R quiere avisarte que algo podría no estar bien. El resultado existe, pero revísalo.

```r
> log(-1)
[1] NaN
Warning message:
In log(-1) : NaNs produced

> as.numeric(c("1", "2", "abc"))
[1]  1  2 NA
Warning message:
NAs introduced by coercion
```

### ℹ️ Mensajes (`message`)

Información general que R o un paquete te comparte. **No hay ningún problema**; es solo contexto.

```r
> library(dplyr)

Attaching package: 'dplyr'

The following objects are masked from 'package:stats':

    filter, lag

> read.csv("datos.csv")
# Algunos paquetes imprimen mensajes sobre cómo leyeron el archivo
```

### Resumen rápido

| Tipo | ¿Se ejecutó? | ¿Qué hacer? |
|---|---|---|
| **Error** | ❌ No | Corregir el código |
| **Warning** | ✅ Sí | Revisar que el resultado tenga sentido |
| **Mensaje** | ✅ Sí | Leer y continuar |

---

> **Tip final:** La consola es tu laboratorio. No tengas miedo de experimentar: lo peor que puede pasar es un error, y los errores son la mejor forma de aprender.