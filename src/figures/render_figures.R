#!/usr/bin/env Rscript

# Reconstruye las diez figuras del estudio a partir de los agregados
# publicados (payloads de figure-data y tablas de tables).
#
# Uso, desde la raíz del repositorio:
#   Rscript src/figures/render_figures.R --data results/aggregate --output figures
#
# `--data` acepta la raíz de los agregados (results/aggregate, forma
# recomendada) o, por compatibilidad, el directorio de payloads
# (results/aggregate/figure-data); en ese caso las tablas se buscan en el
# directorio hermano `tables`.
#
# Escribe <output>/png/<figura>.png (300 dpi) y <output>/pdf/<figura>.pdf.
#
# Con `--assets <directorio>` genera además las piezas editoriales:
#   <directorio>/hero-dose-response.png y .pdf  (portada del README)
#   <directorio>/social-preview.png             (tarjeta 1280×640)

paquetes <- c("jsonlite", "ggplot2")
faltan <- paquetes[!vapply(paquetes, requireNamespace, logical(1),
                           quietly = TRUE)]
if (length(faltan)) {
  stop("Faltan paquetes requeridos: ", paste(faltan, collapse = ", "),
       call. = FALSE)
}

args <- commandArgs(trailingOnly = TRUE)

leer_arg <- function(nombre, defecto = NULL) {
  i <- match(nombre, args)
  if (is.na(i)) {
    if (is.null(defecto)) {
      stop("Falta el argumento obligatorio ", nombre, call. = FALSE)
    }
    return(defecto)
  }
  if (i == length(args) || startsWith(args[i + 1L], "--")) {
    stop("El argumento ", nombre, " requiere un valor.", call. = FALSE)
  }
  args[i + 1L]
}

dir_datos <- leer_arg("--data", "results/aggregate")
dir_salida <- leer_arg("--output")
dir_assets <- if ("--assets" %in% args) leer_arg("--assets") else NULL

# El registro de renderers vive junto a este script.
arg_script <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (!length(arg_script)) {
  stop("Este script debe ejecutarse con Rscript.", call. = FALSE)
}
dir_script <- dirname(normalizePath(sub("^--file=", "", arg_script[1L])))
source(file.path(dir_script, "renderers.R"))

if (!dir.exists(dir_datos)) {
  stop("No existe el directorio de datos: ", dir_datos, call. = FALSE)
}
# Forma recomendada: la raíz de los agregados contiene figure-data/ y tables/.
# Compatibilidad: si --data apunta directo a figure-data, las tablas se
# resuelven en el directorio hermano.
if (dir.exists(file.path(dir_datos, "figure-data"))) {
  dir_payloads <- file.path(dir_datos, "figure-data")
  dir_tablas <- file.path(dir_datos, "tables")
} else {
  dir_payloads <- dir_datos
  dir_tablas <- file.path(dirname(dir_datos), "tables")
}
if (!dir.exists(dir_tablas)) {
  dir_tablas <- NULL
  message("Aviso: no se encontró el directorio de tablas agregadas; ",
          "las figuras que las requieren se detendrán con un error claro.")
}
dir.create(file.path(dir_salida, "png"), recursive = TRUE,
           showWarnings = FALSE)
dir.create(file.path(dir_salida, "pdf"), recursive = TRUE,
           showWarnings = FALSE)

# Dispositivo nulo: evita que la composición de grobs (figura 07) abra el
# dispositivo por defecto y deje un Rplots.pdf suelto al correr con Rscript.
grDevices::pdf(NULL)

leer_payload <- function(ruta) {
  if (!file.exists(ruta)) {
    stop("Falta el payload: ", ruta, call. = FALSE)
  }
  payload <- jsonlite::read_json(ruta, simplifyVector = TRUE)
  if (!is.data.frame(payload$records) || is.null(payload$spec)) {
    stop("Payload sin records/spec: ", ruta, call. = FALSE)
  }
  payload
}

registro <- registro_figuras()
for (nombre in names(registro)) {
  entrada <- registro[[nombre]]
  payload <- leer_payload(file.path(dir_payloads, paste0(nombre, ".json")))
  grafico <- entrada[[1L]](payload, dir_tablas)
  ggplot2::ggsave(
    file.path(dir_salida, "png", paste0(nombre, ".png")), grafico,
    width = entrada[[2L]], height = entrada[[3L]], dpi = 300, bg = "white"
  )
  ggplot2::ggsave(
    file.path(dir_salida, "pdf", paste0(nombre, ".pdf")), grafico,
    width = entrada[[2L]], height = entrada[[3L]],
    device = grDevices::cairo_pdf, bg = "white"
  )
  message("Figura generada: ", nombre)
}

message("Listo: ", length(registro), " figuras en ", dir_salida)

if (!is.null(dir_assets)) {
  dir.create(dir_assets, recursive = TRUE, showWarnings = FALSE)
  payload_01 <- leer_payload(
    file.path(dir_payloads, "01_el_aumento_rinde_donde_llega.json")
  )
  hero <- render_hero_dosis(payload_01, dir_tablas)
  # 8×4 pulgadas a 200 dpi = 1600×800 px.
  ggplot2::ggsave(
    file.path(dir_assets, "hero-dose-response.png"), hero,
    width = 8, height = 4, dpi = 200, bg = "white"
  )
  ggplot2::ggsave(
    file.path(dir_assets, "hero-dose-response.pdf"), hero,
    width = 8, height = 4, device = grDevices::cairo_pdf, bg = "white"
  )
  social <- render_social_preview(payload_01, dir_tablas)
  # 8×4 pulgadas a 160 dpi = 1280×640 px (vista previa social de GitHub).
  ggplot2::ggsave(
    file.path(dir_assets, "social-preview.png"), social,
    width = 8, height = 4, dpi = 160, bg = "#F4F8FB"
  )
  message("Piezas editoriales generadas en ", dir_assets)
}

invisible(grDevices::dev.off())
