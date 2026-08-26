# MINDSET academic website

Source for [www.justinyang.me](https://www.justinyang.me/), the academic
website for **MINDSET (Multimodal INference and Data Science for Epidemiology
and Treatment)**, the research programme led by Dr Justin C Yang at University
College London.

The site presents the programme's research, people and collaborations,
publications, funding, talks, teaching and supervision, research contribution
and engagement, academic leadership, open research resources, and contact
information.

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
| [`content/resources/`](./content/resources/) | Selected open research, code and reusable teaching materials |
| [`content/contribution/`](./content/contribution/) | Research infrastructure, engagement, advisory contribution and capacity building |
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

The direct R dependencies are declared in [`DESCRIPTION`](./DESCRIPTION), while
[`renv.lock`](./renv.lock) records the exact dependency graph tested by the R
rendering workflows. CI uses R 4.6.1 and restores that lockfile for routine
renders. The **Update R dependencies** workflow runs monthly on the 15th and
proposes a pull request when a newer tested dependency graph is available; it
does not merge package updates automatically.

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

The **Open Research & Resources** page is deliberately curated rather than
automatically generated from GitHub. Inclusion indicates that a resource is
reasonably documented, reusable, or useful beyond the project for which it was
created. This prevents the website from exposing every public repository
regardless of maturity or intended audience.

The **Research Contribution & Engagement** page similarly distinguishes enabling
and engagement activity from demonstrated downstream impact. It should describe
infrastructure, advisory contribution, public-interest governance, capacity
building and engagement on their own terms, and reserve impact claims for cases
where uptake, use or change can be evidenced. It is intentionally a prose page
for now: a structured impact dataset should only be introduced when there is
enough evidence to justify maintaining one rather than creating an empty schema.

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

Restore the tested R environment and install the pinned Hugo release:

```r
install.packages("renv")
renv::restore()
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
**Actions** tab. The workflow restores the tested R dependencies, renders and
validates the pages, then opens or updates a pull request only when the
generated content changes.

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

Publication rendering has one additional deliberately small sanity check. It
requires the generated publication files to be non-empty and checks that both
the OpenAlex cache and BibTeX export retain a plausible number of records, so a
transient upstream failure cannot silently replace the publication list with an
empty or near-empty result.

## Updating dependencies and the theme

`DESCRIPTION` is the source of truth for direct R dependencies. The committed
`renv.lock` is the tested resolved graph. The monthly **Update R dependencies**
workflow resolves current package releases, renders the publications page from
committed external-metadata caches, runs the publication sanity check and opens
or updates a reviewable dependency pull request when the lockfile changes.

Dependabot separately checks GitHub Actions and the `hugo-xmin` submodule. Theme
updates are proposed rather than applied automatically. To update the theme
manually:

```bash
git submodule update --remote themes/hugo-xmin
git add themes/hugo-xmin
git commit -m "Update hugo-xmin theme"
```

After a dependency or theme update, inspect the normal CI results and Netlify
preview before merging.

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