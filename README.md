# MINDSET academic website

Source for [www.justinyang.me](https://www.justinyang.me/), the academic website for **MINDSET (Multimodal INference and Data Science for Epidemiology and Treatment)**, the research programme led by Dr Justin C Yang at University College London.

The site presents the programme's research, people and collaborations, publications, funding, talks, teaching and supervision, academic leadership, and contact information.

## Site structure

| Path | Purpose |
| --- | --- |
| [`content/_index.Rmarkdown`](./content/_index.Rmarkdown) | Homepage |
| [`content/research/`](./content/research/) | Research programme |
| [`content/people/`](./content/people/) | Research team, doctoral researchers, partners, and collaborators |
| [`content/publications/`](./content/publications/) | Selected and complete publications |
| [`content/funding/`](./content/funding/) | Research funding |
| [`content/talks/`](./content/talks/) | Talks and presentations |
| [`content/teaching/`](./content/teaching/) | Teaching, supervision, and researcher development |
| [`content/leadership/`](./content/leadership/) | Academic leadership and recognition |
| [`content/contact/`](./content/contact/) | Contact information |
| [`layouts/`](./layouts/) | Site-level Hugo layouts, partials, and shortcodes |
| [`static/css/style.css`](./static/css/style.css) | Site-wide styling |
| [`themes/hugo-xmin/`](./themes/hugo-xmin/) | `hugo-xmin` theme, tracked as a Git submodule |
| [`config.yaml`](./config.yaml) | Hugo configuration and navigation |
| [`netlify.toml`](./netlify.toml) | Netlify build configuration |

## Technology

The site is built with:

- [Hugo](https://gohugo.io/) using the [`hugo-xmin`](https://github.com/yihui/hugo-xmin) theme
- R and [`blogdown`](https://pkgs.rstudio.com/blogdown/) for R Markdown content
- Netlify for deployment from the `main` branch
- Cloudflare for DNS

The `hugo-xmin` theme is tracked as a Git submodule so that upstream updates can be adopted deliberately while site-specific overrides remain in the top-level `layouts/` and `static/` directories.

The Netlify production build runs Hugo only. R Markdown pages therefore need to be rendered locally before changes are pushed so that their generated `.html` or `.markdown` counterparts are committed alongside the source files.

## Data-driven pages

Several sections are designed to minimise manual duplication:

- **Publications** are retrieved from ORCID, with [`selected_publications.csv`](./content/publications/selected_publications.csv) providing the curated programme-defining selection and contribution notes.
- **Funding** is retrieved from ORCID, with [`funding_overrides.csv`](./content/funding/funding_overrides.csv) used to clarify roles and concise descriptions where needed.
- **Teaching and supervision** uses [`students.csv`](./content/teaching/students.csv).
- **Talks and presentations** uses [`talks.csv`](./content/talks/talks.csv).

## Local development

Clone the repository, including the theme submodule, and open the RStudio project:

```bash
git clone --recurse-submodules https://github.com/yangjustinc/yangjustinc-blogdown.git
cd yangjustinc-blogdown
```

If the repository was cloned without submodules, initialise the theme with:

```bash
git submodule update --init --recursive
```

Install `blogdown` if required:

```r
install.packages("blogdown")
```

The production deployment currently uses Hugo `0.165.0`, as specified in [`netlify.toml`](./netlify.toml). For a matching local Hugo installation:

```r
blogdown::install_hugo(version = "0.165.0")
```

Preview the site locally with:

```r
blogdown::serve_site()
```

When editing an R Markdown page, render it locally and confirm that the generated output has also changed before committing. The production build does not run R.

## Updating the theme

Update `hugo-xmin` deliberately rather than on every build:

```bash
git submodule update --remote themes/hugo-xmin
git add themes/hugo-xmin
git commit -m "Update hugo-xmin theme"
```

After updating the theme, build the site locally and confirm that there are no Hugo warnings or layout regressions before pushing.

## Deployment

Pushes to `main` trigger a Netlify deployment using:

```bash
hugo --gc
```

The public site is available at [www.justinyang.me](https://www.justinyang.me/).

## Repository scope

This repository is maintained as the source for a personal academic and research programme website rather than as a general-purpose software package. The code and structure may nevertheless be useful as a reference for academic websites built with Hugo and `blogdown`.

## Author

**Justin C Yang**  
University College London

- [Website](https://www.justinyang.me/)
- [GitHub](https://github.com/yangjustinc)
- [ORCID](https://orcid.org/0000-0003-2881-4906)
