############################################################################

# A small script to introduce some of the basics of R for parallel processing
# for the meeting of the 'R User Group at Maastricht University' (RUG@UM) on
# June 28th, 2023 (https://wviechtb.github.io/r-user-group/)
#
# Author:  Wolfgang Viechtbauer (https://www.wvbauer.com)
# License: CC BY-NC-SA 4.0
#
# last updated: 2023-06-28

############################################################################

### functionals

# a 'functional' is a function that takes, possibly among other inputs, a
# function as input and uses this function internally

# see also: https://adv-r.hadley.nz/functionals.html

# a simple example
randomise <- function(fun, n=100) fun(runif(n))
randomise(mean)
randomise(mean)
randomise(sd)
randomise(sd)
randomise(mean, n=10000)
randomise(mean, n=10000)

# functions like apply() and the *apply() family of functions are functionals

# create a 100000x1000 matrix with random values from a standard normal distribution
X <- matrix(rnorm(100000*1000), nrow=100000, ncol=1000)

# take the mean of the values in each column (1 = rows, 2 = columns)
apply(X, 2, mean)

# for this special case, we have the faster colMeans() function
colMeans(X)

# compare running times
system.time(apply(X, 2, mean))
system.time(colMeans(X))

# take the sd of the values in each column (there is no colSDs() function!)
apply(X, 2, sd)

# turn X into a data frame
dat <- data.frame(X)
dat[1:20, 1:5]

# remember: data frames are stored internally as lists, where each list
# element corresponds to a variable

# take the mean of each variable in dat
sapply(dat, mean)

# this is faster than apply(X, 2, mean) but not quite as fast as colMeans()
system.time(apply(X, 2, mean))
system.time(sapply(dat, mean))
system.time(colMeans(X))

# note: sapply() returns a vector (since mean() produces a single value);
# lapply() returns a list, where each list element contains whatever the
# specified function returns
lapply(dat, mean)

# we use lapply() when the object returned by the function is more complex

# conduct a one-sample t-test on each variable
res <- lapply(dat, t.test)
res[1:2]

# examine the structure of the object returned by t.test()
str(res[[1]])

# pull out the p-value from each t-test
pvals <- sapply(res, function(x) x$p.value)
pvals

# histogram of the p-values
hist(pvals, xlab="p-value", main="", breaks=seq(0,1,by=.05))

############################################################################

### parallel processing/computing

# R is 'single threaded', that is, computations like the ones conducted above
# are carried out sequentially; the more columns/variables, the longer it will
# take to carry out the computations

p <- c(50, 100, 200, 400, 600, 800, 1000)
time <- rep(NA, length(p))

for (i in 1:length(p)) {
   print(p[i])
   X <- matrix(rnorm(100000*p[i]), nrow=100000, ncol=p[i])
   dat <- data.frame(X)
   Sys.sleep(2)
   time[i] <- system.time(res <- lapply(dat, t.test))[3]
}

plot(p, time, pch=21, bg="gray", type="o", lwd=2, cex=1.2,
     xlab="Number of Variables", ylab="Computation Time")

# sidenote: using Sys.sleep() above so that the CPU has a bit of time to cool
# off between values of p (your computer may run the CPU at a lower 'clock
# speed' temporarily to avoid the CPU from becoming too hot)

### what is parallel processing/computing?

# "a type of computation in which many calculations or processes are carried
# out simultaneously" (https://en.wikipedia.org/wiki/Parallel_computing)

### various types of parallel processing we can make use of when working with R

# explicit: we tell R explicitly how to split up a task into subtasks and then
# run them in parallel (e.g., making use of multiple 'cores' on your computer)

# implicit: some of the computations are automatically carried out in parallel

# if implicit parallel processing is happening, it is still important to know
# about this, so you do not add another layer of explicit parallel processing
# on top of it, since this may actually be counterproductive

############################################################################

### explicit parallel processing

# load the parallel package (comes with R)
library(parallel)

# determine the number of cores
detectCores(logical=FALSE)

# notes:
# - we want the number of 'true' cores (not logical/hyperthreaded) cores
# - even when setting logical=FALSE, this may not reliably detect the number
#   of true cores
# - if you know the type of CPU in your computer, look up the specs directly
# - using logical/hyperthreaded cores often yields little benefits, so it is
#   better to stick to parallelization over the true cores
# - might be good to leave one or two cores (if you can spare them) for
#   running other stuff in the background

# create a local 'cluster' with 2 cores on my computer
cl <- makePSOCKcluster(2)

# simulate data one more time for 100 variables
X <- matrix(rnorm(100000*100), nrow=100000, ncol=100)
dat <- data.frame(X)

# run the 100 t-tests sequentially
system.time(res <- lapply(dat, t.test))[3]

# run the 100 t-tests in parallel spread over 2 cores (so each core should
# run approximately 500 tests)
system.time(res <- parLapply(cl, dat, t.test))[3]

# why is this not faster? because there is a bit of overhead in sending the
# data to each process and getting back and collecting the results in 'res';
# parallel processing will be beneficial when the time to run each computation
# is sufficiently long so that the additional overhead is less relevant

# install the mclust package
# install.packages("mclust")

# load the mclust package
library(mclust)

# function to estimate a normal mixture model with 1, 2, or 3 components and
# then return the BIC values of the three models
clustfun <- function(x) {
   res <- Mclust(x, modelNames="E", G=1:3, verbose=FALSE)
   return(res$BIC)
}

# run the 100 analyses sequentially
system.time(res <- lapply(dat, clustfun))[3]

# run a command on each process in the 'cl' cluster (to load mclust)
clusterEvalQ(cl, library(mclust))

# run the 100 analyses in parallel (takes about half of the time)
system.time(res <- parLapply(cl, dat, clustfun))[3]

# stop/close the local cluster
stopCluster(cl)

# examine the results for the first two variables
res[1:2]

# plot the density of the BIC values based on the 1, 2, and 3 component mixtures
plot(density(sapply(res, function(x) x[1])), lwd=3, main="", bty="l")
lines(density(sapply(res, function(x) x[2])), lwd=3, col="dodgerblue")
lines(density(sapply(res, function(x) x[3])), lwd=3, col="firebrick")
legend("topright", inset=.02, lwd=3, col=c("black","dodgerblue","firebrick"),
       legend=c("Components: 1", "Components: 2", "Components: 3"))

############################################################################

### load balancing

# roughly, parLapply() will allocate 500 of the analyses to the first process
# and the other 500 to the second process; but some analyses may take more
# time to finish than others; in this case, it can happen that the analyses
# run on the first process are already finished, while the other analyses are
# still running; during the time, the first process is doing nothing (since it
# is already finished), which is not efficient

# say task 1 takes 10 seconds, tasks 2:4 take 2 seconds

myfun <- function(id) {

   if (id == 1)
      Sys.sleep(10)
   if (id != 1)
      Sys.sleep(2)

   return(list(id = id, id = Sys.getpid()))

}

cl <- makePSOCKcluster(2)

# without load balancing, two tasks are sent to process 1 and the other two to
# process 2, so in total it will take about 12 seconds to finish everything
system.time(res <- parLapply(cl, 1:4, myfun))
res

# with load balancing, tasks are sent to the processes when they are ready to
# receive the next one; in this case, task 1 will be sent to one process and
# while tasks 2-4 are sent to the other process, so in total it will take
# about 10 seconds to finish everything
system.time(res <- parLapplyLB(cl, 1:4, myfun))
res

# load balancing can actually slow things down due to the additional overhead
clusterEvalQ(cl, library(mclust))
system.time(res <- parLapply(cl, dat, clustfun))[3]
system.time(res <- parLapplyLB(cl, dat, clustfun))[3]

############################################################################

### implicit parallelization

# some R packages / functions may automatically use multiple cores for running
# certain analyses; internally, they may use things like makePSOCKcluster()
# and parLapply() for this; this should always be an option (not the default)
# and should be clearly documented

# install the metafor package
# install.packages("metafor")

# load the metafor package
library(metafor)

# fit a multilevel meta-analysis model to the dat.mccurdy2020 data
res <- rma.mv(yi, vi, mods = ~ condition,
              random = list(~ 1 | article/experiment/sample/id, ~ 1 | pairing),
              data=dat.mccurdy2020, sparse=TRUE, time=TRUE)

# construct a likelihood profile for the first variance component
profile(res, sigma2=1, steps=10, time=TRUE)

# the same but now make use of parallel processing with 2 cores
profile(res, sigma2=1, steps=10, time=TRUE, ncpus=2)

# this really isn't all that different from explicit parallelization, except
# that the function makes it a bit easier to make use of that

# another type of implicit parallelization may happen for certain computations
# when using different linear algebra routines (BLAS/LAPACK) than the ones
# that come with R by default

# check what BLAS/LAPACK routines are in use
sessionInfo()

# the default ones are single threaded; but one can switch to different ones
# that make use of parallel processing automatically; this can affect the
# speed with which R carries out certain computations (e.g., taking the
# inverse of a matrix)

p <- 2000
set.seed(1234)
X <- matrix(runif(p*p), ncol=p, nrow=p)
X <- (X + t(X))/2
system.time(inv <- solve(X))

# installing other routines (and telling R to make use of them) is not
# entirely straightforward (and how to do this depends on your operating
# system); some details can be found in the 'R Installation and
# Administration' manual:
#
# https://cran.r-project.org/doc/manuals/r-release/R-admin.html#Linear-algebra

# a popular alternative to the default routines is OpenBLAS
# https://en.wikipedia.org/wiki/OpenBLAS

# even without parallelization, the routines can be considerably faster than
# the default ones; and OpenBLAS can implicitly parallelize computations

############################################################################

# other packages for parallel processing
#
# see the CRAN Task View for 'High-Performance and Parallel Computing with R'
#
# https://cran.r-project.org/web/views/HighPerformanceComputing.html

############################################################################
