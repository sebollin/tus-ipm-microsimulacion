"""Configuración de pytest: hace importable el paquete desde este directorio."""

import sys
from pathlib import Path

_RAIZ = str(Path(__file__).resolve().parent)
if _RAIZ not in sys.path:
    sys.path.insert(0, _RAIZ)
