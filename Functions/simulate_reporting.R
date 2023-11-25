obs_process <- function(my_list, p_report){
  
  epidemic1 <- my_list

  # Take out pieces of list
  locations <- data.frame(matrix(unlist(lapply(epidemic1$cases, function(e) e$location)),
                                 ncol = 2, byrow = TRUE))
  
  dates <- data.frame(matrix(unlist(lapply(epidemic1$cases, function(e) e$date)),
                             ncol = 1, byrow = TRUE))
  colnames(dates) <- "date_onset"
  
  ances <- data.frame(epidemic1$ances)
  colnames(ances) <- "from"
  
  linelist <- data.frame(id = epidemic1$id, 
                         date = dates,
                         Lat = locations$X1,
                         Lon = locations$X2)
  
  contacts <- data.frame(from = ances, to = epidemic1$id)
  
  # Remove NAs?
  #contacts <- contacts[!(is.na(contacts$from)),]
  
  # Sample observed cases according to reporting probability
  obs <- runif(epidemic1$n) < p_report
  
  # Filter out cases that were not observed
  linelist_new <- filter(linelist,  id %in% obs)
  
  ##### Stopped at this part. Think it's better to use %in% rather than
  # do this positionally
  # Remove IDs from linelist and make sure that ID does not show up in any pairs
  # (to or from)
  
  linelist_new <- linelist[which(obs),]
  contacts_new <- contacts[which(obs),]
  
  # Make epicontacts object
  x <- make_epicontacts(linelist = linelist,
                        contacts = contacts,
                        directed = TRUE)
  
  x1 <- make_epicontacts(linelist = linelist_new,
                        contacts = contacts_new,
                        directed = TRUE)
  
  return(list(linelist_new = linelist_new, epicontacts_obj = x))
  
}