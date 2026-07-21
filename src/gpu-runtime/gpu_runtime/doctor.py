"""Diagnóstico estricto del entorno de ejecución: Conda, CuPy, CUDA y VRAM.

La regla de diseño es fallar temprano y con mensaje claro: si el entorno no
cumple lo pedido, se levanta :class:`DoctorError`; nunca se degrada en
silencio a una configuración distinta de la solicitada.
"""

from __future__ import annotations

import os
import platform
import sys
from pathlib import Path
from typing import Any


class DoctorError(RuntimeError):
    """El entorno no satisface los requisitos de ejecución."""


def _ruta_real(path: str) -> Path:
    return Path(path).expanduser().resolve()


def collect_diagnostics(
    *, expected_env: str | None = None, require_gpu: bool = True
) -> dict[str, Any]:
    """Valida el entorno Conda y, si ``require_gpu``, la GPU y su VRAM.

    Parameters
    ----------
    expected_env:
        Nombre del entorno Conda exigido. Con ``None`` se acepta cualquier
        entorno Conda activo y consistente con el intérprete.
    require_gpu:
        Con ``True`` exige CuPy con al menos un dispositivo CUDA utilizable.
        Con ``False`` valida solo intérprete y NumPy (modo CPU).

    Returns
    -------
    dict
        Diagnóstico estructurado, apto para serializar como JSON.

    Raises
    ------
    DoctorError
        Ante cualquier condición inválida, con mensaje accionable.
    """

    conda_prefix = os.environ.get("CONDA_PREFIX", "").strip()
    if not conda_prefix:
        raise DoctorError(
            "CONDA_PREFIX no está definido; active un entorno Conda antes de ejecutar."
        )
    if _ruta_real(sys.prefix) != _ruta_real(conda_prefix):
        raise DoctorError(
            "Intérprete inconsistente: sys.prefix="
            f"{_ruta_real(sys.prefix)} difiere de CONDA_PREFIX={_ruta_real(conda_prefix)}."
        )
    if expected_env and _ruta_real(conda_prefix).name != expected_env:
        raise DoctorError(
            f"Se exige el entorno Conda {expected_env!r}, pero CONDA_PREFIX apunta a "
            f"{_ruta_real(conda_prefix)}."
        )
    if os.environ.get("VIRTUAL_ENV", "").strip():
        raise DoctorError(
            "VIRTUAL_ENV está activo; no se admite mezclar virtualenv con el entorno Conda."
        )
    if os.environ.get("PYTHONPATH", "").strip():
        raise DoctorError(
            "PYTHONPATH debe estar vacío: una corrida reproducible no admite "
            "inyección externa de módulos."
        )

    try:
        import numpy
    except Exception as exc:  # pragma: no cover - el mensaje es la conducta relevante
        raise DoctorError(f"No se pudo importar numpy: {exc}") from exc

    resultado: dict[str, Any] = {
        "status": "ok",
        "expected_env": expected_env,
        "sys_prefix": str(_ruta_real(sys.prefix)),
        "conda_prefix": str(_ruta_real(conda_prefix)),
        "python": platform.python_version(),
        "numpy": numpy.__version__,
        "device": "gpu" if require_gpu else "cpu",
        "gpu": None,
    }
    if not require_gpu:
        return resultado

    try:
        import cupy as cp
    except Exception as exc:
        raise DoctorError(
            f"No se pudo importar cupy: {exc}. Instale CuPy en el entorno "
            "o ejecute explícitamente en modo CPU."
        ) from exc
    try:
        cantidad = int(cp.cuda.runtime.getDeviceCount())
        if cantidad < 1:
            raise DoctorError("CuPy informa 0 dispositivos CUDA.")
        dispositivo = cp.cuda.Device()
        with dispositivo:
            libre, total = (int(x) for x in cp.cuda.runtime.memGetInfo())
            propiedades = cp.cuda.runtime.getDeviceProperties(dispositivo.id)
        nombre = propiedades.get("name", b"desconocida")
        if isinstance(nombre, bytes):
            nombre = nombre.decode("utf-8", "replace")
        if libre <= 0 or total <= 0:
            raise DoctorError(f"VRAM inválida: libre={libre}, total={total}.")
    except DoctorError:
        raise
    except Exception as exc:
        raise DoctorError(f"La validación CUDA falló: {exc}") from exc

    resultado["cupy"] = cp.__version__
    resultado["cuda_runtime"] = int(cp.cuda.runtime.runtimeGetVersion())
    resultado["cuda_driver"] = int(cp.cuda.runtime.driverGetVersion())
    resultado["gpu"] = {
        "count": cantidad,
        "device_id": int(dispositivo.id),
        "name": str(nombre),
        "vram_free_bytes": libre,
        "vram_total_bytes": total,
    }
    return resultado
