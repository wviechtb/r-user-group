################################################################################

# A short script to explain R and RStudio installations and to give a short 
# introduction about the basic functionality of R.
# February 21st, 2024
# https://wviechtb.github.io/r-user-group/
#
# Author:  Ozan Cinar
# License: CC BY-NC-SA 4.0
#
# last updated: 2024-02-20

################################################################################

### Installing R and RStudio

# The files and instructions for installing the base R can be found here:
# https://cran.r-project.org/

# However, we would recommend installing RStudio, an interactive environment for
# using R in a nicer, user-friendly software. 
# Files and instructions for installing RStudio can be found here:
# https://posit.co/download/rstudio-desktop/

# Once both software are installed on your computer, you can start RStudio to 
# use R. 

################################################################################

### Basics of Interacting with R

# The most basic way to interact with R is to use the console.
# A '>' sign indicates R is ready and waits for input. 
1 - (1 - 0.95)^2
date()

# A better way to use R is to create/open an R script (a file with the extension
# of '.r' as this script) and keep your work in it. 

# Putting one or multiple '#' sign(s) makes R to consider everything that 
# follows the # sign in that line as comment for human users. Therefore, R will 
# not try to run and evaluate these parts of the code. Comments are very 
# important to explain your work in a human-readable format. 


### Objects and Values

# R can keep objects in the current environment that are assigned with a value
# so that the user can use them repeatedly. Assigning a value to an object is 
# made by using the '<-' syntax.
a <- 5  # Here the object is a and its value is 5.
a

# A value can be a number, a string, a set of numbers or strings, a data frame,
# outputs of a regression model, and many other more. 
b <- c(3, 5, 2, 1)  # An object with a set of numbers.
b
# See this material from a previous session for more about objects (and object
# classes):
# https://github.com/wviechtb/r-user-group/blob/master/materials/2023-03-15/rcode.r


### Functions

# Functions are R objects that can do specific tasks. For instance, we can use
# the sort function to sort the numbers in the object b in the increasing order.
b
sort(b)

# Almost every function has its own arguments. There arguments can be used to 
# modify the function to do more specific tasks or to tweak the function to your
# needs (as we will see soon with reading in data).
# Information about the function itself and its arguments can be seen from the 
# function's help page.
?sort
sort(b, decreasing=TRUE)  # Using the decreasing argument to sort the values in
                          # the decreasing order. 


### Reading in Data

# The read.table function can be used to read in data sets that are stored in 
# text files. 
?read.table

# Reading in the first toy data. Please note that, in the text file, the columns
# have names. We need to set the header argument to TRUE to read the data 
# correctly.
dat1 <- read.table("toydata1.txt", header=TRUE)
dat1

# It might also be a good practice to experiment to see what happens otherwise
# to understand how R and these functions work. 
# Let us use header=FALSE to see what happens. 
datx <- read.table("toydata1.txt", header=FALSE)
head(datx)  # First six line of the data set with the head function. 

rm(datx)  # Removing this (incorrect) data set from the R environment.
ls()      # Listing all the objects currently in the R environment.

# The second toy data set, toydata2.txt, does not have column names (so we will
# need to use header=FALSE). Also, the columns are separated from each other 
# with a ','. We can use the sep argument of the read.table function to tell R
# to separate columns when there is a comma rather than a tab. 
dat2 <- read.table("toydata2.txt", header=FALSE, sep=",")
head(dat2)

# Naming the columns.
colnames(dat2) <- c("sepal_length", "sepal_width")
head(dat2)

# Note that there are many more ways to read in data in different formats. See
# other functions in ?read.table. There are also other functions in other 
# packages to read in specific file extensions, such as the readxl package to
# read in .xls/.xlsx formats.

# Some basic work with data frames.
str(dat1)       # Data structure
dim(dat1)       # Dimensions of the data
head(dat1)      # First six rows in the data set
summary(dat1)   # Some descriptive statistics of the variables
names(dat1)     # Variable names

colMeans(dat1)  # Means of the values in each variable

# We can call the variables in a data frame using the '$' syntax.
dat1$Sepal.Length
dat1$Sepal.Width

# We can then use various functions on these variables.
mean(dat1$Sepal.Length) # Mean of the values in the Sepal.Length variable
sd(dat1$Sepal.Length)   # Standard deviation of the Sepal.Length values.

# Drawing a scatter plot of Sepal Length against Sepal Width.
plot(dat1$Sepal.Length, dat1$Sepal.Width)

# Improving the plot with modifying it with the arguments of the plot function.
plot(dat1$Sepal.Length, dat1$Sepal.Width, xlab="Sepal Length", ylab="Sepal Width",
     pch=19, cex=1.5)
# Check ?plot and $par help pages for more details about the arguments you can
# use with the plot function. 


### Fitting a Linear Regression Model

# The lm function is used for fitting linear regression models in R. Such 
# modelling functions in R usually follow a specific syntax called 'formula'. 
# For example, let's say we want to use the Sepal.Width as the outcome variable
# and the Sepal.Length as the predictor. We can then set our formula as 
# Sepal.Length ~ Sepal.Width 
# in the lm function.
res <- lm(Sepal.Width ~ Sepal.Length, data=dat1)
res           # Parameter estimates of the model
summary(res)  # More detail about the model

# You can also see a previous session on formulas here: 
# https://github.com/wviechtb/r-user-group/blob/master/materials/2023-03-29/rcode.r

# We can add the regression line over the scatter plot we previously created.
abline(res, col="red", lwd=3)

# One can fit other types of models with R, for instance, logistic regressions 
# with the glm function, mixed-effects and/or multi-level models with lme4 and 
# metafor packages. 


### Installing and Loading Packages

# R utilizes packages that are created by the R community. A package comes with
# necessary tools, such as functions and data sets, to conduct a specific type
# of analysis or a task. The lavaan package, for instance, is an R package to 
# conduct confirmatory factor analysis, structural equation modeling and growth 
# curve models.

# These R packages are usually stored in repositories. CRAN is the main 
# repository for R packages: 
# https://cran.r-project.org/web/packages/available_packages_by_name.html

# Installing R does not install all these packages, instead the user needs to
# install them manually. The install.packages function can be used to install 
# packages from CRAN. 
install.packages("lavaan") # Installing the lavaan package
# Note that a package needs to be installed only once. If the package is 
# installed --you can check the console; R should confirm the installation--, 
# you do not need to run the install.package function again.

# However, installing a package does not mean that it will be automatically 
# loaded in the R environment. They need to be loaded into the R environment 
# with the library function. This needs to be just once for each R session.
library(lavaan)
?lavaan
