my_simOutbreak <- 
  function (R0, # the reproduction number
            infec_curve, # the serial interval distribution
            custom_kernel,
            duration = 60, # number of time steps (days) 
            x_min = 0, #  lower bound of spatial coordinates (x-axis)
            x_max = 446, #  upper bound of spatial coordinates (x-axis)
            y_min = 0, #  lower bound of spatial coordinates (y-axis)
            y_max = 413, #  upper bound of spatial coordinates (y-axis)
            genome_length = 0, # genome length
            mutation_rate = 0, # mutation rate per nucleotide and time step
            separation_lineages = 0, # number of time steps to ancestral lineage for newly introduced pathogens
            import_rate = 0.01) # importation rate per time step, 145/365.25
  {
    
    ## setting up parameter configuration for simulation 
    config <- quicksim::new_config(x_min = x_min, x_max = x_max, y_min = y_min, y_max = y_max,
                                   spatial_kernel = custom_kernel, 
                                   genome_length = genome_length, mutation_rate = mutation_rate, 
                                   separation_lineages = separation_lineages)
    
    ## normalising the serial interval distribution
    infec_curve <- infec_curve / sum(infec_curve)
    infec_curve <- c(infec_curve, rep(0, duration))
    
    ## create one index case 
    index <- quicksim::new_case(config = config)
    
    ## create list to store results and initialise with index case
    res <- list(n = 1, id = NULL, ances = NULL, 
                cases = list(), 
                onset = NULL)
    res$id <- 1
    res$ances <- NA
    res$cases[[1]] <- index
    res$onset[1] <- index$date
    
    ## loop over time steps
    for (t in 1:duration) {
      
      ## compute current force of infection
      indiv_force <- infec_curve[t - res$onset + 1]
      indiv_force <- indiv_force * R0
      
      glob_force <- sum(indiv_force)
      
      ## draw number of newly infected individuals
      n_new_inf <- rpois(1, lambda = glob_force)
      
      ## if any,
      if (n_new_inf > 0) {
        
        ## choose the infectors for each incident case according to their current infectivity
        infectors <- sample(res$id, n_new_inf, replace = TRUE, prob = indiv_force)
        
        ## create the incident cases
        for (i in 1:n_new_inf) {
          res$n <- res$n + 1
          res$id <- c(res$id, res$n)
          res$cases[[res$n]] <- quicksim::new_case(res$cases[[res$id[infectors[i]]]],
                                                   date = t,
                                                   config = config)
          res$ances <- c(res$ances, res$id[infectors[i]])
          res$onset <- c(res$onset, t)
        }
      }
      
      ## draw number of new introductions
      n_imports <- rpois(1, import_rate)
      
      ## if any, create the imported cases
      if (n_imports > 0) {
        
        for (i in 1:n_imports) {
          res$n <- res$n + 1
          res$id <- c(res$id, res$n)
          res$cases[[res$n]] <- quicksim::new_case(date = t, config = config)
          res$ances <- c(res$ances, NA)
          res$onset <- c(res$onset, t)
        }
        
      }
      
    }
    
    res$call <- match.call()
    return(res)
  }