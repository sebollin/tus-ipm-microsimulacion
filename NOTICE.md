# Alcance de licencias y materiales de terceros

## Qué cubre cada licencia

| Material | Licencia |
|---|---|
| Código fuente (`src/`, `tests/`) | MIT — ver `LICENSE-CODE` |
| Documentos, figuras y tablas de resultados (`report/`, `figures/`, `results/`, `site/`) | CC BY 4.0 — ver `LICENSE-CONTENT` |
| Metodologías, cifras y publicaciones de terceros citadas | No se relicencian; conservan los términos de sus titulares |

## Materiales de terceros

Este trabajo usa como fuentes públicas — citadas, no redistribuidas — entre otras:

- **INE (Instituto Nacional de Estadística, Uruguay)**: Encuesta Continua de
  Hogares (ECH) y la metodología oficial del Índice de Pobreza Multidimensional
  (2024), incluidas sus cifras publicadas.
- **MIDES (Ministerio de Desarrollo Social, Uruguay)**: información pública
  sobre la Tarjeta Uruguay Social, AFAM-PE y el Bono Crianza.
- **Alkire, S. y Foster, J. (2011)**: método de conteo y descomposición de
  pobreza multidimensional (Journal of Public Economics).

Las referencias completas están en `references/references.bib` y en el README.

## Qué NO contiene este repositorio

- Microdatos de ningún tipo: ni la ECH pública del INE (disponible en su sitio
  oficial) ni ninguna variante enriquecida con registros administrativos.
- Implementaciones de los módulos reservados del estudio (enlace con registros
  administrativos, cálculo oficial del IPM, índice de carencias críticas).

Todas las tablas publicadas son agregados estadísticos sin identificadores;
ver `results/README.md` para el grano y universo de cada una.
