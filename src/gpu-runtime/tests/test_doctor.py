"""Tests del diagnóstico de entorno, con variables de entorno controladas."""

import sys

import pytest

from gpu_runtime.doctor import DoctorError, collect_diagnostics


def _cuda_disponible() -> bool:
    try:
        import cupy as cp
    except Exception:
        return False
    try:
        return int(cp.cuda.runtime.getDeviceCount()) > 0
    except Exception:
        return False


requiere_gpu = pytest.mark.skipif(
    not _cuda_disponible(),
    reason=(
        "Requiere CuPy con al menos un dispositivo CUDA visible; "
        "sin GPU este test se omite en forma explícita, no se degrada a CPU."
    ),
)


@pytest.fixture
def entorno_limpio(monkeypatch):
    """Simula un entorno Conda consistente con el intérprete en uso."""

    monkeypatch.setenv("CONDA_PREFIX", sys.prefix)
    monkeypatch.delenv("VIRTUAL_ENV", raising=False)
    monkeypatch.delenv("PYTHONPATH", raising=False)


def test_modo_cpu_ok(entorno_limpio):
    diagnostico = collect_diagnostics(require_gpu=False)
    assert diagnostico["status"] == "ok"
    assert diagnostico["device"] == "cpu"
    assert diagnostico["gpu"] is None
    assert diagnostico["numpy"]


def test_falla_sin_conda_prefix(monkeypatch):
    monkeypatch.delenv("CONDA_PREFIX", raising=False)
    with pytest.raises(DoctorError, match="CONDA_PREFIX"):
        collect_diagnostics(require_gpu=False)


def test_falla_con_nombre_de_env_distinto(entorno_limpio):
    with pytest.raises(DoctorError, match="entorno Conda"):
        collect_diagnostics(expected_env="nombre-que-no-existe", require_gpu=False)


def test_falla_con_virtualenv_activo(entorno_limpio, monkeypatch):
    monkeypatch.setenv("VIRTUAL_ENV", "/opt/venv-ficticio")
    with pytest.raises(DoctorError, match="VIRTUAL_ENV"):
        collect_diagnostics(require_gpu=False)


def test_falla_con_pythonpath_definido(entorno_limpio, monkeypatch):
    monkeypatch.setenv("PYTHONPATH", "/opt/modulos-ficticios")
    with pytest.raises(DoctorError, match="PYTHONPATH"):
        collect_diagnostics(require_gpu=False)


def test_falla_con_interprete_inconsistente(monkeypatch):
    monkeypatch.setenv("CONDA_PREFIX", "/opt/otro-prefijo-conda")
    monkeypatch.delenv("VIRTUAL_ENV", raising=False)
    monkeypatch.delenv("PYTHONPATH", raising=False)
    with pytest.raises(DoctorError, match="Intérprete inconsistente"):
        collect_diagnostics(require_gpu=False)


@pytest.mark.skipif(
    _cuda_disponible(),
    reason="Solo aplica cuando NO hay GPU: verifica que la falla sea un DoctorError claro.",
)
def test_sin_gpu_falla_con_mensaje_claro(entorno_limpio):
    with pytest.raises(DoctorError):
        collect_diagnostics(require_gpu=True)


@requiere_gpu
def test_modo_gpu_ok(entorno_limpio):
    diagnostico = collect_diagnostics(require_gpu=True)
    assert diagnostico["status"] == "ok"
    assert diagnostico["gpu"]["count"] >= 1
    assert diagnostico["gpu"]["vram_total_bytes"] > 0
    assert diagnostico["gpu"]["vram_free_bytes"] > 0
    assert diagnostico["cupy"]
