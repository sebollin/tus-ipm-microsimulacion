# Verificación de publicación
# ---------------------------
# Comprueba, desde un clon limpio, que el repositorio cumple sus promesas:
#   1. los diez payloads de figuras existen, parsean y tienen el esquema declarado;
#   2. cada payload coincide (SHA-256) con el embebido en su figura interactiva;
#   3. las tablas agregadas existen, cargan y no contienen identificadores;
#   4. no hay ningún archivo de microdatos en el árbol.
#
# Uso:  Rscript tests/verificar_publicacion.R
# Requiere: jsonlite, digest

suppressMessages({
  library(jsonlite)
  library(digest)
})

raiz <- normalizePath(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE)[1])), ".."))
fallas <- character(0)
anotar <- function(msg) fallas <<- c(fallas, msg)

# 1-2. Payloads de figuras: esquema e integridad contra el HTML interactivo -----
dir_data <- file.path(raiz, "results", "aggregate", "figure-data")
payloads <- sort(list.files(dir_data, pattern = "\\.json$"))
if (length(payloads) != 10L) anotar(sprintf("Se esperaban 10 payloads, hay %d", length(payloads)))

for (p in payloads) {
  ruta <- file.path(dir_data, p)
  obj <- tryCatch(fromJSON(ruta, simplifyVector = FALSE), error = function(e) NULL)
  if (is.null(obj)) { anotar(sprintf("%s: no parsea como JSON", p)); next }
  if (!all(c("records", "spec") %in% names(obj))) anotar(sprintf("%s: falta records/spec", p))
  if (length(obj$records) == 0L) anotar(sprintf("%s: records vacío", p))
  if (!all(c("kind", "title") %in% names(obj$spec))) anotar(sprintf("%s: spec incompleta", p))

  texto <- paste(readLines(ruta, warn = FALSE), collapse = "\n")
  sha_archivo <- digest(texto, algo = "sha256", serialize = FALSE)
  html <- file.path(raiz, "site", "figures", sub("\\.json$", ".html", p))
  if (!file.exists(html)) { anotar(sprintf("%s: falta la figura interactiva", p)); next }
  contenido <- paste(readLines(html, warn = FALSE), collapse = "\n")
  sha_html <- regmatches(contenido, regexpr("data-sha256='[0-9a-f]{64}'", contenido))
  sha_html <- sub(".*'([0-9a-f]{64})'.*", "\\1", sha_html)
  if (!identical(sha_archivo, sha_html))
    anotar(sprintf("%s: SHA-256 no coincide con el HTML (%s vs %s)", p, sha_archivo, sha_html))
}

# 3. Tablas agregadas: existencia, carga y ausencia de identificadores ----------
dir_tablas <- file.path(raiz, "results", "aggregate", "tables")
tablas <- sort(list.files(dir_tablas, pattern = "\\.csv$"))
if (length(tablas) != 14L) anotar(sprintf("Se esperaban 14 tablas, hay %d", length(tablas)))

prohibidas <- c("ID", "id", "nper", "numero", "correlativo", "cedula", "documento")
for (t in tablas) {
  df <- tryCatch(read.csv(file.path(dir_tablas, t), nrows = 5), error = function(e) NULL)
  if (is.null(df)) { anotar(sprintf("%s: no carga", t)); next }
  malas <- intersect(names(df), prohibidas)
  if (length(malas)) anotar(sprintf("%s: columnas de identificador: %s", t, paste(malas, collapse = ", ")))
}

# 4. Ningún archivo de microdatos en el árbol ----------------------------------
ext_prohibidas <- "\\.(rds|RData|Rdata|dta|sav|parquet|arrow|feather|fst|sqlite|duckdb)$"
todo <- list.files(raiz, recursive = TRUE, all.files = TRUE, no.. = TRUE)
micro <- grep(ext_prohibidas, todo, value = TRUE, ignore.case = TRUE)
if (length(micro)) anotar(sprintf("Archivos de microdatos presentes: %s", paste(micro, collapse = ", ")))

# 5. Las diez figuras estáticas ------------------------------------------------
for (sub in c("png", "pdf")) {
  n <- length(list.files(file.path(raiz, "figures", sub), pattern = paste0("\\.", sub, "$")))
  if (n != 10L) anotar(sprintf("figures/%s: se esperaban 10 archivos, hay %d", sub, n))
}

# Veredicto --------------------------------------------------------------------
if (length(fallas)) {
  cat("VERIFICACIÓN FALLÓ:\n")
  cat(paste0("  - ", fallas, collapse = "\n"), "\n")
  quit(status = 1L)
}
cat("Verificación de publicación: OK",
    sprintf("(%d payloads, %d tablas, integridad SHA-256 confirmada)\n",
            length(payloads), length(tablas)))
