"""Tests de CRN sobre datos sintéticos.

La ruta CPU corre siempre con NumPy. Los tests que requieren GPU se omiten
con un motivo explícito cuando no hay un dispositivo CUDA disponible.
"""

import numpy as np
import pytest

from gpu_runtime.crn import (
    DTYPE,
    MAX_CPU_ROWS,
    derive_batch_seed,
    generate_crn_batch,
    iter_crn_batches,
)


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


def test_derive_batch_seed_es_determinista():
    assert derive_batch_seed(123, 7) == derive_batch_seed(123, 7)


def test_derive_batch_seed_varia_por_semilla_y_batch():
    semillas = {derive_batch_seed(99, i) for i in range(100)}
    assert len(semillas) == 100
    assert derive_batch_seed(1, 0) != derive_batch_seed(2, 0)
    for valor in semillas:
        assert 0 <= valor < 2**64


def test_derive_batch_seed_rechaza_negativos():
    with pytest.raises(ValueError):
        derive_batch_seed(-1, 0)
    with pytest.raises(ValueError):
        derive_batch_seed(0, -1)


def test_generate_cpu_forma_dtype_y_rango():
    bloque = generate_crn_batch(
        seed=42, batch_index=0, n_batch_sims=8, n_units=30, n_variables=5, device="cpu"
    )
    assert bloque.values.shape == (8, 30, 5)
    assert bloque.values.dtype == DTYPE
    assert float(bloque.values.min()) >= 0.0
    assert float(bloque.values.max()) < 1.0
    assert bloque.seed_derived == derive_batch_seed(42, 0)


def test_generate_cpu_es_reproducible():
    a = generate_crn_batch(
        seed=42, batch_index=3, n_batch_sims=4, n_units=20, n_variables=6, device="cpu"
    )
    b = generate_crn_batch(
        seed=42, batch_index=3, n_batch_sims=4, n_units=20, n_variables=6, device="cpu"
    )
    np.testing.assert_array_equal(a.values, b.values)


def test_generate_cpu_difiere_entre_batches():
    a = generate_crn_batch(
        seed=42, batch_index=0, n_batch_sims=4, n_units=20, n_variables=6, device="cpu"
    )
    b = generate_crn_batch(
        seed=42, batch_index=1, n_batch_sims=4, n_units=20, n_variables=6, device="cpu"
    )
    assert not np.array_equal(a.values, b.values)


@pytest.mark.parametrize("campo", ["n_batch_sims", "n_units", "n_variables"])
@pytest.mark.parametrize("valor", [0, -3, True, 2.5])
def test_generate_rechaza_dimensiones_invalidas(campo, valor):
    parametros = {"n_batch_sims": 2, "n_units": 10, "n_variables": 3, campo: valor}
    with pytest.raises(ValueError):
        generate_crn_batch(seed=1, batch_index=0, device="cpu", **parametros)


def test_generate_cpu_respeta_tope_de_filas():
    with pytest.raises(ValueError, match="como máximo"):
        generate_crn_batch(
            seed=1,
            batch_index=0,
            n_batch_sims=1,
            n_units=MAX_CPU_ROWS + 1,
            n_variables=1,
            device="cpu",
        )


def test_generate_rechaza_device_invalido():
    with pytest.raises(ValueError, match="device"):
        generate_crn_batch(
            seed=1, batch_index=0, n_batch_sims=1, n_units=1, n_variables=1, device="tpu"
        )


def test_iter_cubre_el_rango_sin_solapamiento():
    bloques = list(
        iter_crn_batches(
            total_simulations=10,
            batch_sims=4,
            n_units=15,
            n_variables=3,
            seed=7,
            device="cpu",
        )
    )
    assert [(b.simulation_start, b.simulation_stop) for b in bloques] == [
        (0, 4),
        (4, 8),
        (8, 10),
    ]
    assert [b.index for b in bloques] == [0, 1, 2]
    assert bloques[-1].values.shape == (2, 15, 3)
    assert len({b.seed_derived for b in bloques}) == 3


def test_iter_coincide_con_generacion_directa():
    bloques = list(
        iter_crn_batches(
            total_simulations=6,
            batch_sims=3,
            n_units=10,
            n_variables=2,
            seed=11,
            device="cpu",
        )
    )
    for bloque in bloques:
        directo = generate_crn_batch(
            seed=11,
            batch_index=bloque.index,
            n_batch_sims=bloque.simulation_stop - bloque.simulation_start,
            n_units=10,
            n_variables=2,
            device="cpu",
        )
        np.testing.assert_array_equal(bloque.values, directo.values)


@pytest.mark.parametrize("total,batch", [(0, 4), (-1, 4), (10, 0), (10, -2)])
def test_iter_valida_totales_y_batch(total, batch):
    with pytest.raises(ValueError):
        list(
            iter_crn_batches(
                total_simulations=total,
                batch_sims=batch,
                n_units=5,
                n_variables=2,
                seed=1,
                device="cpu",
            )
        )


@requiere_gpu
def test_generate_gpu_es_reproducible():
    import cupy as cp

    a = generate_crn_batch(
        seed=42, batch_index=2, n_batch_sims=8, n_units=100, n_variables=4, device="gpu"
    )
    b = generate_crn_batch(
        seed=42, batch_index=2, n_batch_sims=8, n_units=100, n_variables=4, device="gpu"
    )
    assert a.values.shape == (8, 100, 4)
    assert a.values.dtype == cp.float32
    assert bool(cp.array_equal(a.values, b.values))


@requiere_gpu
def test_generate_gpu_difiere_entre_batches():
    import cupy as cp

    a = generate_crn_batch(
        seed=42, batch_index=0, n_batch_sims=4, n_units=50, n_variables=3, device="gpu"
    )
    b = generate_crn_batch(
        seed=42, batch_index=1, n_batch_sims=4, n_units=50, n_variables=3, device="gpu"
    )
    assert not bool(cp.array_equal(a.values, b.values))
