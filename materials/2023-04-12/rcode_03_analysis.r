############################################################################

# Main analysis script.

############################################################################

# install (if necessary) package(s) used below
#install.packages("pROC")
#install.packages("tree")

# load package(s)
library(pROC)
library(tree)

############################################################################

# load prepared data
load("data_heart_prep.rdata")

# number of rows
nrow(dat)

# remove subjects that have at least one missing value
dat <- na.omit(dat)

# number of rows after removing subjects with missing values
nrow(dat)

############################################################################

### logistic regression

# include all predictors at once
res1 <- glm(ahd ~ age + sex + chestpain + fbs + restecg + exang + slope + ca +
            thal + restbp + chol + maxhr + oldpeak, data=dat,
            family=binomial, na.action=na.exclude)
summary(res1)

# ROC curve and AUC
dat$pred1 <- predict(res1, type="response")
roc1 <- roc(ahd ~ pred1, data=dat)

plot(roc1)
auc(roc1)

# model with just age and sex as predictors
res0 <- glm(ahd ~ age + sex, data=dat, family=binomial, na.action=na.exclude)
summary(res0)

# add ROC curve for this model to the plot
dat$pred0 <- predict(res0, type="response")
roc0 <- roc(ahd ~ pred0, data=dat)

plot(roc0, add=TRUE, lty="dotted")

# add legend
legend("bottomright", inset=.02,
       legend=c(paste0("Full Model (AUC = ", round(auc(roc1), 2), ")"),
                paste0("Reduced Model (AUC = ", round(auc(roc0), 2), ")")),
       lty=c("solid", "dotted"))

# cross-classification table of the predicted and actual class based on res1
table(predicted = dat$pred1 > 0.5, actual = dat$ahd)

# note: one should split the data into

############################################################################

### classification tree

# include all predictors
res2 <- tree(ahd ~ age + sex + chestpain + fbs + restecg + exang + slope + ca +
             thal + restbp + chol + maxhr + oldpeak, data=dat)
res2

# plot the tree
plot(res2)
text(res2)

# get some summary information based on the tree
summary(res2)

# prune the tree (note: the appropriate degree of pruning should be determiend
# based on cross validation, but for simplicity, I simply set the degree to a
# relatively low number of terminal nodes)
ptree <- prune.misclass(res2, best=6)
ptree

# plot the pruned tree
plot(ptree)
text(ptree)

# predict the class based on this tree in the test data
dat$pred2 <- predict(ptree, newdata=dat, type="class")

# cross-classification table of the predicted and actual class
table(predicted = dat$pred2, actual = dat$ahd)

############################################################################
