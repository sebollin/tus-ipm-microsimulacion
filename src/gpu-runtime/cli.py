"""Interfaz de línea de comandos del runtime de GPU.

Subcomandos:

* ``doctor``: diagnóstico estricto del entorno (Conda, CuPy, CUDA, VRAM).
* ``benchmark``: mide la generación de un bloque CRN sobre datos sintéticos,
  en CPU y en GPU, e informa el speedup.
"""

from __future__ import annotations

import argparse
import json
import statistics
import sys
import time
from typing import Any

import numpy as np

from gpu_runtime.crn import generate_crn_batch
from gpu_runtime.doctor import DoctorError, collect_diagnostics


def _emitir_error(exc: BaseException) -> None:
    error = {
        "status": "error",
        "error_type": type(exc).__name__,
        "message": str(exc),
    }
    print(json.dumps(error, ensure_ascii=False), file=sys.stderr)


def _medir(
    device: str, repeats: int, shape: tuple[int, int, int], seed: int
) -> dict[str, float]:
    """Mide generación + reducción en el dispositivo; sin transferir el bloque."""

    tiempos: list[float] = []
    checksum = 0.0
    for indice in range(repeats):
        inicio = time.perf_counter()
        bloque = generate_crn_batch(
            seed=seed,
            batch_index=indice,
            n_batch_sims=shape[0],
            n_units=shape[1],
            n_variables=shape[2],
            device=device,  # type: ignore[arg-type]
        )
        if device == "gpu":
            import cupy as cp

            checksum = float(cp.asnumpy(bloque.values.sum()))
            cp.cuda.Stream.null.synchronize()
        else:
            checksum = float(np.sum(bloque.values))
        tiempos.append(time.perf_counter() - inicio)
        del bloque
    return {"median_seconds": statistics.median(tiempos), "checksum_last": checksum}


def cmd_doctor(args: argparse.Namespace) -> int:
    try:
        diagnostico = collect_diagnostics(
            expected_env=args.expected_env, require_gpu=not args.cpu
        )
    except Exception as exc:
        _emitir_error(exc)
        return 2
    if args.json:
        print(json.dumps(diagnostico, ensure_ascii=False, sort_keys=True))
        return 0
    print("Diagnóstico OK")
    print(f"  python:       {diagnostico['python']}")
    print(f"  conda_prefix: {diagnostico['conda_prefix']}")
    print(f"  numpy:        {diagnostico['numpy']}")
    gpu = diagnostico["gpu"]
    if gpu is None:
        print("  gpu:          no verificada (modo --cpu)")
    else:
        libre_gib = gpu["vram_free_bytes"] / 2**30
        total_gib = gpu["vram_total_bytes"] / 2**30
        print(f"  cupy:         {diagnostico['cupy']}")
        print(
            f"  gpu:          {gpu['name']} "
            f"(VRAM libre {libre_gib:.1f} GiB de {total_gib:.1f} GiB)"
        )
    return 0


def cmd_benchmark(args: argparse.Namespace) -> int:
    forma = (args.batch_sims, args.units, args.variables)
    try:
        resultado: dict[str, Any] = {
            "shape": list(forma),
            "dtype": "float32",
            "bytes_per_batch": int(np.prod(forma, dtype=np.int64)) * 4,
            "repeats": args.repeats,
            "seed": args.seed,
            "scope": (
                "generación CRN + reducción en el dispositivo; "
                "sin transferencia del bloque"
            ),
            "cpu": _medir("cpu", args.repeats, forma, args.seed),
            "gpu": None,
            "speedup_gpu_vs_cpu": None,
        }
        if not args.cpu_only:
            collect_diagnostics(require_gpu=True)
            resultado["gpu"] = _medir("gpu", args.repeats, forma, args.seed)
            resultado["speedup_gpu_vs_cpu"] = (
                resultado["cpu"]["median_seconds"] / resultado["gpu"]["median_seconds"]
            )
    except (DoctorError, MemoryError, RuntimeError, ValueError) as exc:
        _emitir_error(exc)
        return 2
    print(json.dumps(resultado, ensure_ascii=False, sort_keys=True))
    return 0


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="gpu-runtime", description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    doctor = sub.add_parser("doctor", help="Diagnóstico estricto del entorno.")
    doctor.add_argument(
        "--expected-env",
        default=None,
        help="Nombre del entorno Conda exigido (opcional).",
    )
    doctor.add_argument(
        "--cpu",
        action="store_true",
        help="Valida solo intérprete y NumPy; no verifica la GPU.",
    )
    doctor.add_argument("--json", action="store_true", help="Emite JSON estructurado.")
    doctor.set_defaults(func=cmd_doctor)

    bench = sub.add_parser(
        "benchmark", help="Benchmark CPU vs GPU de un bloque CRN sintético."
    )
    bench.add_argument("--batch-sims", type=int, default=256)
    bench.add_argument("--units", type=int, default=5_000)
    bench.add_argument("--variables", type=int, default=15)
    bench.add_argument("--repeats", type=int, default=3)
    bench.add_argument("--seed", type=int, default=12345)
    bench.add_argument(
        "--cpu-only",
        action="store_true",
        help="Mide solo la ruta CPU; omite en forma explícita la GPU.",
    )
    bench.set_defaults(func=cmd_benchmark)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    return args.func(args)


if __name__ == "__main__":  # pragma: no cover
    raise SystemExit(main())
