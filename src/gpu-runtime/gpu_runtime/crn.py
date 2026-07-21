"""Números aleatorios comunes (CRN) reproducibles, generados por bloques.

Cada bloque se deriva de ``(seed, batch_index)`` con SplitMix64, de modo que
cualquier bloque puede regenerarse en forma independiente y determinista sin
materializar nunca el cubo completo de simulaciones en memoria.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Iterator, Literal

import numpy as np

Device = Literal["gpu", "cpu"]

#: La ruta CPU existe para pruebas y benchmarks chicos; este tope evita
#: asignaciones grandes por accidente fuera de la GPU.
MAX_CPU_ROWS = 5_000

DTYPE = np.float32
_MASK64 = (1 << 64) - 1


@dataclass(frozen=True)
class CRNBatch:
    """Un único bloque de números aleatorios; el consumidor decide cuándo liberarlo."""

    index: int
    simulation_start: int
    simulation_stop: int
    values: Any
    seed_derived: int


def derive_batch_seed(seed: int, batch_index: int) -> int:
    """Mezcla estable de ``(seed, batch_index)`` mediante SplitMix64."""

    if seed < 0 or batch_index < 0:
        raise ValueError("seed y batch_index deben ser enteros no negativos.")
    x = (int(seed) + 0x9E3779B97F4A7C15 * (int(batch_index) + 1)) & _MASK64
    x = ((x ^ (x >> 30)) * 0xBF58476D1CE4E5B9) & _MASK64
    x = ((x ^ (x >> 27)) * 0x94D049BB133111EB) & _MASK64
    return (x ^ (x >> 31)) & _MASK64


def _validate_shape(
    n_batch_sims: int, n_units: int, n_variables: int, device: Device
) -> None:
    for nombre, valor in {
        "n_batch_sims": n_batch_sims,
        "n_units": n_units,
        "n_variables": n_variables,
    }.items():
        if not isinstance(valor, int) or isinstance(valor, bool) or valor < 1:
            raise ValueError(f"{nombre} debe ser un entero positivo; recibido {valor!r}.")
    if device not in ("gpu", "cpu"):
        raise ValueError("device debe ser 'gpu' o 'cpu'.")
    if device == "cpu" and n_units > MAX_CPU_ROWS:
        raise ValueError(
            f"La ruta CPU admite como máximo {MAX_CPU_ROWS} unidades por bloque; "
            f"se recibieron {n_units}. Use la GPU para tamaños mayores."
        )


def generate_crn_batch(
    *,
    seed: int,
    batch_index: int,
    n_batch_sims: int,
    n_units: int,
    n_variables: int,
    device: Device = "gpu",
) -> CRNBatch:
    """Genera solo el bloque solicitado, con un ``Generator`` Philox explícito.

    En GPU rechaza el pedido si el bloque superaría el 80% de la VRAM libre,
    con un mensaje que indica cómo corregirlo (reducir el tamaño de batch).
    """

    _validate_shape(n_batch_sims, n_units, n_variables, device)
    semilla = derive_batch_seed(seed, batch_index)
    forma = (n_batch_sims, n_units, n_variables)
    if device == "cpu":
        rng = np.random.Generator(np.random.Philox(semilla))
        valores = rng.random(forma, dtype=DTYPE)
    else:
        try:
            import cupy as cp
        except Exception as exc:
            raise RuntimeError(f"No se pudo importar CuPy para generar CRN: {exc}") from exc
        bytes_bloque = int(np.prod(forma, dtype=np.int64)) * np.dtype(DTYPE).itemsize
        libre, _ = (int(x) for x in cp.cuda.runtime.memGetInfo())
        if bytes_bloque > int(libre * 0.80):
            raise MemoryError(
                f"El bloque requiere {bytes_bloque} bytes y supera el 80% de la VRAM "
                f"libre ({libre}); reduzca el tamaño de batch."
            )
        rng = cp.random.Generator(cp.random.Philox4x3210(semilla))
        valores = rng.random(forma, dtype=cp.float32)
    return CRNBatch(
        index=batch_index,
        simulation_start=-1,
        simulation_stop=-1,
        values=valores,
        seed_derived=semilla,
    )


def iter_crn_batches(
    *,
    total_simulations: int,
    batch_sims: int,
    n_units: int,
    n_variables: int,
    seed: int,
    device: Device = "gpu",
) -> Iterator[CRNBatch]:
    """Entrega un bloque por vez; nunca crea ni concatena el cubo completo."""

    if not isinstance(total_simulations, int) or total_simulations < 1:
        raise ValueError("total_simulations debe ser un entero positivo.")
    if not isinstance(batch_sims, int) or batch_sims < 1:
        raise ValueError("batch_sims debe ser un entero positivo.")
    inicio = 0
    indice = 0
    while inicio < total_simulations:
        fin = min(inicio + batch_sims, total_simulations)
        bloque = generate_crn_batch(
            seed=seed,
            batch_index=indice,
            n_batch_sims=fin - inicio,
            n_units=n_units,
            n_variables=n_variables,
            device=device,
        )
        yield CRNBatch(
            index=bloque.index,
            simulation_start=inicio,
            simulation_stop=fin,
            values=bloque.values,
            seed_derived=bloque.seed_derived,
        )
        inicio = fin
        indice += 1
