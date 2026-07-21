"""Runtime genérico para simulación en GPU: diagnóstico de entorno y CRN.

Componentes de infraestructura independientes del modelo que se simule:
verificación estricta del entorno de ejecución (Conda, CuPy, CUDA, VRAM)
y generación reproducible de números aleatorios comunes por bloques.
"""

from gpu_runtime.crn import (
    CRNBatch,
    derive_batch_seed,
    generate_crn_batch,
    iter_crn_batches,
)
from gpu_runtime.doctor import DoctorError, collect_diagnostics

__version__ = "1.0.0"

__all__ = [
    "CRNBatch",
    "DoctorError",
    "collect_diagnostics",
    "derive_batch_seed",
    "generate_crn_batch",
    "iter_crn_batches",
    "__version__",
]
