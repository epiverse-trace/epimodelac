
## calculates the DIC likelihood by integration
diclik <- function(par1, par2, EL, ER, SL, SR, dist){
	
	## if symptom window is bigger than exposure window
	if(SR-SL>ER-EL){
		dic1 <- integrate(fw1, lower=SL-ER, upper=SL-EL,
						  subdivisions=10,
						  par1=par1, par2=par2,
						  EL=EL, ER=ER, SL=SL, SR=SR,
						  dist=dist)$value
		if (dist == "W"){
			dic2 <- (ER-EL)*
				(pweibull(SR-ER, shape=par1, scale=par2) - pweibull(SL-EL, shape=par1, scale=par2))
		} else if (dist == "off1W"){
			dic2 <- (ER-EL)*
				(pweibullOff1(SR-ER, shape=par1, scale=par2) - pweibullOff1(SL-EL, shape=par1, scale=par2))
		} else if (dist == "G"){
			dic2 <- (ER-EL)*
				(pgamma(SR-ER, shape=par1, scale=par2) - pgamma(SL-EL, shape=par1, scale=par2))
		} else if (dist == "off1G"){
			dic2 <- (ER-EL)*
				(pgammaOff1(SR-ER, shape=par1, scale=par2) - pgammaOff1(SL-EL, shape=par1, scale=par2))
		} else if (dist == "L") {
			dic2 <- (ER-EL)*
				(plnorm(SR-ER, par1, par2) - plnorm(SL-EL, par1, par2))
		} else if (dist == "off1L") {
			dic2 <- (ER-EL)*
				(plnormOff1(SR-ER, par1, par2) - plnormOff1(SL-EL, par1, par2))
		} else {
			stop("distribution not supported")
		}
		dic3 <- integrate(fw3, lower=SR-ER, upper=SR-EL,
						  subdivisions=10,
						  par1=par1, par2=par2,
						  EL=EL, ER=ER, SL=SL, SR=SR,
						  dist=dist)$value
		return(dic1 + dic2 + dic3)
	}
	
	## if exposure window is bigger than symptom window
	else{
		dic1 <- integrate(fw1, lower=SL-ER, upper=SR-ER, subdivisions=10,
						  par1=par1, par2=par2,
						  EL=EL, ER=ER, SL=SL, SR=SR,
						  dist=dist)$value
		if (dist == "W"){
			dic2 <- (SR-SL)*
				(pweibull(SL-EL, shape=par1, scale=par2) - pweibull(SR-ER, shape=par1, scale=par2))
		} else if (dist == "off1W"){
			dic2 <- (SR-SL)*
				(pweibullOff1(SL-EL, shape=par1, scale=par2) - pweibullOff1(SR-ER, shape=par1, scale=par2))
		} else if (dist == "G"){
			dic2 <- (SR-SL)*
				(pgamma(SL-EL, shape=par1, scale=par2) - pgamma(SR-ER, shape=par1, scale=par2))
		} else if (dist == "off1G"){
			dic2 <- (SR-SL)*
				(pgammaOff1(SL-EL, shape=par1, scale=par2) - pgammaOff1(SR-ER, shape=par1, scale=par2))
		} else if (dist == "L"){
			dic2 <- (SR-SL)*
				(plnorm(SL-EL, par1, par2) - plnorm(SR-ER, par1, par2))
		} else if (dist == "off1L"){
			dic2 <- (SR-SL)*
				(plnormOff1(SL-EL, par1, par2) - plnormOff1(SR-ER, par1, par2))
		} else {
			stop("distribution not supported")
		}
		dic3 <- integrate(fw3, lower=SL-EL, upper=SR-EL,
						  subdivisions=10,
						  par1=par1, par2=par2,
						  EL=EL, ER=ER, SL=SL, SR=SR,
						  dist=dist)$value
		return(dic1 + dic2 + dic3)
	}
}

## this dic likelihood is designed for data that has overlapping intervals
diclik2 <- function(par1, par2, EL, ER, SL, SR, dist){
	if(SL>ER) {
		
		return(diclik(par1, par2, EL, ER, SL, SR, dist))
	} else {
		
		lik1 <- integrate(diclik2.helper1, lower=EL, upper=SL,
						  SL=SL, SR=SR, par1=par1, par2=par2, dist=dist)$value
		lik2 <- integrate(diclik2.helper2, lower=SL, upper=ER,
						  SR=SR, par1=par1, par2=par2, dist=dist)$value
		return(lik1+lik2)
	}
}

## likelihood functions for diclik2
diclik2.helper1 <- function(x, SL, SR, par1, par2, dist){
	if (dist =="W"){
		pweibull(SR-x, shape=par1, scale=par2) - pweibull(SL-x, shape=par1, scale=par2)
	} else if (dist =="off1W") {
		pweibullOff1(SR-x, shape=par1, scale=par2) - pweibullOff1(SL-x, shape=par1, scale=par2)
	} else if (dist =="G") {
		pgamma(SR-x, shape=par1, scale=par2) - pgamma(SL-x, shape=par1, scale=par2)
	} else if (dist=="off1G"){
		pgammaOff1(SR-x, shape=par1, scale=par2) - pgammaOff1(SL-x, shape=par1, scale=par2)
	} else if (dist == "L"){
		plnorm(SR-x, par1, par2) - plnorm(SL-x, par1, par2)
	} else if (dist == "off1L"){
		plnormOff1(SR-x, par1, par2) - plnormOff1(SL-x, par1, par2)
	} else {
		stop("distribution not supported")     
	}
}

diclik2.helper2 <- function(x, SR, par1, par2, dist){
	if (dist =="W"){
		pweibull(SR-x, shape=par1, scale=par2)
	} else if (dist =="off1W") {
		pweibullOff1(SR-x, shape=par1, scale=par2)
	} else if (dist =="G") {
		pgamma(SR-x, shape=par1, scale=par2)
	} else if (dist =="off1G") {
		pgammaOff1(SR-x, shape=par1, scale=par2)
	} else if (dist=="L"){
		plnorm(SR-x, par1, par2)
	} else if (dist=="off1L"){
		plnormOff1(SR-x, par1, par2)
	} else {
		stop("distribution not supported")     
	}
}

## functions that manipulate/calculate the likelihood for the censored data
## the functions coded here are taken directly from the
## doubly interval censored likelihood notes.
fw1 <- function(t, EL, ER, SL, SR, par1, par2, dist){
	## function that calculates the first function for the DIC integral
	if (dist=="W"){
		(ER-SL+t) * dweibull(x=t,shape=par1,scale=par2)
	} else if (dist=="off1W") {
		(ER-SL+t) * dweibullOff1(x=t,shape=par1,scale=par2)
	} else if (dist=="G") {
		(ER-SL+t) * dgamma(x=t, shape=par1, scale=par2)
	} else if (dist=="off1G") {
		(ER-SL+t) * dgammaOff1(x=t, shape=par1, scale=par2)
	} else if (dist =="L"){
		(ER-SL+t) * dlnorm(x=t, meanlog=par1, sdlog=par2)
	} else if (dist =="off1L"){
		(ER-SL+t) * dlnormOff1(x=t, meanlog=par1, sdlog=par2)
	} else {
		stop("distribution not supported")
	}
}

fw3 <- function(t, EL, ER, SL, SR, par1, par2, dist){
	## function that calculates the third function for the DIC integral
	if (dist == "W"){
		(SR-EL-t) * dweibull(x=t, shape=par1, scale=par2)
	} else if (dist == "off1W"){
		(SR-EL-t) * dweibullOff1(x=t, shape=par1, scale=par2)
	}  else if (dist == "G"){
		(SR-EL-t) * dgamma(x=t, shape=par1, scale=par2)
	}  else if (dist == "off1G"){
		(SR-EL-t) * dgammaOff1(x=t, shape=par1, scale=par2)
	} else if (dist == "L") {
		(SR-EL-t) * dlnorm(x=t, meanlog=par1, sdlog=par2)
	} else if (dist == "off1L"){
		(SR-EL-t) * dlnormOff1(x=t, meanlog=par1, sdlog=par2)
	} else {
		stop("distribution not supported")
	}
}

calc_looic_waic <- function(symp, symp_si, dist){
  # Prepare data and parameters for loo package
  # Need: an S by N matrix, where S is the size of the posterior sample (with all chains
  # merged) and N is the number of data points
  
  mat <- matrix(NA, nrow = length(symp_si@samples$var1), ncol = nrow(si_data)) 
  
for (i in 1:nrow(symp)) {
  for (j in 1:length(symp_si@samples$var1)){
    L <- diclik2(par1 = symp_si@samples$var1[j],
                 par2 = symp_si@samples$var2[j], 
                 EL = symp$EL[i], ER = symp$ER[i], SL = symp$SL[i], SR = symp$SR[i], 
                 dist = dist)
    mat[j,i] <- L
  }
}
  return(list(waic = waic(log(mat)),
              looic = loo(log(mat)))) # now we have to take the log to get log likelihood

}