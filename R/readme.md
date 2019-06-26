# R code for running a simple simulation study
## Taken from the example in https://onlinelibrary.wiley.com/doi/10.1002/sim.8086
The files contained in this repository are provided for for readers of [Morris, White and Crowther's tutorial paper](https://onlinelibrary.wiley.com/doi/10.1002/sim.8086) to run the example simulation study.

## Disclaimer
I am not an R programmer and this represents my first full simulation study in R. I am aware of several alternative ways in which I could have coded this. My code attempts to be clear rather than clever or beautiful, though I may also have failed at clarity.

## Running the `.R` files
For those running the files (rather than just reading them), note that `runsim.R` should be run first, since this is the core of the simulation. It produces the files `estimates.rds` and `states.rds` (these files are also provided in this repo). The file `ansim.R` can then be run.

## R versions
This was run in R version 3.6.0. I don't know if it would work on earlier versions (sorry).

## Additional libraries
To run `runsim.R`, the `simsurv` and `eha` packages are required.

To run `ansim.R`, the `tidyverse` and `rsimsum` packages are required.

## Reproducing data/results of a single repetition
At the end of `runsim.R` there is some code to reproduce the results of a specific repetition and data-generating mechanism. When running the repetitions, I output the current state (`.Random.seed`) of the random-number generator at the beginning of each repetition for each data-generating mechanism. This can then be used to later set `.Random.seed` to the desired value and repeat what was done.

Note that this is not general: it works for the default random-number generator in R (Mersenne twister) and I have not checked how the current state is represented for other generators.

## Bugs, issues and improvements
Please do let me know of any issues you discover in these files, and I will endeavor to acknowledge you here. I am not certain to respond to pull requests that say 'here's how you *should* do it', but I will respond to requests that say 'I found an error here'. It's not that I think I've done it the best way, it's just that I don't know enough about R to judge whether a different approach is better in a worthwhile way; by all means release and publicise your own better version!
