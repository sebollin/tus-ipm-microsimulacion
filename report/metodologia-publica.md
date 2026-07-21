# Nota metodológica

Este documento describe cómo está construido el estudio: sus datos, su forma de
medir la pobreza, la mecánica de simulación y el tratamiento de la incertidumbre.
Está escrito para poder leerse sin formación estadística previa; los términos
técnicos están definidos en el [glosario](glosario.md).

## 1. Pregunta y enfoque

El estudio estima qué pasaría con la pobreza multidimensional en Uruguay si se
aumentara el monto de la Tarjeta Uruguay Social (TUS), recorriendo una grilla de
escenarios que va desde +10% hasta +1000%. El enfoque es **predictivo, no
causal**: proyecta los niveles de pobreza que serían coherentes con un ingreso
mayor en los hogares beneficiarios, según los patrones observados en los datos.
No estima el efecto de un experimento ni incorpora respuestas de comportamiento,
precios u oferta de servicios.

## 2. Datos

La fuente es la **Encuesta Continua de Hogares (ECH) 2025** del INE — la
encuesta oficial de hogares del país, representativa de toda la población. Sobre
esa base, el análisis identifica a los hogares beneficiarios de transferencias
(TUS, AFAM-PE, Bono Crianza) con apoyo de información administrativa.

> **Frontera de datos.** Los microdatos empleados en el análisis no son
> redistribuibles: la ECH pública puede descargarse del catálogo del INE, pero la
> variante enriquecida con información administrativa no puede publicarse. Este
> repositorio contiene exclusivamente resultados agregados (ver `results/`).

## 3. Medición de la pobreza

La pobreza multidimensional se mide con el **Índice de Pobreza Multidimensional
(INE, 2024)**, construido con el método de Alkire y Foster (2011). En su versión
oficial: 15 indicadores agrupados en 5 dimensiones; una persona es pobre
multidimensional si su hogar acumula **4 o más privaciones de 15**; y el índice
se resume en tres métricas — la incidencia **H** (qué porcentaje de personas es
pobre), la intensidad **A** (cuántas privaciones promedio sufren los pobres) y el
índice ajustado **M0 = H × A**. El estudio calcula además la **pobreza monetaria**
oficial (ingreso del hogar contra la línea de pobreza) como métrica complementaria.

La implementación del cálculo replica la metodología publicada por el INE y su
línea de base se valida contra las cifras oficiales (ver §6).

## 4. Mecánica de la microsimulación

Para cada escenario de aumento, el ciclo es el mismo:

```mermaid
flowchart LR
    A["ECH 2025<br/>(INE)"] --> B["Identificación de<br/>beneficiarios<br/>⛔ reservado"]
    B --> C["Aumento simulado<br/>del monto TUS"]
    C --> D["Ingreso del hogar<br/>actualizado"]
    D --> E["Modelos predictivos:<br/>indicadores sensibles<br/>al ingreso"]
    E --> F["Recálculo del IPM<br/>⛔ implementación<br/>reservada"]
    F --> G["Agregación ponderada<br/>e incertidumbre<br/>(GPU)"]
    G --> H["Resultados agregados<br/>→ este repositorio"]
```

1. **Aumento del monto.** El escenario incrementa la transferencia de cada hogar
   beneficiario y actualiza su ingreso.
2. **Respuesta de los indicadores.** Los indicadores del IPM que dependen del
   ingreso responden mediante modelos predictivos estimados en los propios datos;
   los indicadores estructurales (por ejemplo, los ligados a la vivienda o al
   entorno) se mantienen fijos, lo que hace a la proyección deliberadamente
   conservadora.
3. **Recálculo y agregación.** Con los indicadores actualizados se recalculan H,
   A y M0 usando los pesos muestrales, tanto para el total del país como para el
   universo de beneficiarios.

El volumen de cómputo (escenarios × réplicas × simulaciones sobre decenas de
miles de hogares) se resuelve en GPU, con **números aleatorios comunes** (misma
semilla por unidad entre escenarios) para que las diferencias entre escenarios no
contengan ruido de simulación. Los componentes genéricos de esa infraestructura
están publicados en `src/gpu-runtime/`.

## 5. Incertidumbre: dos bandas separadas

Cada efecto se reporta con dos fuentes de incertidumbre que no se mezclan:

- **Intervalo de diseño**: cuánto variaría la estimación si el INE hubiera
  sorteado otra muestra de hogares (replicación de la muestra).
- **Banda Monte Carlo (95%)**: cuánto varía la proyección por la aleatoriedad de
  los modelos predictivos (miles de simulaciones; la convergencia está
  documentada en `results/aggregate/tables/convergencia_montecarlo.csv`).

## 6. Validación de la línea de base

Antes de simular nada, el escenario base (sin aumento) debe reproducir las cifras
oficiales: la incidencia, la intensidad y el índice publicados por el INE para
2025, y la incidencia de cada uno de los 15 indicadores, quedan dentro de los
márgenes de las cifras oficiales vigentes. Esa es la condición de partida del
estudio: si la base no replica lo oficial, ningún efecto simulado es creíble.

## 7. Qué es reproducible públicamente

| | Estado |
|---|---|
| Reconstruir las 10 figuras desde los agregados publicados | ✅ `src/figures/` |
| Verificar la integridad de los payloads de las figuras | ✅ SHA-256 embebido en cada HTML |
| Ejecutar y testear el runtime GPU genérico | ✅ `src/gpu-runtime/` |
| Re-ejecutar el análisis completo desde microdatos | ❌ requiere datos e implementaciones no redistribuibles |

## 8. Limitaciones

- Los datos son transversales: la proyección no captura trayectorias de los
  hogares en el tiempo.
- El enfoque es predictivo: no debe leerse como efecto causal de una política.
- No se modelan respuestas de comportamiento, cambios de precios ni de oferta de
  servicios.
- Los indicadores estructurales se mantienen fijos, por lo que los efectos
  proyectados son un piso razonable antes que un techo.
- La focalización simulada hereda las reglas vigentes de los programas; los
  escenarios de reglas alternativas son ejercicios contables a presupuesto
  constante.

## 9. Bloques reservados

Tres implementaciones no se publican por tratarse de información no pública:
la identificación de beneficiarios en los microdatos (enlace con registros
administrativos), la implementación del cálculo oficial del IPM y el índice de
focalización del MIDES (ICC). El repositorio publica en su lugar la arquitectura
(este documento), los contratos de entrada/salida de cada bloque y todos los
resultados agregados que producen.
