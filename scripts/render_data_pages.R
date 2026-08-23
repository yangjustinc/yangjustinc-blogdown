pages <- c(
  "content/funding/index.Rmd",
  "content/leadership/index.Rmd",
  "content/publications/index.Rmd",
  "content/talks/index.Rmd",
  "content/teaching/index.Rmd"
)

missing_pages <- pages[!file.exists(pages)]
if (length(missing_pages) > 0) {
  stop("Missing R Markdown source files: ", paste(missing_pages, collapse = ", "))
}

blogdown::build_site(
  run_hugo = FALSE,
  build_rmd = pages
)
