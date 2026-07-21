# =============================================================================
# Renderers de las figuras del estudio.
#
# Cada función recibe un payload ya agregado (lista con `records` y `spec`,
# leída de results/aggregate/figure-data/) y, opcionalmente, la ruta del
# directorio de tablas agregadas (results/aggregate/tables) para las figuras
# que combinan el payload con esas tablas. Devuelve un objeto ggplot o gtable
# listo para guardar. No se calcula ninguna métrica del estudio: solo se
# dibujan los valores presentes en los agregados publicados.
# =============================================================================

FUENTE_FIGURAS <- paste(
  "Elaboración propia con ECH 2025, INE.",
  "Pobreza multidimensional: Índice de Pobreza Multidimensional (INE, 2024).",
  "Proyección predictiva, no causal."
)

# Paleta Okabe-Ito; la semántica de colores se mantiene entre figuras.
COLORES_FIGURAS <- c(
  nacional = "#0072B2", beneficiarios = "#D55E00",
  monetaria = "#009E73", amarillo = "#E69F00",
  celeste = "#56B4E9", violeta = "#CC79A7",
  contexto = "#8C8C8C", claro = "#D9D9D9", tinta = "#1A1A1A"
)

ORDEN_METRICAS <- c("Incidencia de pobreza (H)", "Intensidad (A)", "IPM")

# Rótulos legibles de los 15 indicadores del IPM (INE, 2024), en el orden y con
# los nombres usados en todo el estudio.
ROTULOS_INDICADORES <- c(
  hh_no_asiste = "No asistencia", hh_rezago = "Rezago educativo",
  hh_escolaridad = "Baja escolaridad", hh_tenencia = "Tenencia insegura",
  hh_hacinam = "Hacinamiento", hh_problemas_vivienda = "Problemas de vivienda",
  hh_internet = "Sin internet", hh_calefaccion = "Sin calefacción",
  hh_saneamiento = "Saneamiento insuficiente", hh_cuidados = "Sin cuidados",
  hh_pensiones = "Sin pensión", hh_ss_menores = "Menores sin protección",
  hh_informalidad = "Informalidad", hh_desempleo = "Desempleo",
  hh_subempleo = "Subempleo"
)

num_es <- function(x, decimales = 2L) {
  formatC(
    x, format = "f", digits = decimales, big.mark = ".", decimal.mark = ","
  )
}

tema_figuras <- function(base_size = 11) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      plot.title.position = "plot", plot.caption.position = "plot",
      plot.title = ggplot2::element_text(
        face = "bold", size = base_size * 1.42,
        color = COLORES_FIGURAS[["tinta"]]
      ),
      plot.subtitle = ggplot2::element_text(
        size = base_size, color = "#4D4D4D", lineheight = 1.12,
        margin = ggplot2::margin(b = 9)
      ),
      plot.caption = ggplot2::element_text(
        size = base_size * 0.73, color = "#666666", hjust = 0,
        lineheight = 1.12
      ),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "bottom",
      strip.text = ggplot2::element_text(face = "bold"),
      plot.margin = ggplot2::margin(12, 18, 10, 12)
    )
}

.exigir_columnas <- function(registros, columnas, figura,
                             origen = "el payload") {
  faltan <- setdiff(columnas, names(registros))
  if (length(faltan)) {
    stop("Figura ", figura, ": faltan columnas en ", origen, ": ",
         paste(faltan, collapse = ", "), call. = FALSE)
  }
  invisible(TRUE)
}

# Lee una tabla agregada publicada (results/aggregate/tables) validando que
# exista y que traiga las columnas que la figura necesita.
.leer_tabla_publica <- function(dir_tablas, nombre, columnas, figura) {
  if (is.null(dir_tablas) || !nzchar(dir_tablas) || !dir.exists(dir_tablas)) {
    stop("Figura ", figura, ": requiere el directorio de tablas agregadas ",
         "(results/aggregate/tables); ejecute el runner apuntando --data a ",
         "results/aggregate.", call. = FALSE)
  }
  ruta <- file.path(dir_tablas, paste0(nombre, ".csv"))
  if (!file.exists(ruta)) {
    stop("Figura ", figura, ": falta la tabla agregada ", ruta, call. = FALSE)
  }
  tabla <- utils::read.csv(ruta, check.names = FALSE, stringsAsFactors = FALSE)
  .exigir_columnas(tabla, columnas, figura,
                   origen = paste0("la tabla ", nombre))
  tabla
}

# --- 01 · Curvas dosis-respuesta por métrica y lente -------------------------

render_fig_01 <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c(
    "escenario", "lente", "metrica_rotulo", "estimacion_mc", "mc_inferior",
    "mc_superior", "diseno_inferior", "diseno_superior",
    "costo_adicional_anual_mUYU"
  ), "01")
  x$metrica_rotulo <- factor(x$metrica_rotulo, levels = ORDEN_METRICAS)
  costo_por_pct <- unique(
    x$costo_adicional_anual_mUYU[x$escenario == 50]
  ) / 50 / 1000
  central <- x[x$escenario == 50, ]
  central$etiqueta <- paste0(num_es(central$estimacion_mc, 2), " pp")
  ggplot2::ggplot(
    x, ggplot2::aes(escenario, estimacion_mc, color = lente, fill = lente,
                    group = lente)
  ) +
    ggplot2::annotate(
      "rect", xmin = 300, xmax = Inf, ymin = -Inf, ymax = Inf,
      fill = "#EFEFEF", alpha = 0.62
    ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = mc_inferior, ymax = mc_superior),
      alpha = 0.13, color = NA
    ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = diseno_inferior, ymax = diseno_superior),
      alpha = 0.30, color = NA
    ) +
    ggplot2::geom_hline(yintercept = 0, color = "#AAAAAA", linewidth = 0.35) +
    ggplot2::geom_vline(xintercept = 50, linetype = "22", color = "#777777") +
    ggplot2::geom_line(linewidth = 0.85) +
    ggplot2::geom_point(size = 1.45) +
    ggplot2::geom_label(
      data = central, ggplot2::aes(label = etiqueta),
      size = 2.5, linewidth = 0, fill = "white", show.legend = FALSE,
      nudge_x = 18
    ) +
    ggplot2::facet_grid(metrica_rotulo ~ lente, scales = "free_y") +
    ggplot2::scale_color_manual(values = c(
      País = COLORES_FIGURAS[["nacional"]],
      `Personas beneficiarias TUS` = COLORES_FIGURAS[["beneficiarios"]]
    ), guide = "none") +
    ggplot2::scale_fill_manual(values = c(
      País = COLORES_FIGURAS[["nacional"]],
      `Personas beneficiarias TUS` = COLORES_FIGURAS[["beneficiarios"]]
    ), guide = "none") +
    ggplot2::scale_x_continuous(
      breaks = c(50, 250, 500, 750, 1000),
      labels = function(z) paste0("+", z, "%"),
      sec.axis = ggplot2::sec_axis(
        ~ . * costo_por_pct,
        breaks = c(50, 250, 500, 750, 1000) * costo_por_pct,
        labels = function(z) paste0("$", num_es(z, 1), " mil M"),
        name = NULL
      )
    ) +
    ggplot2::labs(
      title = "El aumento de la TUS rinde donde llega",
      subtitle = paste(
        "Cada panel separa medida y lente; +50% es el escenario central.",
        "La zona gris (>300%) es tendencial, no una propuesta factible.",
        "Eje superior: costo adicional anual."
      ),
      x = "Aumento simulado del monto TUS",
      y = "Cambio (puntos en escala 0–100)",
      caption = paste(
        "Banda clara: intervalo Monte Carlo 95%; banda saturada: IC de diseño 95%.",
        FUENTE_FIGURAS
      )
    ) + tema_figuras(9.5) +
    ggplot2::theme(axis.text.x.top = ggplot2::element_text(
      angle = 0, hjust = 0.5, size = 7.5, colour = "#7A7A7A",
      margin = ggplot2::margin(b = 3)
    ))
}

# --- 02 · Incidencia e intensidad por quintil, actual vs. escenario central --
# La incidencia (H) viene del payload; la intensidad (A) por quintil sale de la
# tabla agregada efectos_por_quintil_ingreso.csv.

render_fig_02 <- function(payload, dir_tablas = NULL) {
  q <- payload$records
  .exigir_columnas(q, c("quintil", "escenario", "H_pct", "H_pct_base", "dH_pp"),
                   "02")
  q <- q[q$escenario == 50, ]
  tabla <- .leer_tabla_publica(
    dir_tablas, "efectos_por_quintil_ingreso",
    c("quintil", "escenario", "A_pct", "A_pct_base", "dA_pp"), "02"
  )
  a <- tabla[tabla$escenario == 50, ]
  a <- a[match(q$quintil, a$quintil), ]
  if (anyNA(a$quintil)) {
    stop("Figura 02: la tabla de quintiles no cubre el escenario central.",
         call. = FALSE)
  }
  panel_h <- "Incidencia de pobreza (H)\n¿cuántos son pobres en cada quintil?"
  panel_a <- "Intensidad (A)\n¿qué tan pobres son los pobres de cada quintil?"
  arma <- function(panel, base, post, delta) rbind(
    data.frame(quintil = q$quintil, panel = panel, momento = "Situación actual",
               valor = base, delta = delta),
    data.frame(quintil = q$quintil, panel = panel,
               momento = "Con aumento TUS +50%", valor = post, delta = delta)
  )
  largo <- rbind(
    arma(panel_h, q$H_pct_base, q$H_pct, q$dH_pp),
    arma(panel_a, a$A_pct_base, a$A_pct, a$dA_pp)
  )
  largo$panel <- factor(largo$panel, levels = c(panel_h, panel_a))
  largo$momento <- factor(
    largo$momento, levels = c("Situación actual", "Con aumento TUS +50%")
  )
  largo$destacado <- largo$quintil == 1
  etiquetas <- largo[largo$momento == "Con aumento TUS +50%", ]
  etiquetas$etiqueta <- paste0("Q", etiquetas$quintil, "  ",
                               num_es(etiquetas$delta, 2), " pp")
  anota_h <- data.frame(panel = factor(panel_h, levels = levels(largo$panel)))
  anota_a <- data.frame(panel = factor(panel_a, levels = levels(largo$panel)))
  ggplot2::ggplot(
    largo, ggplot2::aes(momento, valor, group = quintil, color = destacado,
                        linewidth = destacado)
  ) +
    ggplot2::geom_line() + ggplot2::geom_point(size = 2.2) +
    ggplot2::geom_text(
      data = etiquetas,
      ggplot2::aes(momento, valor, label = etiqueta, color = destacado),
      inherit.aes = FALSE, hjust = -0.08, fontface = "bold", size = 2.9
    ) +
    ggplot2::scale_color_manual(values = c(
      `FALSE` = COLORES_FIGURAS[["contexto"]],
      `TRUE` = COLORES_FIGURAS[["beneficiarios"]]
    ), guide = "none") +
    ggplot2::scale_linewidth_manual(values = c(`FALSE` = 0.6, `TRUE` = 1.4),
                                    guide = "none") +
    ggplot2::scale_x_discrete(
      expand = ggplot2::expansion(mult = c(0.16, 0.42))
    ) +
    ggplot2::scale_y_continuous(
      labels = function(z) paste0(num_es(z, 0), "%")
    ) +
    ggplot2::facet_wrap(~panel, scales = "free_y") +
    ggplot2::geom_text(
      data = anota_h, ggplot2::aes(x = 1.5, y = 40),
      label = paste0(
        "Casi 1 de cada 2 personas del quintil\n",
        "más pobre vive en pobreza\nmultidimensional —"
      ),
      inherit.aes = FALSE, color = COLORES_FIGURAS[["beneficiarios"]],
      size = 3.1, lineheight = 1.1
    ) +
    ggplot2::geom_text(
      data = anota_h, ggplot2::aes(x = 1.5, y = 34.2),
      label = "y ahí se concentra\nel efecto del aumento",
      inherit.aes = FALSE, color = COLORES_FIGURAS[["beneficiarios"]],
      size = 3.3, lineheight = 1.1, fontface = "bold"
    ) +
    ggplot2::geom_text(
      data = anota_a, ggplot2::aes(x = 1.5, y = 35.0),
      label = "El aumento no solo saca hogares\nde la pobreza —",
      inherit.aes = FALSE, color = COLORES_FIGURAS[["beneficiarios"]],
      size = 3.1, lineheight = 1.1
    ) +
    ggplot2::geom_text(
      data = anota_a, ggplot2::aes(x = 1.5, y = 34.1),
      label = paste0(
        "también reduce levemente la brecha de\n",
        "privaciones de quienes siguen pobres,\nsobre todo en Q1"
      ),
      inherit.aes = FALSE, color = COLORES_FIGURAS[["beneficiarios"]],
      size = 3.3, lineheight = 1.1, fontface = "bold"
    ) +
    ggplot2::labs(
      title = "La pobreza — y el efecto — viven en el quintil más pobre",
      subtitle = paste(
        "Cada panel compara la situación actual con el escenario +50% y rotula el cambio por quintil. La intensidad (A)\n",
        "solo se calcula entre quienes son pobres: en los quintiles altos casi no hay pobres, por eso sus valores son\n",
        "más inestables."
      ),
      x = NULL, y = NULL,
      caption = paste0(
        "Quintiles de ingreso equivalizado, cada uno con igual población.\n",
        FUENTE_FIGURAS
      )
    ) + tema_figuras(10.5) +
    ggplot2::theme(strip.text = ggplot2::element_text(lineheight = 1.05))
}

# --- 03 · Respuesta de cada carencia y su extensión actual -------------------
# La magnitud mostrada (0 → +50%) se lee de la tabla agregada
# curvas_respuesta_indicadores.csv: probabilidad predicha en el escenario 0
# menos probabilidad en el escenario 50, en puntos porcentuales. El punto 0 de
# esa tabla se valida contra la prevalencia base del payload antes de dibujar.

render_fig_03 <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c(
    "indicador_rotulo", "categoria_rotulo", "prevalencia_predicha_base"
  ), "03")
  curvas <- .leer_tabla_publica(
    dir_tablas, "curvas_respuesta_indicadores",
    c("indicador", "escenario", "probabilidad"), "03"
  )
  if (!all(c(0, 50) %in% curvas$escenario)) {
    stop("Figura 03: la tabla de curvas no cubre los escenarios 0 y 50.",
         call. = FALSE)
  }
  p0 <- curvas[curvas$escenario == 0, ]
  p50 <- curvas[curvas$escenario == 50, ]
  p50 <- p50[match(p0$indicador, p50$indicador), ]
  reduccion <- data.frame(
    indicador_rotulo = unname(ROTULOS_INDICADORES[p0$indicador]),
    reduccion_0_50_pp = 100 * (p0$probabilidad - p50$probabilidad)
  )
  if (anyNA(reduccion$indicador_rotulo)) {
    stop("Figura 03: indicador sin rótulo conocido en la tabla de curvas.",
         call. = FALSE)
  }
  x$reduccion_0_50_pp <- reduccion$reduccion_0_50_pp[
    match(x$indicador_rotulo, reduccion$indicador_rotulo)]
  base_curva <- p0$probabilidad[
    match(x$indicador_rotulo, reduccion$indicador_rotulo)]
  if (anyNA(x$reduccion_0_50_pp) ||
      max(abs(base_curva - x$prevalencia_predicha_base)) > 1e-10) {
    stop("Figura 03: la curva publicada no reproduce el punto 0 del payload.",
         call. = FALSE)
  }
  orden <- x$indicador_rotulo[order(x$reduccion_0_50_pp)]
  panel_red <- "Cuánto cae con el escenario central (0 → +50%)\n(eje: puntos porcentuales de prevalencia)"
  panel_prev <- "Qué tan extendida es hoy\n(eje: % de hogares con la carencia)"
  largo <- rbind(
    data.frame(indicador_rotulo = x$indicador_rotulo, panel = panel_red,
               valor = x$reduccion_0_50_pp,
               categoria_rotulo = x$categoria_rotulo),
    data.frame(indicador_rotulo = x$indicador_rotulo, panel = panel_prev,
               valor = 100 * x$prevalencia_predicha_base,
               categoria_rotulo = x$categoria_rotulo)
  )
  largo$indicador_rotulo <- factor(largo$indicador_rotulo, levels = orden)
  largo$panel <- factor(largo$panel, levels = c(panel_red, panel_prev))
  red <- largo[largo$panel == panel_red, ]
  prev <- largo[largo$panel == panel_prev, ]
  prev_escolaridad <- prev$valor[prev$indicador_rotulo == "Baja escolaridad"]
  red_escolaridad <- red$valor[red$indicador_rotulo == "Baja escolaridad"]
  prev_pension <- prev$valor[prev$indicador_rotulo == "Sin pensión"]
  ggplot2::ggplot(largo, ggplot2::aes(valor, indicador_rotulo)) +
    ggplot2::geom_segment(
      data = red,
      ggplot2::aes(x = 0, xend = valor, yend = indicador_rotulo,
                   color = categoria_rotulo),
      linewidth = 2.6
    ) +
    ggplot2::geom_point(
      data = red, ggplot2::aes(color = categoria_rotulo), size = 3.4
    ) +
    ggplot2::geom_text(
      data = red, ggplot2::aes(label = num_es(valor, 2),
                               color = categoria_rotulo),
      hjust = -0.25, size = 2.9, fontface = "bold", show.legend = FALSE
    ) +
    ggplot2::geom_col(data = prev, fill = "#B9B9B9", width = 0.62) +
    ggplot2::geom_text(
      data = prev, ggplot2::aes(label = paste0(num_es(valor, 0), "%")),
      hjust = -0.12, size = 2.9, color = "#555555"
    ) +
    ggplot2::facet_wrap(~panel, scales = "free_x") +
    ggplot2::scale_x_continuous(
      expand = ggplot2::expansion(mult = c(0.01, 0.15))
    ) +
    ggplot2::scale_color_manual(values = c(
      `Baja respuesta (STOCK)` = COLORES_FIGURAS[["contexto"]],
      `Respuesta intermedia (AMBIGUO)` = COLORES_FIGURAS[["nacional"]],
      `Alta respuesta (FLUJO)` = COLORES_FIGURAS[["beneficiarios"]]
    ), drop = FALSE, name = NULL) +
    ggplot2::labs(
      title = "Dónde actúa el dinero — y dónde no",
      subtitle = paste0(
        "Cada carencia con dos lecturas alineadas: cuánto caería su prevalencia con el aumento del escenario central\n",
        "(izquierda) y qué proporción de hogares la presenta hoy (derecha). Ejemplo: \"Baja escolaridad\" afecta al ",
        num_es(prev_escolaridad, 0), "% de\nlos hogares y caería ",
        num_es(red_escolaridad, 1), " puntos; \"Sin pensión\" afecta al ",
        num_es(prev_pension, 0), "% y casi no responde al ingreso."
      ),
      x = NULL, y = NULL,
      caption = paste0(
        "Clasificación preregistrada de la respuesta al ingreso (grilla 0-30%): STOCK = la carencia casi no cambia al aumentar\n",
        "el ingreso; AMBIGUO = respuesta intermedia; FLUJO = respuesta alta (ningún indicador la alcanzó en esta corrida). La\n",
        "magnitud mostrada llega al escenario central (+50%), calculada con los mismos modelos y validada contra el punto 0.\n",
        "Las categorías describen respuesta predictiva; no estiman eficacia causal. ",
        FUENTE_FIGURAS
      )
    ) + tema_figuras(9.6) +
    ggplot2::theme(
      strip.text = ggplot2::element_text(lineheight = 1.05),
      legend.position = "top", legend.justification = "left"
    )
}

# --- 04 · Composición del IPM por dimensión y su reducción -------------------

render_fig_04 <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c("nivel", "panel", "rotulo", "valor", "bajo", "alto"),
                   "04")
  x <- x[x$nivel == "dimension", ]
  paneles <- c(
    `Composición actual` =
      "Composición actual del IPM\n(eje: % del índice; las cinco suman 100)",
    `Cambio — país` = "Reducción con +50% — país\n(eje: milésimas del IPM)",
    `Cambio — beneficiarios TUS` =
      "Reducción con +50% — beneficiarios TUS\n(eje: milésimas del IPM)"
  )
  x$panel <- factor(unname(paneles[x$panel]), levels = unname(paneles))
  base <- x[x$panel == paneles[[1]], ]
  carencias_dim <- c(
    `Educación` = "no asistencia, rezago y baja escolaridad",
    `Vivienda` = "tenencia insegura, hacinamiento y problemas de la vivienda",
    `Servicios básicos` = "falta de internet, calefacción y saneamiento",
    `Protección social` = "falta de cuidados, pensiones y protección de menores",
    `Empleo` = "informalidad, desempleo y subempleo"
  )
  lider <- base[which.max(base$valor), ]
  lider_ef <- x[
    x$rotulo == lider$rotulo & x$panel == paneles[[3]],
  ]
  ejemplo <- sprintf(
    paste0("Las carencias de %s — %s — explican hoy el %s%% de la pobreza multidimensional;\n",
           "con un aumento de +50%%, su aporte al IPM de los beneficiarios se reduce %s milésimas."),
    tolower(lider$rotulo), unname(carencias_dim[lider$rotulo]),
    num_es(lider$valor, 1), num_es(lider_ef$valor, 1)
  )
  ggplot2::ggplot(x, ggplot2::aes(valor, rotulo)) +
    ggplot2::geom_col(
      data = x[is.na(x$bajo), ], fill = COLORES_FIGURAS[["nacional"]],
      width = 0.62
    ) +
    ggplot2::geom_text(
      data = x[is.na(x$bajo), ],
      ggplot2::aes(label = paste0(num_es(valor, 1), "%")),
      hjust = -0.12, size = 3, color = "#333333"
    ) +
    ggplot2::geom_errorbar(
      data = x[!is.na(x$bajo), ],
      ggplot2::aes(xmin = bajo, xmax = alto), orientation = "y",
      width = 0.16, linewidth = 2.1, alpha = 0.35,
      color = COLORES_FIGURAS[["beneficiarios"]]
    ) +
    ggplot2::geom_point(
      data = x[!is.na(x$bajo), ], size = 2.7,
      color = COLORES_FIGURAS[["beneficiarios"]]
    ) +
    ggplot2::facet_wrap(~panel, scales = "free_x", nrow = 1) +
    ggplot2::scale_x_continuous(
      expand = ggplot2::expansion(mult = c(0.02, 0.16))
    ) +
    ggplot2::labs(
      title = "De qué está hecha la pobreza — y qué parte se mueve",
      subtitle = ejemplo,
      x = NULL, y = NULL,
      caption = paste0(
        "Barras: rango central 95% de la simulación. Los cierres de Alkire-Foster se validan antes de dibujar.\n",
        FUENTE_FIGURAS
      )
    ) + tema_figuras(9.5) +
    ggplot2::theme(strip.text = ggplot2::element_text(lineheight = 1.05))
}

# --- 05 · Mosaico pobreza IPM × elegibilidad ICC (corte TUS, personas) -------

render_fig_05 <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c(
    "cuadrante", "elegibilidad", "unidad", "xmin", "xmax", "ymin", "ymax",
    "proporcion"
  ), "05")
  x <- x[x$elegibilidad == "pe_tus23" & x$unidad == "personas", ]
  x$es_elegible <- !grepl("no elegible", x$cuadrante, ignore.case = TRUE)
  x$relleno <- ifelse(x$es_elegible, COLORES_FIGURAS[["nacional"]], "#D8D8D8")
  x$color_texto <- ifelse(x$es_elegible, "white", COLORES_FIGURAS[["tinta"]])
  x$area <- (x$xmax - x$xmin) * (x$ymax - x$ymin)
  texto_celda <- gsub(", ", "\n", x$cuadrante, fixed = TRUE)
  texto_celda <- gsub(" y ", "\ny ", texto_celda, fixed = TRUE)
  x$texto <- paste0(texto_celda, "\n", num_es(100 * x$proporcion, 1), "%")
  grandes <- x[x$area > 0.03, ]
  pequena <- x[x$area <= 0.03, ]
  # La figura estática presenta un único corte (TUS), por lo que el pie usa la
  # redacción publicada sin repetir el corte.
  nota_ic <- sub(", corte TUS:", ":", payload$spec$ic_note, fixed = TRUE)
  ggplot2::ggplot(x) +
    ggplot2::geom_rect(
      ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                   fill = relleno),
      color = "white", linewidth = 1.2
    ) +
    ggplot2::geom_text(
      data = grandes,
      ggplot2::aes(x = (xmin + xmax) / 2, y = (ymin + ymax) / 2,
                   label = texto, color = color_texto),
      size = 3.2, lineheight = 1.05, show.legend = FALSE
    ) +
    ggplot2::geom_segment(
      data = pequena,
      ggplot2::aes(x = (xmin + xmax) / 2, y = (ymin + ymax) / 2,
                   xend = 0.72, yend = -0.045),
      color = COLORES_FIGURAS[["nacional"]], linewidth = 0.45
    ) +
    ggplot2::annotate(
      "text", x = 0.72, y = -0.07, hjust = 0,
      label = paste0(pequena$cuadrante, ": ",
                     num_es(100 * pequena$proporcion, 1), "%"),
      color = COLORES_FIGURAS[["nacional"]], fontface = "bold", size = 3.1
    ) +
    ggplot2::scale_fill_identity() + ggplot2::scale_color_identity() +
    ggplot2::coord_fixed(xlim = c(0, 1), ylim = c(-0.11, 1), clip = "off") +
    ggplot2::labs(
      title = "Instrumentos distintos, poblaciones que se solapan",
      subtitle = paste0(
        "Área = proporción de personas. El ancho separa pobreza IPM y la altura, ",
        "elegibilidad TUS según ICC.\nNinguna clasificación es patrón de verdad de la otra."
      ),
      x = "Pobreza multidimensional (IPM)", y = "Elegibilidad por ICC",
      caption = paste0(
        payload$spec$note, "\n", nota_ic, ".\n",
        "Elaboración propia con ECH 2025, INE. Pobreza multidimensional: Índice de Pobreza Multidimensional (INE, 2024).\n",
        "Proyección predictiva, no causal."
      )
    ) + tema_figuras(10.5) +
    ggplot2::theme(axis.text = ggplot2::element_blank(),
                   panel.grid = ggplot2::element_blank())
}

# --- 06 · Bono Crianza 2026: intervalos por métrica y lente ------------------
# La equivalencia en hogares del subtítulo se calcula con los agregados
# publicados: hogares_expandidos y costo anual de bono_crianza_escenarios.csv,
# y estimación e intervalo de diseño de bono_crianza_aumento_2026.csv.

render_fig_06 <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c(
    "lente", "metrica_rotulo", "estimacion", "mc_p2_5", "mc_p97_5",
    "diseno_inferior", "diseno_superior"
  ), "06")
  x$lente <- factor(x$lente, levels = c("Hogares beneficiarios", "País"))
  x$metrica_rotulo <- factor(x$metrica_rotulo, levels = ORDEN_METRICAS)
  escenarios <- .leer_tabla_publica(
    dir_tablas, "bono_crianza_escenarios",
    c("escenario", "costo_anual_UYU", "hogares_expandidos"), "06"
  )
  fila <- escenarios[grepl("aumento_bono_crianza_2026", escenarios$escenario), ]
  if (nrow(fila) != 1L) {
    stop("Figura 06: la tabla de escenarios no tiene un único escenario 2026.",
         call. = FALSE)
  }
  detalle <- .leer_tabla_publica(
    dir_tablas, "bono_crianza_aumento_2026",
    c("universo", "metrica", "estimacion", "diseno_inferior",
      "diseno_superior"), "06"
  )
  h <- detalle[detalle$universo == "hogares_afectados" &
                 detalle$metrica == "H", ]
  est_payload <- x$estimacion[
    x$lente == "Hogares beneficiarios" &
      x$metrica_rotulo == "Incidencia de pobreza (H)"]
  if (nrow(h) != 1L || abs(h$estimacion - est_payload) > 1e-9) {
    stop("Figura 06: la tabla del Bono no reproduce la estimación del payload.",
         call. = FALSE)
  }
  hogares <- fila$hogares_expandidos
  salen <- round(-h$estimacion / 100 * hogares)
  rango <- sort(round(-c(h$diseno_inferior, h$diseno_superior) / 100 * hogares))
  # El porcentaje del gasto TUS solo está publicado dentro de la nota del spec;
  # se extrae de ahí (si la nota cambiara, el pie conserva la nota completa).
  pct_gasto <- sub(".*; *([0-9.,]+% del gasto TUS observado[^.]*)\\.?$", "\\1",
                   payload$spec$note)
  linea_costo <- if (identical(pct_gasto, payload$spec$note)) {
    payload$spec$note
  } else {
    paste0("Costo anual: $", num_es(fila$costo_anual_UYU / 1e6, 1),
           " millones (", pct_gasto, ").")
  }
  ggplot2::ggplot(x, ggplot2::aes(estimacion, metrica_rotulo)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "22", color = "#777777") +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = mc_p2_5, xmax = mc_p97_5,
                   color = "Variación Monte Carlo"),
      orientation = "y", width = 0.22, linewidth = 1.4, alpha = 0.42
    ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = diseno_inferior, xmax = diseno_superior,
                   color = "Incertidumbre de la encuesta"),
      orientation = "y", width = 0.08, linewidth = 3.0
    ) +
    ggplot2::geom_point(size = 2.4, color = COLORES_FIGURAS[["tinta"]]) +
    ggplot2::geom_text(
      ggplot2::aes(label = num_es(estimacion, 2)),
      vjust = -1.5, size = 3.1, fontface = "bold",
      color = COLORES_FIGURAS[["tinta"]]
    ) +
    ggplot2::geom_text(
      ggplot2::aes(x = diseno_inferior, label = num_es(diseno_inferior, 2)),
      vjust = 2.6, hjust = 0.9, size = 2.5,
      color = COLORES_FIGURAS[["nacional"]]
    ) +
    ggplot2::geom_text(
      ggplot2::aes(x = diseno_superior, label = num_es(diseno_superior, 2)),
      vjust = 2.6, hjust = 0.1, size = 2.5,
      color = COLORES_FIGURAS[["nacional"]]
    ) +
    ggplot2::geom_text(
      ggplot2::aes(x = mc_p2_5, label = num_es(mc_p2_5, 2)),
      vjust = -1.6, hjust = 0.9, size = 2.4, alpha = 0.85,
      color = COLORES_FIGURAS[["beneficiarios"]]
    ) +
    ggplot2::geom_text(
      ggplot2::aes(x = mc_p97_5, label = num_es(mc_p97_5, 2)),
      vjust = -1.6, hjust = 0.1, size = 2.4, alpha = 0.85,
      color = COLORES_FIGURAS[["beneficiarios"]]
    ) +
    ggplot2::facet_wrap(~lente, scales = "free_x") +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.14)) +
    ggplot2::scale_color_manual(values = c(
      `Variación Monte Carlo` = COLORES_FIGURAS[["beneficiarios"]],
      `Incertidumbre de la encuesta` = COLORES_FIGURAS[["nacional"]]
    ), name = NULL) +
    ggplot2::labs(
      title = "Bono Crianza 2026: qué cambia para quienes lo reciben",
      subtitle = paste0(
        "Entre ", num_es(hogares, 0),
        " hogares beneficiarios, la proyección central equivale a ",
        num_es(salen, 0), " hogares menos en pobreza-IPM (IC de diseño: ",
        num_es(rango[1], 0), "–", num_es(rango[2], 0),
        "). El valor central va en negro;\nlos extremos de cada intervalo, ",
        "en el color de su banda."
      ),
      x = "Cambio (puntos en escala 0–100)", y = NULL,
      caption = paste0(
        "La banda Monte Carlo de H llega a cero y la de A lo cruza; por esa fuente sola ",
        "no se descarta cambio nulo.\n", linea_costo, "\n", FUENTE_FIGURAS
      )
    ) + tema_figuras(10)
}

# --- 07 · Frontera costo-efecto y contrastes pareados entre reglas -----------

render_fig_07 <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c(
    "tipo", "escenario", "costo", "reduccion", "eficiencia", "etiqueta",
    "media", "p2_5", "p97_5"
  ), "07")
  eficiencia <- x[x$tipo == "eficiencia", ]
  forest <- x[x$tipo == "contraste", ]
  forest$par <- factor(forest$etiqueta, levels = rev(forest$etiqueta))
  # Con números aleatorios comunes, la media pareada equivale a la diferencia
  # de efectos medios: el rango entre reglas es el mayor |media| de los pares.
  rango <- max(abs(forest$media))

  p_a <- ggplot2::ggplot(eficiencia, ggplot2::aes(costo, reduccion)) +
    ggplot2::geom_line(color = COLORES_FIGURAS[["contexto"]]) +
    ggplot2::geom_point(ggplot2::aes(color = eficiencia), size = 3) +
    ggplot2::geom_text(ggplot2::aes(label = etiqueta), nudge_y = 0.06,
                       size = 2.5, color = "#555555") +
    ggplot2::scale_color_gradient(
      low = COLORES_FIGURAS[["beneficiarios"]],
      high = COLORES_FIGURAS[["monetaria"]],
      name = "Reducción de incidencia\npor $1.000 millones (pp)"
    ) +
    ggplot2::labs(
      title = "Cuánto rinde el gasto — y cómo repartirlo",
      subtitle = paste0(
        "A. Cuánto rinde cada peso: a mayor gasto, la reducción sigue creciendo\n",
        "pero cada vez más despacio (los puntos pasan del verde al naranja)."
      ),
      x = "Costo adicional anual (miles de millones de $)",
      y = "Reducción de la incidencia de pobreza (H), pp",
      caption = paste0(
        "Contrastes pareados con números aleatorios comunes:\n",
        "misma simulación, solo cambia la regla.\n",
        "Elaboración propia con ECH 2025, INE. Pobreza multidimensional: Índice de Pobreza\n",
        "Multidimensional (INE, 2024). Proyección predictiva, no causal."
      )
    ) + tema_figuras(9.5) +
    ggplot2::theme(
      legend.position = "inside",
      legend.position.inside = c(0.8, 0.25),
      legend.background = ggplot2::element_rect(fill = "white",
                                                colour = "grey85")
    )

  p_b <- ggplot2::ggplot(forest, ggplot2::aes(media, par)) +
    ggplot2::geom_vline(xintercept = 0, linetype = "22", color = "#777777") +
    ggplot2::annotate(
      "text", x = 0, y = nrow(forest) + 0.7,
      label = "0 = las dos reglas rinden igual",
      size = 2.8, color = "#777777", hjust = -0.05
    ) +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = p2_5, xmax = p97_5), orientation = "y",
      width = 0.18, linewidth = 1.1, color = COLORES_FIGURAS[["nacional"]]
    ) +
    ggplot2::geom_point(size = 2.4, color = COLORES_FIGURAS[["nacional"]]) +
    ggplot2::scale_y_discrete(expand = ggplot2::expansion(add = c(0.4, 1.2))) +
    ggplot2::scale_x_continuous(labels = function(z) num_es(z, 2)) +
    ggplot2::labs(
      title = "",
      subtitle = paste0(
        "B. ¿Cambia el resultado según CÓMO se reparte? No: con el mismo\n",
        "presupuesto, las 10 comparaciones entre reglas cruzan el cero\n",
        "(izquierda del 0 = la primera regla del par reduce más la pobreza)."
      ),
      x = "Diferencia de efecto entre las dos reglas (pp)", y = NULL,
      caption = paste0(
        "Reglas: a = proporcional al monto actual · b = suma fija por hogar · c = focalizada en el\n",
        "cluster vulnerable · d = proporcional a los menores · e = focalizada en TUS pobres-IPM.\n",
        "Los cinco efectos difieren a lo sumo ", num_es(rango, 3), " pp."
      )
    ) + tema_figuras(9.5) +
    ggplot2::theme(axis.text.y = ggplot2::element_text(size = 8.5,
                                                       face = "bold"))

  cbind(ggplot2::ggplotGrob(p_a), ggplot2::ggplotGrob(p_b), size = "first")
}

# --- 08 · Sensibilidad al umbral k ------------------------------------------
# Ningún agregado publicado trae la magnitud de la segunda prueba (contraste
# por tipo de tarjeta), por lo que el pie conserva la conclusión cualitativa
# sin el valor puntual.

render_fig_08 <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c("panel", "alternativa", "rol", "valor", "bajo", "alto"),
                   "08")
  ggplot2::ggplot(x, ggplot2::aes(valor, alternativa)) +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = bajo, xmax = alto), orientation = "y",
      width = 0.16, linewidth = 1.6, alpha = 0.3,
      color = COLORES_FIGURAS[["nacional"]]
    ) +
    ggplot2::geom_point(ggplot2::aes(shape = rol, color = rol, size = rol)) +
    ggplot2::geom_text(
      ggplot2::aes(label = paste0(num_es(valor, 2), " pp")),
      vjust = -1.1, size = 3.1, fontface = "bold", show.legend = FALSE
    ) +
    ggplot2::scale_shape_manual(
      values = c(`Elección del estudio` = 18, Alternativa = 16), name = NULL
    ) +
    ggplot2::scale_color_manual(values = c(
      `Elección del estudio` = COLORES_FIGURAS[["beneficiarios"]],
      Alternativa = "#555555"
    ), name = NULL) +
    ggplot2::scale_size_manual(
      values = c(`Elección del estudio` = 4.6, Alternativa = 2.9), name = NULL
    ) +
    ggplot2::facet_wrap(~panel) +
    ggplot2::scale_x_continuous(labels = function(z) num_es(z, 2)) +
    ggplot2::labs(
      title = "Las conclusiones no penden de un supuesto",
      subtitle = paste0(
        "El resultado central del estudio (+50% de TUS: −0,25 pp de incidencia nacional) se recalculó cambiando el umbral\n",
        "que define quién es pobre. Si el resultado dependiera de esa elección sería frágil; la diferencia es de centésimas."
      ),
      x = "Cambio nacional en la incidencia de pobreza (H) con +50%, puntos porcentuales",
      y = NULL,
      caption = paste0(
        "Barras: rango central 95% de la simulación de cada variante. Segunda prueba, no graficada por estar en otra escala:\n",
        "re-estimar el tipo de tarjeta (simple/doble) del escenario Bono con el método anterior no cambia esa conclusión\n",
        "(el intervalo pareado cruza el cero). ",
        FUENTE_FIGURAS
      )
    ) + tema_figuras(10) +
    ggplot2::theme(strip.text = ggplot2::element_text(hjust = 0),
                   legend.position = "top", legend.justification = "left")
}

# --- 09 · Cobertura del cluster vulnerable ----------------------------------

render_fig_09 <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c(
    "segmento", "barra", "valor", "total_barra", "score_vulnerable", "ratio"
  ), "09")
  pais <- x$total_barra[x$barra == "Hogares del país"][1]
  vuln <- x$valor[x$segmento == "Cluster vulnerable"]
  cubierto <- x$valor[x$segmento == "Con TUS o AFAM-PE"]
  sin_cob <- x$valor[x$segmento == "Sin TUS ni AFAM-PE"]
  mil <- function(n) num_es(n / 1000, 0)
  pct <- function(n, tot) num_es(100 * n / tot, 1)
  # Escala absoluta compartida: la barra del zoom mide lo mismo que su
  # segmento en la barra del país.
  seg <- data.frame(
    xmin = c(0, vuln, 0, cubierto),
    xmax = c(vuln, pais, cubierto, vuln),
    y = c(1, 1, 2, 2),
    fill = c(COLORES_FIGURAS[["nacional"]], "#D8D8D8",
             COLORES_FIGURAS[["beneficiarios"]], COLORES_FIGURAS[["contexto"]])
  )
  ggplot2::ggplot(seg) +
    ggplot2::annotate(
      "segment", x = c(0, vuln), xend = c(0, vuln), y = 1.31, yend = 1.69,
      linetype = "22", color = "grey60", linewidth = 0.35
    ) +
    ggplot2::geom_rect(
      ggplot2::aes(xmin = xmin, xmax = xmax, ymin = y - 0.3, ymax = y + 0.3,
                   fill = fill),
      color = "white", linewidth = 0.9
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::annotate(
      "text", x = vuln / 2, y = 1,
      label = paste0("Cluster vulnerable\n", mil(vuln), " mil hogares (",
                     pct(vuln, pais), "%)"),
      color = "white", size = 3.2, lineheight = 1.05, fontface = "bold"
    ) +
    ggplot2::annotate(
      "text", x = vuln + (pais - vuln) / 2, y = 1,
      label = paste0("Resto de los hogares del país\n", mil(pais - vuln),
                     " mil (", pct(pais - vuln, pais), "%)"),
      color = "#444444", size = 3.2, lineheight = 1.05
    ) +
    ggplot2::annotate(
      "text", x = 0, y = 2.48, hjust = 0,
      label = paste0("Recibe TUS o AFAM-PE: ", mil(cubierto), " mil (",
                     pct(cubierto, vuln), "%)"),
      color = COLORES_FIGURAS[["beneficiarios"]], size = 3.2, fontface = "bold"
    ) +
    ggplot2::annotate(
      "text", x = vuln + 0.02 * pais, y = 2, hjust = 0,
      label = paste0("No recibe ninguna:\n", mil(sin_cob), " mil (",
                     pct(sin_cob, vuln), "%)"),
      color = "#555555", size = 3.2, lineheight = 1.05
    ) +
    ggplot2::scale_y_continuous(
      breaks = c(1, 2),
      labels = c("Hogares del país", "Zoom al cluster\nvulnerable"),
      limits = c(0.55, 2.75)
    ) +
    ggplot2::scale_x_continuous(
      labels = NULL, expand = ggplot2::expansion(mult = c(0.005, 0.02))
    ) +
    ggplot2::labs(
      title = "El mapa de la cobertura",
      subtitle = paste0(
        "Ambas barras comparten la misma escala: la de arriba es el zoom al bloque azul de abajo. El cluster vulnerable\n",
        "es el grupo con mayor nivel de privaciones (score IPM ",
        num_es(x$score_vulnerable[1], 3), ", ~", num_es(x$ratio[1], 1),
        " veces el promedio de los otros dos),\nidentificado sin mirar quién cobra."
      ),
      x = NULL, y = NULL,
      caption = paste0(
        "La TUS está diseñada para los hogares de menores recursos; el mapa describe la división de tareas entre instrumentos, no una falla.\n",
        FUENTE_FIGURAS
      )
    ) + tema_figuras(10) +
    ggplot2::theme(panel.grid = ggplot2::element_blank(),
                   axis.text.y = ggplot2::element_text(face = "bold",
                                                       lineheight = 1.05))
}

# --- 10 · Incidencia IPM y monetaria por dosis y lente -----------------------

render_fig_10 <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c("escenario", "lente", "medida", "cambio"), "10")
  central <- x[x$escenario == 50, ]
  central$etiqueta <- paste0(num_es(central$cambio, 2), " pp")
  central$vjust_et <- ifelse(central$medida == "IPM", -0.2, 1.7)
  marca_50 <- data.frame(lente = unique(x$lente))
  ggplot2::ggplot(x, ggplot2::aes(escenario, cambio, color = medida)) +
    ggplot2::geom_hline(yintercept = 0, color = "#AAAAAA") +
    ggplot2::geom_vline(
      data = marca_50, ggplot2::aes(xintercept = 50),
      linetype = "22", color = COLORES_FIGURAS[["beneficiarios"]],
      linewidth = 0.5
    ) +
    ggplot2::geom_text(
      data = marca_50, ggplot2::aes(x = 50, y = Inf),
      label = "escenario central +50%", vjust = 1.6, hjust = -0.05,
      size = 2.9, color = COLORES_FIGURAS[["beneficiarios"]],
      fontface = "bold", inherit.aes = FALSE
    ) +
    ggplot2::geom_line(linewidth = 0.9) + ggplot2::geom_point(size = 1.5) +
    ggplot2::geom_point(data = central, size = 3.2, show.legend = FALSE) +
    ggplot2::geom_label(
      data = central, ggplot2::aes(label = etiqueta, vjust = vjust_et),
      size = 2.6, linewidth = 0, fill = "white", nudge_x = 26,
      fontface = "bold", show.legend = FALSE
    ) +
    ggplot2::facet_wrap(~lente, scales = "free_y") +
    ggplot2::scale_color_manual(values = c(
      IPM = COLORES_FIGURAS[["nacional"]],
      `Pobreza monetaria` = COLORES_FIGURAS[["monetaria"]]
    ), name = NULL) +
    ggplot2::scale_x_continuous(breaks = c(10, 50, 100, 300, 500, 1000)) +
    ggplot2::labs(
      title = "Dos varas, una historia",
      subtitle = paste(
        "La pobreza monetaria responde al cruce de una línea de ingreso; el IPM requiere",
        "que cambien varias carencias.\nLos valores rotulados corresponden al escenario",
        "central (+50%), marcado con la línea punteada naranja."
      ),
      x = "Aumento del monto TUS (%)",
      y = "Cambio en la incidencia (puntos porcentuales)",
      caption = FUENTE_FIGURAS
    ) + tema_figuras(10.5)
}

# --- Piezas editoriales: portada del README y tarjeta social -----------------
# Ambas reutilizan el payload de la figura 01: todos los números provienen de
# ese agregado; solo cambia la composición.

# Versión editorial horizontal de la curva dosis-respuesta: solo incidencia
# (H), las dos lentes lado a lado, marca en +50% y costo anual arriba.
# Pensada para ~1600×800 px y legible reducida a 1000 px de ancho.
render_hero_dosis <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c(
    "escenario", "lente", "metrica_rotulo", "estimacion_mc", "mc_inferior",
    "mc_superior", "diseno_inferior", "diseno_superior",
    "costo_adicional_anual_mUYU"
  ), "hero")
  x <- x[x$metrica_rotulo == "Incidencia de pobreza (H)", ]
  x$lente <- factor(x$lente, levels = c("País", "Personas beneficiarias TUS"))
  costo_por_pct <- unique(
    x$costo_adicional_anual_mUYU[x$escenario == 50]
  ) / 50 / 1000
  central <- x[x$escenario == 50, ]
  central$etiqueta <- paste0(num_es(central$estimacion_mc, 2), " pp")
  lectura <- paste0(
    "El efecto se concentra en quienes reciben la transferencia: con +50%, ",
    "la incidencia entre beneficiarios\ncae ",
    num_es(abs(central$estimacion_mc[
      central$lente == "Personas beneficiarias TUS"]), 2),
    " pp y el promedio país, ",
    num_es(abs(central$estimacion_mc[central$lente == "País"]), 2),
    " pp. La zona gris (>300%) es tendencial, no una propuesta factible."
  )
  ggplot2::ggplot(
    x, ggplot2::aes(escenario, estimacion_mc, color = lente, fill = lente,
                    group = lente)
  ) +
    ggplot2::annotate(
      "rect", xmin = 300, xmax = Inf, ymin = -Inf, ymax = Inf,
      fill = "#EFEFEF", alpha = 0.62
    ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = mc_inferior, ymax = mc_superior),
      alpha = 0.13, color = NA
    ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = diseno_inferior, ymax = diseno_superior),
      alpha = 0.30, color = NA
    ) +
    ggplot2::geom_hline(yintercept = 0, color = "#AAAAAA", linewidth = 0.4) +
    ggplot2::geom_vline(xintercept = 50, linetype = "22", color = "#777777") +
    ggplot2::geom_line(linewidth = 1.1) +
    ggplot2::geom_point(size = 1.8) +
    ggplot2::geom_point(data = central, size = 3.4, show.legend = FALSE) +
    ggplot2::geom_label(
      data = central, ggplot2::aes(label = etiqueta),
      size = 3.6, linewidth = 0, fill = "white", fontface = "bold",
      show.legend = FALSE, nudge_x = 24, vjust = 1.15
    ) +
    ggplot2::facet_wrap(~lente, nrow = 1, scales = "free_y") +
    ggplot2::scale_color_manual(values = c(
      País = COLORES_FIGURAS[["nacional"]],
      `Personas beneficiarias TUS` = COLORES_FIGURAS[["beneficiarios"]]
    ), guide = "none") +
    ggplot2::scale_fill_manual(values = c(
      País = COLORES_FIGURAS[["nacional"]],
      `Personas beneficiarias TUS` = COLORES_FIGURAS[["beneficiarios"]]
    ), guide = "none") +
    ggplot2::scale_x_continuous(
      breaks = c(50, 250, 500, 750, 1000),
      labels = function(z) paste0("+", z, "%"),
      sec.axis = ggplot2::sec_axis(
        ~ . * costo_por_pct,
        breaks = c(50, 250, 500, 750, 1000) * costo_por_pct,
        labels = function(z) paste0("$", num_es(z, 1), " mil M"),
        name = NULL
      )
    ) +
    ggplot2::labs(
      title = "El aumento de la TUS rinde donde llega",
      subtitle = lectura,
      x = "Aumento simulado del monto TUS",
      y = "Cambio en la incidencia (H), pp",
      caption = paste0(
        "Banda clara: intervalo Monte Carlo 95%; banda saturada: IC de diseño ",
        "95%. Eje superior: costo adicional anual.\n", FUENTE_FIGURAS
      )
    ) + tema_figuras(10.5) +
    ggplot2::theme(
      plot.subtitle = ggplot2::element_text(
        size = 9.5, color = "#4D4D4D", lineheight = 1.2,
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        size = 6.8, color = "#666666", hjust = 0, lineheight = 1.15
      ),
      axis.text.x.top = ggplot2::element_text(
        size = 7.5, colour = "#7A7A7A", margin = ggplot2::margin(b = 3)
      ),
      strip.text = ggplot2::element_text(size = 10.5)
    )
}

# Tarjeta social 1280×640 para la vista previa del repositorio: título del
# estudio, dato central y una miniatura simplificada de la curva de
# beneficiarios (sin ejes detallados). Azules sobrios sobre fondo claro.
render_social_preview <- function(payload, dir_tablas = NULL) {
  x <- payload$records
  .exigir_columnas(x, c("escenario", "lente", "metrica_rotulo",
                        "estimacion_mc"), "social")
  h <- x[x$metrica_rotulo == "Incidencia de pobreza (H)", ]
  ben <- h[h$lente == "Personas beneficiarias TUS", ]
  ben <- ben[order(ben$escenario), ]
  pais <- h[h$lente == "País", ]
  v_ben <- ben$estimacion_mc[ben$escenario == 50]
  v_pais <- pais$estimacion_mc[pais$escenario == 50]
  menos <- function(v) paste0("−", num_es(abs(v), 2))
  azul <- COLORES_FIGURAS[["nacional"]]
  azul_oscuro <- "#0b3a5c"
  # Miniatura: curva de beneficiarios reescalada al cuadrante inferior derecho
  # del lienzo 1280×640.
  cx0 <- 830; cx1 <- 1205; cy0 <- 130; cy1 <- 345
  esc <- ben$escenario
  val <- ben$estimacion_mc
  mini <- data.frame(
    x = cx0 + (esc - min(esc)) / (max(esc) - min(esc)) * (cx1 - cx0),
    y = cy0 + (val - min(val)) / (max(val) - min(val)) * (cy1 - cy0)
  )
  marca <- mini[ben$escenario == 50, ]
  ggplot2::ggplot() +
    ggplot2::annotate("rect", xmin = 0, xmax = 1280, ymin = 0, ymax = 640,
                      fill = "#F4F8FB") +
    ggplot2::annotate("rect", xmin = 0, xmax = 14, ymin = 0, ymax = 640,
                      fill = azul) +
    ggplot2::annotate(
      "text", x = 70, y = 575, hjust = 0, vjust = 1, size = 6.6,
      lineheight = 1.12, fontface = "bold", color = azul_oscuro,
      label = paste0("Microsimulación de aumentos de la\n",
                     "Tarjeta Uruguay Social y pobreza\nmultidimensional")
    ) +
    ggplot2::annotate(
      "text", x = 70, y = 402, hjust = 0, vjust = 1, size = 4.4,
      color = azul, fontface = "bold", label = "Uruguay · ECH 2025"
    ) +
    ggplot2::annotate(
      "text", x = 70, y = 312, hjust = 0, vjust = 1, size = 10.5,
      fontface = "bold", color = azul_oscuro,
      label = paste0(menos(v_ben), " pp")
    ) +
    ggplot2::annotate(
      "text", x = 70, y = 200, hjust = 0, vjust = 1, size = 4.2,
      color = "#3D5A73", lineheight = 1.15,
      label = paste0("de incidencia de pobreza multidimensional entre\n",
                     "beneficiarios con un aumento de +50% (",
                     menos(v_pais), " pp país)")
    ) +
    ggplot2::annotate(
      "text", x = 70, y = 78, hjust = 0, vjust = 1, size = 3.4,
      color = "#6B7F90",
      label = "Proyección predictiva, no causal · datos y figuras reproducibles"
    ) +
    ggplot2::annotate(
      "text", x = cx0, y = 424, hjust = 0, vjust = 1, size = 3.2,
      color = "#6B7F90", label = "Curva dosis-respuesta (beneficiarios)"
    ) +
    ggplot2::annotate(
      "segment", x = cx0, xend = cx1, y = 392, yend = 392,
      color = "#C8D8E4", linewidth = 0.7
    ) +
    ggplot2::geom_line(data = mini, ggplot2::aes(x, y), color = azul,
                       linewidth = 1.7, lineend = "round") +
    ggplot2::annotate("point", x = marca$x, y = marca$y, color = azul_oscuro,
                      size = 4.2) +
    ggplot2::annotate(
      "text", x = marca$x + 16, y = marca$y + 26, hjust = 0, size = 3.9,
      fontface = "bold", color = azul_oscuro, label = "+50%"
    ) +
    ggplot2::scale_x_continuous(limits = c(0, 1280), expand = c(0, 0)) +
    ggplot2::scale_y_continuous(limits = c(0, 640), expand = c(0, 0)) +
    ggplot2::coord_fixed() +
    ggplot2::theme_void()
}

# --- Registro: nombre de payload → renderer y dimensiones (pulgadas) ---------

registro_figuras <- function() {
  list(
    `01_el_aumento_rinde_donde_llega` = list(render_fig_01, 12.6, 10.2),
    `02_pobreza_y_efecto_por_quintil` = list(render_fig_02, 10.8, 7.0),
    `03_donde_actua_el_dinero` = list(render_fig_03, 11.0, 7.5),
    `04_de_que_esta_hecha_la_pobreza` = list(render_fig_04, 12.0, 6.0),
    `05_instrumentos_y_poblaciones` = list(render_fig_05, 10.5, 7.0),
    `06_bono_crianza_2026` = list(render_fig_06, 11.5, 6.0),
    `07_cuanto_rinde_y_como_repartir` = list(render_fig_07, 13.0, 7.2),
    `08_conclusiones_y_supuestos` = list(render_fig_08, 11.8, 5.5),
    `09_mapa_de_la_cobertura` = list(render_fig_09, 11.0, 5.2),
    `10_dos_varas_una_historia` = list(render_fig_10, 11.0, 6.2)
  )
}
