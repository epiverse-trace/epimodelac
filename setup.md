---
title: Setup
---

El ‘Curso Internacional: Análisis de Brotes y Modelamiento en Salud Pública, Bogotá 2023’ se llevará a cabo del 4 al 8 de diciembre de 2023 en Bogotá, Colombia. Este evento es liderado por la Pontificia Universidad Javeriana en el marco del proyecto Epiverse-TRACE-LAC y cuenta con el apoyo de la Universidad de los Andes, el London School of Hygiene and Tropical Medicine, data.org, el Centro Internacional de Investigaciones para el Desarrollo (IDRC) de Canadá, la Secretaría de Salud de Bogotá, el Instituto Nacional de Salud (INS), el Field Epidemiology Training Program (FETP), la Red de Programas de Epidemiología de Campo en América del Sur (REDSUR), el Imperial College de Londres y la Universidad de Sussex. 


Este curso presencial de 5 días tiene como objetivo fortalecer la capacidad de análisis y modelamiento de brotes de enfermedades infecciosas en la región de América Latina y el Caribe, mediante el uso de herramientas de alta calidad, de código abierto e interoperables que ayuden en la toma de decisiones en salud pública. El curso está dirigido a 80 profesionales de la salud y otras áreas de STEM que buscan mejorar sus habilidades dentro del ecosistema de ciencia de datos y salud pública para responder a futuras crisis de salud.

Para más información consulte: [Epimodelac](https://epimodelac.com/)

En esta página encontrará los talleres del día 2 del curso al día 5. 

## Recomendaciones para antes del curso

Instale Latex (Aquí tutorial)

Instale RTools (Aquí tutorial)

Instale estas dependencias de R

```{r message=FALSE, warning=FALSE}
library(deSolve)   # Paquete deSolve para resolver las ecuaciones diferenciales
library(tidyverse) # Paquetes ggplot2 y dplyr de tidyverse
library(cowplot) # Paquete gridExtra para unir gráficos.
```



## Noticias

Estimado participante

¡Ya está disponible una nueva unidad del curso virtual en ciencia de datos en salud pública y modelamiento de enfermedades infecciosas! Esta nueva unidad tiene contenido sobre los conceptos básicos para entender las epidemias y pandemias. En esta unidad de Introducción a la Teoría Epidémica podrá encontrar nuevos recursos como videos, interactivos y lecturas. Recuerde que cada semana habilitaremos nuevas unidades y nuevos recursos de aprendizaje. 

Si no ha podido acceder a la plataforma, adjunto encontrará el paso a paso para realizar la inscripción en el programa. El plazo de inscripción al curso es hoy 17 de noviembre de 2023 a las 11:00pm (GMT-5). Si tiene algún problema para el ingreso o la inscripción al curso o la plataforma por favor escríbanos a  tracelac@javeriana.edu.co o gomezblaura@javeriana.edu.co 


Normas del curso



## Data Sets

<!--
FIXME: place any data you want learners to use in `episodes/data` and then use
       a relative link ( [data zip file](data/lesson-data.zip) ) to provide a
       link to it, replacing the example.com link.
-->
Download the [data zip file](https://example.com/FIXME) and unzip it to your Desktop

## Software Setup

::::::::::::::::::::::::::::::::::::::: discussion

### Details

Setup for different systems can be presented in dropdown menus via a `solution`
tag. They will join to this discussion block, so you can give a general overview
of the software used in this lesson here and fill out the individual operating
systems (and potentially add more, e.g. online setup) in the solutions blocks.

:::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::: solution

### Windows

Use PuTTY

:::::::::::::::::::::::::

:::::::::::::::: solution

### MacOS

Use Terminal.app

:::::::::::::::::::::::::


:::::::::::::::: solution

### Linux

Use Terminal

:::::::::::::::::::::::::

