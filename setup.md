---
title: Setup
---

El ‘Curso Internacional: Análisis de Brotes y Modelamiento en Salud Pública, Bogotá 2023’ se llevará a cabo del 4 al 8 de diciembre de 2023 en Bogotá, Colombia. Este evento es liderado por la Pontificia Universidad Javeriana en el marco del proyecto Epiverse-TRACE-LAC y cuenta con el apoyo de la Universidad de los Andes, el London School of Hygiene and Tropical Medicine, data.org, el Centro Internacional de Investigaciones para el Desarrollo (IDRC) de Canadá, la Secretaría de Salud de Bogotá, el Instituto Nacional de Salud (INS), el Field Epidemiology Training Program (FETP), la Red de Programas de Epidemiología de Campo en América del Sur (REDSUR), el Imperial College de Londres y la Universidad de Sussex. 


Este curso presencial de 5 días tiene como objetivo fortalecer la capacidad de análisis y modelamiento de brotes de enfermedades infecciosas en la región de América Latina y el Caribe, mediante el uso de herramientas de alta calidad, de código abierto e interoperables que ayuden en la toma de decisiones en salud pública. El curso está dirigido a 80 profesionales de la salud y otras áreas de STEM que buscan mejorar sus habilidades dentro del ecosistema de ciencia de datos y salud pública para responder a futuras crisis de salud.

Para más información consulte: [Epimodelac](https://epimodelac.com/)

En esta página encontrará los talleres del día 2 del curso al día 5. 


## Normas del curso

Conozca nuestro [código de conducta TRACE-LAC](https://drive.google.com/file/d/1z9EecMJR0CIyrUI6hzUugS4i9aAgSD-5/view?usp=sharing).

## Configuración del software

Siga estos dos pasos:

### 1. Instale o actualice R y RStudio

R y RStudio son dos piezas separadas de software: 

* **R** es un lenguaje de programación y software utilizado para ejecutar código escrito en R.
* **RStudio** es un entorno de desarrollo integrado (IDE) que facilita el uso de R. Recomendamos utilizar RStudio para interactuar con R. 

Para instalar R y RStudio, siga estas instrucciones <https://posit.co/download/rstudio-desktop/>.

::::::::::::::::::::::::::::: callout

### ¿Ya está instalado? 

Espere: Este es un buen momento para asegurarse de que su instalación de R está actualizada.

Este tutorial requiere **R versión 4.0.0 o posterior**.

:::::::::::::::::::::::::::::

Para comprobar si tu versión de R está actualizada:

- En RStudio tu versión de R se imprimirá en [la ventana de la consola](https://docs.posit.co/ide/user/ide/guide/code/console.html). O ejecute `sessionInfo()` allí.

- **Para actualizar R**, descargue e instale la última versión desde el [sitio web del proyecto R](https://cran.rstudio.com/) para su sistema operativo.

  - Después de instalar una nueva versión, tendrás que reinstalar todos tus paquetes con la nueva versión. 

  - Para Windows, el paquete `{installr}` puede actualizar su versión de R y migrar su biblioteca de paquetes.

- **Para actualizar RStudio**, abra RStudio y haga clic en 
Ayuda > Buscar actualizaciones`. Si hay una nueva versión disponible siga las 
instrucciones en pantalla.

::::::::::::::::::::::::::::: callout

### Buscar actualizaciones regularmente

Aunque esto puede sonar aterrador, es **mucho más común** encontrarse con problemas debido al uso de versiones desactualizadas de R o de paquetes de R. Mantenerse al día con las últimas versiones de R, RStudio, y cualquier paquete que utilice regularmente es una buena práctica.

:::::::::::::::::::::::::::::

### 2. Instale los paquetes R necesarios

<!--
During the tutorial, we will need a number of R packages. Packages contain useful R code written by other people. We will use packages from the [Epiverse-TRACE](https://epiverse-trace.github.io/). 
-->

Abra RStudio y **copie y pegue** el siguiente fragmento de código en la [ventana de la consola](https://docs.posit.co/ide/user/ide/guide/code/console.html), luego presione < kbd>Enter</kbd> (Windows y Linux) o <kbd>Return</kbd> (MacOS) para ejecutar el comando:

```r
# para episodios sobre analitica de brotes

if(!require("pak")) install.packages("pak")

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
# para episodio modelo matemático simple

if(!require("pak")) install.packages("pak")

new_packages <- c(
  "deSolve",
  "cowplot",
  "tidyverse"
)

pak::pkg_install(new_packages)
```

Debería actualizar **todos los paquetes** necesarios para el tutorial, aunque los haya instalado hace relativamente poco. Las nuevas versiones traen mejoras y correcciones de errores importantes.

Cuando la instalación haya terminado, puedes intentar cargar los paquetes pegando el siguiente código en la consola:

```r
# para episodios sobre analitica de brotes

library(tidyverse) # contiene ggplot2, dplyr, tidyr, readr, purrr, tibble
library(readxl) # para leer archivos Excel
library(binom) # para intervalos de confianza binomiales
library(knitr) # para crear tablas bonitas con kable()
library(incidence) # para calcular incidencia y ajustar modelos
library(EpiEstim) # para estimar R(t)
```

```r
# para episodio sobre modelo matemático

library(deSolve)   # Paquete deSolve para resolver las ecuaciones diferenciales
library(tidyverse) # Paquetes ggplot2 y dplyr de tidyverse
library(cowplot) # Paquete gridExtra para unir gráficos.
```

## Lecturas relacionadas

Sobre analítica de brotes:

- Cori A, Donnelly CA, Dorigatti I, Ferguson NM, Fraser C, Garske T, Jombart T, Nedjati-Gilani G, Nouvellet P, Riley S, Van Kerkhove MD, Mills HL, Blake IM. **Key data for outbreak evaluation: building on the Ebola experience.** Philos Trans R Soc Lond B Biol Sci. 2017 May 26;372(1721):20160371. doi: 10.1098/rstb.2016.0371. PMID: 28396480; PMCID: PMC5394647. <https://royalsocietypublishing.org/doi/10.1098/rstb.2016.0371>

- Polonsky JA, Baidjoe A, Kamvar ZN, Cori A, Durski K, Edmunds WJ, Eggo RM, Funk S, Kaiser L, Keating P, de Waroux OLP, Marks M, Moraga P, Morgan O, Nouvellet P, Ratnayake R, Roberts CH, Whitworth J, Jombart T. **Outbreak analytics: a developing data science for informing the response to emerging pathogens.** Philos Trans R Soc Lond B Biol Sci. 2019 Jul 8;374(1776):20180276. doi: 10.1098/rstb.2018.0276. PMID: 31104603; PMCID: PMC6558557. <https://royalsocietypublishing.org/doi/full/10.1098/rstb.2018.0276>
