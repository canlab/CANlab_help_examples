library(rstanarm)       # main package for simple bayesian model implementation
library(bridgesampling) # required for using stan derived MCMC samples in bayes factor computations
library(bayesplot)      # provides diagnostic tools like mcmc_traice
library(here)
setwd(here())
options(mc.cores=parallel::detectCores())

# import data
dataDir <- "/home/bogdan/MyDocuments/canlab/pain_predictive_rois_rnd4/results/"
data <- read.csv(file.path(dataDir,"contrast_validation_data.csv"))

# classic frequentist model
lm_alt <- lmer(zr ~ dist_gt_loc*train + (1 | sid) + (dist_gt_loc | st_id), data=data, REML = TRUE)

# bayesian impelementation with vague priors
alt <- stan_lmer(zr ~ dist_gt_loc:train + train + dist_gt_loc + (1 | sid) + (dist_gt_loc | st_id), data=data, iter=10000, chains=4, diagnostic_file = file.path(tempdir(),'alt.csv'))

# bayes factor test of null
# first impelement null model
null <- stan_lmer(zr ~ dist_gt_loc + train + (1 | sid) + (dist_gt_loc | st_id), data=data, iter=10000, chains=4, diagnostic_file = file.path(tempdir(),'null.csv'))
# now compute bayes factor of null vs. alt models
bf = bayes_factor( bridge_sampler(null), bridge_sampler(alt) )


## EXTRA ##
# check that MCMCs converge on stable posterior distributions
summary(lm_alt) # check that rhat ~ 1

mcmc_trace(lm_alt, pars=c("dist_gt_loc","train","dist_gt_loc:train")) # visualize MCMCs, should be a "fuzzy caterpillar

# you should do the same for your null model. Also check that parameter estimates are similar in MCMC models and REML estimates. If not your
# priors may be driving your bayesian fit. These should agree:
fixef(lm_alt)
fixef(alt)