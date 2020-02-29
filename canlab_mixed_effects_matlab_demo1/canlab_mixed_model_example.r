library(lme4) # fits LME model usin REML
library(lmerTest) # gets p-values using Satterthwaite corrected df

behav_dat <- read.csv('paingen_behav_dat_sid_14_164.csv')

heat_dat <- behav_dat[behav_dat$heat == 1,]
mdl <- lmerTest::lmer('Yint ~ stimLvl*prodicaine + (stimLvl*prodicaine | sid)', data = heat_dat)
summary(mdl)

### EXPECTED OUTPUT ###

#Linear mixed model fit by REML. t-tests use Satterthwaite's method ['lmerModLmerTest']
#Formula: "Yint ~ stimLvl*prodicaine + (stimLvl*prodicaine | sid)"
#   Data: heat_dat
#
#REML criterion at convergence: -1979.2
#
#Scaled residuals: 
#    Min      1Q  Median      3Q     Max 
#-3.1860 -0.4945 -0.1495  0.2818  5.2039 
#
#Random effects:
# Groups   Name               Variance Std.Dev. Corr             
# sid      (Intercept)        0.014215 0.11923                   
#          stimLvl            0.004538 0.06736   0.75            
#          prodicaine         0.005016 0.07083  -0.32  0.00      
#          stimLvl:prodicaine 0.003126 0.05591   0.26 -0.29  0.20
# Residual                    0.013716 0.11712                   
#Number of obs: 1704, groups:  sid, 121
#
#Fixed effects:
#                     Estimate Std. Error         df t value Pr(>|t|)    
#(Intercept)          0.164019   0.011235 120.333475  14.599  < 2e-16 ***
#stimLvl              0.073985   0.009176 127.155505   8.063 4.75e-13 ***
#prodicaine          -0.054471   0.008682 121.387530  -6.274 5.64e-09 ***
#stimLvl:prodicaine   0.006581   0.014501 255.323366   0.454     0.65    
#---
#Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#
#Correlation of Fixed Effects:
#            (Intr) stmLvl prodcn
#stimLvl      0.494              
#prodicaine  -0.232  0.014       
#stmLvl:prdc  0.093 -0.075  0.079
#convergence code: 0
#Model failed to converge with max|grad| = 0.0115361 (tol = 0.002, component 1)