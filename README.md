# MINDSET academic website

Source for [www.justinyang.me](https://www.justinyang.me/), the academic
website for **MINDSET (Multimodal INference and Data Science for Epidemiology
and Treatment)**, the research programme led by Dr Justin C Yang at University
College London.

The site presents the programme's research, people and collaborations,
publications, funding, talks, teaching and supervision, academic leadership,
and contact information.

## Site structure

| Path | Purpose |
| --- | --- |
| [`content/_index.md`](./content/_index.md) | Homepage |
| [`content/research/`](./content/research/) | Research programme |
| [`content/people/`](./content/people/) | Research team, doctoral researchers, partners and collaborators |
| [`content/publications/`](./content/publications/) | Selected and complete publications |
| [`content/funding/`](./content/funding/) | Research funding |
| [`content/talks/`](./content/talks/) | Talks and presentations |
| [`content/teaching/`](./content/teaching/) | Teaching, supervision and researcher development |
| [`content/leadership/`](./content/leadership/) | Academic leadership and recognition |
| [`content/contact/`](./content/contact/) | Contact information |
| [`data/site/`](./data/site/) | Curated CSV inputs used by R Markdown pages |
| [`layouts/`](./layouts/) | Site-level Hugo layouts, partials and shortcodes |
| [`assets/css/style.css`](./assets/css/style.css) | Site-wide styling, processed and fingerprinted by Hugo |
| [`themes/hugo-xmin/`](./themes/hugo-xmin/) | Pinned `hugo-xmin` Git submodule |
| [`scripts/`](./scripts/) | Rendering and validation utilities |
| [`.github/workflows/`](./.github/workflows/) | Build validation and content refresh workflows |

## Technology and build boundary

The site uses:

- [Hugo](https://gohugo.io/) with the
  [`hugo-xmin`](https://github.com/yihui/hugo-xmin) theme;
- R and [`blogdown`](https://pkgs.rstudio.com/blogdown/) for pages that
  generate structured content;
- Netlify for production and pull-request preview deployments;
- GitHub Actions for clean builds, link checks and controlled content refreshes;
- Cloudflare for DNS.

Netlify runs Hugo only. Ordinary prose pages are therefore Markdown files that
Hugo can build directly. Data-driven R Markdown pages are rendered separately,
and their generated `index.html` files are committed alongside the source.

The direct R dependencies are declared in [`DESCRIPTION`](./DESCRIPTION).
The automated refresh workflow pins R 4.6.1 and Hugo 0.165.0. A full
`renv.lock` should only be generated from a tested local R installation; it
has not been fabricated by hand.

## Data-driven pages

Several sections minimise manual duplication:

- **Publications** are retrieved from ORCID, with
  [`selected_publications.csv`](./data/site/selected_publications.csv)
  providing the curated programme-defining selection and contribution notes.
- **Funding** is retrieved from ORCID, with
  [`funding_overrides.csv`](./data/site/funding_overrides.csv) clarifying
  roles and concise descriptions where needed.
- **Teaching and supervision** uses
  [`students.csv`](./data/site/students.csv).
- **Talks and presentations** uses [`talks.csv`](./data/site/talks.csv).

The CSV inputs live under `data/`, so Hugo does not copy them into the
published website.

## Local development

Clone the repository with the theme:

```bash
git clone --recurse-submodules https://github.com/yangjustinc/yangjustinc-blogdown.git
cd yangjustinc-blogdown
```

If the repository was cloned without submodules:

```bash
git submodule update --init --recursive
```

Install the declared R packages and the pinned Hugo release:

```r
install.packages(c(
  "blogdown", "htmltools", "httr2", "knitr", "lubridate", "orcidtr",
  "purrr", "rcrossref", "rmarkdown", "stringr", "tidyverse"
))
blogdown::install_hugo(version = "0.165.0", extended = TRUE)
```

Preview the site with:

```r
blogdown::serve_site()
```

## Rendering data-driven pages

Refresh every R-generated page:

```bash
Rscript scripts/render_data_pages.R
```

The script renders Funding, Leadership, Publications, Talks and Teaching
without running Hugo. Review the generated HTML diff before committing it.
ORCID and Crossref are external services, so transient API failures should not
be treated as evidence that the Hugo site itself is broken.

The **Refresh data-driven content** workflow runs automatically at 06:17 UTC on
the first day of each month. It can also be run manually from the repository's
**Actions** tab. The workflow renders and validates the pages, then opens or
updates a pull request only when the generated content changes.

Changing a curated CSV does not itself trigger the workflow. After updating a
CSV, run the workflow manually or render the pages locally so that the generated
HTML can be reviewed alongside the source change.

## Build and validation

Build the production site locally:

```bash
hugo --gc --minify
python3 scripts/check_internal_links.py public --base-url https://www.justinyang.me/
```

The **Build site** GitHub Action performs the same clean build and internal-link
check on every pull request and every push to `main`. Netlify then deploys
the merged `main` branch using the same Hugo release.

## Updating the theme

Update `hugo-xmin` deliberately:

```bash
git submodule update --remote themes/hugo-xmin
git add themes/hugo-xmin
git commit -m "Update hugo-xmin theme"
```

Dependabot checks monthly for an upstream submodule change and opens a pull
request rather than changing the theme automatically. After an update, run the
production build and inspect the Netlify preview before merging.

## Deployment and security

Netlify publishes `public/`, redirects the apex domain to
`www.justinyang.me`, and supplies baseline content-type, framing, referrer
and browser-permission headers. A strict Content Security Policy is deferred
until the remaining Google Fonts dependency is either self-hosted or explicitly
allowed.

Production continuous deployment should remain enabled. Development work is
performed on branches, so the production site changes only after a pull request
is merged into `main`.

## Repository history

The current tree is small, but older Git history contains large generated data
and presentation files. Rewriting that history would change every historical
commit identifier, so it is intentionally outside routine site maintenance.

## Author

**Justin C Yang**  
University College London

- [Website](https://www.justinyang.me/)
- [GitHub](https://github.com/yangjustinc)
- [ORCID](https://orcid.org/0000-0003-2881-4906)
