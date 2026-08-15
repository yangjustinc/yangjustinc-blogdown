# Justin C. Yang — Personal Academic Website

Source code for my personal academic website:

**https://www.justinyang.me/**

The site contains information about my research, publications, presentations, teaching and other academic activities.

It is built with **Hugo** through the R [`blogdown`](https://pkgs.rstudio.com/blogdown/) package and deployed automatically via **Netlify**.

## Technology

The site uses:

* **Hugo** as the static site generator;
* **blogdown** for managing and building the site from R;
* a customised version of the [`hugo-xmin`](https://github.com/yihui/hugo-xmin) theme;
* **Netlify** for continuous deployment from the `main` branch; and
* **Cloudflare** for DNS.

## Repository structure

| Path                                                         | Purpose                                                                 |
| ------------------------------------------------------------ | ----------------------------------------------------------------------- |
| [`content/`](./content/)                                     | Website content, including posts, publications, presentations and talks |
| [`layouts/`](./layouts/)                                     | Custom Hugo layouts, template overrides and shortcodes                  |
| [`static/`](./static/)                                       | Static assets such as images, documents and stylesheets                 |
| [`static/css/`](./static/css/)                               | Custom CSS                                                              |
| [`themes/hugo-xmin/`](./themes/hugo-xmin/)                   | Base Hugo theme                                                         |
| [`archetypes/`](./archetypes/)                               | Hugo content templates                                                  |
| [`R/`](./R/)                                                 | R scripts used in the site build workflow                               |
| [`config.yaml`](./config.yaml)                               | Main Hugo site configuration                                            |
| [`netlify.toml`](./netlify.toml)                             | Netlify build and deployment configuration                              |
| [`index.Rmd`](./index.Rmd)                                   | Root blogdown document                                                  |
| [`yangjustinc-blogdown.Rproj`](./yangjustinc-blogdown.Rproj) | RStudio project file                                                    |

## Local development

### Requirements

To work with the site locally, you will need:

* R;
* the `blogdown` package; and
* Hugo.

Install `blogdown` and Hugo from R:

```r
install.packages("blogdown")
blogdown::install_hugo()
```

Clone the repository:

```bash
git clone https://github.com/yangjustinc/yangjustinc-blogdown.git
cd yangjustinc-blogdown
```

Then start a local development server from R:

```r
blogdown::serve_site()
```

By default, the site is served locally at:

```text
http://localhost:4321
```

Changes to site content, layouts and styling can then be previewed locally before being committed.

## Deployment

The production site is deployed through **Netlify**.

Changes pushed to the `main` branch trigger a new build and deployment automatically according to the configuration in [`netlify.toml`](./netlify.toml).

The public site is available at:

**https://www.justinyang.me/**

## Content

Most site content lives under [`content/`](./content/) and includes material such as:

* research and academic interests;
* publications;
* presentations and talks;
* teaching and training materials; and
* blog posts and other professional material.

The site also includes custom Hugo layouts and styling layered on top of the `hugo-xmin` theme.

## Contributing

This repository contains the source for a personal website and is not maintained as a general-purpose software project.

Issues and pull requests are therefore not generally expected, although the code and site structure may be useful as a reference for others building academic websites with Hugo and `blogdown`.

## Author

**Justin C. Yang**

University College London

* Website: https://www.justinyang.me/
* GitHub: https://github.com/yangjustinc
