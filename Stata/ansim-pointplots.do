*! Tim P Morris 29nov2017
version 15

use estimateslabels, clear

* Scatter of theta_i against repetition id, by method and DGM
* Note - I space the different methods out by adding 2500 to rep number
* of method 2 and 5000 to rep number of method 3, then label the methods
replace idrep = idrep + 2500 if method==2
replace idrep = idrep + 5000 if method==1
lab def idreplab 750 "Cox" 3250 "Weibull" 5750 "Exponential"
	lab val idrep idreplab
twoway scatter idrep theta, ///
	msymbol(o) msize(small) mcolor(%30) mlc(%0)	///
	by(dgm, cols(1) note("") xrescale)	///
	ytitle("") ylabel(750 3250 5750, nogrid)	///
	ytick(-450 2050 4550, noticks grid)	///
	xline(-.5, lc(gs8)) name(thetai, replace)
	
* As above but for modelse
twoway scatter idrep se, ///
	msymbol(o) msize(small) mcolor(%30) mlc(%0)	///
	by(dgm, cols(1) note("") xrescale)	///
	ytitle("") ylabel(750 3250 5750, nogrid)	///
	ytick(-450 2050 4550, noticks grid) name(sei, replace)

graph combine thetai sei, xsize(7) iscale(*1.5)

graph export thetaisei.pdf, replace
graph export thetaisei.svg, replace


* theta_i vs. se_i
twoway scatter se theta, msym(o) msize(small) mcol(%30) mlc(%0) by(method dgm, cols(2) yrescale xrescale)


* Comparing each method vs. each other method
use estimateslabels, clear
drop conv error // all reps converged, no errors
reshape wide theta se, i(idrep dgm) j(method)

label var theta1 "θ, Exponential"
label var se1 "SE(θ), Exponential"
label var theta2 "θ, Weibull"
label var se2 "SE(θ), Weibull"
label var theta3 "θ, Cox"
label var se3 "SE(θ), Cox"

* Standard matrix plot of theta(method) vs. theta(!method)
* Waste of space
foreach s in theta se {
	graph matrix `s'1 `s'2 `s'3, by(dgm, note("")) msym(p) name(`s', replace) xsize(8)
}


* This plot takes more effort but is better
local opts yscale(range(-1.5 0)) xscale(range(-1.5 0)) msym(i) mlabs(vlarge) mlabc(black) aspect(1) graphregion(margin(zero)) plotregion(margin(zero)) xtit("") ytit("") legend(off) nodraw
twoway scatteri 0 0 (0) "Exponential" .5 .7 (0) "θᵢ " -.5 0 (0) "SE(θᵢ)", `opts' xlab(none) ylab(none) name(Exponential, replace)
twoway scatteri 0 0 (0) "Weibull" .5 .5 (0) "θᵢ" -.5 -.5 (0) "SE(θᵢ)", `opts' xlab(none) ylab(none) name(Weibull, replace)
twoway scatteri 0 0 (0) "Cox" .5 0 (0) "θᵢ" -.5 -.5 (0) "SE(θᵢ)", `opts' xlab(none) ylab(none) name(Cox, replace)
forval dgm = 2/2 {
	if `dgm'==1 {
		local frtheta -1 0
		local frse .18 .25
	}
	else if `dgm'==2 {
		local frtheta -1 .1
		local frse .14 .17
	}
	twoway (function x, range(`frtheta') lcolor(gs10)) (scatter theta1 theta2 if dgm==`dgm', mc(%50) msize(vsmall)), `opts' name(theta12dgm`dgm', replace)
	twoway (function x, range(`frtheta') lcolor(gs10)) (scatter theta1 theta3 if dgm==`dgm', mc(%50) msize(vsmall)), `opts' name(theta13dgm`dgm', replace)
	twoway (function x, range(`frtheta') lcolor(gs10)) (scatter theta2 theta2 if dgm==`dgm', mc(%50) msize(vsmall)), `opts' name(theta23dgm`dgm', replace)
	twoway (function x, range(`frse')) (scatter se1 se2 if dgm==`dgm', mc(%50) msize(vsmall)), `opts' name(se12dgm`dgm', replace)
	twoway (function x, range(`frse')) (scatter se1 se3 if dgm==`dgm', mc(%50) msize(vsmall)), `opts' name(se13dgm`dgm', replace)
	twoway (function x, range(`frse')) (scatter se2 se2 if dgm==`dgm', mc(%50) msize(vsmall)), `opts' name(se23dgm`dgm', replace)
	graph combine Exponential theta12dgm`dgm' theta13dgm`dgm'	///
		se12dgm`dgm'	Weibull theta23dgm`dgm'	///
		se13dgm`dgm' se23dgm`dgm' Cox	///
		, cols(3)	///
		xsize(4)	///
		name(dgm`dgm', replace)
	//graph export dgm`dgm'.pdf, replace
}
