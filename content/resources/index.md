---
title: Code & Resources
description: "Open analysis code, teaching materials, and reproducible research resources by Dr Justin C Yang."
---

Most of my research uses data that cannot be shared, so I release the analysis code and teaching materials instead. Stable releases are archived on Zenodo with DOIs. Many of my publications have freely accessible versions; see [Publications](../publications/) for DOI and open access links.

## Research code

<article class="entry">
  <p class="margin-note"><span>Analysis code</span><span>R · ECHILD</span></p>
  <h3>HOPESEN: SEND provision and secondary school outcomes</h3>
  <p><a href="https://github.com/yangjustinc/hopesen">HOPESEN</a> provides the analytical code for population-based analyses of SEND provision profiles and education and health outcomes among secondary school pupils in England using the ECHILD Research Database.</p>
  <p>It includes linked data cohort construction, outcome derivation, descriptive analyses, and fixed effects Poisson regression workflows for the ONS Secure Research Service, while documenting practical reproducibility constraints in an air-gapped trusted research environment.</p>
  <p><a href="https://github.com/yangjustinc/hopesen">Source code and documentation</a> · <a href="https://doi.org/10.5281/zenodo.22710433">Archived v1.0.0 release and DOI</a></p>
</article>

## Teaching and methods resources

<article class="entry">
  <p class="margin-note"><span>Workshop</span><span>R · ONS SRS</span><span>2026</span></p>
  <h3>Good practice in R for secure research environments</h3>
  <p><a href="https://yangjustinc.github.io/good-practice-r-ons-srs/">Good Practice for R Users When Working in the ONS SRS</a> provides materials for a one hour workshop on writing efficient, reproducible, and robust R code for large linked administrative data in the ONS Secure Research Service and similar trusted research environments. It was developed for a workshop through <a href="https://dataciseopenlearning.org/courses/good-practice-for-r-users-when-working-in-the-ons-srs/">Datacise Open Learning</a> on 25 November 2026, and the lesson notes can be read without running any code.</p>
  <p>It covers analytical units and join checks, reducing data early and letting the database do the work, managing memory and recomputation, telling missing records from true zeroes, and rerunnable pipelines. Because SRS data cannot leave the SRS, the worked example uses public New York City trip records with the same structural problems, about 240 million rows a year, in data.table, dplyr, Arrow, and dbplyr. <a href="https://github.com/yangjustinc/good-practice-r-ons-srs">Source code and lesson notes</a> · <a href="https://doi.org/10.5281/zenodo.24343725">Archived v1.0.0 release and DOI</a></p>
</article>

<article class="entry">
  <p class="margin-note"><span>Teaching resource</span><span>R, Python, Stata</span><span>2024</span></p>
  <h3>Routine data analysis across R, Python, and Stata</h3>
  <p><a href="https://yangjustinc.github.io/2024-ncras/">Risk of Suicide After Cancer Diagnosis in England</a> is a worked teaching resource demonstrating approaches to analysing routinely collected health data. It covers survival analysis workflows, person-time, standardised mortality ratios, and absolute excess risks, with examples in R, Python, and Stata.</p>
  <p>The material uses synthetic and published data for methodological and educational purposes. <a href="https://github.com/yangjustinc/2024-ncras">Source code and documentation</a> · <a href="https://doi.org/10.5281/zenodo.22710447">Archived v1.0.0 release and DOI</a></p>
</article>

<article class="entry">
  <p class="margin-note"><span>Tutorial</span><span>R</span><span>2025</span></p>
  <h3>Mapping and spatial analysis in R</h3>
  <p><a href="https://yangjustinc.github.io/2025-mapping-and-spatial-analysis-in-r/">Mapping and Spatial Analysis in R</a> is an introductory tutorial developed for the UCL R User Group. It covers spatial data structures, coordinate reference systems, vector and raster analysis, mapping, spatial joins, proximity and adjacency, spatial autocorrelation, hotspot analysis, and introductory spatial interpolation.</p>
  <p>The tutorial is designed for researchers and analysts with basic R experience who are new to spatial analysis. <a href="https://github.com/yangjustinc/2025-mapping-and-spatial-analysis-in-r">Source materials</a> · <a href="https://doi.org/10.5281/zenodo.22710469">Archived v1.0.0 release and DOI</a></p>
</article>

## Open infrastructure

<article class="entry">
  <p class="margin-note"><span>Website source</span><span>Hugo, R</span></p>
  <h3>Reproducible website infrastructure</h3>
  <p>The <a href="https://github.com/yangjustinc/yangjustinc-blogdown">website source</a> is public. The site uses Hugo, R, ORCID, OpenAlex, Crossref, GitHub Actions, and small curated data files to maintain publications, funding, talks, teaching, and other academic content with limited manual duplication.</p>
  <p>The repository documents the build, dependency management, content refresh, and validation workflow.</p>
</article>

## More code, talks, and materials

Additional public repositories are available through my [GitHub profile](https://github.com/yangjustinc), including the materials for a [four session course in reproducible analysis in R and Python](https://yangjustinc.github.io/2026-10-14-ucldop-online/) for mental health researchers. Talks and methods courses are listed under [Talks](../talks/).

Outputs from UNITED, my NIHR Team Science award on England's national drug and alcohol treatment data, are collected on the [UNITED project website](https://yangjustinc.github.io/united/), including the scoping review preprint, a conference poster, and the recording and slides of a November 2026 Lunch and Learn with the NIHR Public Health Policy Research Unit.

Code and materials for specific projects are also linked from the relevant [research](../research/), [publication](../publications/), and [teaching](../teaching/) pages where available.
