# Justin C Yang — Personal Website

[![Netlify Status](https://api.netlify.com/api/v1/badges/ca4bf514-a216-41a3-a986-806cf0a21180/deploy-status)](https://app.netlify.com/sites/yangjustinc/deploys)

Source code for [justinyang.me](https://www.justinyang.me), the personal academic website of Justin C Yang. Built with [Hugo](https://gohugo.io) and [blogdown](https://pkgs.rstudio.com/blogdown/), deployed via [Netlify](https://www.netlify.com).

## Stack

- **Framework**: Hugo (static site generator) via blogdown (R)
- **Theme**: [hugo-xmin](https://github.com/yihui/hugo-xmin) with custom modifications
- **Deployment**: Netlify (continuous deployment from `main`)
- **DNS**: Cloudflare

## Prerequisites

- R (≥ 4.0)
- blogdown package
- Hugo (installed automatically via blogdown)

## Local Development

```r
install.packages("blogdown")
blogdown::install_hugo()
blogdown::serve_site()
```

The site will be available at `http://localhost:4321`.

## Project Structure

| Path | Description |
|---|---|
| `content/` | Posts, publications, presentations, and talks |
| `layouts/` | Custom Hugo template overrides and shortcodes |
| `static/` | Static assets (PDFs, images) |
| `themes/` | hugo-xmin theme files |
| `config.yaml` | Hugo site configuration |
| `netlify.toml` | Netlify build configuration |

## Contributing

This is a personal website. Issues and pull requests are not expected, but feel free to use the code as a reference.
