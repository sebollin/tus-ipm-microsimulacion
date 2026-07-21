"""Tests de humo de la interfaz de línea de comandos; no requieren GPU."""

import json
import sys

import cli


def _entorno_conda(monkeypatch):
    monkeypatch.setenv("CONDA_PREFIX", sys.prefix)
    monkeypatch.delenv("VIRTUAL_ENV", raising=False)
    monkeypatch.delenv("PYTHONPATH", raising=False)


def test_doctor_cpu_json(monkeypatch, capsys):
    _entorno_conda(monkeypatch)
    codigo = cli.main(["doctor", "--cpu", "--json"])
    assert codigo == 0
    salida = json.loads(capsys.readouterr().out)
    assert salida["status"] == "ok"
    assert salida["gpu"] is None


def test_doctor_falla_sin_conda_con_error_estructurado(monkeypatch, capsys):
    monkeypatch.delenv("CONDA_PREFIX", raising=False)
    codigo = cli.main(["doctor", "--cpu", "--json"])
    assert codigo == 2
    error = json.loads(capsys.readouterr().err)
    assert error["status"] == "error"
    assert error["error_type"] == "DoctorError"
    assert "CONDA_PREFIX" in error["message"]


def test_benchmark_cpu_only(capsys):
    codigo = cli.main(
        [
            "benchmark",
            "--cpu-only",
            "--batch-sims",
            "4",
            "--units",
            "50",
            "--variables",
            "3",
            "--repeats",
            "2",
        ]
    )
    assert codigo == 0
    resultado = json.loads(capsys.readouterr().out)
    assert resultado["shape"] == [4, 50, 3]
    assert resultado["cpu"]["median_seconds"] > 0
    assert resultado["gpu"] is None
    assert resultado["speedup_gpu_vs_cpu"] is None
