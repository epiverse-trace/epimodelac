# x is two things, an x and a y coordinate
custom_kernel_tshuapa <- function(x, 
                                  x_min = 0, #  lower bound of spatial coordinates (x-axis) 
                                  x_max = 446, #  upper bound of spatial coordinates (x-axis)
                                  y_min = 0, #  lower bound of spatial coordinates (y-axis)
                                  y_max = 413, #  upper bound of spatial coordinates (y-axis)
                                  sd = 0.10) { # standard deviation of the spatial kernel) bounds were calculated in this script: Calculating l and w of Tshuapa for simulation.R
  
  out <- stats::rnorm(length(x), mean = x, sd = sd)
  
  # Mirror effect
  # If first coordinate is lower than x min, reflect it back in taking absolute value
  # Else if first coordinate is higher than x max, reflect it back in 
  if (out[1] < x_min){
    out[1] <- abs(out[1])
  }
  if (out[1] > x_max){
    step1 <- out[1] - x_max
    out[1] <- out[1] - 2*step1
  } else {
    out[1] <- out[1]
  }
  
  
  # Do the same for y coordinates
  if (out[2] < y_min){
    out[2] <- abs(out[2])
  }
  if (out[2] > y_max){
    step1 <- out[2] - y_max
    out[2] <- out[2] - 2*step1
  } else {
    out[2] <- out[2]
  }
  
  out
}