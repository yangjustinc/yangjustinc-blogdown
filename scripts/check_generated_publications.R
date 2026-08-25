#!/usr/bin/env Rscript

required_files <- c(
  "content/publications/index.html",
  "content/publications/justin-yang-publications.bib",
  "data/generated/openalex-publications.json"
)

missing_or_empty <- required_files[
  !file.exists(required_files) |
    file.info(required_files)$size <= 0
]

if (length(missing_or_empty) > 0) {
  stop(
    "Required publication output is missing or empty: ",
    paste(missing_or_empty, collapse = ", ")
  )
}

openalex <- jsonlite::fromJSON("data/generated/openalex-publications.json")
if (!is.data.frame(openalex) || nrow(openalex) < 20) {
  stop("OpenAlex publication cache contains fewer than 20 records.")
}

if ("doi" %in% names(openalex)) {
  doi <- tolower(trimws(openalex$doi))
  doi <- doi[!is.na(doi) & nzchar(doi)]
  if (anyDuplicated(doi)) {
    stop("OpenAlex publication cache contains duplicate non-empty DOIs.")
  }
}

bib_lines <- readLines(
  "content/publications/justin-yang-publications.bib",
  warn = FALSE,
  encoding = "UTF-8"
)
bib_entries <- sum(grepl("^\\s*@", bib_lines))
if (bib_entries < 20) {
  stop("Generated BibTeX contains fewer than 20 entries.")
}

message(
  "Publication outputs look plausible: ",
  nrow(openalex), " OpenAlex records; ", bib_entries, " BibTeX entries."
)
