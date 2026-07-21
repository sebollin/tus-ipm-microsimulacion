# Efecto de aumentos de la Tarjeta Uruguay Social sobre la pobreza multidimensional
## Síntesis ejecutiva

> **Autor:** Lic. Sebastián Lucas
> 
> **Julio de 2026**
> 
> **Marco:** proyección predictiva condicionada a supuestos; el estudio no estima
> efectos causales.

Este estudio estima, mediante microsimulación sobre los microdatos oficiales de la
Encuesta Continua de Hogares (ECH) 2025, cómo cambiaría la **pobreza multidimensional**
de Uruguay ante distintos aumentos del monto de la **Tarjeta Uruguay Social (TUS)**,
incluida la política ya decidida para 2026 sobre el Bono Crianza. La pobreza
multidimensional se mide con el instrumento oficial del país: el **Índice de Pobreza
Multidimensional (INE, 2024)**. El resultado central: un aumento del 50% de la TUS
($2.811 millones anuales) reduciría la incidencia de pobreza multidimensional en **2,44
puntos porcentuales entre las personas beneficiarias** y 0,25 puntos a nivel nacional —
la diferencia entre ambas lecturas no es una contradicción sino la aritmética de una
política focalizada. El estudio también identifica dónde el dinero no alcanza: tres
carencias que piden políticas sectoriales además del ingreso.

## 1. Cómo se mide la pobreza multidimensional

**El instrumento de medición.** La pobreza multidimensional puede medirse de muchas
maneras; este estudio utiliza el **Índice de Pobreza Multidimensional (INE, 2024)** —
el oficial de Uruguay: quince indicadores de privación en cinco dimensiones (educación,
vivienda, servicios básicos, empleo y protección social), con umbral de cuatro o más
privaciones para identificar a un hogar como pobre.

**Las tres métricas del índice y la pregunta que responde cada una:**

| Métrica | La pregunta | En palabras |
|---|---|---|
| **Incidencia de pobreza (H)** | *¿Cuántos son pobres?* | Qué proporción de la población vive en hogares con 4 o más de las 15 privaciones. H = 18,7% → casi 1 de cada 5 personas. |
| **Intensidad (A)** | *¿Qué tan pobres son los pobres?* | Entre quienes SON pobres, qué porcentaje de las privaciones posibles sufren en promedio. A = 33,4% → el pobre típico acumula 5 de las 15 carencias. Puede bajar aunque nadie salga de la pobreza: basta que los pobres sufran menos privaciones. |
| **IPM** | *¿Cuánta pobreza hay en total?* | Las dos cosas juntas: IPM = H × A. Baja si salen hogares de la pobreza o si los que quedan están menos privados. Por eso es la medida más completa. |

- Los efectos están en **puntos porcentuales (pp)**: si H pasa de 18,71% a 18,46%, bajó
  0,25 pp (que acá equivale a ~9.000 personas cruzando el umbral).
- Cada resultado tiene **dos lentes**: la **nacional** (todo el país, diluida porque la
  mayoría no recibe TUS) y la de **beneficiarios** (los hogares que sí — la lectura
  sustantiva de una política focalizada).
- Cada efecto lleva **dos incertidumbres separadas**: el intervalo de diseño (¿y si el
  INE hubiera sorteado otra muestra de hogares?) y la banda de simulación (variación
  interna del método Monte Carlo). Un intervalo que cruza el 0 indica un efecto no
  distinguible de la ausencia de efecto.

## 2. El estudio y por qué es válido

El estudio combina dos piezas: (i) quince modelos predictivos —uno por cada privación del
IPM— que aprenden de los datos cómo se relaciona el ingreso de los hogares con cada
carencia; y (ii) una microsimulación Monte Carlo que aplica los aumentos hipotéticos de
TUS al ingreso de los hogares beneficiarios y recalcula las métricas oficiales,
respetando cómo se correlacionan las privaciones entre sí.

**La ECH es el mejor instrumento disponible para esta pregunta**: es la encuesta oficial
del INE, representativa de todo el país, y la única fuente que combina en los mismos
hogares los ingresos, las quince privaciones del IPM y los montos de transferencias
completados con registros administrativos. Un diseño de panel o un registro longitudinal
serían superiores para medir efectos en el tiempo, pero exceden el alcance institucional
actual; la ECH —con sus ponderadores replicados oficiales para cuantificar la precisión—
permite evaluar escenarios de manera rigurosa y reproducible. La metodología es válida
porque antes de proyectar reproduce lo observable: replica las cifras oficiales del
Índice de Pobreza Multidimensional (INE, 2024) y valida la reconstrucción de las transferencias contra la información oficial del MIDES
(sección 14), y somete cada componente a verificación automática.

## 3. La línea de base reproduce las cifras oficiales

Antes de proyectar nada, el modelo replica lo observable:

| Métrica 2025 (personas) | Estudio | IC 95% de diseño | Oficial INE | |
|---|---|---|---|---|
| Incidencia (H) | **18,71%** | 17,85–19,57 | 18,7 ±0,9 | ✓ |
| Intensidad (A) | **33,40%** | 32,96–33,83 | 33,4 ±0,4 | ✓ |
| IPM (= H×A) | **0,0625** | 0,0593–0,0656 | 0,063 ±0,003 | ✓ |

En hogares: incidencia (H) 13,92%, intensidad (A) 32,66%, IPM 0,0454. Los **15/15
indicadores** del Cuadro 2 oficial caen dentro del margen publicado, y la reproducción
del año 2024 coincide exactamente con la serie oficial revisada del INE (criterio de
rezago educativo corregido).

## 4. El resultado central: +50% de TUS

| | ΔIncidencia (H) | ΔIntensidad (A) | ΔIPM |
|---|---|---|---|
| **Beneficiarios** (personas en hogares TUS) | **−2,44 pp** [simulación −3,57; −1,44] | −0,50 pp | −0,0112 |
| **Nacional** | **−0,25 pp** [simulación −0,37; −0,15] [diseño −0,27; −0,23] | −0,16 pp | −0,0012 |

**Costo: $2.811 millones/año.** La brecha entre lentes es aritmética pura, no un defecto:
la TUS cubre por diseño al **6,5% de los hogares** (82.426), que por su mayor tamaño
(4,47 vs 2,82 personas) reúnen el **10,3% de las personas** — y 2,44 pp × 0,103 = 0,25 pp.
El efecto nacional ES el efecto sobre beneficiarios repartido sobre todo el país.

## 5. La curva completa de escenarios

Efectos como diferencias pareadas contra el escenario sin aumento; banda de simulación
(percentiles 2,5–97,5):

| Aumento TUS | ΔIncidencia (H) nacional (pp) | Costo anual | Eficiencia (pp por $1.000M/año) |
|---|---|---|---|
| +10% | −0,051 | $562M | 0,091 |
| **+50%** | **−0,250** | **$2.811M** | **0,089** |
| +100% | −0,488 | $5.623M | 0,087 |
| +150% | −0,710 | $8.434M | 0,084 |
| +300% | −1,293 | $16.868M | 0,077 |
| +1000% | −2,902 | $56.227M | 0,052 |

**Lectura:** el dinero rinde de forma casi constante hasta aumentos de ~100–150% (~0,09
pp por cada $1.000 millones anuales); los rendimientos decrecientes aparecen con claridad
después. Los escenarios de +500% en adelante son tendenciales, no propuestas factibles.

## 6. Cuánto importa más que cómo (reglas de reparto)

Con el mismo presupuesto del +50% ($2.811M/año), cinco formas de repartirlo entre los
hogares TUS actuales dan ΔH nacional entre −0,241 y −0,263 pp (rango 0,021 pp): **las
diez comparaciones pareadas entre reglas incluyen el cero en sus intervalos**: ninguna
diferencia es separable del ruido de simulación. **Conclusión: la regla de asignación es
de segundo orden; el tamaño del presupuesto es la variable de primer orden.**

La excepción separable: **extender cobertura** con ese presupuesto rinde menos en estas
métricas (−0,115 pp) — pero la extensión responde a objetivos que el IPM no captura (piso
de protección, equidad de acceso), y así corresponde informarla.

## 7. Dónde actúa el dinero y dónde no

La respuesta de los 15 indicadores al ingreso es monótona en todos, pero de magnitud muy
distinta. Con la clasificación preestablecida:

- **12 indicadores muestran respuesta intermedia**: encabezan problemas de vivienda,
  acceso a internet, baja escolaridad e informalidad.
- **3 indicadores quedan bajo el umbral de respuesta** ("No asistencia", "Sin pensión",
  "Menores sin protección"): señal de que esas privaciones piden **políticas
  sectoriales** además del ingreso — resultado central para no sobre-prometer.

## 8. Sobre quiénes: concentración por quintil

La pobreza multidimensional está fuertemente concentrada: en el quintil de menores
ingresos la incidencia es **47,1%** de las personas (contra 18,7% nacional), y ahí se
concentra también el efecto de los aumentos (−0,93 pp con +50%, contra −0,05 o menos en
los quintiles 3 a 5).

## 9. Contraste con pobreza monetaria

La pobreza monetaria parte de 16,6% de personas (55,0% entre beneficiarios TUS —
recordatorio de a quién llega la tarjeta). Ante +50%: −0,40 pp nacional y **−3,85 pp en
beneficiarios** — responde más fuerte que el IPM porque el ingreso adicional cruza la
línea de pobreza *por definición*. El IPM exige que cambien las privaciones concretas:
por eso es la métrica exigente y la principal de este estudio.

## 10. Bono Crianza: componentes y escenarios

El estudio identificó y documentó que los montos TUS observados en la encuesta contienen,
además del tarifario común, componentes adicionales cargados en la tarjeta: **Bono
Crianza ($2.226 por menor de 0 a 3 años en 2025)**, el adicional TUS ($447), y
prestaciones especiales. Esta descomposición —verificada contra publicaciones oficiales
del MIDES y validada empíricamente en el 95,7% de los montos administrativos— permitió
construir escenarios específicos del Bono y estimar el tipo de tarjeta (simple/doble) de
cada hogar.

Escenarios (universo: 24.702 hogares TUS con menores de 0–3, 27.938 menores; cota
inferior porque la encuesta no identifica embarazadas, que también perciben el Bono):

| Escenario | Costo anual | ΔIncidencia (H) beneficiarios | ΔIncidencia (H) nacional |
|---|---|---|---|
| Prestación $2.226 | $746M | −2,04 pp | −0,071 pp |
| Prestación por tipo: $2.226/$3.339 | $941M | −2,74 pp | −0,089 pp |
| **Aumento 2026: +$557/+$1.113** | **$284M** | **−0,83 pp** [diseño −0,90; −0,75] | −0,027 pp |

**El escenario 2026 en palabras** (la política ya decidida, evaluada sobre la ECH 2025
previa al aumento): la proyección indica que unos **204 de los 24.702 hogares
beneficiarios** dejarían la pobreza multidimensional (~965 personas a escala nacional), y
el **IPM del grupo baja de forma consistente** (ambas fuentes de incertidumbre excluyen
el cero). La intensidad casi no se mueve: el aumento saca hogares del umbral más de lo
que reduce la brecha de quienes siguen debajo. Como contexto presupuestal equivale al
5,0% del gasto TUS anual — referencia, no resultado de bienestar. El tipo de tarjeta es
una estimación a partir del monto observado (validada al peso en 189 de los 279 hogares
muestrales del universo), no el registro administrativo.

## 11. Cobertura del sistema focalizado

La segmentación de hogares (tres grupos, estable ante remuestreo) identifica un **grupo
vulnerable de 387.495 hogares** — con el mayor nivel de privaciones: score IPM 0,160,
~1,9 veces el promedio de los otros dos grupos —, del cual 47,9% recibe TUS o AFAM-PE y
52,1% no. **Lectura correcta:** esto no es una falla de la TUS — el programa está
diseñado para los ~100.000 hogares más pobres; el dato describe el mapa de instrumentos
sobre la población vulnerable. La especificación de la segmentación fue sometida a un
análisis de sensibilidad con 40 variables candidatas y resultó robusta.

## 12. El índice de focalización (ICC) y el IPM

El Índice de Carencias Críticas —el instrumento real con el que se focaliza la TUS— fue
replicado y validado exactamente contra la implementación oficial. Su relación con el
IPM: **asociación alta pero no intercambiable** (correlación de rangos ponderada 0,71 en
personas). Las discordancias son esperables por diseño: 13,2% de las personas son
pobres-IPM sin ser elegibles TUS por ICC y 1,5% lo inverso — composición distinta, no
error de ningún instrumento. El ICC se utiliza como lente descriptiva, no como insumo de
los modelos.

## 13. El estudio en figuras (ideas fuerza)

Las diez figuras del estudio, cada una con su idea fuerza. Todas existen además en
versión interactiva (con valores exactos por escenario) y en PDF vectorial para
impresión.

1. **El aumento rinde donde llega**: las tres métricas — incidencia (H), intensidad (A),
   IPM — por tamaño de aumento, en dos lentes con sus dos incertidumbres y el costo anual
   arriba. Se ve que el efecto nacional y el de beneficiarios son EL MISMO resultado: los
   beneficiarios son el 10% de la población, y el promedio país lo diluye exactamente en
   esa proporción.
   ![Figura 1](../figures/png/01_el_aumento_rinde_donde_llega.png)

2. **La pobreza — y el efecto — viven en el quintil más pobre**: casi la mitad del
   quintil 1 está en pobreza multidimensional y el aumento actúa casi exclusivamente ahí.
   Incluye la intensidad (A) por quintil — la única lectura de "qué tan pobres son los
   pobres" desagregada del estudio.
   ![Figura 2](../figures/png/02_pobreza_y_efecto_por_quintil.png)

3. **Dónde actúa el dinero — y dónde no**: cada carencia con dos lecturas alineadas —
   cuánto caería su prevalencia con el escenario central y qué proporción de hogares la
   presenta hoy. Doce muestran respuesta intermedia y tres ("No asistencia", "Sin
   pensión", "Menores sin protección") quedan bajo el umbral: el límite honesto de la
   transferencia.
   ![Figura 3](../figures/png/03_donde_actua_el_dinero.png)

4. **De qué está hecha la pobreza — y qué parte se mueve**: el aporte de cada dimensión
   al IPM (las carencias de empleo y de educación encabezan) y cuánto lo reduce el
   aumento.
   ![Figura 4](../figures/png/04_de_que_esta_hecha_la_pobreza.png)

5. **Instrumentos distintos, poblaciones que se solapan**: el índice con el que se
   focaliza la TUS (ICC) y el que mide la pobreza (IPM) clasifican parecido pero no
   igual — por diseño, no por error.
   ![Figura 5](../figures/png/05_instrumentos_y_poblaciones.png)

6. **Bono Crianza 2026: qué cambia para quienes lo reciben**: la política ya decidida —
   ~204 de los 24.702 hogares beneficiarios dejarían la pobreza multidimensional y el IPM
   del grupo baja de forma consistente, con las dos incertidumbres separadas y todos los
   valores rotulados.
   ![Figura 6](../figures/png/06_bono_crianza_2026.png)

7. **Cuánto rinde el gasto — y cómo repartirlo**: la eficiencia cae con dosis mayores, y
   a presupuesto fijo las diez comparaciones pareadas entre reglas de reparto cruzan el
   cero. El cuánto importa; el cómo, casi no.
   ![Figura 7](../figures/png/07_cuanto_rinde_y_como_repartir.png)

8. **Las conclusiones no penden de un supuesto**: el resultado central recalculado
   cambiando el umbral que define quién es pobre, con la elección del estudio destacada.
   Las diferencias son de centésimas.
   ![Figura 8](../figures/png/08_conclusiones_y_supuestos.png)

9. **El mapa de la cobertura**: del grupo más vulnerable (387 mil hogares), 47,9% recibe
   TUS o AFAM-PE. Las dos barras comparten la misma escala: la de arriba es el zoom al
   bloque azul de abajo. División de tareas entre instrumentos — no una "falla".
   ![Figura 9](../figures/png/09_mapa_de_la_cobertura.png)

10. **Dos varas, una historia**: la pobreza monetaria responde más rápido porque sumar
    ingreso cruza la línea por definición; el IPM exige que cambien las privaciones
    concretas. Se ve por qué este estudio usa la vara exigente.
    ![Figura 10](../figures/png/10_dos_varas_una_historia.png)

## 14. Solidez metodológica y validación

**Verificaciones realizadas, todas automatizadas y reproducibles:**

- La reconstrucción de las transferencias coincide fila por fila con la base oficial del
  MIDES (55.395 personas; las divergencias — menos del 0,1% — están enumeradas y
  explicadas una por una).
- La línea de base replica las cifras oficiales del INE 2025 en las tres métricas y en
  los 15 indicadores, y reproduce exactamente la serie oficial revisada de 2024.
- Prueba de escenario nulo: simular "0% de aumento" no altera la realidad observada
  (diferencia de 0,11 puntos porcentuales, por debajo del criterio de aceptación fijado
  de antemano).
- Validación fuera de muestra: el modelo estimado con la ECH 2025 predice correctamente
  la ECH 2024, que no participó de ninguna decisión de modelado.
- Convergencia verificada: cuadruplicar el número de simulaciones cambia el resultado en
  0,00013 pp.
- Sensibilidad: las conclusiones se mantienen al cambiar el umbral de pobreza y las
  demás elecciones metodológicas evaluadas; las dos fuentes de incertidumbre (muestral y
  de simulación) se reportan siempre por separado.
- Más de 500 pruebas automáticas acompañan el proceso completo. Los microdatos y las
  implementaciones reservadas no son redistribuibles: lo reproducible públicamente —
  las figuras y las verificaciones sobre los resultados agregados — está incluido en
  este repositorio.

**Límites declarados (los caveats que acompañan cada cifra):** es una proyección
predictiva sobre datos transversales — no hay contrafactual observado, ni dinámica
temporal, ni efectos de segundo orden (oferta, precios, comportamiento); la dependencia
entre indicadores se calibra en la misma encuesta; las embarazadas beneficiarias del Bono
no son observables en la ECH (los universos son cota inferior); un panel o registro
longitudinal sería superior y excede el alcance actual.

## 15. Conclusiones

1. **La focalización funciona: el efecto vive donde llega el instrumento.** Un aumento
   del 50% de la TUS reduce la incidencia de pobreza multidimensional en 2,44 pp entre
   las personas beneficiarias. El promedio nacional (−0,25 pp) no lo desmiente: es el
   mismo efecto repartido sobre diez veces más personas.
2. **El presupuesto es la variable de primer orden; la regla de reparto, de segundo.**
   Cinco formas de distribuir el mismo dinero entre los beneficiarios actuales resultan
   estadísticamente indistinguibles entre sí.
3. **El dinero rinde de forma casi constante hasta aumentos de ~100–150%**; después
   aparecen rendimientos decrecientes claros.
4. **La transferencia tiene un límite honesto**: la asistencia escolar, las pensiones y
   la protección social de menores casi no responden al ingreso. Reducir esas carencias
   requiere políticas sectoriales.
5. **El aumento 2026 del Bono Crianza tendría un efecto real y medible en su población**:
   unos 204 de los 24.702 hogares beneficiarios dejarían la pobreza multidimensional y el
   IPM del grupo baja de forma consistente, con un costo anual de $284 millones (5% del
   gasto TUS).
6. **El IPM es la vara exigente, y por eso la principal**: la pobreza monetaria responde
   mecánicamente al ingreso; el IPM solo baja si cambian las privaciones concretas de los
   hogares.
7. Todo lo anterior es una **proyección condicionada a supuestos** — validada contra las
   cifras oficiales, sometida a pruebas de robustez y con sus límites declarados — sobre
   el mejor instrumento disponible hoy: la Encuesta Continua de Hogares 2025.
