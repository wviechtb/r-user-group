############################################################################

# An illustration of how to carry out parallel processing using the 'future'
# package for the meeting of the 'R User Group at Maastricht University'
# (RUG@UM) on January 24th, 2024 (https://wviechtb.github.io/r-user-group/)
#
# Author:  Wolfgang Viechtbauer (https://www.wvbauer.com)
# License: CC BY-NC-SA 4.0
#
# last updated: 2024-01-25

############################################################################

# copy the mtcars dataset to dat and inspect the dataset
dat <- mtcars
dat

# suppose we want to regress mpg (miles per gallon) on each of the other
# variables in the dataset in turn and extract the corresponding p-values

myfun <- function(pred, out, data) {

   # fit the simple regression model and extract the p-value
   res <- lm(data[[out]] ~ data[[pred]])
   pval <- coef(summary(res))[2,4]

   # pretend that the code above takes more time by sleeping for 1 second
   Sys.sleep(1)

   # return the p-value (and the predictor name and id of the process)
   out <- data.frame(pred=names(data)[pred], pval=pval, pid=Sys.getpid())
   return(out)

}

# this takes around 10 seconds to run (sequentially)
print(system.time(res <- lapply(2:11, myfun, out=1, data=dat)))
do.call(rbind, res)

# get the process id of the current R session
Sys.getpid()

# we see that the regression models were run in the current R session

############################################################################

### quick review of how to carry out parallel processing using the parallel package

# load the parallel package
library(parallel)

# set up a local cluster with 2 nodes
cl <- makePSOCKcluster(2)

# get the process ids of the 2 nodes (note that these are different from the
# process id of the current R session)
clusterEvalQ(cl, Sys.getpid())

# this takes around 5 seconds to run (in parallel)
print(system.time(res <- parLapply(cl, 2:11, myfun, out=1, data=dat)))
do.call(rbind, res)

# we see that the regression models were run in the 2 node processes, not the
# current R session (and half of the models were run on one node while the
# other half were run on the other node)

# close the cluster
stopCluster(cl)

############################################################################

### carry out parallel processing using the future package

# install the future and future.apply packages (do once)
#install.packages("future")
#install.packages("future.apply")

# load the future and future.apply packages
library(future)
library(future.apply)

# https://cran.r-project.org/package=future
# https://cran.r-project.org/package=future.apply

# the default 'plan' is to run things sequentially

# this takes around 10 seconds to run (sequentially)
print(system.time(res <- future_lapply(2:11, myfun, out=1, data=dat)))
do.call(rbind, res)

# set up a multisession plan with 2 workers
plan(multisession, workers=2)

# get the process ids of the 2 workers
future_sapply(1:2, function(x) Sys.getpid())

# this takes around 5 seconds to run (in parallel)
print(system.time(res <- future_lapply(2:11, myfun, out=1, data=dat)))
do.call(rbind, res)

# return to a sequential plan
plan(sequential)

############################################################################
