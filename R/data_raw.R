# Carga de parquet raw (ZSTD → Snappy). El filtrado electoral está en scripts/01_prepare_data.R

project_root <- function() {
  path <- normalizePath(getwd(), mustWork = FALSE)
  for (i in seq_len(20L)) {
    if (file.exists(file.path(path, "right_fragmented.Rproj"))) {
      return(path)
    }
    parent <- dirname(path)
    if (identical(parent, path)) break
    path <- parent
  }
  stop(
    "No se encontró right_fragmented.Rproj. ",
    "Abre el proyecto en RStudio o setwd() a la raíz del repo."
  )
}

raw_paths <- function(root = project_root()) {
  raw <- file.path(root, "data", "raw")
  list(
    root = root,
    raw = raw,
    parquet_zstd = file.path(raw, "reddit_comentarios_unido.parquet"),
    parquet_snappy = file.path(raw, "reddit_comentarios_unido_snappy.parquet"),
    csv = file.path(raw, "reddit_comentarios_unido.csv"),
    posts = file.path(raw, "reddit_posts.parquet")
  )
}

prepare_comentarios_unido <- function(overwrite = FALSE, verbose = TRUE) {
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("Instala arrow: install.packages('arrow')")
  }

  p <- raw_paths()
  if (!dir.exists(p$raw)) {
    stop("No existe ", p$raw, ". Revisa enlaces a thesis_maci (ver data/raw/README.md).")
  }

  needs_build <- overwrite || !file.exists(p$parquet_snappy)
  if (!needs_build) {
    src_time <- max(
      file.mtime(p$parquet_zstd),
      if (file.exists(p$csv)) file.mtime(p$csv) else 0,
      na.rm = TRUE
    )
    if (file.mtime(p$parquet_snappy) < src_time) {
      needs_build <- TRUE
    }
  }

  if (!needs_build) {
    if (verbose) message("OK (ya actualizado): ", p$parquet_snappy)
    return(invisible(p$parquet_snappy))
  }

  tab <- NULL

  if (file.exists(p$parquet_zstd)) {
    if (verbose) message("Leyendo parquet original…")
    tab <- tryCatch(
      arrow::read_parquet(p$parquet_zstd),
      error = function(e) {
        if (verbose) {
          message(
            "No se pudo leer ZSTD (", conditionMessage(e), "). ",
            "Usando CSV…"
          )
        }
        NULL
      }
    )
  }

  if (is.null(tab)) {
    if (!file.exists(p$csv)) {
      stop(
        "Falta ", p$csv, " y no se pudo leer el parquet ZSTD.\n",
        "Opcional: install.packages('arrow', repos = 'https://apache.r-universe.dev')"
      )
    }
    if (!requireNamespace("readr", quietly = TRUE)) {
      stop("Instala readr: install.packages('readr')")
    }
    if (verbose) message("Leyendo CSV (puede tardar varios minutos)…")
    tab <- readr::read_csv(p$csv, show_col_types = FALSE, progress = verbose)
  }

  if (verbose) message("Escribiendo parquet Snappy…")
  arrow::write_parquet(tab, p$parquet_snappy, compression = "snappy")

  if (verbose) {
    message(
      "Listo: ", p$parquet_snappy,
      " (", format(nrow(tab), big.mark = "."), " filas)"
    )
  }
  invisible(p$parquet_snappy)
}

as_tibble_parquet <- function(path) {
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("Instala arrow: install.packages('arrow')")
  }
  x <- arrow::read_parquet(path, as_data_frame = TRUE)
  if (inherits(x, "ArrowTabular") || inherits(x, "ArrowObject")) {
    x <- as.data.frame(x)
  }
  if (requireNamespace("tibble", quietly = TRUE)) {
    return(tibble::as_tibble(x))
  }
  x
}

load_comentarios_unido <- function(prepare = TRUE, ...) {
  p <- raw_paths()
  if (prepare) prepare_comentarios_unido(...)
  if (!file.exists(p$parquet_snappy)) {
    stop("No existe ", p$parquet_snappy, ". Ejecuta prepare_comentarios_unido().")
  }
  as_tibble_parquet(p$parquet_snappy)
}

load_posts <- function() {
  p <- raw_paths()
  if (!file.exists(p$posts)) {
    stop("No existe ", p$posts)
  }
  as_tibble_parquet(p$posts)
}
