normalize_doi <- function(x) {
  x |>
    stringr::str_to_lower() |>
    stringr::str_squish() |>
    stringr::str_remove("^https?://(dx\\.)?doi\\.org/") |>
    dplyr::na_if("")
}

collapse_openalex_topics <- function(x) {
  if (is.null(x) || length(x) == 0 || (length(x) == 1 && is.na(x))) {
    return(NA_character_)
  }

  values <- unlist(x, recursive = TRUE, use.names = TRUE)
  if (length(values) == 0) {
    return(NA_character_)
  }

  value_names <- names(values)
  if (is.null(value_names)) {
    value_names <- rep("", length(values))
  }
  keep <- stringr::str_detect(
    value_names,
    "display_name"
  )

  if (any(keep)) {
    values <- values[keep]
  }

  values <- values[!is.na(values) & values != ""]
  if (length(values) == 0) {
    return(NA_character_)
  }

  paste(unique(as.character(values)), collapse = " | ")
}

empty_openalex_enrichment <- function() {
  tibble::tibble(
    doi = character(),
    openalex_id = character(),
    openalex_source = character(),
    openalex_topics = character(),
    is_open_access = logical(),
    open_access_status = character(),
    open_access_url = character()
  )
}

openalex_column <- function(x, candidates, default = NA) {
  candidate <- candidates[candidates %in% names(x)][1]
  if (length(candidate) == 0 || is.na(candidate)) {
    return(rep(default, nrow(x)))
  }
  x[[candidate]]
}

fetch_openalex_chunk <- function(dois) {
  result <- tryCatch(
    openalexR::oa_fetch(
      entity = "works",
      doi = dois,
      abstract = FALSE,
      verbose = FALSE
    ),
    error = function(e) {
      warning("OpenAlex enrichment failed: ", conditionMessage(e))
      NULL
    }
  )

  if (is.null(result) || nrow(result) == 0) {
    return(empty_openalex_enrichment())
  }

  raw_doi <- openalex_column(result, c("doi", "DI"), NA_character_)
  topic_values <- openalex_column(
    result,
    c("topics", "primary_topic", "concepts"),
    list(NULL)
  )

  if (!is.list(topic_values)) {
    topic_values <- as.list(topic_values)
  }

  is_oa <- openalex_column(
    result,
    c("is_oa", "is_oa_anywhere"),
    NA
  )

  tibble::tibble(
    doi = normalize_doi(raw_doi),
    openalex_id = as.character(
      openalex_column(result, c("id", "id_oa"), NA_character_)
    ),
    openalex_source = as.character(
      openalex_column(result, "source_display_name", NA_character_)
    ),
    openalex_topics = purrr::map_chr(
      topic_values,
      collapse_openalex_topics
    ),
    is_open_access = as.logical(is_oa),
    open_access_status = as.character(
      openalex_column(result, "oa_status", NA_character_)
    ),
    open_access_url = as.character(
      openalex_column(result, "oa_url", NA_character_)
    )
  ) |>
    dplyr::filter(!is.na(.data$doi)) |>
    dplyr::distinct(.data$doi, .keep_all = TRUE)
}

fetch_openalex_enrichment <- function(dois, chunk_size = 20L) {
  dois <- unique(stats::na.omit(normalize_doi(dois)))
  if (length(dois) == 0) {
    return(empty_openalex_enrichment())
  }

  chunks <- split(dois, ceiling(seq_along(dois) / chunk_size))
  purrr::map_dfr(chunks, fetch_openalex_chunk) |>
    dplyr::distinct(.data$doi, .keep_all = TRUE)
}

publication_cache_only <- function() {
  tolower(Sys.getenv("PUBLICATIONS_USE_CACHE_ONLY", unset = "false")) %in%
    c("1", "true", "yes")
}

refresh_openalex_enrichment <- function(dois, cache_path) {
  requested_dois <- unique(stats::na.omit(normalize_doi(dois)))

  cached <- if (file.exists(cache_path)) {
    tryCatch(
      jsonlite::read_json(
        cache_path,
        simplifyVector = TRUE
      ) |>
        tibble::as_tibble(),
      error = function(e) empty_openalex_enrichment()
    )
  } else {
    empty_openalex_enrichment()
  }

  if (!"doi" %in% names(cached)) {
    cached <- empty_openalex_enrichment()
  }

  cached <- cached |>
    dplyr::mutate(doi = normalize_doi(.data$doi)) |>
    dplyr::filter(.data$doi %in% requested_dois)

  fresh <- if (publication_cache_only()) {
    empty_openalex_enrichment()
  } else {
    fetch_openalex_enrichment(requested_dois)
  }

  enrichment <- dplyr::bind_rows(
    fresh |>
      dplyr::mutate(cache_priority = 1L),
    cached |>
      dplyr::mutate(cache_priority = 2L)
  ) |>
    dplyr::arrange(.data$cache_priority) |>
    dplyr::distinct(.data$doi, .keep_all = TRUE) |>
    dplyr::select(-.data$cache_priority) |>
    dplyr::filter(.data$doi %in% requested_dois) |>
    dplyr::arrange(.data$doi)

  dir.create(dirname(cache_path), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(
    enrichment,
    cache_path,
    dataframe = "rows",
    auto_unbox = TRUE,
    pretty = TRUE,
    na = "null"
  )

  enrichment
}

classify_research_strand <- function(title, openalex_topics = NA_character_) {
  text <- paste(
    dplyr::coalesce(title, ""),
    dplyr::coalesce(openalex_topics, "")
  ) |>
    stringr::str_to_lower()

  dplyr::case_when(
    stringr::str_detect(
      text,
      "autis|neurodiver|special education|school registry|school-age|pupil|record-linked|administrative data|spatial analysis"
    ) ~ "administrative",
    stringr::str_detect(
      text,
      "sexual orientation|gender identity|lgbt|minority|inequal|unmet need|depriv|socioeconomic|social determinant"
    ) ~ "inequalities",
    stringr::str_detect(
      text,
      "addiction|substance|alcohol|opioid|drug use|e-cigarette|tobacco|buprenorphine|methadone|chemsex|psychoactive"
    ) ~ "addiction",
    stringr::str_detect(
      text,
      "antipsychotic|in-patient|inpatient|hospital|rehabilitation|clinical record|electronic health record|mental health service|treatment order|prescribing|adverse drug"
    ) ~ "clinical",
    TRUE ~ "population"
  )
}

classify_selected_strand <- function(theme) {
  theme <- stringr::str_to_lower(dplyr::coalesce(theme, ""))
  dplyr::case_when(
    stringr::str_detect(theme, "clinical") ~ "clinical",
    stringr::str_detect(theme, "administrative|neurodiverg") ~ "administrative",
    stringr::str_detect(theme, "addiction") ~ "addiction",
    stringr::str_detect(theme, "inequal") ~ "inequalities",
    TRUE ~ NA_character_
  )
}

research_strand_labels <- c(
  clinical = "Clinical data",
  administrative = "Administrative data",
  addiction = "Addiction",
  inequalities = "Inequalities",
  population = "Population health"
)

add_publication_ids <- function(publications) {
  doi_key <- normalize_doi(publications$doi)
  title_key <- publications$title |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^a-z0-9]+", "-") |>
    stringr::str_remove_all("(^-|-$)")

  base_key <- dplyr::if_else(
    !is.na(doi_key),
    doi_key,
    title_key
  ) |>
    stringr::str_replace_all("[^a-z0-9]+", "-") |>
    stringr::str_sub(1, 72)

  publications$publication_id <- make.unique(
    paste0("publication-", base_key),
    sep = "-"
  )
  publications
}

bibtex_escape <- function(x) {
  x <- dplyr::coalesce(x, "")
  x <- gsub("\\\\", "\\\\textbackslash{}", x)
  gsub("([#$%&_])", "\\\\\\1", x, perl = TRUE)
}

fallback_bibtex <- function(title, journal, year, doi, type) {
  entry_type <- dplyr::case_when(
    type == "journal-article" ~ "article",
    type == "book-chapter" ~ "incollection",
    TRUE ~ "misc"
  )

  fields <- c(
    paste0("  title = {", bibtex_escape(title), "}"),
    if (!is.na(journal) && journal != "")
      paste0("  journal = {", bibtex_escape(journal), "}"),
    if (!is.na(year)) paste0("  year = {", year, "}"),
    if (!is.na(doi) && doi != "")
      paste0("  doi = {", bibtex_escape(doi), "}"),
    if (!is.na(doi) && doi != "")
      paste0("  url = {https://doi.org/", bibtex_escape(doi), "}")
  )

  paste0(
    "@", entry_type, "{placeholder,\n",
    paste(fields, collapse = ",\n"),
    "\n}"
  )
}

make_bibtex_key <- function(title, year) {
  words <- title |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^a-z0-9 ]+", " ") |>
    stringr::str_squish() |>
    stringr::str_split(" ")

  stop_words <- c(
    "a", "an", "and", "among", "for", "from", "in", "of", "on", "the",
    "to", "using", "with"
  )

  slug <- purrr::map_chr(words, function(x) {
    x <- x[!x %in% stop_words]
    paste(utils::head(x, 3), collapse = "")
  })

  paste0("yang", dplyr::coalesce(as.character(year), "nd"), slug)
}

replace_bibtex_key <- function(record, key) {
  stringr::str_replace(
    record,
    "^(@[[:alnum:]_:-]+\\{)[^,]+",
    paste0("\\1", key)
  )
}

fetch_crossref_bibtex <- function(doi) {
  if (is.na(doi) || doi == "") {
    return(NA_character_)
  }

  tryCatch({
    result <- rcrossref::cr_cn(
      dois = doi,
      format = "bibtex",
      raw = TRUE
    )
    result <- paste(as.character(result), collapse = "\n") |>
      stringr::str_trim() |>
      stringr::str_replace_all(
        stringr::fixed("&amp;"),
        function(match) paste0(intToUtf8(92), "&")
      )
    if (!stringr::str_detect(result, "^@[[:alnum:]_:-]+\\{")) {
      return(NA_character_)
    }
    result
  }, error = function(e) NA_character_)
}

empty_crossref_bibtex_cache <- function() {
  tibble::tibble(
    doi = character(),
    bibtex = character(),
    citation = character()
  )
}

read_crossref_cache <- function(cache_path) {
  cached <- if (file.exists(cache_path)) {
    tryCatch(
      jsonlite::read_json(cache_path, simplifyVector = TRUE) |>
        tibble::as_tibble(),
      error = function(e) empty_crossref_bibtex_cache()
    )
  } else {
    empty_crossref_bibtex_cache()
  }

  if (!"doi" %in% names(cached)) {
    return(empty_crossref_bibtex_cache())
  }
  if (!"bibtex" %in% names(cached)) cached$bibtex <- NA_character_
  if (!"citation" %in% names(cached)) cached$citation <- NA_character_

  cached |>
    dplyr::transmute(
      doi = normalize_doi(.data$doi),
      bibtex = as.character(.data$bibtex),
      citation = as.character(.data$citation)
    ) |>
    dplyr::filter(!is.na(.data$doi)) |>
    dplyr::distinct(.data$doi, .keep_all = TRUE)
}

write_crossref_cache <- function(cached, cache_path) {
  dir.create(dirname(cache_path), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(
    cached |>
      dplyr::arrange(.data$doi),
    cache_path,
    dataframe = "rows",
    auto_unbox = TRUE,
    pretty = TRUE,
    na = "null"
  )
}

fetch_crossref_citation <- function(doi) {
  result <- tryCatch(
    rcrossref::cr_cn(dois = doi, format = "text"),
    error = function(e) NA_character_
  )
  if (length(result) != 1 || is.na(result) || result == "") {
    return(NA_character_)
  }
  as.character(result) |>
    stringr::str_replace_all(
      stringr::regex("&amp;", ignore_case = TRUE),
      "&"
    )
}

refresh_crossref_citations <- function(dois, cache_path) {
  requested_dois <- unique(stats::na.omit(normalize_doi(dois)))
  cached <- read_crossref_cache(cache_path)

  fresh <- if (publication_cache_only()) {
    tibble::tibble(doi = character(), citation = character())
  } else {
    tibble::tibble(
      doi = requested_dois,
      citation = purrr::map_chr(requested_dois, fetch_crossref_citation)
    ) |>
      dplyr::filter(!is.na(.data$citation))
  }

  citations <- dplyr::bind_rows(
    fresh |> dplyr::mutate(cache_priority = 1L),
    cached |>
      dplyr::select(.data$doi, .data$citation) |>
      dplyr::filter(!is.na(.data$citation)) |>
      dplyr::mutate(cache_priority = 2L)
  ) |>
    dplyr::arrange(.data$cache_priority) |>
    dplyr::distinct(.data$doi, .keep_all = TRUE) |>
    dplyr::select(-.data$cache_priority)

  updated <- cached |>
    dplyr::select(.data$doi, .data$bibtex) |>
    dplyr::full_join(citations, by = "doi")
  write_crossref_cache(updated, cache_path)

  citations |>
    dplyr::filter(.data$doi %in% requested_dois)
}

generate_bibtex_records <- function(publications, cache_path) {
  publication_dois <- unique(stats::na.omit(normalize_doi(publications$doi)))
  cached <- read_crossref_cache(cache_path)

  fresh <- if (publication_cache_only()) {
    tibble::tibble(doi = character(), bibtex = character())
  } else {
    tibble::tibble(
      doi = publication_dois,
      bibtex = purrr::map_chr(
        publication_dois,
        fetch_crossref_bibtex
      )
    ) |>
      dplyr::filter(!is.na(.data$bibtex))
  }

  bibtex_cache <- dplyr::bind_rows(
    fresh |>
      dplyr::mutate(cache_priority = 1L),
    cached |>
      dplyr::select(.data$doi, .data$bibtex) |>
      dplyr::filter(!is.na(.data$bibtex)) |>
      dplyr::mutate(cache_priority = 2L)
  ) |>
    dplyr::arrange(.data$cache_priority) |>
    dplyr::distinct(.data$doi, .keep_all = TRUE) |>
    dplyr::select(-.data$cache_priority) |>
    dplyr::arrange(.data$doi)

  updated <- bibtex_cache |>
    dplyr::full_join(
      cached |>
        dplyr::select(.data$doi, .data$citation),
      by = "doi"
    )
  write_crossref_cache(updated, cache_path)

  cached_lookup <- stats::setNames(
    bibtex_cache$bibtex,
    bibtex_cache$doi
  )

  raw_records <- purrr::pmap_chr(
    publications |>
      dplyr::select(
        .data$title,
        .data$journal,
        .data$year,
        .data$doi,
        .data$type
    ),
    function(title, journal, year, doi, type) {
      normalised_doi <- normalize_doi(doi)
      if (
        !is.na(normalised_doi) &&
        normalised_doi %in% names(cached_lookup)
      ) {
        return(unname(cached_lookup[[normalised_doi]]))
      }
      fallback_bibtex(title, journal, year, doi, type)
    }
  )

  keys <- make.unique(
    make_bibtex_key(publications$title, publications$year),
    sep = "_"
  )

  filename_stems <- paste0(
    dplyr::coalesce(as.character(publications$year), "undated"),
    "-",
    publications$title |>
      stringr::str_to_lower() |>
      stringr::str_replace_all("[^a-z0-9]+", "-") |>
      stringr::str_remove_all("(^-|-$)") |>
      stringr::str_sub(1, 64)
  )

  filenames <- paste0(make.unique(filename_stems, sep = "-"), ".bib")

  tibble::tibble(
    publication_id = publications$publication_id,
    bibtex_key = keys,
    bibtex = purrr::map2_chr(raw_records, keys, replace_bibtex_key),
    bibtex_filename = filenames
  )
}

citation_to_html <- function(citation) {
  citation <- citation |>
    stringr::str_remove("\\s*https://doi\\.org/\\S+\\s*\\.?$") |>
    htmltools::htmlEscape() |>
    as.character()

  citation |>
    stringr::str_replace_all("\\*\\*([^*]+)\\*\\*", "<strong>\\1</strong>") |>
    stringr::str_replace_all("\\*([^*]+)\\*", "<em>\\1</em>")
}
