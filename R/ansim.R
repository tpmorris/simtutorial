# Runs simulation study to produce estimates data and states data
# See example in https://onlinelibrary.wiley.com/doi/10.1002/sim.8086
# Tim Morris @tmorris_mrc | 30apr2019
# (based partly on code of Alessandro Gasparini; also  on some pestering of Matteo Quartagno)

if (!requireNamespace("tidyverse")) install.packages("tidyverse")
if (!requireNamespace("ggplot2")) install.packages("ggplot2")
if (!requireNamespace("rsimsum")) install.packages("rsimsum")

library(tidyverse)
library(ggplot2)
library(rsimsum)

# no vomit grid in ggplot
theme_set(theme_bw(base_size = 12))
theme_update(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

# Load estimates produced by runsim.R
load("estimates.RData")

# Medium-long estimates data; label method var
estmlong <- estimates %>%
  gather(key = "meththing", value = "est", -rep, -dgmgamma) %>% 
    separate(meththing, into = c("thetase", "method"), sep = "_" ) %>% 
      spread(thetase,est)
estmlong$dgmgamma <- factor(estmlong$dgmgamma, levels = c(1,1.5), labels = c("gamma = 1", "gamma = 1.5"))
estmlong$method <- factor(estmlong$method, levels = c(1,2,3), labels = c("Exponential", "Weibull", "Cox"))
head(estmlong)


# Alternative way to get estmlong
#estlong <- reshape(estimates,
#  direction = "long", idvar = c("rep","dgmgamma"),
#  timevar = c("method"), times = c("exp", "wei", "cox"), v.names=c("theta", "se"),
#  varying = list(c("thetaexp", "thetawei", "thetacox"), c("seexp", "sewei", "secox"))
#)


# Swarm plot of theta (separated vertically by rep)
meantheta <- estmlong %>%
  group_by(dgmgamma, method) %>%
    summarise(Mean.Theta = mean(theta))
thetaswarm <- ggplot(estmlong,
  aes(x = theta, y = rep, labs(y = "", x = ""))
) + geom_point(color = rgb(.129,.404,.494) , alpha = .3) + geom_vline(data = meantheta, aes(xintercept = Mean.Theta), colour = rgb(1,0.859,0)) + facet_wrap(facets = c("dgmgamma","method"), ncol = 1, strip.position = "left") + theme(axis.title.y=element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank())
# Output pdf
thetaswarm
ggsave(filename = "thetaswarmR.pdf", plot = last_plot(), device = "pdf",
  scale = 1, width = 4, height = 6, units = "in")


# Swarm plot of se (separated vertically by rep)
meanse <- estmlong %>%
  group_by(dgmgamma, method) %>%
    summarise(Mean.SE = mean(se))
seswarm <- ggplot(estmlong,
  aes(x = se, y = rep, labs(y = "", x = ""))
) + geom_point(color = rgb(.129,.404,.494) , alpha = .3) + geom_vline(data = meanse, aes(xintercept = Mean.SE), colour = rgb(1,0.859,0)) + facet_wrap(facets = c("dgmgamma","method"), ncol = 1, strip.position = "left") + theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
# Output pdf
seswarm
ggsave(filename = "seswarmR.pdf", plot = last_plot(), device = "pdf",
  scale = 1, width = 4, height = 6, units = "in")


# Run simsum to estimate performances
ssres <- rsimsum::simsum(
  data = estmlong, estvarname = "theta", true = -.5 , se = "se",
  methodvar = "method", ref = "Weibull", by = "dgmgamma", x = TRUE
)
performance <- ssres["summ"][["summ"]]
head(performance)

# Comparison of theta according to method
autoplot(ssres, type = "est")
autoplot(ssres, type = "est_ba")
# Comparison of SE according to method
autoplot(ssres, type = "se")
autoplot(ssres, type = "se_ba")
# Ridge plots comparing theta
autoplot(ssres, type = "est_ridge")
autoplot(ssres, type = "se_ridge")
# Zip plot
zip <- autoplot(ssres, type = "zip")
zip
ggsave(filename = "zipR.pdf", plot = last_plot(), device = "pdf",
  scale = 1, width = 4, height = 6, units = "in")

# Lollipop plot for whatever performance measure you favour
autoplot(summary(ssres), type = "lolly", stats = "bias")
