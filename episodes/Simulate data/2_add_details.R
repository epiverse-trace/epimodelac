# Adding more details to simulated linelist for practical
# 19 oct 2023
# Group 1

library(dplyr)
library(incidence)
library(epicontacts)

sims <- readRDS("Data/mpox_sims_19oct2023.RDS")

linelist <- sims$linelist
contacts <- sims$contacts

# Pick arbitrary date to start the epidemic
dates <- data.frame(date = seq(from = as.Date("2023-10-01"), to = as.Date("2023-11-30"), by = "days"),
                    date_onset = 0:60)

# Add dates to simulated data
linelist <- linelist |>
  left_join(dates) |>
  select(-date_onset) |>
  rename(date_onset = date)

# Add demographics
set.seed(1234)
sex <- sample(x = c("M","F"), size = nrow(linelist), 
                       replace = T, prob = c(0.55, 0.45))

age <- round(rnorm(n = nrow(linelist), mean = 35, sd = 4), digits = 0)
hist(age)

# Add some missing
exposure <- sample(x = c("Close, skin-to-skin contact",NA), size = nrow(linelist), replace = T, prob = c(0.7, 0.3))

linelist <- linelist |>
  mutate(sex = sex, age = age, exposure = exposure)

# Make sure women don't report MMSC
#linelist$exposure <- ifelse(linelist$sex == "F", NA, linelist$exposure)

# Plot the outbreak
#i <- incidence(linelist$date_onset)
#plot(i)

# Add dates to contact df to prepare for estimation of serial interval
infectors <- linelist |>
  select(id, date_onset) |>
  rename(from = id, primary_onset_date = date_onset)

infectees <- linelist |>
  select(id, date_onset) |>
  rename(to = id, secondary_onset_date = date_onset)

contacts2 <- contacts |>
  left_join(infectors) |>
  left_join(infectees)

# Later, remove some rows bc you don't have contact tracing data for everyone
contacts2 <- contacts2[-1,]

# Sample observed cases according to reporting probability
obs <- runif(nrow(contacts2)) < 0.4

contacts3 <- contacts2[which(obs),]

# check <- select(contacts3, from, to)
# 
# x1 <- make_epicontacts(linelist = linelist,
#                       contacts = contacts3,
#                       directed = TRUE)
# 
# plot(x1)

# Make it easy: no pre-symptomatic transmission. Have them evaluate this possibility though

# Next sort out IP from first 25 cases
IP <- contacts2[1:50,]

IP <- IP |>
  select(-from) |>
  mutate(SI = secondary_onset_date - primary_onset_date)

# Sample from IP from Madewell et al.
IP_v <- vector()
for (i in 1:nrow(IP)){
  IP_samp <- round(rlnorm(n = 1, meanlog = 1.5, sdlog = 0.7), digits = 0)
  #IP_v[i] <- ifelse(IP_samp > IP$SI[i], IP$SI[i], IP_samp) # Make sure no pre-symptomatic transmission
  IP_v[i] <- IP_samp
  }

IP2 <- cbind(IP, IP_v)

IP2 <- IP2 |>
  rename(id = to, date_onset = secondary_onset_date) |>
  select(-primary_onset_date, -SI) |>
  mutate(exposure_date = date_onset - IP_v) |>
  select(-IP_v)

# Add some uncertainty about exposure date
IP2$exposure_window <- sample(x = c(0,1,2), size = nrow(IP2), 
                               replace = T, prob = c(0.7, 0.2, 0.1))

exposure_start_v <- vector()
exposure_end_v <- vector()
for (i in 1:nrow(IP2)){
  
  exposure_window <- IP2$exposure_window[i]
  
  if (exposure_window == 0) {
    exposure_start_v[i] <- IP2$exposure_date[i]
    exposure_end_v[i] <- IP2$exposure_date[i]
  }
  if (exposure_window == 1 & IP2$id[i] < 30){
    exposure_start_v[i] <- IP2$exposure_date[i] - 1
    exposure_end_v[i] <- IP2$exposure_date[i]
  } 
  
  if (exposure_window == 1 & IP2$id[i] >= 30){
    exposure_start_v[i] <- IP2$exposure_date[i] 
    exposure_end_v[i] <- IP2$exposure_date[i] + 1
  } 
  
  if (exposure_window == 2) {
    exposure_start_v[i] <- IP2$exposure_date[i] - 1
    exposure_end_v[i] <- IP2$exposure_date[i] + 1
  }
}

exposure_start <- as.Date(exposure_start_v)
exposure_end <- as.Date(exposure_end_v)

IP3 <- cbind(IP2, exposure_start, exposure_end)

IP4 <- select(IP3, -exposure_date, -exposure_window)


linelist_new <- left_join(linelist, IP4)

contacts4 <- contacts3 |>
  rename(primary_case_id = from,
         secondary_case_id = to)

saveRDS(list(linelist = linelist_new,
                         contacts = contacts4), "practical_data_group1.RDS")

