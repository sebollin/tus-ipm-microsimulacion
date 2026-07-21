# Resultados agregados

Todo lo que hay en `results/` son **agregados estadísticos**: cada fila resume un
escenario, un quintil, un indicador o un universo de análisis completo. No existe
en este repositorio ningún dato a nivel de persona u hogar.

Convenciones comunes:

- **Universos**: `personas` (población nacional), `hogares` (hogares del país),
  `beneficiarios` (personas u hogares que reciben la transferencia según el caso).
- **Métricas del IPM** (INE, 2024; método Alkire–Foster): `H` incidencia (% de
  pobres multidimensionales), `A` intensidad (% promedio de privaciones entre los
  pobres), `M0` índice ajustado (M0 = H × A, en escala 0–1).
- **Efectos**: prefijo `d` = cambio respecto de la línea de base; `pp` = puntos
  porcentuales. Ejemplo: `dH_pp_personas` es el cambio de la incidencia nacional
  en personas, en puntos porcentuales.
- **Incertidumbre**: `p2_5` / `p97_5` delimitan el intervalo del 95% por
  Monte Carlo; `se_mc` es el error estándar de simulación; las columnas `diseno_*`
  traen la estimación e intervalo por diseño muestral (replicación). Cuando figura
  `*_excluye_cero`, indica si el intervalo correspondiente excluye el cero.
- **Escenarios**: los códigos numéricos (10–1000) son el aumento porcentual
  simulado de la transferencia; 0 es la línea de base.
- Separador decimal punto (formato CSV estándar); los documentos usan coma.

## `aggregate/figure-data/` — payloads de las figuras

Diez archivos JSON, uno por figura, con esquema uniforme:

```json
{ "records": [ ... filas agregadas que dibuja la figura ... ],
  "spec":    { "kind": "...", "title": "...", "subtitle": "...", "note": "..." } }
```

Son exactamente los datos embebidos en las figuras interactivas de `site/figures/`
(cada HTML declara el SHA-256 de su payload en `data-sha256`, verificable contra
estos archivos). Los renderers de `src/figures/` reconstruyen las figuras
estáticas leyendo estos payloads junto con las tablas de `aggregate/tables/`.

## `aggregate/tables/` — tablas del estudio

| Archivo | Grano (una fila =) | Contenido |
|---|---|---|
| `escenarios_efectos_ipm.csv` | escenario | Efectos de cada aumento sobre H, A y M0, en personas y hogares, con intervalos Monte Carlo. Tabla central del estudio. |
| `efectos_por_quintil_ingreso.csv` | quintil × escenario | Niveles y cambios de H, A y M0 por quintil de ingreso equivalente, con población expandida. |
| `escenarios_pobreza_monetaria.csv` | escenario | Efecto de los mismos aumentos sobre la pobreza monetaria (personas, hogares, beneficiarios). |
| `bono_crianza_escenarios.csv` | escenario del Bono | Efectos del Bono Crianza y su aumento 2026 sobre el IPM, con costo anual. |
| `bono_crianza_aumento_2026.csv` | métrica × universo | Detalle del escenario de aumento 2026 del Bono Crianza con intervalos Monte Carlo y de diseño. |
| `reglas_presupuesto_fijo.csv` | regla de asignación | Comparación de reglas de reparto a presupuesto constante (uniforme, suma fija, focalizadas), con rendimiento por cada 1.000 millones. |
| `contrastes_pareados_reglas.csv` | par de reglas × métrica | Diferencias pareadas entre reglas de asignación con intervalos del 95% y si son separables de cero. |
| `convergencia_montecarlo.csv` | tamaño de simulación | Diagnóstico de convergencia: estimaciones e intervalos según el número de simulaciones Monte Carlo. |
| `sensibilidad_umbral_k.csv` | umbral k | Sensibilidad de los efectos al umbral de identificación del IPM (k privaciones de 15). |
| `sensibilidad_definicion_ingreso.csv` | definición de ingreso | Sensibilidad de los efectos a la definición de ingreso empleada. |
| `curvas_respuesta_indicadores.csv` | indicador × escenario | Probabilidad predicha de privación de cada indicador a lo largo de la grilla de aumentos (0 a +50%). |
| `clasificacion_respuesta_indicadores.csv` | indicador | Clasificación de los 15 indicadores según cuánto responden a la transferencia (prevalencia base, reducción total y por tramo, monotonía). |
| `descomposicion_dimensiones.csv` | escenario × universo × dimensión | Aporte de cada dimensión del IPM al cambio total, con intervalos. |
| `descomposicion_indicadores.csv` | escenario × universo × indicador | Cambio de la incidencia censurada y no censurada de cada indicador y su contribución al cambio de M0. |

Fuente de todos los valores: microsimulación del estudio sobre la ECH 2025 con la
línea de base validada contra las cifras oficiales del INE. Los universos, la
mecánica de simulación y las limitaciones están descritos en el README principal
y en `report/`.
