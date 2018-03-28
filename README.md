# Stata code for running a simple simulation study
The files contained in this repository are provided for for readers of [Morris, White and Crowther's tutorial paper](https://arxiv.org/abs/1712.03198) to run the example simulation study.

## Running the `.do` files
For those running the files (rather than just reading them), note that `simstudy.do` should be run first, since this is the core of the simulation. It produces the data files `estimates.dta`, `estimateslabels.dta` (a cleanly labelled version of estimates) and `states.dta`. However, these data files are also provided here.

## Stata versions
Relatively recent versions of Stata are needed:   
* `simstudy.do` requires version 14 (Stata's random number generator changed from using KISS to Mersenne twister, and the form of `c(rngstate)` also changed to be more complex; This file shows how to handle the resulting >5000 character strings defining the random number generator state).
* `ansim-simsum.do` requires version 14 (due to the `ci proportions` command).
* `ansim-pointplots.do` requires version 15 (the graphs use the translucency features introduced at version 15)
* `ansim-zipplot.do` requires version 15 (the graphs use the translucency features introduced at version 15)
The guts of these files would work in older versions (down to 11.2), and could be adapted by users.

## User-written packages
To run `simstudy.do`, the user-written package `survsim` is required. This can be installed with:   
`. ssc install survsim`   
See: [Crowther MJ and Lambert PC. Simulating complex survival data. The Stata Journal 2012;12(4):674-687.](http://www.stata-journal.com/article.html?article=st0275)   

Similarly, to run `ansim-simsum.do`, submit:   
`. ssc install simsum`   
See: [White IR. simsum: Analyses of simulation studies including Monte Carlo error. The Stata Journal 2010;10(3):369-385](http://www.stata-journal.com/article.html?article=st0200)   

Note that the graphs presented in the [tutorial](https://arxiv.org/abs/1712.03198) used the MRC graph scheme, which can be downloaded using:
`. ssc install scheme-mrc`
and invoked with
`. set scheme mrc`

## Bugs, issues and improvements
Please do let us know of any issues you discover in these files, and we will endeavor to acknowledge you here.

## To-do
**Produce R scripts to perform the same simulation study**   
Background: In Stata, saving estimates and random number states are what trips people up. This is straightforward to do in R. Many of the simulation studies we reviewed in [https://arxiv.org/abs/1712.03198](https://arxiv.org/abs/1712.03198) were coded in R, and very few in Stata. We therefore judged that the Stata community were more likely to want these files, and did not expect demand from R users. However, having now received several requests from R users, we are working on this.
