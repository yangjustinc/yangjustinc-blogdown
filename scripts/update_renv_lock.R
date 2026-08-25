#!/usr/bin/env Rscript

description <- read.dcf("DESCRIPTION")
fields <- intersect(c("Depends", "Imports", "LinkingTo"), colnames(description))
raw_dependencies <- paste(description[1, fields], collapse = ",")
packages <- trimws(unlist(strsplit(raw_dependencies, ",", fixed = TRUE)))
packages <- sub("\\s*\\([^)]*\\)\\s*$", "", packages)
packages <- unique(packages[nzchar(packages) & packages != "R"])

if (length(packages) == 0) {
  stop("No runtime R dependencies were found in DESCRIPTION.")
}

message("Resolving ", length(packages), " direct R dependencies from repositories.")
renv::checkout(
  packages = packages,
  actions = "snapshot",
  dependencies = c("Depends", "Imports", "LinkingTo"),
  restart = FALSE,
  project = "."
)

if (!file.exists("renv.lock") || file.info("renv.lock")$size <= 0) {
  stop("renv did not produce a non-empty renv.lock.")
}
