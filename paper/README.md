# Paper — `right_fragmented`

Artículo derivado de la tesis (`thesis_maci`), redactado en **Quarto** por secciones.

## Estructura

```
paper/docs/
├── _quarto.yml           # Configuración del manuscrito (book)
├── index.qmd             # Portada y resumen
├── 01-introduccion.qmd
├── 02-marco-teorico.qmd
├── 03-metodos.qmd
├── 04-resultados.qmd
├── 05-conclusion.qmd
├── references.qmd
└── bibliography.bib
```

## Trabajar por apartado

Desde `paper/docs/`:

```bash
# Vista previa de un capítulo (HTML)
quarto preview 03-metodos.qmd

# Renderizar solo un capítulo
quarto render 02-marco-teorico.qmd
```

Cada `.qmd` es autocontenido: puedes escribir y revisar un apartado sin tocar el resto.

## Compilar el paper completo

```bash
cd paper/docs
quarto render --to html    # recomendado para revisión rápida
quarto render --to pdf     # manuscrito PDF (requiere LaTeX)
quarto render              # HTML + PDF

Cuando tengas citas en `bibliography.bib`, descomenta `references.qmd` en `_quarto.yml` (capítulos y `render:`).
```

Salidas en `paper/docs/_output/` (nombre según título del libro en `_quarto.yml`).

## Requisitos

- [Quarto](https://quarto.org/) ≥ 1.4
- R (opcional, para chunks R) o solo texto si no usas código en los `.qmd`
- Para PDF: distribución LaTeX (TinyTeX recomendado: `quarto install tinytex`)

## Bibliografía

Añade referencias en `bibliography.bib`. Las citas usan Pandoc (`@clave2024`).

## Datos

Los datos raw están en `../../data/raw/` (enlaces a `thesis_maci`). En métodos/resultados, usa rutas relativas al repo, por ejemplo `../../data/raw/reddit_comentarios_unido.parquet`.
