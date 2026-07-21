# gpu-runtime

Runtime genérico de reproducibilidad y diagnóstico para simulación estadística
a gran escala en GPU. Aporta dos piezas de infraestructura independientes del
modelo que se simule:

- **`gpu_runtime.doctor`** — diagnóstico estricto del entorno de ejecución:
  entorno Conda consistente con el intérprete, sin contaminación de
  `VIRTUAL_ENV` ni `PYTHONPATH`, y (si se exige GPU) CuPy con al menos un
  dispositivo CUDA y VRAM utilizable. Falla temprano con mensajes accionables;
  nunca degrada en silencio.
- **`gpu_runtime.crn`** — números aleatorios comunes (CRN) por bloques:
  cada bloque se deriva de `(seed, batch_index)` con SplitMix64 y se genera
  con Philox, de modo que cualquier bloque es regenerable de forma
  independiente y determinista, sin materializar el cubo completo. En GPU se
  rechaza todo bloque que supere el 80% de la VRAM libre.

## Qué NO es

Este componente **no contiene el motor del estudio** ni lógica estadística
sustantiva: no hay aquí definición de indicadores, reglas de política ni
cálculo de resultados. Es solo infraestructura de ejecución reutilizable.

## Requisitos

Python ≥ 3.11 con NumPy y pytest. CuPy es opcional: sin CuPy funcionan la ruta
CPU (acotada a bloques chicos, pensada para pruebas) y el benchmark con
`--cpu-only`. Ver `environment/environment.yml` en la raíz del repositorio.

## Uso

Desde este directorio (`src/gpu-runtime/`):

```bash
# Diagnóstico del entorno (exige GPU; use --cpu para validar solo el intérprete)
python cli.py doctor
python cli.py doctor --cpu --json
python cli.py doctor --expected-env rapids

# Benchmark CPU vs GPU de un bloque CRN sintético
python cli.py benchmark
python cli.py benchmark --cpu-only --batch-sims 64 --units 2000 --variables 10

# Tests (los que requieren GPU se omiten con motivo explícito si no hay CUDA)
pytest
```

Ambos subcomandos emiten JSON en la salida estándar (o un resumen legible en
`doctor` sin `--json`) y, ante cualquier problema, un error JSON estructurado
por stderr con código de salida 2.
