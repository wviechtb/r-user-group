############################################################################

# Scripts for the meeting of the 'R User Group at Maastricht University'
# (RUG@UM) on April 12th, 2023 (https://wviechtb.github.io/r-user-group/)
#
# Author:  Wolfgang Viechtbauer (https://www.wvbauer.com)
# License: CC BY-NC-SA 4.0
#
# last updated: 2023-04-11

############################################################################

# dataset from: https://www.statlearning.com/resources-second-edition
# (with some minor adjustments to make it easier to work with)
#
# The dataset includes 303 patients and the following variables:
#
# id          - subject id
# age         - age (in years)
# sex         - sex (0 = female, 1 = male)
# chestpain   - chest pain type (typical, nontypical, nonanginal, asymptomatic)
# restbp      - resting blood pressure (in mm Hg on admission to the hospital)
# chol        - serum cholestoral (in mg/dl)
# fbs         - fasting blood sugar > 120 mg/dl (0 = false, 1 = true)
# restecg     - resting electrocardiographic result (0 = normal, 1 = some abnormality)
# maxhr       - maximum heart rate achieved (in bpm)
# exang       - exercise induced angina (0 = no, 1 = yes)
# oldpeak     - ST depression induced by exercise relative to rest
# slope       - slope of the peak exercise ST segment (1 = upsloping, 2 = flat, 3 = downsloping)
# ca          - number of major vessels colored by flourosopy (0-3)
# thal        - Thallium stress test result (normal, fixed, or reversable)
# ahd         - have angiographic heart disease or not (no, yes)
#
# The purpose of the dataset was to study whether the presence/absence of
# angiographic heart disease (variable 'ahd') can be predicted based on the
# other variables (and if so, how well).

############################################################################

### setup / prep / load data

# set the working directory to the location where this script and the dataset
# (data_heart.dat) are located

# read in data
dat <- read.table("data_heart.dat", header=TRUE, sep="\t", as.is=TRUE)

############################################################################

### data inspection

# show first 6 rows of the dataset
head(dat)

# number of rows
nrow(dat)

# structure of dataset
str(dat)

# summary of dataset
summary(dat)

# frequency tables of the categorical variables
table(dat$sex,       useNA="ifany")
table(dat$chestpain, useNA="ifany")
table(dat$fbs,       useNA="ifany")
table(dat$restecg,   useNA="ifany")
table(dat$exang,     useNA="ifany")
table(dat$slope,     useNA="ifany")
table(dat$ca,        useNA="ifany")
table(dat$thal,      useNA="ifany")
table(dat$ahd,       useNA="ifany")

# turn categorical variables that are coded numerically into factors and also
# set the desired level order for all categorical variables (the first level
# is the 'reference level')
dat$sex       <- factor(dat$sex,       levels=c(0,1), labels=c("female","male"))
dat$chestpain <- factor(dat$chestpain, levels=c("asymptomatic","typical","nonanginal","nontypical"))
dat$fbs       <- factor(dat$fbs,       levels=c(0,1), labels=c("no","yes"))
dat$restecg   <- factor(dat$restecg,   levels=c(0,1), labels=c("normal","some abnormality"))
dat$exang     <- factor(dat$exang,     levels=c(0,1), labels=c("no","yes"))
dat$slope     <- factor(dat$slope,     levels=1:3, labels=c("upsloping","flat","downsloping"))
dat$ca        <- factor(dat$ca,        levels=0:3, labels=c("0","1+","1+","1+")) # collapse 1-3 into 1+
dat$thal      <- factor(dat$thal,      levels=c("normal","fixed","reversable"))
dat$ahd       <- factor(dat$ahd,       levels=c("no","yes"))

# mean, sd, and range of the quantitative variables
round(c(mean=mean(dat$age),     sd=sd(dat$age),     range=range(dat$age)),     2)
round(c(mean=mean(dat$restbp),  sd=sd(dat$restbp),  range=range(dat$restbp)),  2)
round(c(mean=mean(dat$chol),    sd=sd(dat$chol),    range=range(dat$chol)),    2)
round(c(mean=mean(dat$maxhr),   sd=sd(dat$maxhr),   range=range(dat$maxhr)),   2)
round(c(mean=mean(dat$oldpeak), sd=sd(dat$oldpeak), range=range(dat$oldpeak)), 2)

# histograms with kernel density estimates for the quantitative variables

vars <- c("age", "restbp", "chol", "maxhr", "oldpeak")

par(mfrow=c(3,2))

for (i in 1:5) {
   hist(dat[,vars[i]], freq=FALSE, xlab="", main=vars[i])
   lines(density(dat[,vars[i]]), lwd=3)
}

############################################################################

# save prepared data to rdata file
save(dat, file="data_heart_prep.rdata")

############################################################################
