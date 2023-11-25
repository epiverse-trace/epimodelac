---
title: "Estimación de las distribuciones de rezagos epidemiológicos: Enfermedad X"
author: "Kelly Charniga, PhD MPH & Zulma Cuucnubá MD, PhD"
date: "2023-11-23"
output: html_document
teaching: 90
exercises: 8
---

:::::::::::::::::::::::::::::::::::::: questions 
 
- ¿Cómo responder ante un brote de una enfermedad desconocida?

::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::: objectives

Al final de este taller usted podrá:

- Comprender los conceptos clave de las distribuciones de retrasos epidemiológicos para la Enfermedad X.

- Entender las estructuras de datos y las herramientas para el análisis de datos de rastreo de contactos.

- Aprender cómo ajustar las estimaciones del intervalo serial y del período de incubación de la Enfermedad X teniendo en cuenta la censura por intervalo usando un marco de trabajo Bayesiano.

- Aprender a utilizar estos parámetros para informar estrategias de control en un brote de un patógeno desconocido.
::::::::::::::::::::::::::::::::::::::::::::::::



### 1. Introducción

La Enfermedad X representa un hipotético, pero plausible, brote de una enfermedad infecciosa en el futuro. Este término fue acuñado por la Organización Mundial de la Salud (OMS) y sirve como un término general para un patógeno desconocido que podría causar una epidemia grave a nivel internacional. Este concepto representa la naturaleza impredecible de la aparición de enfermedades infecciosas y resalta la necesidad de estar preparados y contar con mecanismos de respuesta rápida a nivel global. La Enfermedad X simboliza el potencial de una enfermedad inesperada y de rápida propagación, y destaca la necesidad de sistemas de salud flexibles y adaptativos, así como de capacidades de investigación para identificar, entender y combatir patógenos novedosos.

En esta práctica, va a aprender a estimar los retrasos epidemiológicos, el tiempo entre dos eventos epidemiológicos, utilizando un conjunto de datos simulado de la Enfermedad X.

La Enfermedad X es causada por un patógeno desconocido y se transmite directamente de persona a persona. Específicamente, la practica se centrará en estimar el período de incubación y el intervalo serial.


### 2. Agenda



### 3. Key Concepts

#### **3.1. Epidemiological delays: incubation period and serial interval**

In epidemiology, delay distributions refer to the *time lags* inherent in from two key dates during an outbreak. For example: the time between the symptoms onset and the diagnostics, the time between symptoms and death, among many others.

Today we will be focusing on two key delays known as the incubation period and serial interval. Both are crucial for informing public health response.

The [**incubation period**]{.underline} is the time between infection and symptom onset.

The [**serial interval**]{.underline} is the time between symptom onset in a primary and secondary case pair.

The relationship between these quantities have an impact on whether the disease transmits before [(**Pre-symptomatic transmission)**]{.underline} or after symptoms [**(Symptomatic transmission)**]{.underline} have developed in the primary case (Figure 1).

![](practicalfig.jpg)

Figure 1. Relationship between the incubation period and serial interval on the timing of transmission (*Adapted from Nishiura et al. 2020)*

#### 3.2. Potential biases and adjustments of epidemiological delays

##### **2.2.1 Potential biases**

When estimating epidemiological delays, it is important to consider potential biases:

[**Censoring**]{.underline} means that we know an event happened, but we do not know exactly when it happened. Most epidemiological data are "doubly censored" because there is uncertainty surrounding both primary and secondary event times. Not accounting for censoring can lead to biased estimates of the delay's standard deviation (Park et al. in progress).

[**Right truncation**]{.underline} is a type of sampling bias related to the data collection process. It arises because only cases that have been reported can be observed. Not accounting for right truncation during the growth phase of an epidemic can lead to underestimation of the mean delay (Park et al. in progress).

[**Dynamical (or epidemic phase)**]{.underline} **bias** is another type of sampling bias. It affects backward-looking data and is related to the phase of the epidemic: during the exponential growth phase, cases that developed symptoms recently are over-represented in the observed data, while during the declining phase, these cases are underrepresented, leading to the estimation of shorter and longer delay intervals, respectively (Park et al. in progress).

##### **2.2.2 Delay distributions**

Three common probability distributions used to characterize delays in infectious disease epidemiology include the following (Table 1).

+-----------------+-----------------------------------------+
| Distribution    | Parameters                              |
+=================+:=======================================:+
| **weibull**     | `shape` and `scale`                     |
+-----------------+-----------------------------------------+
| **gamma**       | `shape` and `scale`                     |
+-----------------+-----------------------------------------+
| **log normal**  | `log mean` and `log standard deviation` |
+-----------------+-----------------------------------------+

: Table 1. Three of the most common probability distributions for epidemiological delays.

### 4. R packages for the practical

We will use the following `R` packages in this practical:

-   `dplyr` for data handling

-   `epicontacts` to visualize contact tracing data

-   `ggplot2` and `patchwork` for plotting

-   `incidence` to visualize epidemic curves

-   `rstan` to estimate the incubation period

-   `coarseDataTools` via `EpiEstim` to estimate the serial interval

Installation instructions for packages:



To load the packages, type:


```r
library(dplyr)
library(epicontacts)
library(incidence)
library(coarseDataTools)
library(EpiEstim)
library(ggplot2)
library(loo)
library(patchwork)
library(rstan)
```

## 5. Data

We are going to split into two groups for this practical to tackle two unknown diseases with different modes of transmission.

Let's load the simulated data, which is saved as an `.RDS` file.

There are two items of interest:

-   `linelist`, a file that contains one case of Disease X per row.

-   `contacts`, a file with contact tracing data which contains information about primary and secondary case pairs.


```r
# Group 1
dat <- readRDS("data/practical_data_group1.RDS")
linelist <- dat$linelist
contacts <- dat$contacts

# Group 2
#dat <- readRDS("Data/practical_data_group2.RDS")
#linelist <- dat$linelist
#contacts <- dat$contacts
```

## 6. Data exploration

#### **6.1. Exploring `linelist` data**

Let's start with the `linelist`. These data were collected as part of routine epidemiological surveillance. Each row represents one case of Disease X, and there are 7 variables:

-   `id`: unique case id number

-   `date_onset`: the patient's symptom onset date

-   `sex`: M = male; F = female

-   `age`: the patient's age in years

-   `exposure`: information about how the patient might have been exposed

-   `exposure_start`: earliest date that the patient was exposed

-   `exposure_end`: latest date that the patient was exposed

::: {.alert .alert-secondary}
+----------------------------------------------------------------------+
| ::: {.alert .alert-secondary}                                        |
| *💡 **Questions (1)***                                               |
|                                                                      |
| -   *How many cases are in the `linelist` dataset?*                  |
|                                                                      |
| -   *What proportion of the cases are female?*                       |
|                                                                      |
| -   *What is the age distribution of cases?*                         |
|                                                                      |
| -   *What type of exposure information is available?*                |
| :::                                                                  |
+----------------------------------------------------------------------+
:::


```r
# Inspect data
head(linelist)
```

```{.output}
  id date_onset sex age                    exposure exposure_start exposure_end
1  1 2023-10-01   M  34 Close, skin-to-skin contact           <NA>         <NA>
2  2 2023-10-03   F  38 Close, skin-to-skin contact     2023-09-29   2023-09-29
3  3 2023-10-06   F  38 Close, skin-to-skin contact     2023-09-28   2023-09-28
4  4 2023-10-10   F  37                        <NA>     2023-09-25   2023-09-27
5  5 2023-10-11   F  33                        <NA>     2023-10-05   2023-10-05
6  6 2023-10-12   F  34 Close, skin-to-skin contact     2023-10-10   2023-10-10
```

```r
# Q1
nrow(linelist)
```

```{.output}
[1] 166
```

```r
# Q2
table(linelist$sex)[2]/nrow(linelist)
```

```{.output}
        M 
0.6144578 
```

```r
#Q3
summary(linelist$age)
```

```{.output}
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  22.00   33.00   36.00   35.51   38.00   47.00 
```

```r
#Q4
table(linelist$exposure, exclude = F)[1]/nrow(linelist)
```

```{.output}
Close, skin-to-skin contact 
                  0.6626506 
```

::: {.alert .alert-secondary}
+----------------------------------------------------------------------+
| ::: {.alert .alert-secondary}                                        |
| *💡 **Discuss***                                                     |
|                                                                      |
| Why do you think the exposure information is missing for some cases? |
| Discuss.                                                             |
| :::                                                                  |
+----------------------------------------------------------------------+
:::

Now let's plot the epidemic curve. Where in the outbreak do you think we are (beginning, middle, end)?


```r
i <- incidence(linelist$date_onset)
plot(i) + 
  theme_classic() + 
  scale_fill_manual(values = "purple") +
  theme(legend.position = "none")
```

<img src="fig/EnfermedadX-rendered-epi curve-1.png" style="display: block; margin: auto;" />

It looks like the epidemic might still be growing.

#### **6.1. Exploring `contact tracing` data**

Now let's look at the contact tracing data, which were obtained through patient interviews. Patients were asked about recent activities and interactions to identify possible sources of infection. Primary and secondary case pairs were matched if the secondary case named the primary case as a contact. We only have information on a subset of the cases because not all patients could be contacted for an interview.

Note that for this exercise, we will assume that the secondary cases only had one possible infector. In reality, the potential for a case to have multiple possible infectors needs to be assessed.

The contact tracing data has 4 variables:

-   `primary_case_id`: unique id number for the primary case (infector)

-   `secondary_case_id`: unique id number for the secondary case (infectee)

-   `primary_onset_date`: symptom onset date of the primary case

-   `secondary_onset_date`: symptom onset date of the secondary case


```r
x <- make_epicontacts(linelist = linelist,
                       contacts = contacts,
                       from = "primary_case_id",
                       to = "secondary_case_id",
                       directed = TRUE) # Don´t remember what directed means

plot(x)
```

<!--html_preserve--><div id="htmlwidget-4c98e28226fa72382cb4" style="width:90%;height:700px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-4c98e28226fa72382cb4">{"x":{"nodes":{"id":[1,2,4,5,6,8,9,10,11,12,15,16,19,21,22,23,25,28,29,30,31,32,33,34,36,37,38,41,42,43,44,45,46,47,51,52,53,54,55,57,59,60,61,63,64,65,66,68,69,70,71,73,74,78,79,80,81,83,86,88,89,90,92,96,98,99,100,102,103,105,106,107,108,111,113,114,115,117,119,120,121,122,125,127,128,129,133,136,138,141,142,144,149,152,153,154,156,158,159,160,161,162,164,165,166],"date_onset":["2023-10-01","2023-10-03","2023-10-10","2023-10-11","2023-10-12","2023-10-13","2023-10-15","2023-10-16","2023-10-16","2023-10-18","2023-10-20","2023-10-21","2023-10-24","2023-10-24","2023-10-25","2023-10-26","2023-10-28","2023-10-30","2023-10-30","2023-10-30","2023-10-31","2023-11-03","2023-11-03","2023-11-03","2023-11-04","2023-11-04","2023-11-05","2023-11-06","2023-11-06","2023-11-06","2023-11-06","2023-11-07","2023-11-07","2023-11-07","2023-11-08","2023-11-09","2023-11-10","2023-11-10","2023-11-10","2023-11-11","2023-11-12","2023-11-12","2023-11-12","2023-11-12","2023-11-13","2023-11-13","2023-11-13","2023-11-14","2023-11-14","2023-11-14","2023-11-14","2023-11-15","2023-11-15","2023-11-16","2023-11-16","2023-11-16","2023-11-16","2023-11-17","2023-11-17","2023-11-18","2023-11-18","2023-11-18","2023-11-18","2023-11-20","2023-11-20","2023-11-20","2023-11-20","2023-11-20","2023-11-21","2023-11-21","2023-11-21","2023-11-21","2023-11-22","2023-11-22","2023-11-23","2023-11-23","2023-11-23","2023-11-24","2023-11-25","2023-11-25","2023-11-25","2023-11-25","2023-11-26","2023-11-26","2023-11-26","2023-11-26","2023-11-26","2023-11-27","2023-11-27","2023-11-27","2023-11-27","2023-11-28","2023-11-29","2023-11-29","2023-11-29","2023-11-29","2023-11-29","2023-11-30","2023-11-30","2023-11-30","2023-11-30","2023-11-30","2023-11-30","2023-11-30","2023-11-30"],"sex":["M","F","F","F","F","M","F","M","F","M","M","F","M","M","M","M","M","F","F","M","M","M","M","M","F","M","M","F","F","M","F","M","M","F","M","M","F","M","M","M","M","F","F","M","M","M","F","M","M","F","M","M","F","M","M","F","F","M","F","M","M","F","F","M","M","M","F","F","M","M","M","M","M","F","F","M","M","F","M","F","F","F","M","M","M","M","M","M","F","M","F","M","F","M","M","F","F","F","M","F","M","F","M","M","F"],"age":[34,38,37,33,34,35,36,42,39,33,39,39,33,33,32,36,36,34,32,31,38,35,38,30,38,35,34,38,42,35,32,29,32,36,38,28,34,34,27,33,41,38,35,37,42,36,37,33,35,42,31,40,34,32,34,33,34,37,34,42,35,34,41,36,24,35,39,39,43,33,38,34,33,37,37,37,31,27,38,36,38,36,39,31,37,33,37,34,39,40,36,47,34,36,31,22,35,35,37,31,38,38,40,37,36],"exposure":["Close, skin-to-skin contact","Close, skin-to-skin contact",null,null,"Close, skin-to-skin contact",null,null,null,"Close, skin-to-skin contact",null,null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact",null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact",null,null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact",null,null,null,"Close, skin-to-skin contact","Close, skin-to-skin contact",null,null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact",null,null,null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact",null,"Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact",null,"Close, skin-to-skin contact",null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact","Close, skin-to-skin contact",null,"Close, skin-to-skin contact","Close, skin-to-skin contact",null,null,null,"Close, skin-to-skin contact"],"exposure_start":[null,"2023-09-29","2023-09-25","2023-10-05","2023-10-10","2023-10-08","2023-10-13","2023-10-04","2023-10-03","2023-10-11","2023-10-13","2023-10-19","2023-10-20","2023-10-05","2023-10-20","2023-10-14","2023-10-26","2023-10-27","2023-10-24","2023-10-17","2023-10-30","2023-11-02","2023-10-27","2023-10-30","2023-10-29","2023-10-25","2023-11-01","2023-11-03","2023-11-03","2023-11-01","2023-11-03","2023-11-05","2023-10-18","2023-10-30","2023-11-02",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"exposure_end":[null,"2023-09-29","2023-09-27","2023-10-05","2023-10-10","2023-10-08","2023-10-13","2023-10-04","2023-10-03","2023-10-11","2023-10-14","2023-10-20","2023-10-20","2023-10-05","2023-10-20","2023-10-15","2023-10-26","2023-10-27","2023-10-25","2023-10-17","2023-10-30","2023-11-02","2023-10-27","2023-10-30","2023-10-30","2023-10-25","2023-11-01","2023-11-03","2023-11-03","2023-11-03","2023-11-04","2023-11-05","2023-10-19","2023-10-30","2023-11-04",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"label":["1","2","4","5","6","8","9","10","11","12","15","16","19","21","22","23","25","28","29","30","31","32","33","34","36","37","38","41","42","43","44","45","46","47","51","52","53","54","55","57","59","60","61","63","64","65","66","68","69","70","71","73","74","78","79","80","81","83","86","88","89","90","92","96","98","99","100","102","103","105","106","107","108","111","113","114","115","117","119","120","121","122","125","127","128","129","133","136","138","141","142","144","149","152","153","154","156","158","159","160","161","162","164","165","166"],"title":["<p> id: 1<br>date_onset: 2023-10-01<br>sex: M<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 2<br>date_onset: 2023-10-03<br>sex: F<br>age: 38<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-09-29<br>exposure_end: 2023-09-29 <\/p>","<p> id: 4<br>date_onset: 2023-10-10<br>sex: F<br>age: 37<br>exposure: NA<br>exposure_start: 2023-09-25<br>exposure_end: 2023-09-27 <\/p>","<p> id: 5<br>date_onset: 2023-10-11<br>sex: F<br>age: 33<br>exposure: NA<br>exposure_start: 2023-10-05<br>exposure_end: 2023-10-05 <\/p>","<p> id: 6<br>date_onset: 2023-10-12<br>sex: F<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-10<br>exposure_end: 2023-10-10 <\/p>","<p> id: 8<br>date_onset: 2023-10-13<br>sex: M<br>age: 35<br>exposure: NA<br>exposure_start: 2023-10-08<br>exposure_end: 2023-10-08 <\/p>","<p> id: 9<br>date_onset: 2023-10-15<br>sex: F<br>age: 36<br>exposure: NA<br>exposure_start: 2023-10-13<br>exposure_end: 2023-10-13 <\/p>","<p> id: 10<br>date_onset: 2023-10-16<br>sex: M<br>age: 42<br>exposure: NA<br>exposure_start: 2023-10-04<br>exposure_end: 2023-10-04 <\/p>","<p> id: 11<br>date_onset: 2023-10-16<br>sex: F<br>age: 39<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-03<br>exposure_end: 2023-10-03 <\/p>","<p> id: 12<br>date_onset: 2023-10-18<br>sex: M<br>age: 33<br>exposure: NA<br>exposure_start: 2023-10-11<br>exposure_end: 2023-10-11 <\/p>","<p> id: 15<br>date_onset: 2023-10-20<br>sex: M<br>age: 39<br>exposure: NA<br>exposure_start: 2023-10-13<br>exposure_end: 2023-10-14 <\/p>","<p> id: 16<br>date_onset: 2023-10-21<br>sex: F<br>age: 39<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-19<br>exposure_end: 2023-10-20 <\/p>","<p> id: 19<br>date_onset: 2023-10-24<br>sex: M<br>age: 33<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-20<br>exposure_end: 2023-10-20 <\/p>","<p> id: 21<br>date_onset: 2023-10-24<br>sex: M<br>age: 33<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-05<br>exposure_end: 2023-10-05 <\/p>","<p> id: 22<br>date_onset: 2023-10-25<br>sex: M<br>age: 32<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-20<br>exposure_end: 2023-10-20 <\/p>","<p> id: 23<br>date_onset: 2023-10-26<br>sex: M<br>age: 36<br>exposure: NA<br>exposure_start: 2023-10-14<br>exposure_end: 2023-10-15 <\/p>","<p> id: 25<br>date_onset: 2023-10-28<br>sex: M<br>age: 36<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-26<br>exposure_end: 2023-10-26 <\/p>","<p> id: 28<br>date_onset: 2023-10-30<br>sex: F<br>age: 34<br>exposure: NA<br>exposure_start: 2023-10-27<br>exposure_end: 2023-10-27 <\/p>","<p> id: 29<br>date_onset: 2023-10-30<br>sex: F<br>age: 32<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-24<br>exposure_end: 2023-10-25 <\/p>","<p> id: 30<br>date_onset: 2023-10-30<br>sex: M<br>age: 31<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-17<br>exposure_end: 2023-10-17 <\/p>","<p> id: 31<br>date_onset: 2023-10-31<br>sex: M<br>age: 38<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-30<br>exposure_end: 2023-10-30 <\/p>","<p> id: 32<br>date_onset: 2023-11-03<br>sex: M<br>age: 35<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-11-02<br>exposure_end: 2023-11-02 <\/p>","<p> id: 33<br>date_onset: 2023-11-03<br>sex: M<br>age: 38<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-27<br>exposure_end: 2023-10-27 <\/p>","<p> id: 34<br>date_onset: 2023-11-03<br>sex: M<br>age: 30<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-30<br>exposure_end: 2023-10-30 <\/p>","<p> id: 36<br>date_onset: 2023-11-04<br>sex: F<br>age: 38<br>exposure: NA<br>exposure_start: 2023-10-29<br>exposure_end: 2023-10-30 <\/p>","<p> id: 37<br>date_onset: 2023-11-04<br>sex: M<br>age: 35<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-25<br>exposure_end: 2023-10-25 <\/p>","<p> id: 38<br>date_onset: 2023-11-05<br>sex: M<br>age: 34<br>exposure: NA<br>exposure_start: 2023-11-01<br>exposure_end: 2023-11-01 <\/p>","<p> id: 41<br>date_onset: 2023-11-06<br>sex: F<br>age: 38<br>exposure: NA<br>exposure_start: 2023-11-03<br>exposure_end: 2023-11-03 <\/p>","<p> id: 42<br>date_onset: 2023-11-06<br>sex: F<br>age: 42<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-11-03<br>exposure_end: 2023-11-03 <\/p>","<p> id: 43<br>date_onset: 2023-11-06<br>sex: M<br>age: 35<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-11-01<br>exposure_end: 2023-11-03 <\/p>","<p> id: 44<br>date_onset: 2023-11-06<br>sex: F<br>age: 32<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-11-03<br>exposure_end: 2023-11-04 <\/p>","<p> id: 45<br>date_onset: 2023-11-07<br>sex: M<br>age: 29<br>exposure: NA<br>exposure_start: 2023-11-05<br>exposure_end: 2023-11-05 <\/p>","<p> id: 46<br>date_onset: 2023-11-07<br>sex: M<br>age: 32<br>exposure: Close, skin-to-skin contact<br>exposure_start: 2023-10-18<br>exposure_end: 2023-10-19 <\/p>","<p> id: 47<br>date_onset: 2023-11-07<br>sex: F<br>age: 36<br>exposure: NA<br>exposure_start: 2023-10-30<br>exposure_end: 2023-10-30 <\/p>","<p> id: 51<br>date_onset: 2023-11-08<br>sex: M<br>age: 38<br>exposure: NA<br>exposure_start: 2023-11-02<br>exposure_end: 2023-11-04 <\/p>","<p> id: 52<br>date_onset: 2023-11-09<br>sex: M<br>age: 28<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 53<br>date_onset: 2023-11-10<br>sex: F<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 54<br>date_onset: 2023-11-10<br>sex: M<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 55<br>date_onset: 2023-11-10<br>sex: M<br>age: 27<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 57<br>date_onset: 2023-11-11<br>sex: M<br>age: 33<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 59<br>date_onset: 2023-11-12<br>sex: M<br>age: 41<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 60<br>date_onset: 2023-11-12<br>sex: F<br>age: 38<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 61<br>date_onset: 2023-11-12<br>sex: F<br>age: 35<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 63<br>date_onset: 2023-11-12<br>sex: M<br>age: 37<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 64<br>date_onset: 2023-11-13<br>sex: M<br>age: 42<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 65<br>date_onset: 2023-11-13<br>sex: M<br>age: 36<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 66<br>date_onset: 2023-11-13<br>sex: F<br>age: 37<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 68<br>date_onset: 2023-11-14<br>sex: M<br>age: 33<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 69<br>date_onset: 2023-11-14<br>sex: M<br>age: 35<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 70<br>date_onset: 2023-11-14<br>sex: F<br>age: 42<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 71<br>date_onset: 2023-11-14<br>sex: M<br>age: 31<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 73<br>date_onset: 2023-11-15<br>sex: M<br>age: 40<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 74<br>date_onset: 2023-11-15<br>sex: F<br>age: 34<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 78<br>date_onset: 2023-11-16<br>sex: M<br>age: 32<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 79<br>date_onset: 2023-11-16<br>sex: M<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 80<br>date_onset: 2023-11-16<br>sex: F<br>age: 33<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 81<br>date_onset: 2023-11-16<br>sex: F<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 83<br>date_onset: 2023-11-17<br>sex: M<br>age: 37<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 86<br>date_onset: 2023-11-17<br>sex: F<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 88<br>date_onset: 2023-11-18<br>sex: M<br>age: 42<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 89<br>date_onset: 2023-11-18<br>sex: M<br>age: 35<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 90<br>date_onset: 2023-11-18<br>sex: F<br>age: 34<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 92<br>date_onset: 2023-11-18<br>sex: F<br>age: 41<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 96<br>date_onset: 2023-11-20<br>sex: M<br>age: 36<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 98<br>date_onset: 2023-11-20<br>sex: M<br>age: 24<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 99<br>date_onset: 2023-11-20<br>sex: M<br>age: 35<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 100<br>date_onset: 2023-11-20<br>sex: F<br>age: 39<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 102<br>date_onset: 2023-11-20<br>sex: F<br>age: 39<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 103<br>date_onset: 2023-11-21<br>sex: M<br>age: 43<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 105<br>date_onset: 2023-11-21<br>sex: M<br>age: 33<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 106<br>date_onset: 2023-11-21<br>sex: M<br>age: 38<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 107<br>date_onset: 2023-11-21<br>sex: M<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 108<br>date_onset: 2023-11-22<br>sex: M<br>age: 33<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 111<br>date_onset: 2023-11-22<br>sex: F<br>age: 37<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 113<br>date_onset: 2023-11-23<br>sex: F<br>age: 37<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 114<br>date_onset: 2023-11-23<br>sex: M<br>age: 37<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 115<br>date_onset: 2023-11-23<br>sex: M<br>age: 31<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 117<br>date_onset: 2023-11-24<br>sex: F<br>age: 27<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 119<br>date_onset: 2023-11-25<br>sex: M<br>age: 38<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 120<br>date_onset: 2023-11-25<br>sex: F<br>age: 36<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 121<br>date_onset: 2023-11-25<br>sex: F<br>age: 38<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 122<br>date_onset: 2023-11-25<br>sex: F<br>age: 36<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 125<br>date_onset: 2023-11-26<br>sex: M<br>age: 39<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 127<br>date_onset: 2023-11-26<br>sex: M<br>age: 31<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 128<br>date_onset: 2023-11-26<br>sex: M<br>age: 37<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 129<br>date_onset: 2023-11-26<br>sex: M<br>age: 33<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 133<br>date_onset: 2023-11-26<br>sex: M<br>age: 37<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 136<br>date_onset: 2023-11-27<br>sex: M<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 138<br>date_onset: 2023-11-27<br>sex: F<br>age: 39<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 141<br>date_onset: 2023-11-27<br>sex: M<br>age: 40<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 142<br>date_onset: 2023-11-27<br>sex: F<br>age: 36<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 144<br>date_onset: 2023-11-28<br>sex: M<br>age: 47<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 149<br>date_onset: 2023-11-29<br>sex: F<br>age: 34<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 152<br>date_onset: 2023-11-29<br>sex: M<br>age: 36<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 153<br>date_onset: 2023-11-29<br>sex: M<br>age: 31<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 154<br>date_onset: 2023-11-29<br>sex: F<br>age: 22<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 156<br>date_onset: 2023-11-29<br>sex: F<br>age: 35<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 158<br>date_onset: 2023-11-30<br>sex: F<br>age: 35<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 159<br>date_onset: 2023-11-30<br>sex: M<br>age: 37<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 160<br>date_onset: 2023-11-30<br>sex: F<br>age: 31<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 161<br>date_onset: 2023-11-30<br>sex: M<br>age: 38<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 162<br>date_onset: 2023-11-30<br>sex: F<br>age: 38<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 164<br>date_onset: 2023-11-30<br>sex: M<br>age: 40<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 165<br>date_onset: 2023-11-30<br>sex: M<br>age: 37<br>exposure: NA<br>exposure_start: NA<br>exposure_end: NA <\/p>","<p> id: 166<br>date_onset: 2023-11-30<br>sex: F<br>age: 36<br>exposure: Close, skin-to-skin contact<br>exposure_start: NA<br>exposure_end: NA <\/p>"],"color":["#CCDDFF","#C4DCF7","#BDDBEF","#B6DAE7","#AFD9E0","#A8D8D8","#A0D7D0","#99D6C9","#92D5C1","#8BD4B9","#84D3B1","#7CD2AA","#7ED0A6","#89CEA7","#95CBA8","#A0C8A9","#ACC6AB","#B8C3AC","#C3C0AD","#CFBEAE","#DABBAF","#E6B8B0","#F2B5B1","#FDB3B2","#F7B1B4","#F0B0B5","#E8AFB6","#E0ADB7","#D8ACB8","#D0ABBA","#C8AABB","#C0A8BC","#B8A7BD","#B1A6BE","#A9A4C0","#A6A5BB","#AEA8AA","#B6AC9A","#BEAF89","#C6B378","#CEB667","#D5B957","#DDBD46","#E5C035","#EDC425","#F5C714","#FDCB03","#FFC808","#FFC513","#FFC11E","#FFBD29","#FFB934","#FFB540","#FFB14B","#FFAD56","#FFA961","#FFA56C","#FFA277","#FEA080","#F9A982","#F5B184","#F0B986","#ECC289","#E7CA8B","#E3D28D","#DFDB8F","#DAE391","#D6EB93","#D1F396","#CDFC98","#CDF99B","#CEF19E","#D0E8A1","#D2E0A5","#D3D8A8","#D5CFAB","#D6C7AE","#D8BFB2","#DAB6B5","#DBAEB8","#DDA6BC","#DF9FBE","#E2A3BB","#E4A7B8","#E7ABB4","#EAAFB1","#EDB2AE","#EFB6AA","#F2BAA7","#F5BEA4","#F8C2A1","#FBC69D","#FDCA9A","#FCCC9B","#F8CCA0","#F3CCA4","#EFCCA9","#EBCCAD","#E6CCB2","#E2CCB6","#DECCBB","#D9CCBF","#D5CCC4","#D1CCC8","#CDCDCD"],"borderWidth":[2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]},"edges":{"from":[1,1,5,4,6,12,9,15,2,22,22,25,25,29,16,31,34,25,36,30,38,41,28,44,41,23,45,45,37,31,42,54,47,61,54,46,79,68,80,60,74,71,70,88,83,64,63,34,113,69,90,108,113,80,73,107,70,78,64,105,55,108,113,103,128,156,99,128,89,92,106,103],"to":[2,5,8,10,11,16,19,21,23,25,30,32,33,34,36,38,42,43,46,51,52,53,55,57,59,61,65,66,69,70,78,79,80,81,83,86,90,92,96,98,100,102,107,111,114,115,117,119,120,121,122,125,127,129,133,136,138,141,142,144,149,152,153,154,158,159,160,161,162,164,165,166],"primary_onset_date":["2023-10-01","2023-10-01","2023-10-11","2023-10-10","2023-10-12","2023-10-18","2023-10-15","2023-10-20","2023-10-03","2023-10-25","2023-10-25","2023-10-28","2023-10-28","2023-10-30","2023-10-21","2023-10-31","2023-11-03","2023-10-28","2023-11-04","2023-10-30","2023-11-05","2023-11-06","2023-10-30","2023-11-06","2023-11-06","2023-10-26","2023-11-07","2023-11-07","2023-11-04","2023-10-31","2023-11-06","2023-11-10","2023-11-07","2023-11-12","2023-11-10","2023-11-07","2023-11-16","2023-11-14","2023-11-16","2023-11-12","2023-11-15","2023-11-14","2023-11-14","2023-11-18","2023-11-17","2023-11-13","2023-11-12","2023-11-03","2023-11-23","2023-11-14","2023-11-18","2023-11-22","2023-11-23","2023-11-16","2023-11-15","2023-11-21","2023-11-14","2023-11-16","2023-11-13","2023-11-21","2023-11-10","2023-11-22","2023-11-23","2023-11-21","2023-11-26","2023-11-29","2023-11-20","2023-11-26","2023-11-18","2023-11-18","2023-11-21","2023-11-21"],"secondary_onset_date":["2023-10-03","2023-10-11","2023-10-13","2023-10-16","2023-10-16","2023-10-21","2023-10-24","2023-10-24","2023-10-26","2023-10-28","2023-10-30","2023-11-03","2023-11-03","2023-11-03","2023-11-04","2023-11-05","2023-11-06","2023-11-06","2023-11-07","2023-11-08","2023-11-09","2023-11-10","2023-11-10","2023-11-11","2023-11-12","2023-11-12","2023-11-13","2023-11-13","2023-11-14","2023-11-14","2023-11-16","2023-11-16","2023-11-16","2023-11-16","2023-11-17","2023-11-17","2023-11-18","2023-11-18","2023-11-20","2023-11-20","2023-11-20","2023-11-20","2023-11-21","2023-11-22","2023-11-23","2023-11-23","2023-11-24","2023-11-25","2023-11-25","2023-11-25","2023-11-25","2023-11-26","2023-11-26","2023-11-26","2023-11-26","2023-11-27","2023-11-27","2023-11-27","2023-11-27","2023-11-28","2023-11-29","2023-11-29","2023-11-29","2023-11-29","2023-11-30","2023-11-30","2023-11-30","2023-11-30","2023-11-30","2023-11-30","2023-11-30","2023-11-30"],"width":[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],"arrows":["to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to","to"]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot"},"manipulation":{"enabled":false},"physics":{"stabilization":false}},"groups":null,"width":"90%","height":"700px","idselection":{"enabled":false,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":true,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false,"variable":"id","main":"Select by id","values":[1,2,4,5,6,8,9,10,11,12,15,16,19,21,22,23,25,28,29,30,31,32,33,34,36,37,38,41,42,43,44,45,46,47,51,52,53,54,55,57,59,60,61,63,64,65,66,68,69,70,71,73,74,78,79,80,81,83,86,88,89,90,92,96,98,99,100,102,103,105,106,107,108,111,113,114,115,117,119,120,121,122,125,127,128,129,133,136,138,141,142,144,149,152,153,154,156,158,159,160,161,162,164,165,166]},"main":null,"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","legend":{"width":0.2,"useGroups":false,"position":"left","ncol":1,"stepX":100,"stepY":100,"zoom":true},"highlight":{"enabled":true,"hoverNearest":false,"degree":1,"algorithm":"all","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":false,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"},"opts_manipulation":{"datacss":"table.legend_table {\n  font-size: 11px;\n  border-width:1px;\n  border-color:#d3d3d3;\n  border-style:solid;\n}\ntable.legend_table td {\n  border-width:1px;\n  border-color:#d3d3d3;\n  border-style:solid;\n  padding: 2px;\n}\ndiv.table_content {\n  width:80px;\n  text-align:center;\n}\ndiv.table_description {\n  width:100px;\n}\n\n.operation {\n  font-size:20px;\n}\n\n.network-popUp {\n  display:none;\n  z-index:299;\n  width:250px;\n  /*height:150px;*/\n  background-color: #f9f9f9;\n  border-style:solid;\n  border-width:1px;\n  border-color: #0d0d0d;\n  padding:10px;\n  text-align: center;\n  position:fixed;\n  top:50%;  \n  left:50%;  \n  margin:-100px 0 0 -100px;  \n\n}","addNodeCols":["id","label"],"editNodeCols":["id","label"],"tab_add_node":"<span id=\"addnode-operation\" class = \"operation\">node<\/span> <br><table style=\"margin:auto;\"><tr><td>id<\/td><td><input id=\"addnode-id\"  type= \"text\" value=\"new value\"><\/td><\/tr><tr><td>label<\/td><td><input id=\"addnode-label\"  type= \"text\" value=\"new value\"><\/td><\/tr><\/table><input type=\"button\" value=\"save\" id=\"addnode-saveButton\"><\/button><input type=\"button\" value=\"cancel\" id=\"addnode-cancelButton\"><\/button>","tab_edit_node":"<span id=\"editnode-operation\" class = \"operation\">node<\/span> <br><table style=\"margin:auto;\"><tr><td>id<\/td><td><input id=\"editnode-id\"  type= \"text\" value=\"new value\"><\/td><\/tr><tr><td>label<\/td><td><input id=\"editnode-label\"  type= \"text\" value=\"new value\"><\/td><\/tr><\/table><input type=\"button\" value=\"save\" id=\"editnode-saveButton\"><\/button><input type=\"button\" value=\"cancel\" id=\"editnode-cancelButton\"><\/button>"},"iconsRedraw":true},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Describe the clusters. Do you see any potential superspreading events (where one cases spreads the pathogen to many other cases)?

# *`_______Break 1 __________`*

------------------------------------------------------------------------

## 7. Estimating the incubation period

Now let's focus on the incubation period. We will use the `linelist` for this part. We need both time of symptom onset and time of possible exposure. Notice that there are two dates for exposure, a start and end, in the data. Sometimes the exact date of exposure is unknown and exposure window is provided during case interviews instead. Answer the following questions:

1.  For how many cases do we have data on both dates of symptom onset and exposure?

2.  Calculate the exposure windows. How many cases have a single date of exposure?


```r
ip <- filter(linelist, !is.na(exposure_start) &
               !is.na(exposure_end))
nrow(ip)
```

```{.output}
[1] 50
```

```r
ip$exposure_window <- as.numeric(ip$exposure_end - ip$exposure_start)

table(ip$exposure_window)
```

```{.output}

 0  1  2 
34 11  5 
```

### 7.1. Naive estimate of the incubation period

Let's start by calculating a naive estimate of the incubation period.


```r
# Max incubation period 
ip$max_ip <- ip$date_onset - ip$exposure_start
summary(as.numeric(ip$max_ip))
```

```{.output}
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
   1.00    3.00    4.50    6.38    7.75   20.00 
```

```r
# Minimum incubation period
ip$min_ip <- ip$date_onset - ip$exposure_end
summary(as.numeric(ip$min_ip))
```

```{.output}
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
   1.00    2.00    4.00    5.96    7.75   19.00 
```

### 7.2. Censoring adjusted estimate of the incubation period

Now let's fit three probability distributions to the incubation period data accounting for double censoring. We will adapt some `stan` code that was published by Miura et al. during the 2022 mpox outbreak. This method does not account for right truncation or dynamical bias.

Remember we are mainly interested in considering three probability distributions: *weibull*, *gamma*, *lognormal* (See Table 1).

`Stan` is a software program that implements the Hamiltonian Monte Carlo (HMC) algorithm. HMC is a Markov chain Monte Carlo (MCMC) method for fitting complex models to data using Bayesian statistics.

#### **7.1.1. Running the model in Stan**

We will fit all three distributions in this code chunk.


```r
# Prepare data
earliest_exposure <- as.Date(min(ip$exposure_start))

ip <- ip |>
  mutate(date_onset = as.numeric(date_onset - earliest_exposure),
         exposure_start = as.numeric(exposure_start - earliest_exposure),
         exposure_end = as.numeric(exposure_end - earliest_exposure)) |>
  select(id, date_onset, exposure_start, exposure_end)

# Setting some options to run the MCMC chains in parallel
# Running the MCMC chains in parallel means that we will run multiple MCMC chains at the same time by using multiple cores on your computer
options(mc.cores=parallel::detectCores())

input_data <- list(N = length(ip$exposure_start), # Number of observations
              tStartExposure = ip$exposure_start,
              tEndExposure = ip$exposure_end,
              tSymptomOnset = ip$date_onset)

# We are going to fit three probbility distributions
distributions <- c("weibull", "gamma", "lognormal") # three distributions to fit

# Stan code
code <- sprintf("
  data{
    int<lower=1> N;
    vector[N] tStartExposure;
    vector[N] tEndExposure;
    vector[N] tSymptomOnset;
  }
  parameters{
    real<lower=0> par[2];
    vector<lower=0, upper=1>[N] uE;	// Uniform value for sampling between start and end exposure
  }
  transformed parameters{
    vector[N] tE; 	// infection moment
    tE = tStartExposure + uE .* (tEndExposure - tStartExposure);
  }
model{
    // Contribution to likelihood of incubation period
    target += %s_lpdf(tSymptomOnset -  tE  | par[1], par[2]);
  }
  generated quantities {
    // likelihood for calculation of looIC
    vector[N] log_lik;
    for (i in 1:N) {
      log_lik[i] = %s_lpdf(tSymptomOnset[i] -  tE[i]  | par[1], par[2]);
    }
  }
", distributions, distributions)
names(code) <- distributions

# Next line takes ~1.5 min
models <- mapply(stan_model, model_code = code)

# Takes ~40 sec.
fit <- mapply(sampling, models, list(input_data), 
              iter=3000, # Number of iterations (length of MCMC chains)
              warmup=1000, # Number of samples to discard at the beginning of MCMC
              chain=4) # Number of chains to run MCMC

pos <- mapply(function(z) rstan::extract(z)$par, fit, SIMPLIFY=FALSE) # Posterior samples
```

#### **7.1.2. Checking for convergence**

Now we will check for model convergence. We will look at r-hat values, effective sample sizes, and the MCMC traces. R-hat compares the between- and within-chain estimates for model parameters; values near 1 tell us that chains have mixed well (Vehtari et al. 2021). The effective sample size estimates the number of independent samples after accounting for dependence in the MCMC chains (Lambert 2018). For a model with 4 MCMC chains, a total effective sample size of at least 400 is recommended (Vehtari et al. 2021).

For each model of different fitted distributions:

1.  Are the r-hat values close to 1?

2.  Do the 4 MCMC chains generally lay on top of each other and stay around the same values (fuzzy caterpillars)?

#### **7.1.2.1. Convergence for Gamma**


```r
print(fit$gamma, digits = 3, pars = c("par[1]","par[2]")) 
```

```{.output}
Inference for Stan model: anon_model.
4 chains, each with iter=3000; warmup=1000; thin=1; 
post-warmup draws per chain=2000, total post-warmup draws=8000.

        mean se_mean    sd  2.5%   25%   50%   75% 97.5% n_eff Rhat
par[1] 1.980   0.003 0.364 1.344 1.720 1.956 2.213 2.756 11151    1
par[2] 0.325   0.001 0.068 0.207 0.277 0.320 0.368 0.470 11659    1

Samples were drawn using NUTS(diag_e) at Sat Nov 25 18:22:24 2023.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at 
convergence, Rhat=1).
```

```r
rstan::traceplot(fit$gamma, pars = c("par[1]","par[2]")) 
```

<img src="fig/EnfermedadX-rendered-convergence gamma-1.png" style="display: block; margin: auto;" />

#### **7.1.2.2. Convergence for log normal**


```r
print(fit$lognormal, digits = 3, pars = c("par[1]","par[2]")) 
```

```{.output}
Inference for Stan model: anon_model.
4 chains, each with iter=3000; warmup=1000; thin=1; 
post-warmup draws per chain=2000, total post-warmup draws=8000.

        mean se_mean    sd  2.5%   25%   50%   75% 97.5% n_eff Rhat
par[1] 1.530   0.001 0.114 1.307 1.454 1.529 1.607 1.752  9743    1
par[2] 0.802   0.001 0.085 0.654 0.742 0.795 0.853 0.990  9553    1

Samples were drawn using NUTS(diag_e) at Sat Nov 25 18:22:29 2023.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at 
convergence, Rhat=1).
```

```r
rstan::traceplot(fit$lognormal, pars = c("par[1]","par[2]")) 
```

<img src="fig/EnfermedadX-rendered-convergence lognormal-1.png" style="display: block; margin: auto;" />

#### **7.1.2.3. Convergence for weibull**


```r
print(fit$weibull, digits = 3, pars = c("par[1]","par[2]")) 
```

```{.output}
Inference for Stan model: anon_model.
4 chains, each with iter=3000; warmup=1000; thin=1; 
post-warmup draws per chain=2000, total post-warmup draws=8000.

        mean se_mean    sd  2.5%   25%   50%   75% 97.5% n_eff Rhat
par[1] 1.374   0.002 0.147 1.098 1.274 1.372 1.471 1.679  8858    1
par[2] 6.951   0.008 0.771 5.534 6.405 6.918 7.447 8.563  8822    1

Samples were drawn using NUTS(diag_e) at Sat Nov 25 18:22:19 2023.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at 
convergence, Rhat=1).
```

```r
rstan::traceplot(fit$weibull, pars = c("par[1]","par[2]")) 
```

<img src="fig/EnfermedadX-rendered-convergence weibull-1.png" style="display: block; margin: auto;" />

#### **7.1.3. Compute model comparison criteria**

Let's compute the widely applicable information criterion (WAIC) and leave-one-out-information criterion (LOOIC) to compare model fits. The best fitting model is the model with the lowest WAIC or LOOIC. We will also summarize the distributions and make some plots.

Which model has the best fit?


```r
# Compute WAIC for all three models
waic <- mapply(function(z) waic(extract_log_lik(z))$estimates[3,], fit)
waic
```

```{.output}
          weibull     gamma lognormal
Estimate 278.1269 276.09802 272.85010
SE        11.9816  13.42051  13.84262
```

```r
# For looic, we need to provide the relative effective sample sizes
# when calling loo. This step leads to better estimates of the PSIS effective
# sample sizes and Monte Carlo error

# Extract pointwise log-likelihood for the Weibull distribution
loglik <- extract_log_lik(fit$weibull, merge_chains = FALSE)
# Get the relative effective sample sizes
r_eff <- relative_eff(exp(loglik), cores = 2)
# Compute LOOIC
loo_w <- loo(loglik, r_eff = r_eff, cores = 2)$estimates[3,]
# Print the results
loo_w[1]
```

```{.output}
Estimate 
278.1566 
```

```r
# Extract pointwise log-likelihood for the gamma distribution
loglik <- extract_log_lik(fit$gamma, merge_chains = FALSE)
r_eff <- relative_eff(exp(loglik), cores = 2)
loo_g <- loo(loglik, r_eff = r_eff, cores = 2)$estimates[3,]
loo_g[1]
```

```{.output}
Estimate 
276.1188 
```

```r
# Extract pointwise log-likelihood for the log normal distribution
loglik <- extract_log_lik(fit$lognormal, merge_chains = FALSE)
r_eff <- relative_eff(exp(loglik), cores = 2)
loo_l <- loo(loglik, r_eff = r_eff, cores = 2)$estimates[3,]
loo_l[1]
```

```{.output}
Estimate 
272.8674 
```

#### **7.1.5. Report the results**

The right tail of the incubation period distribution is important for designing control strategies (e.g. quarantine), the 25th-75th percentiles tells us about the most likely time symptom onset could occur, and the full distribution can be used as an input in mathematical or statistical models, like for forecasting (Lessler et al. 2009).

Let's get the summary statistics


```r
# We need to convert the parameters of the distributions to the mean and standard deviation delay

# In Stan, the parameters of the distributions are:
# Weibull: shape and scale
# Gamma: shape and inverse scale (aka rate)
# Log normal: mu and sigma
# Reference: https://mc-stan.org/docs/2_21/functions-reference/positive-continuous-distributions.html
means <- cbind(pos$weibull[,2]*gamma(1+1/pos$weibull[,1]), # mean of Weibull
               pos$gamma[,1] / pos$gamma[,2], # mean of gamma
               exp(pos$lognormal[,1]+pos$lognormal[,2]^2/2)) # mean of log normal

standard_deviations <- cbind(sqrt(pos$weibull[,2]^2*(gamma(1+2/pos$weibull[,1])-(gamma(1+1/pos$weibull[,1]))^2)),
                             sqrt(pos$gamma[,1]/(pos$gamma[,2]^2)),
                             sqrt((exp(pos$lognormal[,2]^2)-1) * (exp(2*pos$lognormal[,1] + pos$lognormal[,2]^2))))

# Print the mean delays and 95% credible intervals
probs <- c(0.025, 0.5, 0.975)

res_means <- apply(means, 2, quantile, probs)
colnames(res_means) <- colnames(waic)
res_means
```

```{.output}
       weibull    gamma lognormal
2.5%  5.170669 5.062121  5.045619
50%   6.342766 6.126234  6.352484
97.5% 7.850934 7.500145  8.416546
```

```r
res_sds <- apply(standard_deviations, 2, quantile, probs)
colnames(res_sds) <- colnames(waic)
res_sds
```

```{.output}
       weibull    gamma lognormal
2.5%  3.684054 3.434770  3.996661
50%   4.657801 4.364611  5.937318
97.5% 6.364717 5.834201 10.167466
```

```r
# Report the median and 95% credible intervals for the quantiles of each distribution
quantiles_to_report <- c(0.025, 0.05, 0.5, 0.95, 0.975, 0.99)

# Weibull
cens_w_percentiles <- sapply(quantiles_to_report, function(p) quantile(qweibull(p = p, shape = pos$weibull[,1], scale = pos$weibull[,2]), probs = probs))
colnames(cens_w_percentiles) <- quantiles_to_report
print(cens_w_percentiles)
```

```{.output}
          0.025      0.05      0.5     0.95    0.975     0.99
2.5%  0.2219427 0.4188145 4.118272 12.52120 14.41361 16.66984
50%   0.4722998 0.7908790 5.295841 15.37918 17.90652 21.05056
97.5% 0.8456238 1.2963507 6.635022 20.05165 23.99252 29.05998
```

```r
# Gamma
cens_g_percentiles <- sapply(quantiles_to_report, function(p) quantile(qgamma(p = p, shape = pos$gamma[,1], rate = pos$gamma[,2]), probs = probs))
colnames(cens_g_percentiles) <- quantiles_to_report
print(cens_g_percentiles)
```

```{.output}
          0.025      0.05      0.5     0.95    0.975     0.99
2.5%  0.3308360 0.5671041 4.110047 11.86920 13.86697 16.36722
50%   0.7146542 1.0548335 5.108790 14.60094 17.16988 20.47761
97.5% 1.1866589 1.6170377 6.250661 18.70023 22.33927 27.05160
```

```r
# Log normal
cens_ln_percentiles <- sapply(quantiles_to_report, function(p) quantile(qlnorm(p = p, meanlog = pos$lognormal[,1], sdlog= pos$lognormal[,2]), probs = probs))
colnames(cens_ln_percentiles) <- quantiles_to_report
print(cens_ln_percentiles)
```

```{.output}
          0.025      0.05      0.5     0.95    0.975     0.99
2.5%  0.6160634 0.8336365 3.694421 12.59517 15.67557 20.12174
50%   0.9741899 1.2543316 4.614982 17.07851 21.93266 29.32990
97.5% 1.3644079 1.6967794 5.765250 25.25766 34.08309 48.47358
```

For each model, find these items for the estimated incubation period in the output above and write them below.

-   Mean and 95% credible interval

-   Standard deviation and 95% credible interval

-   Percentiles (e.g., 2.5, 5, 25, 50, 75, 95, 97.5, 99)

-   The parameters of the fitted distributions (e.g., shape and scale for gamma distribution)

#### **7.1.5. Plot the results**


```r
# Prepare results for plotting
df <- data.frame(
#Take mean values to draw empirical cumulative density function
  inc_day = ((input_data$tSymptomOnset-input_data$tEndExposure)+(input_data$tSymptomOnset-input_data$tStartExposure))/2
)

x_plot <- seq(0, 30, by=0.1) # This sets the range of the x axis (number of days)

Gam_plot <- as.data.frame(list(dose= x_plot, 
                               pred= sapply(x_plot, function(q) quantile(pgamma(q = q, shape = pos$gamma[,1], rate = pos$gamma[,2]), probs = c(0.5))),
                               low = sapply(x_plot, function(q) quantile(pgamma(q = q, shape = pos$gamma[,1], rate = pos$gamma[,2]), probs = c(0.025))),
                               upp = sapply(x_plot, function(q) quantile(pgamma(q = q, shape = pos$gamma[,1], rate = pos$gamma[,2]), probs = c(0.975)))
))

Wei_plot <- as.data.frame(list(dose= x_plot, 
                               pred= sapply(x_plot, function(q) quantile(pweibull(q = q, shape = pos$weibull[,1], scale = pos$weibull[,2]), probs = c(0.5))),
                               low = sapply(x_plot, function(q) quantile(pweibull(q = q, shape = pos$weibull[,1], scale = pos$weibull[,2]), probs = c(0.025))),
                               upp = sapply(x_plot, function(q) quantile(pweibull(q = q, shape = pos$weibull[,1], scale = pos$weibull[,2]), probs = c(0.975)))
))

ln_plot <- as.data.frame(list(dose= x_plot, 
                              pred= sapply(x_plot, function(q) quantile(plnorm(q = q, meanlog = pos$lognormal[,1], sdlog= pos$lognormal[,2]), probs = c(0.5))),
                              low = sapply(x_plot, function(q) quantile(plnorm(q = q, meanlog = pos$lognormal[,1], sdlog= pos$lognormal[,2]), probs = c(0.025))),
                              upp = sapply(x_plot, function(q) quantile(plnorm(q = q, meanlog = pos$lognormal[,1], sdlog= pos$lognormal[,2]), probs = c(0.975)))
))

# Plot cumulative distribution curves
gamma_ggplot <- ggplot(df, aes(x=inc_day)) +
  stat_ecdf(geom = "step")+ 
  xlim(c(0, 30))+
  geom_line(data=Gam_plot, aes(x=x_plot, y=pred), color=RColorBrewer::brewer.pal(11, "RdBu")[11], linewidth=1) +
  geom_ribbon(data=Gam_plot, aes(x=x_plot,ymin=low,ymax=upp), fill = RColorBrewer::brewer.pal(11, "RdBu")[11], alpha=0.1) +
  theme_bw(base_size = 11)+
  labs(x="Incubation period (days)", y = "Proportion")+
  ggtitle("Gamma")

weibul_ggplot <- ggplot(df, aes(x=inc_day)) +
  stat_ecdf(geom = "step")+ 
  xlim(c(0, 30))+
  geom_line(data=Wei_plot, aes(x=x_plot, y=pred), color=RColorBrewer::brewer.pal(11, "RdBu")[11], linewidth=1) +
  geom_ribbon(data=Wei_plot, aes(x=x_plot,ymin=low,ymax=upp), fill = RColorBrewer::brewer.pal(11, "RdBu")[11], alpha=0.1) +
  theme_bw(base_size = 11)+
  labs(x="Incubation period (days)", y = "Proportion")+
  ggtitle("Weibull")

lognorm_ggplot <- ggplot(df, aes(x=inc_day)) +
  stat_ecdf(geom = "step")+ 
  xlim(c(0, 30))+
  geom_line(data=ln_plot, aes(x=x_plot, y=pred), color=RColorBrewer::brewer.pal(11, "RdBu")[11], linewidth=1) +
  geom_ribbon(data=ln_plot, aes(x=x_plot,ymin=low,ymax=upp), fill = RColorBrewer::brewer.pal(11, "RdBu")[11], alpha=0.1) +
  theme_bw(base_size = 11)+
  labs(x="Incubation period (days)", y = "Proportion")+
  ggtitle("Log normal")

(lognorm_ggplot|gamma_ggplot|weibul_ggplot) + plot_annotation(tag_levels = 'A') 
```

<img src="fig/EnfermedadX-rendered-plot ip-1.png" style="display: block; margin: auto;" />

In the plots above, the black line is the empirical cumulative distribution (the data), while the blue curve is the fitted probability distribution with the 95% credible intervals. Make sure that the blue curve lays on top of the black line.

# \-\-\-\-\-\-\-\-\-- Break 2 ----------

## 8. Estimating the serial interval

Now we will estimate the serial interval. Again, we'll do a naive estimate first by calculating the difference between the onset times of primary and secondary case pairs.

1.  Are there any instances of negative serial intervals in the data (e.g., symptom onset in the secondary case came before symptom onset in primary case)?

2.  Report the median serial interval as well as the minimum and maximum.

3.  Plot the distribution of the serial interval.

### 8.1. Naive estimate


```r
contacts$diff <- as.numeric(contacts$secondary_onset_date - contacts$primary_onset_date)
summary(contacts$diff)
```

```{.output}
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  1.000   4.000   6.000   7.625  10.000  23.000 
```

```r
hist(contacts$diff, xlab = "Serial interval (days)", breaks = 25, main = "", col = "pink")
```

<img src="fig/EnfermedadX-rendered-si naive-1.png" style="display: block; margin: auto;" />

### 8.2. Censoring adjusted estimate

Now we will estimate the serial interval using an implementation of the `courseDataTools` package within the `EpiEstim` R package. This method accounts for double censoring and allows different probability distributions to be compared, but it does not adjust for right truncation or dynamical bias.

We will consider three probability distributions and select the one that best fits the data using WAIC or LOOIC. Recall that the best-fitting distribution will have the lowest WAIC or LOOIC.

Note that in `coarseDataTools`, the parameters for the distributions are slightly different than in rstan. Here, the parameters for the gamma distribution are shape and scale (<https://cran.r-project.org/web/packages/coarseDataTools/coarseDataTools.pdf>).

We will only run one MCMC chain for each distribution in the interest of time, but you should run more than one chain in practice to make sure the MCMC converges on the target distribution. We will use the default prior distributions, which can be found in the package documentation (see 'details' for the dic.fit.mcmc function here: <https://cran.r-project.org/web/packages/coarseDataTools/coarseDataTools.pdf>).

#### 8.2.1. Preparing the data


```r
# Format interval-censored serial interval data

# Each line represents a transmission event 
# EL/ER show the lower/upper bound of the symptoms onset date in the primary case (infector)
# SL/SR show the same for the secondary case (infectee)
# type has entries 0 corresponding to doubly interval-censored data
# (see Reich et al. Statist. Med. 2009)
si_data <- contacts |>
  select(-primary_case_id, -secondary_case_id, -primary_onset_date, -secondary_onset_date,) |>
  rename(SL = diff) |>
  mutate(type = 0, EL = 0, ER = 1, SR = SL + 1) |>
  select(EL, ER, SL, SR, type)
```

#### 8.2.2. Fitting a gamma distribution

Let's fit the gamma distribution to the serial interval data first.


```r
overall_seed <- 3 # seed for the random number generator for MCMC
MCMC_seed <- 007

# We will run the model for 4000 iterations with the first 1000 samples discarded as burnin
n_mcmc_samples <- 3000 # number of samples to draw from the posterior (after the burnin)

params = list(
dist = "G", # Fitting a Gamma distribution for the SI
method = "MCMC", # MCMC using coarsedatatools
burnin = 1000, # number of burnin samples (samples discarded at the beginning of MCMC) 
n1 = 50, # n1 is the number of pairs of mean and sd of the SI that are drawn
n2 = 50) # n2 is the size of the posterior sample drawn for each pair of mean, sd of SI

mcmc_control <- make_mcmc_control(
seed = MCMC_seed,
burnin = params$burnin)

dist <- params$dist

config <- make_config(
list(
si_parametric_distr = dist,
mcmc_control = mcmc_control,
seed = overall_seed,
n1 = params$n1,
n2 = params$n2))

# Fitting the SI
si_fit <- coarseDataTools::dic.fit.mcmc(
dat = si_data,
dist = dist,
init.pars = init_mcmc_params(si_data, dist),
burnin = mcmc_control$burnin,
n.samples = n_mcmc_samples,
seed = mcmc_control$seed)
```

```{.output}
Running 4000 MCMC iterations 
MCMCmetrop1R iteration 1 of 4000 
function value = -201.95281
theta = 
   1.04012
   0.99131
Metropolis acceptance rate = 0.00000

MCMCmetrop1R iteration 1001 of 4000 
function value = -202.42902
theta = 
   0.95294
   1.05017
Metropolis acceptance rate = 0.55445

MCMCmetrop1R iteration 2001 of 4000 
function value = -201.88547
theta = 
   1.18355
   0.82124
Metropolis acceptance rate = 0.56522

MCMCmetrop1R iteration 3001 of 4000 
function value = -202.11109
theta = 
   1.26323
   0.77290
Metropolis acceptance rate = 0.55148



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
The Metropolis acceptance rate was 0.55500
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

Let's look at the results.


```r
# Check convergence of MCMC chains 
converg_diag <- check_cdt_samples_convergence(si_fit@samples)
```

```{.output}

Gelman-Rubin MCMC convergence diagnostic was successful.
```

```r
converg_diag
```

```{.output}
[1] TRUE
```

```r
# Estimated serial interval results
si_fit
```

```{.output}
Coarse Data Model Parameter and Quantile Estimates: 
         est  CIlow CIhigh
shape  3.087  2.201  4.137
scale  2.481  1.831  3.645
p5     2.121  1.491  2.754
p50    6.839  5.912  7.784
p95   15.878 13.741 18.944
p99   21.127 18.015 26.043
Note: please check that the MCMC converged on the target distribution by running multiple chains. MCMC samples are available in the mcmc slot (e.g. my.fit@mcmc) 
```

```r
# Save these for later
si_fit_gamma <- si_fit

# Save MCMC samples in dataframe
si_samples <- data.frame(
type = 'Symptom onset',
shape = si_fit@samples$var1,
scale = si_fit@samples$var2,
p50 = qgamma(
p = 0.5, 
shape = si_fit@samples$var1, 
scale = si_fit@samples$var2)) |>
mutate( # Equation for conversion is here https://en.wikipedia.org/wiki/Gamma_distribution
mean = shape*scale,
sd = sqrt(shape*scale^2)
) 

# Get the mean, SD, and 95% CrI
si_samples |>
summarise(
mean_mean = mean(mean),
mean_l_ci = quantile(mean,probs=.025),
mean_u_ci = quantile(mean,probs=.975),
sd_mean = mean(sd),
sd_l_ci = quantile(sd,probs=.025),
sd_u_ci = quantile(sd,probs=.975)
)
```

```{.output}
  mean_mean mean_l_ci mean_u_ci  sd_mean  sd_l_ci  sd_u_ci
1  7.658723   6.65395  8.707372 4.386498 3.602425 5.481316
```

```r
# Get the same summary statistics for the parameters of the distribution
si_samples |>
summarise(
shape_mean = mean(shape),
shape_l_ci = quantile(shape, probs=.025),
shape_u_ci = quantile(shape, probs=.975),
scale_mean = mean(scale),
scale_l_ci = quantile(scale, probs=.025),
scale_u_ci = quantile(scale, probs=.975)
)
```

```{.output}
  shape_mean shape_l_ci shape_u_ci scale_mean scale_l_ci scale_u_ci
1   3.104917   2.201138   4.136793   2.528536   1.831139   3.645062
```

```r
# We will need these for plotting later
gamma_shape <- si_fit@ests['shape',][1]
gamma_rate <- 1 / si_fit@ests['scale',][1]
```

#### 8.2.3. Fitting a log normal distribution

Now let's fit a log normal distribution to the serial interval data.


```r
# We will run the model for 4000 iterations with the first 1000 samples discarded as burnin
n_mcmc_samples <- 3000 # number of samples to draw from the posterior (after the burnin)

params = list(
dist = "L", # Fitting a log normal distribution for the SI
method = "MCMC", # MCMC using coarsedatatools
burnin = 1000, # number of burnin samples (samples discarded at the beginning of MCMC) 
n1 = 50, # n1 is the number of pairs of mean and sd of the SI that are drawn
n2 = 50) # n2 is the size of the posterior sample drawn for each pair of mean, sd of SI

mcmc_control <- make_mcmc_control(
seed = MCMC_seed,
burnin = params$burnin)

dist <- params$dist

config <- make_config(
list(
si_parametric_distr = dist,
mcmc_control = mcmc_control,
seed = overall_seed,
n1 = params$n1,
n2 = params$n2))

# Fitting the serial interval
si_fit <- coarseDataTools::dic.fit.mcmc(
dat = si_data,
dist = dist,
init.pars = init_mcmc_params(si_data, dist),
burnin = mcmc_control$burnin,
n.samples = n_mcmc_samples,
seed = mcmc_control$seed)
```

```{.output}
Running 4000 MCMC iterations 
MCMCmetrop1R iteration 1 of 4000 
function value = -216.54581
theta = 
   1.94255
  -0.47988
Metropolis acceptance rate = 1.00000

MCMCmetrop1R iteration 1001 of 4000 
function value = -216.21549
theta = 
   1.81272
  -0.47418
Metropolis acceptance rate = 0.56643

MCMCmetrop1R iteration 2001 of 4000 
function value = -215.86791
theta = 
   1.85433
  -0.52118
Metropolis acceptance rate = 0.57221

MCMCmetrop1R iteration 3001 of 4000 
function value = -216.32347
theta = 
   1.93196
  -0.52205
Metropolis acceptance rate = 0.55948



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
The Metropolis acceptance rate was 0.56875
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

Let's check the results.


```r
# Check convergence of MCMC chains
converg_diag <- check_cdt_samples_convergence(si_fit@samples)
converg_diag

# Serial interval results
si_fit

# Save these for later
si_fit_lnorm <- si_fit

# Save MCMC samples in a dataframe
si_samples <- data.frame(
type = 'Symptom onset',
meanlog = si_fit@samples$var1,
sdlog = si_fit@samples$var2,
p50 = qlnorm(
p = 0.5, 
meanlog = si_fit@samples$var1, 
sdlog = si_fit@samples$var2)) |>
mutate( # Equation for conversion is here https://en.wikipedia.org/wiki/Log-normal_distribution
mean = exp(meanlog + (sdlog^2/2)), 
sd = sqrt((exp(sdlog^2)-1) * (exp(2*meanlog + sdlog^2)))
)

# Get the mean, SD, and 95% CrI
si_samples %>%
summarise(
mean_mean = mean(mean),
mean_l_ci = quantile(mean,probs=.025),
mean_u_ci = quantile(mean,probs=.975),
sd_mean = mean(sd),
sd_l_ci = quantile(sd,probs=.025),
sd_u_ci = quantile(sd,probs=.975)
)

# Now get the summary statistics for the parameters of the distribution
si_samples |>
summarise(
meanlog_mean = mean(meanlog),
meanlog_l_ci = quantile(meanlog, probs=.025),
meanlog_u_ci = quantile(meanlog, probs=.975),
sdlog_mean = mean(sdlog),
sdlog_l_ci = quantile(sdlog, probs=.025),
sdlog_u_ci = quantile(sdlog, probs=.975)
)

lognorm_meanlog <- si_fit@ests['meanlog',][1]
lognorm_sdlog <- si_fit@ests['sdlog',][1]
```

#### 8.2.4. Fitting a Weibull distribution

Finally, let's fit a Weibull distribution to the serial interval data.


```r
# We will run the model for 4000 iterations with the first 1000 samples discarded as burnin
n_mcmc_samples <- 3000 # number of samples to draw from the posterior (after the burnin)

params = list(
dist = "W", # Fitting a weibull distribution for the SI
method = "MCMC", # MCMC using coarsedatatools
burnin = 1000, # number of burnin samples (samples discarded at the beginning of MCMC) 
n1 = 50, # n1 is the number of pairs of mean and sd of the SI that are drawn
n2 = 50) # n2 is the size of the posterior sample drawn for each pair of mean, sd of SI

mcmc_control <- make_mcmc_control(
seed = MCMC_seed,
burnin = params$burnin)

dist <- params$dist

config <- make_config(
list(
si_parametric_distr = dist,
mcmc_control = mcmc_control,
seed = overall_seed,
n1 = params$n1,
n2 = params$n2))

# Fitting the serial interval 
si_fit <- coarseDataTools::dic.fit.mcmc(
dat = si_data,
dist = dist,
init.pars = init_mcmc_params(si_data, dist),
burnin = mcmc_control$burnin,
n.samples = n_mcmc_samples,
seed = mcmc_control$seed)
```

```{.output}
Running 4000 MCMC iterations 
MCMCmetrop1R iteration 1 of 4000 
function value = -218.78605
theta = 
   0.60527
   2.16747
Metropolis acceptance rate = 0.00000

MCMCmetrop1R iteration 1001 of 4000 
function value = -219.07523
theta = 
   0.52978
   2.09992
Metropolis acceptance rate = 0.55445

MCMCmetrop1R iteration 2001 of 4000 
function value = -219.35585
theta = 
   0.52396
   2.07360
Metropolis acceptance rate = 0.56672

MCMCmetrop1R iteration 3001 of 4000 
function value = -219.23607
theta = 
   0.54457
   2.19562
Metropolis acceptance rate = 0.55248



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
The Metropolis acceptance rate was 0.55375
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

Now we'll check the results.


```r
# Check convergence
converg_diag <- check_cdt_samples_convergence(si_fit@samples)
```

```{.output}

Gelman-Rubin MCMC convergence diagnostic was successful.
```

```r
converg_diag
```

```{.output}
[1] TRUE
```

```r
# Serial interval results
si_fit
```

```{.output}
Coarse Data Model Parameter and Quantile Estimates: 
         est  CIlow CIhigh
shape  1.791  1.508  2.090
scale  8.631  7.481  9.943
p5     1.647  1.102  2.241
p50    7.025  5.967  8.158
p95   15.878 13.957 18.927
p99   20.191 17.560 24.681
Note: please check that the MCMC converged on the target distribution by running multiple chains. MCMC samples are available in the mcmc slot (e.g. my.fit@mcmc) 
```

```r
# Save these for later
si_fit_weibull <- si_fit

# Save MCMC samples in dataframe
si_samples <- data.frame(
type = 'Symptom onset',
shape = si_fit@samples$var1,
scale = si_fit@samples$var2,
p50 = qweibull(
p = 0.5, 
shape = si_fit@samples$var1, 
scale = si_fit@samples$var2)) |>
mutate( # Equation for conversion is here https://en.wikipedia.org/wiki/Weibull_distribution
mean = scale*gamma(1+1/shape),
sd = sqrt(scale^2*(gamma(1+2/shape)-(gamma(1+1/shape))^2))
) 

# Get the summary statistics
si_samples %>%
summarise(
mean_mean = mean(mean),
mean_l_ci = quantile(mean,probs=.025),
mean_u_ci = quantile(mean,probs=.975),
sd_mean = mean(sd),
sd_l_ci = quantile(sd, probs=.025),
sd_u_ci = quantile(sd, probs=.975)
)
```

```{.output}
  mean_mean mean_l_ci mean_u_ci  sd_mean  sd_l_ci  sd_u_ci
1  7.693916  6.677548  8.809715 4.463549 3.797158 5.456492
```

```r
# Now get the summary statistics for the parameters of the distribution
si_samples |>
summarise(
shape_mean = mean(shape),
shape_l_ci = quantile(shape, probs=.025),
shape_u_ci = quantile(shape, probs=.975),
scale_mean = mean(scale),
scale_l_ci = quantile(scale, probs=.025),
scale_u_ci = quantile(scale, probs=.975)
)
```

```{.output}
  shape_mean shape_l_ci shape_u_ci scale_mean scale_l_ci scale_u_ci
1   1.792317    1.50812   2.090071   8.638298   7.481234   9.943215
```

```r
weibull_shape <- si_fit@ests['shape',][1]
weibull_scale <- si_fit@ests['scale',][1]
```

#### 8.2.5. Plot the results

Now we will plot the three fitted distributions. Make sure the distributions fit the serial interval data well.


```r
ggplot()+
	theme_classic()+
	geom_bar(data = contacts, aes(x=diff), fill = "#FFAD05") +
	scale_y_continuous(limits = c(0,14), breaks = c(0,2,4,6,8,10,12,14), expand = c(0,0)) +
	stat_function(
		linewidth=.8,
		fun = function(z, shape, rate)(dgamma(z, shape, rate) * length(contacts$diff)),
		args = list(shape = gamma_shape, rate = gamma_rate),
		aes(linetype  = 'Gamma')
	) +
	stat_function(
		linewidth=.8,
		fun = function(z, meanlog, sdlog)(dlnorm(z, meanlog, sdlog) * length(contacts$diff)),
		args = list(meanlog = lognorm_meanlog, sdlog = lognorm_sdlog),
		aes(linetype ='Log normal')
	) +
	stat_function(
		linewidth=.8,
		fun = function(z, shape, scale)(dweibull(z, shape, scale) * length(contacts$diff)),
		args = list(shape = weibull_shape, scale = weibull_scale),
		aes(linetype ='Weibull')
	) +
	scale_linetype_manual(values = c('solid','twodash','dotted')) +
	labs(x = "Days", y = "Number of case pairs") + 
	theme(
		legend.position = c(0.75, 0.75),
		plot.margin = margin(.2,5.2,.2,.2, "cm"),
		legend.title = element_blank(),
	) 
```

<img src="fig/EnfermedadX-rendered-plot dist-1.png" style="display: block; margin: auto;" />

Let's calculate the WAIC and LOOIC. `coarseDataTools` does not have a built-in way to do this, so we need to calculate the likelihood from the MCMC chains and use the `loo` R package.


```r
# Load likelihood functions from coarseDataTools
source("Functions/likelihood_function.R")
```

```{.warning}
Warning in file(filename, "r", encoding = encoding): cannot open file
'Functions/likelihood_function.R': No such file or directory
```

```{.error}
Error in file(filename, "r", encoding = encoding): cannot open the connection
```

```r
compare_gamma <- calc_looic_waic(symp = si_data, symp_si = si_fit_gamma, dist = "G")
```

```{.error}
Error in calc_looic_waic(symp = si_data, symp_si = si_fit_gamma, dist = "G"): could not find function "calc_looic_waic"
```

```r
compare_lnorm <- calc_looic_waic(symp = si_data, symp_si = si_fit_lnorm, dist = "L")
```

```{.error}
Error in calc_looic_waic(symp = si_data, symp_si = si_fit_lnorm, dist = "L"): could not find function "calc_looic_waic"
```

```r
compare_weibull <- calc_looic_waic(symp = si_data, symp_si = si_fit_weibull, dist = "W")
```

```{.error}
Error in calc_looic_waic(symp = si_data, symp_si = si_fit_weibull, dist = "W"): could not find function "calc_looic_waic"
```

```r
# Print results
compare_gamma[["waic"]]$estimates
```

```{.error}
Error in eval(expr, envir, enclos): object 'compare_gamma' not found
```

```r
compare_lnorm[["waic"]]$estimates
```

```{.error}
Error in eval(expr, envir, enclos): object 'compare_lnorm' not found
```

```r
compare_weibull[["waic"]]$estimates
```

```{.error}
Error in eval(expr, envir, enclos): object 'compare_weibull' not found
```

```r
compare_gamma[["looic"]]$estimates
```

```{.error}
Error in eval(expr, envir, enclos): object 'compare_gamma' not found
```

```r
compare_lnorm[["looic"]]$estimates
```

```{.error}
Error in eval(expr, envir, enclos): object 'compare_lnorm' not found
```

```r
compare_weibull[["looic"]]$estimates
```

```{.error}
Error in eval(expr, envir, enclos): object 'compare_weibull' not found
```

Which distribution(s) have the lowest WAIC and LOOIC?

Include the following when reporting the serial interval:

-   Mean and 95% credible interval

-   Standard deviation and 95% credible interval

-   The parameters of the fitted distribution (e.g., shape and scale for gamma distribution)

# \-\-\-\-\-\-\-\-\-- Break 3 ----------

## 9. Control measures

Now let's compare the serial interval and incubation period we estimated. Which one is longer? Does pre-symptomatic transmission occur with Disease X?

Will isolating symptomatic individuals and tracing and quarantining their contacts be effective measures? If not, which other measures can be implemented to slow the outbreak?

Based on the estimated delays as well as the demographics of cases, decide on 2-3 control strategies for the outbreak and develop a communications plan.

## 10. True values

The true values used to simulate the epidemics were:

|         |              |             |                           |
|---------|:------------:|:-----------:|:-------------------------:|
|         | Distribution | Mean (days) | Standard deviation (days) |
| Group 1 |    Gamma     |     8.4     |            4.9            |
| Group 2 |    Gamma     |     4.8     |            3.3            |

: Table 2. True values of the incubation period.

|         |              |             |                           |
|---------|:------------:|:-----------:|:-------------------------:|
|         | Distribution | Mean (days) | Standard deviation (days) |
| Group 1 |  Log normal  |     5.7     |            4.6            |
| Group 2 |   Weibull    |     7.1     |            3.7            |

: Table 3. True values of the serial interval.

How do your estimates compare with the true values? Discuss possible reasons for any differences.

## 11. Further resources

In this practical, we largely ignored biases due to right truncation and dynamical bias, partly due to a lack of readily available tools that implement all best practices. To learn more about how these biases could affect the estimation of epidemiological delay distributions in real-time, we recommend a tutorial on the `dynamicaltruncation` R package by Sam Abbott and Sang Woo Park (<https://github.com/parksw3/epidist-paper>).

::::::::::::::::::::::::::::::::::::: keypoints 

Revise si al final de esta lección adquirió estas competencias:


- Comprender los conceptos clave de las distribuciones de retrasos epidemiológicos para la Enfermedad X.

- Entender las estructuras de datos y las herramientas para el análisis de datos de rastreo de contactos.

- Aprender cómo ajustar las estimaciones del intervalo serial y del período de incubación de la Enfermedad X teniendo en cuenta la censura por intervalo usando un marco de trabajo Bayesiano.

- Aprender a utilizar estos parámetros para informar estrategias de control en un brote de un patógeno desconocido.

::::::::::::::::::::::::::::::::::::::::::::::::

## 12. Contributors

Kelly Charniga, Zachary Madewell, Zulma M. Cucunubá

## 13. References

1.  Reich NG et al. Estimating incubation period distributions with coarse data. Stat Med. 2009;28:2769--84. PubMed <https://doi.org/10.1002/sim.3659>
2.  Miura F et al. Estimated incubation period for monkeypox cases confirmed in the Netherlands, May 2022. Euro Surveill. 2022;27(24):pii=2200448. <https://doi.org/10.2807/1560-7917.ES.2022.27.24.2200448>
3.  Abbott S, Park Sang W. Adjusting for common biases in infectious disease data when estimating distributions. 2022 [cited 7 November 2023]. <https://github.com/parksw3/dynamicaltruncation>
4.  Lessler J et al. Incubation periods of acute respiratory viral infections: a systematic review, The Lancet Infectious Diseases. 2009;9(5):291-300. [https://doi.org/10.1016/S1473-3099(09)70069-6](https://doi.org/10.1016/S1473-3099(09)70069-6){.uri}.
5.  Cori A et al. Estimate Time Varying Reproduction Numbers from Epidemic Curves. 2022 [cited 7 November 2023]. <https://github.com/mrc-ide/EpiEstim>
6.  Lambert B. A Student's Guide to Bayesian Statistics. Los Angeles, London, New Delhi, Singapore, Washington DC, Melbourne: SAGE, 2018.
7.  Vehtari A et al. Rank-normalization, folding, and localization: An improved R-hat for assessing convergence of MCMC. Bayesian Analysis 2021: Advance publication 1-28. <https://doi.org/10.1214/20-BA1221>
8.  Nishiura H et al. Serial interval of novel coronavirus (COVID-19) infections. Int J Infect Dis. 2020;93:284-286. <https://doi.org/10.1016/j.ijid.2020.02.060>
