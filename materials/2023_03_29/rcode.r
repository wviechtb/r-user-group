############################################################################

# A script to discuss formulas and formula syntax for the meeting of the
# 'R User Group at Maastricht University' (RUG@UM) on March 29th, 2023
# (https://wviechtb.github.io/r-user-group/)
#
# Author:  Wolfgang Viechtbauer (https://www.wvbauer.com)
# License: CC BY-NC-SA 4.0
#
# last updated: 2023-03-29

############################################################################

# load the dataset
load("data_survey_edit.rdata")

# note: this is the same dataset that was used in the session on 2023-03-01;
# see the materials from that session for details on this dataset and the
# steps that were taken during the data preparation

############################################################################

# so-called 'formulas' are used quite a bit in R, especially when fitting
# various types of statistical models; as an introduction, you could take a
# look at the help file (see especially the 'Details' section)
help(formula)

# before looking at models, let's first consider some simpler cases where
# formulas can be used

# say we are interested in the stress level of male and female subjects
head(dat[c("pss", "sex")])

# and we want to conduct an independent samples t-test to test the null
# hypothesis that the mean stress level is the same for the two groups

# for this, we can pass the data for the male and female subjects to the
# t.test() function (var.equal=TRUE to conduct a classical Student's t-test)
t.test(dat$pss[dat$sex == "male"], dat$pss[dat$sex == "female"], var.equal=TRUE)

# the repeated use of 'dat$' is a bit ugly; can use with() to avoid this
with(dat, t.test(pss[sex == "male"], pss[sex == "female"], var.equal=TRUE))

# but the t.test() function also allows the first argument to be a formula
# (see the 'Usage' section, which provides this clue)
help(t.test)

# then the syntax becomes
t.test(pss ~ sex, data=dat, var.equal=TRUE)

# note: can only use the 'data' argument when using a formula; the following
# will *NOT* work (you will get an error message)
t.test(pss[sex == "male"], pss[sex == "female"], data=dat, var.equal=TRUE)

# the formula syntax is much more readable

# in general, the 'outcome' (dependent variable, response variable) is given
# before the tilde (~) and the 'predictor' is given after; the 'data' argument
# is used to specify a data frame that contains these variables

# but be careful: if the data frame does not actually contain a variable, but
# such a variable is floating around in your general workspace, it will be
# picked up there
blah <- dat$pss / 10
t.test(blah ~ sex, data=dat, var.equal=TRUE)

# to avoid the potential for errors/confusion, it is best to avoid pulling
# variables out of the a data frame like this (e.g., if you transform a
# variable, make it part of the original data frame, so in the example above,
# you should use: dat$blah <- dat$pss / 10)

# let's keep our workspace tidy, so remove the 'blah' variable from it
rm(blah)

# formulas can also be used when creating various types of graphs

# scatterplot of rses (x-axis) versus pss (y-axis) with blue points for male
# subjects and red points for female subjects
plot(dat$rses, dat$pss,
     xlab="Self-Esteem", ylab="Stress",
     main="Scatterplot of Self-Esteem versus Stress",
     xlim=c(10,40), ylim=c(10,50), pch=21, cex=1.2, lwd=1.5,
     bg=ifelse(dat$sex == "male", "dodgerblue", "firebrick"))

# the same plot but using formula syntax
plot(pss ~ rses, data=dat,
     xlab="Self-Esteem", ylab="Stress",
     main="Scatterplot of Self-Esteem versus Stress",
     xlim=c(10,40), ylim=c(10,50), pch=21, cex=1.2, lwd=1.5,
     bg=ifelse(sex == "male", "dodgerblue", "firebrick"))

# note: also don't need to use dat$sex anymore in the ifelse()

# since points may overlap, we can apply some 'jittering' to them
set.seed(1234)
plot(jitter(pss, amount=0.5) ~ jitter(rses, amount=0.5), data=dat,
     xlab="Self-Esteem", ylab="Stress",
     main="Scatterplot of Self-Esteem versus Stress",
     xlim=c(10,40), ylim=c(10,50), pch=21, cex=1.2, lwd=1.5,
     bg=ifelse(sex == "male", "dodgerblue", "firebrick"))

# add a legend
legend("topright", inset=0.02, pch=21, pt.cex=1.2, pt.lwd=1.5,
       pt.bg=c("dodgerblue", "firebrick"), legend=c("male", "female"))

# as we can see above, transformations can also be applied within formulas

############################################################################

# let's consider formulas in the context of linear regression models

# a simple regression model
res <- lm(pss ~ sex, data=dat)
summary(res)

# note: since the predictor is a two-level grouping variable, this is
# identical to the independent samples t-test we conducted above)

# note: an intercept is automatically included in the model, but we could
# explicitly show this with the following formula
res <- lm(pss ~ 1 + sex, data=dat)
summary(res)

# a multiple regression model
res <- lm(pss ~ sex + rses, data=dat)
summary(res)

# a multiple regression model with an interaction
res <- lm(pss ~ sex + rses + sex:rses, data=dat)
summary(res)

# can use the shorter syntax
res <- lm(pss ~ sex * rses, data=dat)
summary(res)

# transformation of the dependent variable
res <- lm(log(pss) ~ sex + rses, data=dat)
summary(res)

# center rses at its mean
res <- lm(pss ~ sex + I(rses - mean(rses, na.rm=TRUE)), data=dat)
summary(res)

# note: when doing arithmetic on a variable, have to wrap things in I()

# personally, I find the output a bit ugly now, so I would construct the
# centered variable first and then include it in the model
dat$rsescent <- with(dat, rses - mean(rses, na.rm=TRUE))
res <- lm(pss ~ sex + rsescent, data=dat)
summary(res)

# can also use scale() but this not only subtracts the mean but by default
# also divides by the standard deviation (i.e., it creates z-scores), but we
# can switch this off
res <- lm(pss ~ sex + scale(rses, scale=FALSE), data=dat)
summary(res)

# a polynomial regression model
res <- lm(pss ~ sex + rses + I(rses^2), data=dat)
summary(res)

# the update() function is also used quite a bit with formulas
res <- update(res, . ~ . + I(rses^3))
summary(res)

# . stands for the part in the original formula; see
help(update.formula)

# one can also use - to remove terms
res <- update(res, . ~ . - sex)
summary(res)

# note: there is another way that . can be used in formulas; when not used as
# part of update(), it stands for 'use all variables' (except for the outcome)
sub <- dat[c("age", "sex", "pss", "rses")]
res <- lm(pss ~ ., data=sub)
summary(res)

# note that this is rarely a sensible thing to do unless one has constructed a
# data frame that only contains the variables of interest (and one is only
# interested in 'main effects')

############################################################################

# some models may contain multiple formulas, there can also be 'one-sided
# formulas', and other syntax that is specific to the type of model being
# fitted; an example of this are mixed-effects models (multilevel models)
# fitted with the 'nlme' package

# load the nlme package
library(nlme)

# examine the Orthodont dataset
Orthodont

# read the help file for this dataset
help(Orthodont)

# mixed-effects model predicting 'distance' from 'age' and allowing the
# intercept and slope of the relationship to differ across subjects
res <- lme(distance ~ age, random = ~ age | Subject, data=Orthodont)
summary(res)

# note the one-sided formula for 'random' and the | syntax to define the
# grouping variable for the random effects

# extended model allowing the average intercept and slope to differ for male
# and female subjects
res <- lme(distance ~ age * Sex, random = ~ age | Subject, data=Orthodont)
summary(res)

############################################################################

# more details on formulas can also be found in "An Introduction to R"; see:
# https://cran.r-project.org/doc/manuals/r-release/R-intro.html#Formulae-for-statistical-models

# many functions allow (or even require) the use of formulas; the nice thing
# is that they provide a relatively consistent syntax across different types
# of models (but always check the documentation of the function how a formula
# should be used in its context)

############################################################################
