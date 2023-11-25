re_number_clusters <- function(sim_mpx){
  
  # Re-number the clusters
  sort(unique(sim_mpx$cluster_member))
  table(sim_mpx$cluster_member)
  max_num <- length(unique(sim_mpx$cluster_member))
  
  seq_num <- seq(1,max_num, by = 1)
  
  # Keep the order 
  sim_mpx$order <- 1:nrow(sim_mpx)
  sim_mpx <- sim_mpx[order(sim_mpx$cluster_member),]
  
  sim_mpx$cluster_member <- as.numeric(sim_mpx$cluster_member)
  
  cluster_member <- sort(unique(sim_mpx$cluster_member))
  clust_renumbered <- seq(1, length(unique((sim_mpx$cluster_member))), by = 1)
  dat_renum <- data.frame(cluster_member, clust_renumbered)
  
  sim_mpx <- merge(sim_mpx, dat_renum, by = "cluster_member", all.x = TRUE)
  
  # return to original order
  sim_mpx <- sim_mpx[order(sim_mpx$order),]
  
  # Drop order variable
  sim_mpx <- select(sim_mpx, -order)
  
  return(sim_mpx)
  
  
  
}