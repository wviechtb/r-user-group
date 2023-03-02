############################################################################

# A small script to introduce some of the basics of R for the first meeting of
# the 'R User Group at Maastricht University' (RUG@UM) on March 1st, 2023
# (https://wviechtb.github.io/r-user-group/)
#
# Author:  Wolfgang Viechtbauer (https://www.wvbauer.com)
# License: CC BY-NC-SA 4.0
#
# last updated: 2023-03-01

############################################################################

### reading in data

# make sure the 'working directory' is set to the directory/folder where this
# script and the data (data_survey.dat) are stored

# read in the survey dataset (tab-delimited plain-text format)

dat <- read.table("data_survey.dat", header=TRUE, sep="\t", na.strings="")

# it is also possible to read in SPSS, Excel, etc. files directly (using the
# readxl and haven packages, but we will skip this for now)

############################################################################

### data inspection

# look at the dataset

View(dat)

# get some information about the dataset

dim(dat)
str(dat)
names(dat)
head(dat)
summary(dat)

# mean/SD for quantitative variables

mean(dat$age)
sd(dat$age)
mean(dat$smokenum)
mean(dat$smokenum, na.rm=TRUE)
sd(dat$smokenum, na.rm=TRUE)

# install (if necessary) the psych package
# install.packages("psych")

# load the psych package

library(psych)

# get summary statistics for the quantitative variables

describe(dat, omit=TRUE)

# frequency table for a categorical variable

table(dat$source)

############################################################################

### data preparation

# recode items as needed (see 'data_survey.pdf')

dat$lotr2 <- 6 - dat$lotr2
dat$lotr4 <- 6 - dat$lotr4
dat$lotr5 <- 6 - dat$lotr5

dat$mastery1  <- 5 - dat$mastery1
dat$mastery3  <- 5 - dat$mastery3
dat$mastery4  <- 5 - dat$mastery4
dat$mastery6  <- 5 - dat$mastery6
dat$mastery7  <- 5 - dat$mastery7

dat$pss4  <- 6 - dat$pss4
dat$pss5  <- 6 - dat$pss5
dat$pss7  <- 6 - dat$pss7
dat$pss8  <- 6 - dat$pss8

dat$rses3  <- 5 - dat$rses3
dat$rses5  <- 5 - dat$rses5
dat$rses8  <- 5 - dat$rses8
dat$rses9  <- 5 - dat$rses9
dat$rses10 <- 5 - dat$rses10

# compute scale total for the LOTR

dat$lotr <- dat$lotr1 + dat$lotr2 + dat$lotr3 + dat$lotr4 + dat$lotr5 + dat$lotr6

# compute scale totals for the other scales

dat$mastery <- rowSums(dat[grep("mastery[0-9]", names(dat))])
dat$pss     <- rowSums(dat[grep("pss[0-9]",     names(dat))])
dat$rses    <- rowSums(dat[grep("rses[0-9]",    names(dat))])

dat$posaff <- with(dat, panas1 + panas4 + panas6 + panas7 + panas9 +
                        panas12 + panas13 + panas15 + panas17 + panas18)
dat$negaff <- with(dat, panas2 + panas3 + panas5 + panas8 + panas10 +
                        panas11 + panas14 + panas16 + panas19 + panas20)

############################################################################

### saving data

# save the dataset (in tab-delimited plain-text format)

write.table(dat, file="data_survey_edit.dat", row.names=FALSE,
            quote=FALSE, sep="\t", na="")

# save the dataset (in R's own file format)

save(dat, file="data_survey_edit.rdata")

############################################################################

# restart the R session

# load the edited dataset

load("data_survey_edit.rdata")

############################################################################

### some basic plotting

# histogram of the PSS
# https://en.wikipedia.org/wiki/Histogram

hist(dat$pss)
hist(dat$pss, xlab="PSS", main="Histogram of PSS", breaks=seq(10,50,by=2.5))

# boxplot
# https://en.wikipedia.org/wiki/Box_plot

boxplot(dat$pss, ylab="PSS", main="Boxplot of PSS")

# kernel density estimate
# https://en.wikipedia.org/wiki/Kernel_density_estimation

plot(density(dat$pss, na.rm=TRUE))

# scatterplot
# https://en.wikipedia.org/wiki/Scatter_plot

plot(dat$pss, dat$posaff, xlab="Stress", ylab="Positive Affect",
     main="Scatterplot of Stress versus Positive Affect",
     pch=19, xlim=c(10,50), ylim=c(10,50), col="blue")

############################################################################

### some standard statistical methods

# t-test
# https://en.wikipedia.org/wiki/Student's_t-test
# https://en.wikipedia.org/wiki/Welch's_t-test

t.test(pss ~ sex, data=dat)
t.test(pss ~ sex, data=dat, var.equal=TRUE)

# one-way ANOVA
# https://en.wikipedia.org/wiki/One-way_analysis_of_variance

res <- aov(pss ~ marital, data=dat)
summary(res)

# correlation between two variables
# https://en.wikipedia.org/wiki/Pearson_correlation_coefficient

cor(dat$posaff, dat$negaff)

# correlation testing

cor.test(dat$posaff, dat$negaff)

# Spearman correlation
# https://en.wikipedia.org/wiki/Spearman's_rank_correlation_coefficient

cor(dat$posaff, dat$negaff, method="spearman")

# scatterplot of age (x-axis) versus stress (y-axis)

plot(pss ~ age, data=dat, pch=19, xlab="Age", ylab="PSS", col="darkgray")

# simple regression of stress (outcome) on age (predictor)
# https://en.wikipedia.org/wiki/Linear_regression

res <- lm(pss ~ age, data=dat)
summary(res)

# add the regression line to the scatterplot

abline(res, lwd=5)

# multiple regression

res <- lm(pss ~ age + rses, data=dat)
summary(res)

# two-way contingency table

table(dat$sex, dat$smoke)

# chi-square test of the association between two categorical variables
# https://en.wikipedia.org/wiki/Pearson's_chi-squared_test#Testing_for_statistical_independence

chisq.test(dat$sex, dat$smoke)

############################################################################

### psychometrics

# load the psych package

library(psych)

# Cronbach's alpha
# https://en.wikipedia.org/wiki/Cronbach's_alpha

alpha(dat[grep("pss[0-9]", names(dat))])

# scree plot
# https://en.wikipedia.org/wiki/Scree_plot

sub <- dat[grep("pss[0-9]", names(dat))]
scree(sub)

# principal component analysis (PCA)
# https://en.wikipedia.org/wiki/Principal_component_analysis

principal(sub, nfactors=2, rotate="oblimin")

# exploratory factor analysis (EFA) using principal axis factoring (PAF)
# https://en.wikipedia.org/wiki/Exploratory_factor_analysis

fa(sub, nfactors=2, rotate="oblimin", fm="pa")

# confirmatory factor analysis (CFA)
# https://en.wikipedia.org/wiki/Confirmatory_factor_analysis

# install (if necessary) the lavaan package
# install.packages("lavaan")

# load the lavaan package

library(lavaan)

# fit a one-factor CFA model to the items of the PSS scale

model1 <- 'PSS =~ pss1 + pss2 + pss3 + pss4 + pss5 + pss6 + pss7 + pss8 + pss9 + pss10'

res1 <- cfa(model1, data=dat, estimator="ML", std.lv=TRUE)
summary(res1, fit.measures=TRUE, standardized=TRUE)

# fit a two-factor CFA model to the items of the PSS scale

model2 <- '
PSSpos =~ pss1 + pss2 + pss3 + pss6 + pss9 + pss10
PSSneg =~ pss4 + pss5 + pss7 + pss8'

res2 <- cfa(model2, data=dat, estimator="ML", std.lv=TRUE)
summary(res2, fit.measures=TRUE, standardized=TRUE)

# likelihood ratio test (LRT) comparing the fit of the two models
# https://en.wikipedia.org/wiki/Likelihood-ratio_test

anova(res1, res2)

############################################################################
