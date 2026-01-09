---
title: Setup
---

The 'International Course: Outbreak Analysis and Modeling in Public Health, Bogota 2023' will be held from December 4-8, 2023 in Bogota, Colombia.
This event is led by the Pontificia Universidad Javeriana in the framework of the Epiverse-TRACE-LAC project and is supported by the Universidad de los Andes, the London School of Hygiene and Tropical Medicine, data.org, the International Development Research Centre (IDRC) of Canada, the Secretariat of Health of Bogota, the National Institute of Health (INS), the Field Epidemiology Training Program (FETP), the Network of Field Epidemiology Programs in South America (REDSUR), Imperial College London and the University of Sussex.

This 5-day classroom course aims to strengthen the capacity for analysis and modeling of infectious disease outbreaks in the Latin America and Caribbean region, through the use of high quality, open source and interoperable tools that aid in public health decision making.
The course is aimed at 80 professionals from health and other STEM fields who seek to improve their skills within the data science and public health ecosystem to respond to future health crises.

For more information see: [Epimodelac](https://epimodelac.com/)

On this page you will find the workshops from day 2 of the course to day 5.

## Course rules

Learn about our [TRACE-LAC Code of Conduct](https://drive.google.com/file/d/1z9EecMJR0CIyrUI6hzUugS4i9aAgSD-5/view?usp=sharing).

## Software Setup

Follow these two steps:

### 1. Install or upgrade R and RStudio

R and RStudio are two separate pieces of software:

* **R** is a programming language and software used to run code written in R.
* **RStudio** is an integrated development environment (IDE) that makes using R easier. We recommend to use RStudio to interact with R.

To install R and RStudio, follow these instructions <https://posit.co/download/rstudio-desktop/>.

::::::::::::::::::::::::::::: callout

### Already installed?

Hold on: This is a great time to make sure your R installation is current.

This tutorial requires **R version 4.0.0 or later**.

:::::::::::::::::::::::::::::

To check if your R version is up to date:

- In RStudio your R version will be printed in [the console window](https://docs.posit.co/ide/user/ide/guide/code/console.html). Or run `sessionInfo()`.

- **To update R**, download and install the latest version from the [R project website](https://cran.rstudio.com/) for your operating system.

  - After installing a new version, you will have to reinstall all your packages with the new version.

  - For Windows, the `{installr}` package can upgrade your R version and migrate your package library.

- **To update RStudio**, open RStudio and click on
`Help > Check for Updates`. If a new version is available follow the
instructions on the screen.

::::::::::::::::::::::::::::: callout

### Check for Updates regularly

While this may sound scary, it is **far more common** to run into issues due to using out-of-date versions of R or R packages. Keeping up with the latest versions of R, RStudio, and any packages you regularly use is a good practice.

:::::::::::::::::::::::::::::

### 2. Install the required R packages

<!--
During the tutorial, we will need a number of R packages. Packages contain useful R code written by other people. We will use packages from the [Epiverse-TRACE](https://epiverse-trace.github.io/).
-->

Open RStudio and **copy and paste** the following code chunk into the [console window](https://docs.posit.co/ide/user/ide/guide/code/console.html), then press the <kbd>Enter</kbd> (Windows and Linux) or <kbd>Return</kbd> (MacOS) to execute the command:

```r
# for episodes on outbreak analysis

if(!require("pak"))) install.packages("pak")

new_packages <- c(
  "EpiEstim",
  "incidence",
  "epicontacts",
  "tidyverse",
  "binom",
  "knitr"
)

pak::pkg_install(new_packages)
```

```r
# for episode simple mathematical model

if(!require("pak"))) install.packages("pak")

new_packages <- c(
  "deSolve",
  "cowplot",
  "tidyverse"
)

pak::pkg_install(new_packages)
```

You should update **all the packages** required for the tutorial, even if you have installed them relatively recently.
New versions bring important improvements and bug fixes.

When the installation is finished, you can try to load the packages by pasting the following code into the console:

```r
# for episodes on outbreak analysis

library(tidyverse) # contains ggplot2, dplyr, tidyr, readr, purrr, tibble
library(readxl) # for reading Excel files
library(binom) # for binomial confidence intervals
library(knitr) # to create beautiful tables with kable()
library(incidence) # for calculating incidence and fitting models
library(EpiEstim) # for estimating R(t)
```

```r
# for episode on mathematical model

library(deSolve) # deSolve package for solving differential equations
library(tidyverse) # tidyverse's ggplot2 and dplyr packages
library(cowplot) # gridExtra package for joining graphs.
```

## Related reading

About outbreak analysis:

- Cori A, Donnelly CA, Dorigatti I, Ferguson NM, Fraser C, Garske T, Jombart T, Nedjati-Gilani G, Nouvellet P, Riley S, Van Kerkhove MD, Mills HL, Blake IM. **Key data for outbreak evaluation: building on the Ebola experience.** Philos Trans R Soc Lond B Biol Sci. 2017 May 26;372(1721):20160371. doi: 10.1098/rstb.2016.0371. PMID: 28396480; PMCID: PMC5394647. <https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371>

- Polonsky JA, Baidjoe A, Kamvar ZN, Cori A, Durski K, Edmunds WJ, Eggo RM, Funk S, Kaiser L, Keating P, de Waroux OLP, Marks M, Moraga P, Morgan O, Nouvellet P, Ratnayake R, Roberts CH, Whitworth J, Jombart T. **Outbreak analytics: a developing data science for informing the response to emerging pathogens.** Philos Trans R Soc Lond B Biol Sci. 2019 Jul 8;374(1776):20180276. doi: 10.1098/rstb.2018..0276. PMID: 31104603; PMCID: PMC6558557. <https://royalsocietypublishing.org/doi/full/10.1098/rstb.2018.0276>
