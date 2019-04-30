*! Tim P Morris 29nov2017
version 10

use estimateslabels, clear

* Run simsum
simsum theta, true(-.5) se(se) by(dgm) methodvar(method) id(idrep) ref(Weibull) mcse format(%6.3fc)

gen byte bccovers = 0
* bias-corrected coverage
forval dgm = 1/2 {
	forval method = 1/3 {
		summ theta if dgm==`dgm' & method==`method', meanonly
		local thetahat = r(mean)
		replace bccovers = 1 if theta-(1.96*se)<`thetahat' & theta+(1.96*se)>`thetahat' & dgm==`dgm' & method==`method'
	}
}

bysort dgm method: ci proportions bccovers
