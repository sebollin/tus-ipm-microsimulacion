# Entornos

## R (figuras y verificación)

Paquetes CRAN necesarios — sin dependencias privadas:

| Paquete | Uso |
|---|---|
| `jsonlite` | lectura de los payloads de figuras |
| `digest` | verificación SHA-256 de integridad |
| `ggplot2` (≥ 3.5) | renderers de las diez figuras |

```r
install.packages(c("jsonlite", "digest", "ggplot2"))
```

## Python (runtime GPU genérico)

Especificación Conda en [`environment.yml`](environment.yml): NumPy y pytest como
base (todo corre en CPU); CuPy es opcional y solo hace falta para ejecutar el modo
GPU del diagnóstico y el benchmark.

La integración continua ([workflow](../.github/workflows/verificar.yml)) instala
exactamente estos entornos desde cero en cada push: si el badge está en verde, un
clon limpio puede reproducir todo lo que este repositorio promete.
