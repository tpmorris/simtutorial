*! Tim P Morris 29nov2017
* File to produce the zip plot
version 15

* Zip plot of conf int
use estimateslabels, clear
gen float cilow = theta + (se*invnorm(.025))
gen float ciupp = theta + (se*invnorm(.975))

local trteff -0.5 // name true value of theta `trteff'

* For coverage (or type I error), use true θ for null value
* so p<=.05 is a non-covering interval
gen float ptheta = 1-normal(abs(theta-`trteff')/se) // if sim outputs df, use ttail and remove '1-'
gen byte covers = ptheta > .025  // binary indicator of whether ci covers true theta

sort dgm method ptheta
by dgm method: gen double pthetarank = 100 - (_n/16) // scale from 0-100. This will be vertical axis.

* Create MC conf. int. for coverage
gen float covlb = .
gen float covub = .
forval dgm = 1/2 {
	forval method = 1/3 {
		di as text "DGM = " as result `dgm' as text ", method = " as result `method'
		qui ci proportions covers if dgm==`dgm' & method==`method'
			qui replace covlb = 100*(r(lb)) if dgm==`dgm' & method==`method'
			qui replace covub = 100*(r(ub)) if dgm==`dgm' & method==`method'
	}
}
bysort dgm method: replace covlb = . if _n>1
bysort dgm method: replace covub = . if _n>1
qui gen float lpoint = -1.5 if !missing(covlb)
qui gen float rpoint =  1.5 if !missing(covlb)


* Plot of confidence interval coverage:
* First two rspike plots: Monte Carlo confidence interval for percent coverage
* second two rspike plots: confidence intervals for individual reps
* blue intervals cover, purple do not
* scatter plot (white dots) are point estimates - probably unnecessary
#delimit ;
twoway (rspike lpoint rpoint covlb, hor lw(thin) pstyle(p5)) // MC 
	(rspike lpoint rpoint covub, hor lw(thin) pstyle(p5))
	(rspike cil ciu pthetarank if !covers, hor lw(medium) pstyle(p2) lcol(%30))
	(rspike cil ciu pthetarank if covers, hor lw(medium) pstyle(p1) lcol(%30))
	(scatter pthetarank theta, msym(p) mcol(white%30)) // plots point estimates in white
	(pci 0 -.5 100 -.5, pstyle(p5) lw(thin))
	,
	name(coverage, replace)
	xtit("95% confidence intervals")
	ytit("Centile of ranked p-values for null: θ=–0.5")
	ylab(5 50 95)
	by(dgm method, cols(3) note("") noxrescale iscale(*.8)) scale(.8)
	legend(order(4 "Coverer" 3 "Non-coverer") rows(1))
	xsize(4) scheme(economist)
	;
#delimit cr
graph export zipplot.pdf, replace
