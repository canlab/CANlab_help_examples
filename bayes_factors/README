This package describes how to compute Bayes Factors for complex models using MCMC sampling. For
simpler models you may wish to consider simpler approaches such as Richard D. Morey's package
available here:
https://cran.r-project.org/web/packages/BayesFactor/index.html

The contents of this folder provide an example of using bayes factors to test whether or not an
estimate in a validation dataset is the same as an estimate in a training dataset. This is a null
hypothesis test that is not tractable within a frequentist framework. 

Bayesian models are defined using the common LMER model formula specification, estimated using
full MCMC (Hamiltonian Monte Carlo (HMC), for details refer to rstanarm and STAN documentations)
implemented seemlessly from the users perspective (by rstanarm), and then bayes factors are
obtained by using bridge sampling to compensate for certain limitations posed by the HMC MCMC
algorithm. All this is done in a handful of lines and is easy to impelement. 

Bayesian models should be checked for several factors before Bayes factors can be trusted.
1) Do the MCMC chains converge? Multiple chains should be run, and the results from these chains
should agree. use mcmc_trace, as detailed in bayes_factor_test_with_rstanarm.r to check. If they
do not agree your model is either poorly specified or you need to increase your MCMC "burn-in"
time. Easiest way to do this is to increase the iter parameter when running stan_lmer().
2) Are your parameter estimates stable? Check rhat values from summary(stan_lmer(...)). These
should be 1 or at least very close to 1.
3) Do your parameter estimates agree with those estimated using frequentist methods? Bayesian
models have a lot of power in that you can specify sensible priors, but if you're doing a null
hypothesis test then you're likely operating within a frequentist hypothesis testing framework and
aren't interested in having the priors influence your parameter estimates. The priors used by
rstanarm are vaguely informative (e.g. a wide cauchy distribution) to facilitate efficient MCMC
computation and faster convergence, but if your posterior parameter estimates do not agree with
your frequentist estimates (obtained using REML and LME4 for instance), then you likely have
insufficient data to fit your model, and care should be taken in interpretting your bayes factors.
Bayes factors are subject to the influence of priors, and if your priors are manifesting in your
posterior estimates that's reason for me at least to suspect that they're also more likely than
I'd like to be driving my bayes factors.

On the topic of priors, if you find that you test a model both with Morey's package (assuming your
model is simple enough to make that possible), and the approach described here, you will find
divergent results due to different choices in priors. To obtain results with the current approach
similar to Morey's you will need to specify a narrower prior in your stan models. The default is a
normal(0,2.5*s_x/s_y) prior on coefficients, but for results more comparable to Morey's it seems a
normal(0,sqrt(2)/2*s_x/s_y) prior is more appropriate. The former can be specified by supplying
prior=normal(0,sqrt(2)/2,autoscale=TRUE) to stan_lmer calls. rstanarm 'autoscales' priors, while
Morey's package places a prior on effect sizes. I'm not sure if these are equivalent, and while
Morey's prior on the scale of the effect size is sqrt(2)/2 I don't want to give the impression
that this necessarily corresponds to a prior on the coefficients of 2.5*s_x/s_y in rstanarm. The
equivalence is purely anecdotal. That said, setting an rscale=2.5 prior in Morey's package does
seem to provide results that agree with the rstanarm + bridgesampling defaults, so maybe 
autoscaling and priors on the effect size are the same thing. At any rate, the consequence of a 
wider scale prior seems to be to increase the odds in favor of the null. Morey justifies narrower
priors on the grounds that psychology research tends to have small effect sizes. Perhaps, but 
another way to say that is that psychology is a field happy to entertain belief in things without
much evidence. So narrow your priors according to the strength of your faith I suppose.

Finally, just because you have a correct bayes factor doesn't mean that bayes factors are right
for your application, or that they're good for any application at all. Model comparison is a hotly
contested domain of statistical theory, no method is without it's detractors and some will object
to model comparison outright (e.g. an argument that focus should be shifted to parameter
estimation can be made easily enough). One thing to note about bayes factors however is that they
do tend to be biased towards the more parsimonious model (consider the choice of using BIC vs.
AIC, BIC penalizes model complexity more than AIC. That's related to the bias for the null in
bayes factors).


File descriptions ::

bayes_factor_test_with_rstanarm.r - main script. Performs Bayes Factor tests using the the STAN
statistical programming language (implemented in a userfriendly way by rstanarm) and
bridgesampling

contrast_validation_data.csv - this is data from a machine learning study where six different
models (aka MVPA patterns) were developed in a hierarchical training. Cross validated prediction
metrics are saved and were used to make inferential claims about which model was best. The models
were then applied to novel data to validate the inferential claims made in the cross validated
data. The data includes several columns
zr - z-fisher r-values. r-values represent within subject predicted vs. observed pain. One value
per subject per model.
dist_gt_loc - planned contrast: models 1,2,3 vs. 4,5,6.
roi_gt_net - planned contrast: models 1 vs 2,3
brain_gt_ns - planned contrast: models 5 vs 6
ns_and_b_gt_ppath - planned contrast: models 5,6 vs 4
net17_gt_net7 - planned contrast: model 2 vs 3
brain_gt_roi - post-hoc contrast: model 1 vs 6
st_id - study index (subjects are grouped by study)
dummyVar - model indices. Value indicates which model a row's predictions (zr) came from
sid - subject id
train - contrast variable. 0.5 indicates training data. -0.5 indicates validation data


problem_space.png - visual illustration of the problem.
top left: ANOVA illustrated planned and post-hoc contrasts in training data.
top right: contrasts and standard errors (REML estimated) in training data.
bottom left: violin plots indicate predicted random study effect distributions for each model.
dots indicate validation data study mean prediction accuracy for each model with standard errors
(estimated by REML).
bottom center: violin plots indicate predicted random effect distributions for contrasts found to
be statistically significant in the training data (top row).
bottom right: training and validation data mean contrast estimates. Bayes factors provide a
quantitative way of determining if these the same or different, providing a formal framework for
evaluating whether our validation data in fact validates our inferential and MVPA models.


Additional Reading ::

Two sources in particular might provide helpful reading

The documentation for stan is technical but helpful (for instance the procedure for obtaining
posterior point estimates is different from that for obtaining posterior samples).
https://mc-stan.org/users/documentation/

Andrew Gelman's "Bayesian Data Analysis" textbook is also quite good, but presupposes a certain
level of mathematical abilities and statistical knowledge.

Example provided by Bogdan Petre, 9/18/20
