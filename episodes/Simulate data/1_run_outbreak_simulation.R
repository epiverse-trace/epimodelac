# Run mpox simulation 
# Running sim for 6 months
# 17 oct 2023

# Load packages
library(vimes)
library(ape)
library(dplyr)
library(EpiEstim)
library(epicontacts)
library(ggplot2)

# Load in functions
source("Functions/X_simulation.R")
source("Functions/custom_kernel_tshuapa.R") # this doesn't really matter bc we don't care about spatial distribution of cases
#source("Functions/simulate_reporting.R") potentially come back to this

# Number of simulations to run
n_sims <- 20

# Specify parameters for serial interval distribution (gamma)
# Group 1
gamma_shape <- 2.9
gamma_scale <- 2.9
gamma_rate <- 1/gamma_scale

# Group 2
gamma_shape <- 2.2
gamma_scale <- 2.2
gamma_rate <- 1/gamma_scale

gamma_mean <- gamma_shape/gamma_rate
gamma_std <- sqrt(gamma_shape)/gamma_rate

si_dist <- discr_si(seq(0, 50), gamma_mean, gamma_std)
plot(seq(0, 50), si_dist, type = "h",
     lwd = 10, lend = 1, xlab = "time (days)", ylab = "frequency")

###########################################
# Simulate the epidemic (perfect reporting)
###########################################

my_list <- list()
tictoc::tic() 
for (i in 1:n_sims){
  res <- my_simOutbreak(R0 = 1.5,
                        infec_curve = si_dist,
                        custom_kernel = custom_kernel_tshuapa)
  
  # Save each result to a list
  my_list[[i]] <- res
}
tictoc::toc()

########################################
# Simulate different levels of reporting
########################################

epidemic1 <- my_list[[1]] 

# Take out pieces of list
dates <- data.frame(matrix(unlist(lapply(epidemic1$cases, function(e) e$date)),
                           ncol = 1, byrow = TRUE))
colnames(dates) <- "date_onset"

ances <- data.frame(epidemic1$ances)
colnames(ances) <- "from"

linelist <- data.frame(id = epidemic1$id, 
                       date = dates)

contacts <- data.frame(from = ances, to = epidemic1$id)

x <- make_epicontacts(linelist = linelist,
                      contacts = contacts,
                      directed = TRUE)

plot(x)

# Save as a list
mpx_sims <- list(linelist = linelist, contacts = contacts)

#saveRDS(mpx_sims, "mpox_sims_19oct2023.RDS")
saveRDS(mpx_sims, "mpox_sims_2nov2023.RDS")

