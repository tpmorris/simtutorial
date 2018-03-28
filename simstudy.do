*! Michael J Crowther, Tim P Morris | 29nov2017
version 14
* Runs simulation study to produce 
* 1. estimates data
* 2. states data at start of a rep
/*
Note
-> add quietly to suppress output
-> add noisily after 'capture' to show the output
*/
quietly {
  set seed 72789 		// set your seed
  local nsim 1600		// number of simulated data sets required for each parameter setting
  local nobs 300		// number of observations in each simulated data set
  local gamma1 1		// for Weibull and exponential DGM
  local gamma2 1.5	// for Weibull not exponential DGM

  * Create temporary objects: 'post' is the name used to refer to estimates and 'postseed' to states
  tempname estimates states

  /*
	declare your post file containing:
  -> i = the simulation iteration
  -> dgm = the data generating model
  -> method = a string variable with (maximum) 7 characters, which refers to the survival model being fitted, e.g. "weibull"
  -> b = estimated log hazard ratio
  -> se = standard error of the estimated log hazard ratio
  -> conv = model converged (0=no, 1=yes)
  -> error = (0=no, 1=yes)
	*/

  postfile `estimates' int(idrep) byte(dgm method) float(theta se) byte(conv error) using estimates, replace
  * seed file
  postfile `states' int(idrep) str2000 s1 str2000 s2 str1100 s3 using states.dta, replace
	set coeftabresults off //  runs faster
	timer on 1 // if you want to time the whole sim

  * loop over iterations, conducting 1000 repetitions
	noi _dots 0, title("Simulation running...")
  forvalues i = 1/`nsim' {

    * store the rngstate
    post `states' (`i') (substr(c(rngstate),1,2000)) (substr(c(rngstate),2001,2000)) (substr(c(rngstate),4001,.))

    * at the beginning of each iteration, clear the dataset
    clear			
    * declare your sample size
    set obs `nobs'
    * generate a binary treatment group (0/1), with Prob(0.5) of being in each arm 
    gen trt = rbinomial(1,0.5)

    * DGM 
    forvalues j=1/2 {
    	* Simulate survival times from Weibull, under proportional hazards, with administrative censoring at 5 years
    	capture: survsim stime`j' event`j', dist(weibull) lambda(0.1) gamma(`gamma`j'') cov(trt -0.5) maxt(5)
			if _rc > 0 display as error "You do not have the survsim command installed" _n as text "To install it, type:" _n "ssc install survsim"
    	* Declare the data to be survival data
    	stset stime`j', failure(event`j'=1)

    	* Fit an exponential proportional hazards model, adjusting for treatment
   		capture streg trt, dist(exp) nohr
   		if (_rc>0) local error = 1
   		else local error = 0
   		* Post the iteration, DGM, model, estimated log hazard ratio, and s.e. of estimated log hazard ratio
   		post `estimates' (`i') (`j') (1) (_b[trt]) (_se[trt]) (e(converged)) (`error')

   		* Fit a Weibull proportional hazards model, adjusting for treatment
   		capture streg trt, dist(weibull) nohr
   		if (_rc>0) local error = 1
   		else local error = 0
   		* Post the iteration, DGM, model, estimated log hazard ratio, and s.e. of estimated log hazard ratio
   		post `estimates' (`i') (`j') (2) (_b[trt]) (_se[trt]) (e(converged)) (`error')

   		* Fit a Cox proportional hazards model, adjusting for treatment
   		capture stcox trt, estimate
   		if (_rc>0) local error = 1
   		else local error = 0
   		* Post the iteration, DGM, model, estimated log hazard ratio, and s.e. of estimated log hazard ratio
   		post `estimates' (`i') (`j') (3) (_b[trt]) (_se[trt]) (e(converged)) (`error')
   	}
	noi _dots `i' 0
  }
	timer off 1 // if you want to time the whole sim
	timer list // display run time
  * close the postfiles
  postclose `estimates'
  postclose `states'
}

* Label estimates data and re-save
use estimates, clear
	label variable idrep "Rep num"
	label variable dgm "Data-generating mechanism"
	label variable method "Method"
	label variable theta "θᵢ"
	label variable se "SE(θᵢ)"
	label variable conv "Converged"
	label define nylab 0 "No" 1 "Yes"
		label values conv error nylab
	label define dgmlab 1 "DGM: γ=1" 2 "DGM: γ=1.5"
		label values dgm dgmlab
	label define methodlab 1 "Exponential" 2 "Weibull" 3 "Cox"
		label values method methodlab
	sort idrep dgm method
save estimateslabels, replace

* to load your dataset of random number states
use states, replace
* to extract the first seed and reset the rngstate for repetition i
local i 23
local statei = s1[`i']+s2[`i']+s3[`i']
set rngstate `statei'
