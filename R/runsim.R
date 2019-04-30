# Runs simulation study to produce estimates data and states data
# See example in https://onlinelibrary.wiley.com/doi/10.1002/sim.8086
# Tim Morris @tmorris_mrc | 30apr2019
# (based partly on code of Alessandro Gasparini; also on some pestering of Matteo Quartagno)

if (!requireNamespace("simsurv")) install.packages("simsurv")
if (!requireNamespace("eha")) install.packages("eha")
library(simsurv)
library(eha)


# Function to generate one-repetition worth of data
# Generate survival times s from a Weibull dist. with single binary covariate trt
# and administrative censoring at time s = 5
# Then analyse using exponential, Weibull and Cox
onerep <- function(rep, nobs = 300, prob = 0.5, lambda = 0.1, gamma = 1, beta = -0.5) {
  df <- data.frame(
    id = 1:nobs,
    trt = rbinom(n = nobs, size = 1, prob = prob)
  )
  # Generate survival times and merge into df
  s <- simsurv(lambdas = lambda, gammas = gamma, betas = c(trt = beta), x = df, maxt = 5)
  df <- merge(df, s)
  # Exponential model
  fitexp <- phreg(Surv(eventtime, status) ~ trt, data = df, dist = "weibull", shape = 1)
    thetaexp <- coef(fitexp)[["trt"]]
    se_thetaexp <- sqrt(fitexp[["var"]]["trt", "trt"])
  # Weibull model
  fitwei <- phreg(Surv(eventtime, status) ~ trt, data = df, dist = "weibull")
    thetawei <- coef(fitwei)[["trt"]]
    se_thetawei <- sqrt(fitwei[["var"]]["trt", "trt"])
  # Cox model
  fitcox <- coxph(Surv(eventtime, status) ~ trt, df)
    thetacox <- coef(fitcox)[["trt"]]
    se_thetacox <- sqrt(fitcox[["var"]])
  # Output coeffs and SEs
  out <- data.frame(
    rep = rep,
    dgmgamma = gamma,
    theta_1 = thetaexp,
    se_1 = se_thetaexp,
    theta_2 = thetawei,
    se_2 = se_thetawei,
    theta_3 = thetacox,
    se_3 = se_thetacox
  )
  return(out)
}

# Uncomment the following line to run once with large n_obs.
#onerep(i = 1, nobs = 100000)

# Preparation to run nsim repetitions
set.seed(65416)
nsim <- 1600
# Empty estimates data frame to fill up.
# Note - requires nsim*2 rows because 2 data-generating mechanisms
estimates <- data.frame(matrix(ncol = 8, nrow = (nsim*2)))
x <- c("rep", "dgmgamma", "theta_1", "se_1", "theta_2", "se_2", "theta_3", "se_3")
colnames(estimates) <- x
states <- matrix(ncol = 626, nrow = (nsim*2))

# Run all nsim reps
for (r in 1:nsim) {
  # 1st data-generating mechanism
  states[r, ] <- .Random.seed
  estimates[r, ] <- onerep(rep = r, gamma=1)
  # 2nd data-generating mechanism
  states[(nsim+r), ] <- .Random.seed
  estimates[(nsim+r), ] <- onerep(rep = r, gamma=1.5)
}

# Save data frame for analysis
head(estimates)
saveRDS(estimates, file = "estimates.RData")
head(states)
saveRDS(states, file = "states.RData")

# Want to reproduce data from a particular rep? This is why we produced (and saved) states
# Here is repetition 3, gamma = 1
.Random.seed <- states[3,]
onerep(rep = 3, gamma=1)
# Now for repetition 211, gamma = 1.5
.Random.seed <- states[(nsim+211),] # For the second data-generating mechanism, we stored state r in row nsim+r
onerep(rep = 211, gamma=1.5)
