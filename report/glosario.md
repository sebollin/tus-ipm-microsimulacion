# Glosario

Este glosario define todos los términos técnicos que aparecen en el informe, las figuras
y las tablas de `results/`. Está pensado para lectores sin formación previa en estadística
ni en medición de pobreza: cada entrada explica el concepto desde cero y, cuando
corresponde, indica cómo leer el número asociado. Dentro de cada sección los términos
siguen un orden pedagógico (cada definición se apoya en las anteriores), no alfabético.

## 1. Medición de la pobreza

- **Pobreza multidimensional.** Enfoque que entiende la pobreza como algo más que falta de
  ingresos: un hogar puede tener carencias en educación, vivienda, empleo u otras áreas
  aunque su ingreso supere la línea de pobreza. En lugar de mirar solo cuánta plata entra
  al hogar, se observa directamente un conjunto de condiciones de vida.
- **Privación.** Cada carencia concreta que se verifica en un hogar: por ejemplo, que un
  menor en edad escolar no asista a un centro educativo, o que la vivienda esté hacinada.
  Cada privación se registra de forma binaria: el hogar la tiene o no la tiene.
- **Dimensión.** Agrupación temática de privaciones. El índice oficial uruguayo organiza
  las privaciones en cinco dimensiones (entre ellas educación, vivienda y empleo).
- **Indicador.** La variable específica que mide cada privación posible. El índice oficial
  uruguayo usa quince indicadores repartidos en las cinco dimensiones, todos con el mismo
  peso (1/15). En las tablas de `results/` los indicadores aparecen con nombres cortos con
  prefijo `hh_` (por ejemplo, `hh_hacinamiento`).
- **IPM.** Índice de Pobreza Multidimensional: la medida oficial de pobreza
  multidimensional en Uruguay, publicada por el INE desde 2024. Resume en un solo número
  cuánta gente es pobre multidimensional y qué tan intensa es su pobreza (ver **M0**).
- **Método Alkire–Foster.** Procedimiento estándar internacional con el que se construye
  el IPM: (1) se definen privaciones binarias, (2) se suman con sus pesos para obtener un
  puntaje por hogar, (3) se identifica como pobre a quien supera un umbral, y (4) se
  resume la situación con tres números: H, A y M0.
- **Puntaje de privaciones.** La suma ponderada de privaciones de un hogar. Con quince
  indicadores de igual peso, es la fracción de privaciones que el hogar sufre: toma
  valores como 0; 0,067 (una privación); 0,133 (dos); y así hasta 1.
- **Umbral k.** El punto de corte sobre el puntaje de privaciones que define quién es
  pobre multidimensional. En la medición oficial uruguaya equivale a tener **4 o más
  privaciones de las 15 posibles**. La tabla `sensibilidad_umbral_k.csv` muestra que los
  resultados del estudio se sostienen con valores de k vecinos (0,18; 0,21; 0,24).
- **H — incidencia.** ¿Qué proporción de la población es pobre multidimensional? Se
  expresa en porcentaje: H = 6% significa que 6 de cada 100 personas (u hogares, según el
  universo) viven en situación de pobreza multidimensional.
- **A — intensidad.** De quienes ya son pobres multidimensionales, ¿qué tan profunda es su
  pobreza en promedio? Es el promedio del puntaje de privaciones **solo entre los
  pobres**. A = 30% significa que un pobre típico sufre el 30% de las privaciones
  posibles, unas 4,5 de 15.
- **M0 — índice de pobreza ajustado.** El número que combina las dos cosas: M0 = H × A.
  Baja tanto si hay menos pobres (cae H) como si los que siguen siendo pobres sufren menos
  privaciones (cae A); por eso es la medida más completa de las tres. Se expresa en escala
  0–1, no en porcentaje.
- **Incidencia censurada.** Prevalencia de una privación contada **solo entre los pobres
  multidimensionales**. "Censurada" significa que se ignoran las privaciones de quienes no
  llegan al umbral de pobreza. Se contrapone a la **incidencia no censurada**, que cuenta
  la privación en toda la población.
- **Contribución al IPM.** Cuánto aporta cada indicador (o dimensión) al valor total de
  M0. Las quince contribuciones suman exactamente M0; permiten responder "¿de qué está
  hecha la pobreza multidimensional?". Las tablas `descomposicion_indicadores.csv` y
  `descomposicion_dimensiones.csv` muestran cómo cambia cada aporte en los escenarios.
- **Pobreza monetaria / línea de pobreza.** La medida tradicional de pobreza: un hogar es
  pobre monetario si su ingreso está por debajo de la línea de pobreza, un valor monetario
  que representa el costo de una canasta básica de bienes y servicios. Es un concepto
  distinto y complementario del IPM: el estudio reporta ambas (la monetaria en
  `escenarios_pobreza_monetaria.csv`).

## 2. Programas y transferencias

- **Transferencia monetaria.** Dinero que el Estado entrega en forma periódica a hogares
  seleccionados, para sostener su consumo. Los tres programas de este estudio son
  transferencias monetarias no contributivas (no exigen aportes previos a la seguridad
  social).
- **Tarjeta Uruguay Social (TUS).** Programa del MIDES que carga mensualmente un monto en
  una tarjeta para comprar alimentos y artículos de primera necesidad. Está dirigida a los
  hogares en situación de mayor vulnerabilidad socioeconómica del país. Es la
  transferencia cuyos aumentos hipotéticos simula este estudio.
- **TUS simple y doble.** Dos niveles del mismo programa: los hogares de vulnerabilidad
  extrema (los de mayor carencia dentro de la población TUS) reciben el monto duplicado
  ("tarjeta doble"); el resto recibe el monto base ("tarjeta simple"). El monto depende
  además de la cantidad de menores en el hogar.
- **AFAM-PE.** Asignaciones Familiares del Plan de Equidad: transferencia mensual por cada
  menor a cargo, dirigida a hogares en situación de vulnerabilidad. Es distinta de la
  asignación familiar contributiva (la de trabajadores formales) y llega a una población
  más amplia que la TUS.
- **Bono Crianza.** Transferencia adicional para hogares que ya reciben TUS y tienen
  menores de 0 a 3 años o embarazadas, orientada a la primera infancia. El estudio simula
  el efecto del bono y de su aumento dispuesto para 2026
  (`bono_crianza_escenarios.csv` y `bono_crianza_aumento_2026.csv`).
- **Focalización.** Estrategia de dirigir un programa a una población específica (en este
  caso, los hogares más vulnerables) en lugar de darlo a toda la población. Requiere algún
  instrumento que ordene a los hogares según su nivel de carencia.
- **ICC.** Índice de Carencias Críticas: el instrumento que usa el MIDES para focalizar
  transferencias como la TUS y la AFAM-PE. Combina características del hogar en un puntaje
  de vulnerabilidad; su fórmula no es pública. Importante: el ICC y el IPM miden cosas
  distintas por diseño (uno selecciona beneficiarios, el otro mide pobreza), así que las
  diferencias entre las poblaciones que cada uno delimita no son "errores".
- **Elegibilidad.** Condición de cumplir los requisitos para recibir un programa. Ser
  elegible no es lo mismo que recibir: puede haber elegibles que no cobran y viceversa.
- **Cobertura.** Cuántos hogares (o personas) reciben efectivamente un programa, y cómo se
  distribuyen en la población. La "extensión de cobertura" que aparece entre las reglas
  comparadas es un escenario donde la transferencia llega a hogares priorizados que hoy no
  la reciben.

## 3. Datos

- **ECH.** Encuesta Continua de Hogares del INE: la encuesta oficial que releva ingresos y
  condiciones de vida de los hogares uruguayos, base de las cifras oficiales de pobreza.
  Este estudio usa la ECH 2025.
- **Microdatos.** La base de datos con una fila por hogar o por persona encuestada (sin
  identificarla), a partir de la cual se calcula todo. Este repositorio **no** contiene
  microdatos: publica solo resultados agregados; los microdatos de la ECH los distribuye
  el INE.
- **Registros administrativos.** Bases de datos de los organismos públicos (por ejemplo,
  las nóminas de beneficiarios de los programas). El INE los usa para complementar y
  mejorar la información de transferencias de la ECH; gracias a eso la encuesta permite
  identificar con buena precisión qué hogares reciben cada programa y por qué monto.
- **Factor de expansión (peso).** Número que indica cuántos hogares o personas del país
  representa cada unidad encuestada. Como la ECH es una muestra, cada hogar encuestado
  "habla por" cientos de hogares reales. Todos los resultados del estudio están ponderados
  por estos factores, de modo que describen a la población del país y no a la muestra.
- **n muestral y n expandido.** Dos conteos que no hay que confundir: el n muestral es la
  cantidad de hogares efectivamente encuestados; el n expandido es la cantidad de hogares
  del país que esos hogares representan una vez aplicados los factores de expansión. Las
  tablas reportan ambos cuando corresponde (`n_hogares_muestrales`, `hogares_expandidos`).
- **Ingreso equivalente.** Ingreso del hogar ajustado por su tamaño y composición, para
  que sea comparable entre hogares distintos: no es lo mismo un ingreso de $50.000 para
  una persona sola que para una familia de seis. El ajuste divide el ingreso total por una
  escala que crece con el número de integrantes.
- **Quintil de ingreso.** Resultado de ordenar a toda la población por ingreso equivalente
  y partirla en cinco grupos iguales: el quintil 1 es el 20% más pobre y el quintil 5 el
  20% más rico. La tabla `efectos_por_quintil_ingreso.csv` muestra los efectos por
  quintil.

## 4. Método del estudio

- **Microsimulación.** Técnica que aplica un cambio hipotético de política (acá: aumentos
  de la TUS) hogar por hogar sobre los microdatos, recalcula los resultados de interés y
  compara contra la situación sin el cambio. Permite estimar "qué pasaría si..." antes de
  implementar la política.
- **Línea de base.** La situación de partida contra la que se compara todo: la ECH 2025
  tal como es, sin ningún aumento simulado. En las tablas corresponde al escenario 0, y
  las columnas con sufijo `_base` traen sus valores.
- **Escenario.** Cada variante hipotética simulada. Los códigos numéricos 10 a 1000 son el
  porcentaje de aumento de la TUS (el escenario 50 es "TUS aumentada 50%"); hay además
  códigos propios para las reglas de reparto comparadas y para los escenarios del Bono
  Crianza, identificados por su nombre en cada tabla.
- **Curva dosis-respuesta.** La relación entre el tamaño del aumento (la "dosis") y el
  efecto sobre la pobreza (la "respuesta"), trazada a lo largo de toda la grilla de
  escenarios. Permite ver si el efecto crece de forma proporcional, se acelera o se
  amortigua a medida que el aumento es mayor.
- **Modelo predictivo (no causal).** Los efectos del estudio provienen de modelos
  estadísticos que relacionan el ingreso de los hogares con la probabilidad de cada
  privación, estimados sobre la propia ECH. Son **proyecciones condicionales**: dicen "si
  las relaciones observadas en los datos se mantienen, esto esperaríamos ver". No son una
  medición causal: no reemplazan la evaluación de la política una vez implementada.
- **Puntos porcentuales (pp).** La unidad de los efectos sobre H y A. Si la incidencia
  pasa de 5,9% a 5,65%, bajó 0,25 pp. No es lo mismo que "bajó 0,25%": una caída de 0,25%
  sería casi nula, mientras que 0,25 pp equivale acá a una reducción relativa de alrededor
  del 4%. Confundir % con pp es el error de lectura más común.
- **Notación `dH_pp`, `dA_pp`, `dM0`.** En las tablas, el prefijo `d` indica el cambio de
  una métrica respecto de la línea de base, y el sufijo `pp` que está expresado en puntos
  porcentuales. Así, `dH_pp_personas` = cambio de la incidencia en personas, en puntos
  porcentuales; `dM0` va en la escala 0–1 del propio M0, sin sufijo `pp`. Los valores
  negativos son reducciones de pobreza.
- **Universos (personas / hogares / beneficiarios / hogares afectados).** El grupo sobre
  el que se calcula cada resultado. `personas` y `hogares` son la población nacional
  completa; `beneficiarios` restringe a quienes reciben la transferencia; en los cuadros
  del Bono Crianza, `hogares_afectados` son los alcanzados por ese cambio puntual. La
  distinción importa porque el promedio nacional diluye: la mayoría de la población no
  recibe la transferencia, así que el efecto entre beneficiarios es mucho mayor que el
  efecto país aunque provenga del mismo escenario.
- **Simulación Monte Carlo.** Método que repite la simulación miles de veces con números
  aleatorios distintos y examina la distribución de resultados. Se usa porque los modelos
  predicen probabilidades de privación, no certezas: cada corrida sortea una realización
  posible, y el conjunto de corridas describe el rango de resultados compatibles con el
  modelo.
- **Banda Monte Carlo (`p2_5` / `p97_5`).** Intervalo que resume esa variabilidad: `p2_5`
  y `p97_5` son los percentiles 2,5 y 97,5 de las miles de simulaciones, de modo que el
  95% central de los resultados simulados queda entre ambos. Responde "¿cuánto varía la
  simulación por su propio azar interno?"; no es un intervalo de confianza poblacional.
- **Error estándar de simulación (`se_mc`).** Medida resumida de cuánta incertidumbre de
  simulación queda en el promedio reportado. Cuanto más chico, más estable es la cifra
  frente al azar interno del método.
- **Convergencia.** Verificación de que se corrieron suficientes simulaciones: si al
  agregar más corridas los resultados ya no cambian de forma apreciable, la simulación
  "convergió" y las cifras son estables. La tabla `convergencia_montecarlo.csv` muestra
  las estimaciones con tamaños crecientes de simulación.
- **Réplicas bootstrap.** Conjunto de 1.000 ponderadores alternativos que publica el INE
  junto con la ECH, cada uno representando una "muestra posible" distinta de la encuesta.
  Recalculando el resultado con cada réplica se mide cuánto depende la cifra del azar del
  muestreo, respetando el diseño real de la encuesta.
- **Intervalo de confianza de diseño.** Intervalo construido con esas réplicas: responde
  "¿cuánto cambiaría el resultado si el INE hubiera sorteado otra muestra de hogares?". En
  las tablas aparece en las columnas `diseno_*`. Es una fuente de incertidumbre distinta
  de la banda Monte Carlo, y por eso se reporta por separado, nunca fusionada. Las
  columnas `*_excluye_cero` indican si el intervalo correspondiente deja afuera al cero
  (es decir, si esa fuente de variación no admite un efecto nulo).
- **Números aleatorios comunes (CRN).** Técnica para comparar escenarios de forma limpia:
  todos se simulan con exactamente los mismos números aleatorios, de modo que las
  diferencias observadas se deben al cambio de política y no al azar de la simulación.
- **Diferencia pareada.** La resta entre dos escenarios hecha corrida por corrida (con
  CRN), en lugar de restar promedios de simulaciones independientes. Aísla el efecto y
  reduce el ruido. En `contrastes_pareados_reglas.csv`, la columna `separable_de_cero`
  indica si el intervalo del 95% de esa diferencia excluye al cero.
- **Regla de asignación.** Forma de repartir un mismo presupuesto adicional entre hogares:
  aumento porcentual uniforme, suma fija por hogar, variantes focalizadas en los más
  vulnerables, o extensión de cobertura a hogares que hoy no reciben la transferencia. El
  estudio las compara en `reglas_presupuesto_fijo.csv`.
- **Presupuesto constante.** Condición que hace justa esa comparación: todas las reglas
  gastan exactamente lo mismo, así que las diferencias de efecto reflejan el diseño del
  reparto y no el tamaño del gasto.
- **Análisis de sensibilidad.** Rehacer los cálculos cambiando un supuesto por vez (el
  umbral k, la definición de ingreso) para verificar que las conclusiones no dependen de
  una elección particular. Las tablas `sensibilidad_umbral_k.csv` y
  `sensibilidad_definicion_ingreso.csv` documentan estos chequeos.
- **GPU.** Procesador gráfico usado como hardware de cálculo masivo en paralelo. La
  microsimulación corre en GPU porque implica miles de simulaciones sobre quince
  indicadores y decenas de miles de hogares; es un detalle de cómputo que no altera los
  resultados, solo el tiempo que lleva obtenerlos.
