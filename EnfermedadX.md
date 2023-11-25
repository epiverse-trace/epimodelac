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
dat <- readRDS("Data/practical_data_group1.RDS")
```

```{.warning}
Warning in gzfile(file, "rb"): cannot open compressed file
'Data/practical_data_group1.RDS', probable reason 'No such file or directory'
```

```{.error}
Error in gzfile(file, "rb"): cannot open the connection
```

```r
linelist <- dat$linelist
```

```{.error}
Error in eval(expr, envir, enclos): object 'dat' not found
```

```r
contacts <- dat$contacts
```

```{.error}
Error in eval(expr, envir, enclos): object 'dat' not found
```

```r
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

```{.error}
Error in eval(expr, envir, enclos): object 'linelist' not found
```

```r
# Q1
nrow(linelist)
```

```{.error}
Error in eval(expr, envir, enclos): object 'linelist' not found
```

```r
# Q2
table(linelist$sex)[2]/nrow(linelist)
```

```{.error}
Error in eval(expr, envir, enclos): object 'linelist' not found
```

```r
#Q3
summary(linelist$age)
```

```{.error}
Error in h(simpleError(msg, call)): error in evaluating the argument 'object' in selecting a method for function 'summary': object 'linelist' not found
```

```r
#Q4
table(linelist$exposure, exclude = F)[1]/nrow(linelist)
```

```{.error}
Error in eval(expr, envir, enclos): object 'linelist' not found
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'linelist' not found
```

```r
plot(i) + 
  theme_classic() + 
  scale_fill_manual(values = "purple") +
  theme(legend.position = "none")
```

```{.error}
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': object 'i' not found
```

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
```

```{.error}
Error in eval(expr, envir, enclos): object 'linelist' not found
```

```r
plot(x)
```

```{.error}
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'plot': object 'x' not found
```

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
```

```{.error}
Error in eval(expr, envir, enclos): object 'linelist' not found
```

```r
nrow(ip)
```

```{.error}
Error in eval(expr, envir, enclos): object 'ip' not found
```

```r
ip$exposure_window <- as.numeric(ip$exposure_end - ip$exposure_start)
```

```{.error}
Error in eval(expr, envir, enclos): object 'ip' not found
```

```r
table(ip$exposure_window)
```

```{.error}
Error in eval(expr, envir, enclos): object 'ip' not found
```

### 7.1. Naive estimate of the incubation period

Let's start by calculating a naive estimate of the incubation period.


```r
# Max incubation period 
ip$max_ip <- ip$date_onset - ip$exposure_start
```

```{.error}
Error in eval(expr, envir, enclos): object 'ip' not found
```

```r
summary(as.numeric(ip$max_ip))
```

```{.error}
Error in h(simpleError(msg, call)): error in evaluating the argument 'object' in selecting a method for function 'summary': object 'ip' not found
```

```r
# Minimum incubation period
ip$min_ip <- ip$date_onset - ip$exposure_end
```

```{.error}
Error in eval(expr, envir, enclos): object 'ip' not found
```

```r
summary(as.numeric(ip$min_ip))
```

```{.error}
Error in h(simpleError(msg, call)): error in evaluating the argument 'object' in selecting a method for function 'summary': object 'ip' not found
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'ip' not found
```

```r
ip <- ip |>
  mutate(date_onset = as.numeric(date_onset - earliest_exposure),
         exposure_start = as.numeric(exposure_start - earliest_exposure),
         exposure_end = as.numeric(exposure_end - earliest_exposure)) |>
  select(id, date_onset, exposure_start, exposure_end)
```

```{.error}
Error in eval(expr, envir, enclos): object 'ip' not found
```

```r
# Setting some options to run the MCMC chains in parallel
# Running the MCMC chains in parallel means that we will run multiple MCMC chains at the same time by using multiple cores on your computer
options(mc.cores=parallel::detectCores())

input_data <- list(N = length(ip$exposure_start), # Number of observations
              tStartExposure = ip$exposure_start,
              tEndExposure = ip$exposure_end,
              tSymptomOnset = ip$date_onset)
```

```{.error}
Error in eval(expr, envir, enclos): object 'ip' not found
```

```r
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'input_data' not found
```

```r
pos <- mapply(function(z) rstan::extract(z)$par, fit, SIMPLIFY=FALSE) # Posterior samples
```

```{.error}
Error in dots[[1L]][[1L]]: object of type 'closure' is not subsettable
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

```{.error}
Error in fit$gamma: object of type 'closure' is not subsettable
```

```r
rstan::traceplot(fit$gamma, pars = c("par[1]","par[2]")) 
```

```{.error}
Error in (function (cond) : error in evaluating the argument 'object' in selecting a method for function 'traceplot': object of type 'closure' is not subsettable
```

#### **7.1.2.2. Convergence for log normal**


```r
print(fit$lognormal, digits = 3, pars = c("par[1]","par[2]")) 
```

```{.error}
Error in fit$lognormal: object of type 'closure' is not subsettable
```

```r
rstan::traceplot(fit$lognormal, pars = c("par[1]","par[2]")) 
```

```{.error}
Error in (function (cond) : error in evaluating the argument 'object' in selecting a method for function 'traceplot': object of type 'closure' is not subsettable
```

#### **7.1.2.3. Convergence for weibull**


```r
print(fit$weibull, digits = 3, pars = c("par[1]","par[2]")) 
```

```{.error}
Error in fit$weibull: object of type 'closure' is not subsettable
```

```r
rstan::traceplot(fit$weibull, pars = c("par[1]","par[2]")) 
```

```{.error}
Error in (function (cond) : error in evaluating the argument 'object' in selecting a method for function 'traceplot': object of type 'closure' is not subsettable
```

#### **7.1.3. Compute model comparison criteria**

Let's compute the widely applicable information criterion (WAIC) and leave-one-out-information criterion (LOOIC) to compare model fits. The best fitting model is the model with the lowest WAIC or LOOIC. We will also summarize the distributions and make some plots.

Which model has the best fit?


```r
# Compute WAIC for all three models
waic <- mapply(function(z) waic(extract_log_lik(z))$estimates[3,], fit)
```

```{.error}
Error in dots[[1L]][[1L]]: object of type 'closure' is not subsettable
```

```r
waic
```

```{.output}
function(x, ...) {
  UseMethod("waic")
}
<bytecode: 0x5580def10e60>
<environment: namespace:loo>
```

```r
# For looic, we need to provide the relative effective sample sizes
# when calling loo. This step leads to better estimates of the PSIS effective
# sample sizes and Monte Carlo error

# Extract pointwise log-likelihood for the Weibull distribution
loglik <- extract_log_lik(fit$weibull, merge_chains = FALSE)
```

```{.error}
Error in fit$weibull: object of type 'closure' is not subsettable
```

```r
# Get the relative effective sample sizes
r_eff <- relative_eff(exp(loglik), cores = 2)
```

```{.error}
Error in eval(expr, envir, enclos): object 'loglik' not found
```

```r
# Compute LOOIC
loo_w <- loo(loglik, r_eff = r_eff, cores = 2)$estimates[3,]
```

```{.error}
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'loo': object 'loglik' not found
```

```r
# Print the results
loo_w[1]
```

```{.error}
Error in eval(expr, envir, enclos): object 'loo_w' not found
```

```r
# Extract pointwise log-likelihood for the gamma distribution
loglik <- extract_log_lik(fit$gamma, merge_chains = FALSE)
```

```{.error}
Error in fit$gamma: object of type 'closure' is not subsettable
```

```r
r_eff <- relative_eff(exp(loglik), cores = 2)
```

```{.error}
Error in eval(expr, envir, enclos): object 'loglik' not found
```

```r
loo_g <- loo(loglik, r_eff = r_eff, cores = 2)$estimates[3,]
```

```{.error}
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'loo': object 'loglik' not found
```

```r
loo_g[1]
```

```{.error}
Error in eval(expr, envir, enclos): object 'loo_g' not found
```

```r
# Extract pointwise log-likelihood for the log normal distribution
loglik <- extract_log_lik(fit$lognormal, merge_chains = FALSE)
```

```{.error}
Error in fit$lognormal: object of type 'closure' is not subsettable
```

```r
r_eff <- relative_eff(exp(loglik), cores = 2)
```

```{.error}
Error in eval(expr, envir, enclos): object 'loglik' not found
```

```r
loo_l <- loo(loglik, r_eff = r_eff, cores = 2)$estimates[3,]
```

```{.error}
Error in h(simpleError(msg, call)): error in evaluating the argument 'x' in selecting a method for function 'loo': object 'loglik' not found
```

```r
loo_l[1]
```

```{.error}
Error in eval(expr, envir, enclos): object 'loo_l' not found
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'pos' not found
```

```r
standard_deviations <- cbind(sqrt(pos$weibull[,2]^2*(gamma(1+2/pos$weibull[,1])-(gamma(1+1/pos$weibull[,1]))^2)),
                             sqrt(pos$gamma[,1]/(pos$gamma[,2]^2)),
                             sqrt((exp(pos$lognormal[,2]^2)-1) * (exp(2*pos$lognormal[,1] + pos$lognormal[,2]^2))))
```

```{.error}
Error in eval(expr, envir, enclos): object 'pos' not found
```

```r
# Print the mean delays and 95% credible intervals
probs <- c(0.025, 0.5, 0.975)

res_means <- apply(means, 2, quantile, probs)
```

```{.error}
Error in eval(expr, envir, enclos): object 'means' not found
```

```r
colnames(res_means) <- colnames(waic)
```

```{.error}
Error: object 'res_means' not found
```

```r
res_means
```

```{.error}
Error in eval(expr, envir, enclos): object 'res_means' not found
```

```r
res_sds <- apply(standard_deviations, 2, quantile, probs)
```

```{.error}
Error in eval(expr, envir, enclos): object 'standard_deviations' not found
```

```r
colnames(res_sds) <- colnames(waic)
```

```{.error}
Error: object 'res_sds' not found
```

```r
res_sds
```

```{.error}
Error in eval(expr, envir, enclos): object 'res_sds' not found
```

```r
# Report the median and 95% credible intervals for the quantiles of each distribution
quantiles_to_report <- c(0.025, 0.05, 0.5, 0.95, 0.975, 0.99)

# Weibull
cens_w_percentiles <- sapply(quantiles_to_report, function(p) quantile(qweibull(p = p, shape = pos$weibull[,1], scale = pos$weibull[,2]), probs = probs))
```

```{.error}
Error in FUN(X[[i]], ...): object 'pos' not found
```

```r
colnames(cens_w_percentiles) <- quantiles_to_report
```

```{.error}
Error: object 'cens_w_percentiles' not found
```

```r
print(cens_w_percentiles)
```

```{.error}
Error in eval(expr, envir, enclos): object 'cens_w_percentiles' not found
```

```r
# Gamma
cens_g_percentiles <- sapply(quantiles_to_report, function(p) quantile(qgamma(p = p, shape = pos$gamma[,1], rate = pos$gamma[,2]), probs = probs))
```

```{.error}
Error in FUN(X[[i]], ...): object 'pos' not found
```

```r
colnames(cens_g_percentiles) <- quantiles_to_report
```

```{.error}
Error: object 'cens_g_percentiles' not found
```

```r
print(cens_g_percentiles)
```

```{.error}
Error in eval(expr, envir, enclos): object 'cens_g_percentiles' not found
```

```r
# Log normal
cens_ln_percentiles <- sapply(quantiles_to_report, function(p) quantile(qlnorm(p = p, meanlog = pos$lognormal[,1], sdlog= pos$lognormal[,2]), probs = probs))
```

```{.error}
Error in FUN(X[[i]], ...): object 'pos' not found
```

```r
colnames(cens_ln_percentiles) <- quantiles_to_report
```

```{.error}
Error: object 'cens_ln_percentiles' not found
```

```r
print(cens_ln_percentiles)
```

```{.error}
Error in eval(expr, envir, enclos): object 'cens_ln_percentiles' not found
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'input_data' not found
```

```r
x_plot <- seq(0, 30, by=0.1) # This sets the range of the x axis (number of days)

Gam_plot <- as.data.frame(list(dose= x_plot, 
                               pred= sapply(x_plot, function(q) quantile(pgamma(q = q, shape = pos$gamma[,1], rate = pos$gamma[,2]), probs = c(0.5))),
                               low = sapply(x_plot, function(q) quantile(pgamma(q = q, shape = pos$gamma[,1], rate = pos$gamma[,2]), probs = c(0.025))),
                               upp = sapply(x_plot, function(q) quantile(pgamma(q = q, shape = pos$gamma[,1], rate = pos$gamma[,2]), probs = c(0.975)))
))
```

```{.error}
Error in FUN(X[[i]], ...): object 'pos' not found
```

```r
Wei_plot <- as.data.frame(list(dose= x_plot, 
                               pred= sapply(x_plot, function(q) quantile(pweibull(q = q, shape = pos$weibull[,1], scale = pos$weibull[,2]), probs = c(0.5))),
                               low = sapply(x_plot, function(q) quantile(pweibull(q = q, shape = pos$weibull[,1], scale = pos$weibull[,2]), probs = c(0.025))),
                               upp = sapply(x_plot, function(q) quantile(pweibull(q = q, shape = pos$weibull[,1], scale = pos$weibull[,2]), probs = c(0.975)))
))
```

```{.error}
Error in FUN(X[[i]], ...): object 'pos' not found
```

```r
ln_plot <- as.data.frame(list(dose= x_plot, 
                              pred= sapply(x_plot, function(q) quantile(plnorm(q = q, meanlog = pos$lognormal[,1], sdlog= pos$lognormal[,2]), probs = c(0.5))),
                              low = sapply(x_plot, function(q) quantile(plnorm(q = q, meanlog = pos$lognormal[,1], sdlog= pos$lognormal[,2]), probs = c(0.025))),
                              upp = sapply(x_plot, function(q) quantile(plnorm(q = q, meanlog = pos$lognormal[,1], sdlog= pos$lognormal[,2]), probs = c(0.975)))
))
```

```{.error}
Error in FUN(X[[i]], ...): object 'pos' not found
```

```r
# Plot cumulative distribution curves
gamma_ggplot <- ggplot(df, aes(x=inc_day)) +
  stat_ecdf(geom = "step")+ 
  xlim(c(0, 30))+
  geom_line(data=Gam_plot, aes(x=x_plot, y=pred), color=RColorBrewer::brewer.pal(11, "RdBu")[11], linewidth=1) +
  geom_ribbon(data=Gam_plot, aes(x=x_plot,ymin=low,ymax=upp), fill = RColorBrewer::brewer.pal(11, "RdBu")[11], alpha=0.1) +
  theme_bw(base_size = 11)+
  labs(x="Incubation period (days)", y = "Proportion")+
  ggtitle("Gamma")
```

```{.error}
Error in `ggplot()`:
! `data` cannot be a function.
ℹ Have you misspelled the `data` argument in `ggplot()`
```

```r
weibul_ggplot <- ggplot(df, aes(x=inc_day)) +
  stat_ecdf(geom = "step")+ 
  xlim(c(0, 30))+
  geom_line(data=Wei_plot, aes(x=x_plot, y=pred), color=RColorBrewer::brewer.pal(11, "RdBu")[11], linewidth=1) +
  geom_ribbon(data=Wei_plot, aes(x=x_plot,ymin=low,ymax=upp), fill = RColorBrewer::brewer.pal(11, "RdBu")[11], alpha=0.1) +
  theme_bw(base_size = 11)+
  labs(x="Incubation period (days)", y = "Proportion")+
  ggtitle("Weibull")
```

```{.error}
Error in `ggplot()`:
! `data` cannot be a function.
ℹ Have you misspelled the `data` argument in `ggplot()`
```

```r
lognorm_ggplot <- ggplot(df, aes(x=inc_day)) +
  stat_ecdf(geom = "step")+ 
  xlim(c(0, 30))+
  geom_line(data=ln_plot, aes(x=x_plot, y=pred), color=RColorBrewer::brewer.pal(11, "RdBu")[11], linewidth=1) +
  geom_ribbon(data=ln_plot, aes(x=x_plot,ymin=low,ymax=upp), fill = RColorBrewer::brewer.pal(11, "RdBu")[11], alpha=0.1) +
  theme_bw(base_size = 11)+
  labs(x="Incubation period (days)", y = "Proportion")+
  ggtitle("Log normal")
```

```{.error}
Error in `ggplot()`:
! `data` cannot be a function.
ℹ Have you misspelled the `data` argument in `ggplot()`
```

```r
(lognorm_ggplot|gamma_ggplot|weibul_ggplot) + plot_annotation(tag_levels = 'A') 
```

```{.error}
Error in eval(expr, envir, enclos): object 'lognorm_ggplot' not found
```

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
```

```{.error}
Error in eval(expr, envir, enclos): object 'contacts' not found
```

```r
summary(contacts$diff)
```

```{.error}
Error in h(simpleError(msg, call)): error in evaluating the argument 'object' in selecting a method for function 'summary': object 'contacts' not found
```

```r
hist(contacts$diff, xlab = "Serial interval (days)", breaks = 25, main = "", col = "pink")
```

```{.error}
Error in eval(expr, envir, enclos): object 'contacts' not found
```

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

```{.error}
Error in eval(expr, envir, enclos): object 'contacts' not found
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

```{.error}
Error in eval(expr, envir, enclos): object 'si_data' not found
```

Let's look at the results.


```r
# Check convergence of MCMC chains 
converg_diag <- check_cdt_samples_convergence(si_fit@samples)
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
converg_diag
```

```{.error}
Error in eval(expr, envir, enclos): object 'converg_diag' not found
```

```r
# Estimated serial interval results
si_fit
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
# Save these for later
si_fit_gamma <- si_fit
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
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

```{.error}
Error in eval(expr, envir, enclos): object 'si_samples' not found
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

```{.error}
Error in eval(expr, envir, enclos): object 'si_samples' not found
```

```r
# We will need these for plotting later
gamma_shape <- si_fit@ests['shape',][1]
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
gamma_rate <- 1 / si_fit@ests['scale',][1]
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
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

```{.error}
Error in eval(expr, envir, enclos): object 'si_data' not found
```

Let's check the results.


```r
# Check convergence of MCMC chains
converg_diag <- check_cdt_samples_convergence(si_fit@samples)
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
converg_diag
```

```{.error}
Error in eval(expr, envir, enclos): object 'converg_diag' not found
```

```r
# Serial interval results
si_fit
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
# Save these for later
si_fit_lnorm <- si_fit
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_samples' not found
```

```r
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_samples' not found
```

```r
lognorm_meanlog <- si_fit@ests['meanlog',][1]
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
lognorm_sdlog <- si_fit@ests['sdlog',][1]
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
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

```{.error}
Error in eval(expr, envir, enclos): object 'si_data' not found
```

Now we'll check the results.


```r
# Check convergence
converg_diag <- check_cdt_samples_convergence(si_fit@samples)
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
converg_diag
```

```{.error}
Error in eval(expr, envir, enclos): object 'converg_diag' not found
```

```r
# Serial interval results
si_fit
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
# Save these for later
si_fit_weibull <- si_fit
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
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
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
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

```{.error}
Error in eval(expr, envir, enclos): object 'si_samples' not found
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

```{.error}
Error in eval(expr, envir, enclos): object 'si_samples' not found
```

```r
weibull_shape <- si_fit@ests['shape',][1]
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
```

```r
weibull_scale <- si_fit@ests['scale',][1]
```

```{.error}
Error in eval(expr, envir, enclos): object 'si_fit' not found
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

```{.error}
Error in eval(expr, envir, enclos): object 'contacts' not found
```

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
