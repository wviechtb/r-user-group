
################################################################################

# R script for the second meeting of the 'R User Group at Maastricht University' 
# (RUG@UM) on March 15th, 2023
# (https://wviechtb.github.io/r-user-group/)

# Topics include:
#   - Getting Help (in R)
#   - Object Classes
#   - R Packages

################################################################################


### Getting Help (in R)

# The main way to get help about an R function is to use the console.
help(plot)  # Searching the documentation of a specific function.
?plot	      # Same as the previous code.

# The help-page documentations usually provide details and could be difficult to
# follow or understand. The example section at the end might be beneficial to 
# see the practical use of the function and help people to understand it.

# One good practice is to separate the examples into pieces or play with them to
# understand how a function and its arguments* work.
#   * Arguments are specific options that accomplish different jobs of a function.
#   E.g., 'x', 'y', 'type', etc., are arguments of the plot function.
plot(cars$speed, cars$dist, panel.first=grid(8, 8), pch=19, cex=1.2, col="blue")
# Removing the 'panel.first' argument to see what it does in the function.
plot(cars$speed, cars$dist, pch=19, cex=1.2, col="blue")

# A more detailed search can be made by using ?? syntax.
??plot
# Note that it does not look only for the functions whose names include the 
# keyword you are searching.

# ?? can also look for functions that are available in packages* that are not 
# loaded into your R environment. 
#   * A package is a set of R functions that work together to accomplish a 
#   specific work. E.g., The lme4 package is a set of R commands that can fit 
#   mixed-effects models and accomplish work related to mixed-effects models.
?xyplot
??xyplot

# lattice::xyplot means that there is a function named xyplot under the package
# lattice. So, we need to load lattice package to use xyplot(), first. We will 
# come back to packages later. 

# However, there are (more common cases) where a need about a warning* or error*.
# thrown by R when a command is run.
#   * A warning is a message from R when there is something unexpected or incorrect
#   happens when a command is run. The command has completed but it possibly did
#   not run as intended.
a <- 5.4L   # L forces to make the value integer but it has a decimal.
a           # However, the code still run.
#   * En error is thrown when there is something wrong with the code and it did
#   not complete.
a <- 1 + "a"
a

# R tries to be clear and explanatory in the error and warning messages to make 
# us able to trace back what was incorrect in the command. But, they could still
# be difficult to understand. In such cases, one way to get help is to ask others
# in-person or looking for online help by "googling" the error or warning message.
# Stack Overflow is particularly very helpful in such situations. It is helpful
# and important to be:
# - Being clear about what the code expected to do;
# - Being able to reproduce the error (save the script).


### Object Classes

# R usually has a common way to work where it assigns values to objects and the
# objects are stored and used in commands. Depending on their values, objects 
# have different classes that allows appropriate work to be done with them.
# Some basic classes are "numeric", "integer", "character" and "logical" and the
# class of an object can be seen with the class function.
a <- 5.4  # Here, a is the object and 5.4 is its value.
class(a)  # The class of the object a is numeric.
class(5)  # To be safe, R tries to store numbers as numerics even if they do not
          # have decimals. 
class(5L) # The syntax L can be used to force a numeric to be integer. 

# Characters are objects that can store semantic values. 
b <- "example"  
b
class(b)
# Note the quotation marks around the (string) value. Alternatively, one can 
# also use single quotation marks.
b <- 'example'
b
class(b)
# However, be careful about being consistent in the syntax you use.
# b <- "example'  # This will not complete because R expects you to use the same
                  # snytax to begin and end a string value.
# One can also assign a longer string (with empty spaces) value to an object.
b <- "a longer string value"
b

# As aforementioned, the class of an object is important in the appropriateness
# of the work that you want to do.
a * 2   # A numeric/integer object can be used in arithmetic operations.
b * 2   # But a character cannot be used in arithmetic operations.

# Logical is a specific object class with two possible values, TRUE or FALSE.
c <- TRUE
c
class(c)
# Logical objects are usually created after comparisons. 
a > 5
class(a > 5)
# Logical objects can be used for subsetting* or in conditional and control flow
# works. 
#   * Subsetting refers to get a part or pieces of an object that contains 
#   multiple values.
set <- c(1, 3, 6, 2, 8, 7)  # The c function concatenates values in a single one.
set
# Some simple subsetting examples.
set[1:3]        # Subsetting the first three values.
set[c(1, 5, 2)] # Subsetting the first, fifth and second values. 

# Creating an indexing value based on a comparison.
ind <- set > 4
ind   # A logical object based on the comparison above.
set[ind]

class(set)  # The class of a 1D array is found by the objects in it.

# These 1D array objects cannot include objects of different classes.
set <- c(1, 3, 5, "a")  # It seems to work, ...
set                     # but R converted all the values in it to characters.
class(set)

# Array objects with two dimensions, i.e., a matrix.
mat <- matrix(1:6, nrow=2, ncol=3)
mat
class(mat)

# Neither a matrix contain objects of different classes.
mat <- matrix(c(1, 2, 3, "a", "b", "c"), nrow=2, ncol=3, byrow=TRUE)
mat

# Lists are specific class of objects that can include objects from different
# classes with different lengths.
list_obj <- list(1:5, c("a", "b", "c"), c(TRUE, FALSE))
list_obj

# Subsetting in lists.
list_obj[1]
list_obj[[1]]

class(list_obj[1])    # The whole first 'branch' of the list.
class(list_obj[[1]])  # The content of the first 'branch' in the list.
list_obj[1][1]
list_obj[[1]][1]

# The branches of a list can be named.
list_obj <- list(num = 1:5, char=c("a", "b", "c"), log=c(TRUE, FALSE))
list_obj

# The branch names can be used for subsetting using the $ syntax.
list_obj$num

# A data.frame object is a special matrix that can include objects of different
# classes. There are various data.frames (i.e., data sets) available in the base
# R and ready to use.
data()
?iris   # These data sets are documented and have an help page.

dat <- iris   # Assigning the data set to an object.
head(dat)     # First six rows of the data set.
str(dat)      # The structure of the data set.
# Factors are special character objects that can be categorized. 

summary(dat)  # A summary of the variables in the data set that may differ in 
              # presentation based on the class of the variable. 

# Subsetting in matrices and data.frames is done by indexing both the rows and 
# columns.
dat[1:3, 1:2]   # First three rows of the first two columns.
dat[1:3, c(1, 2, 5)]
dat[1:5, ]      # Leaving the dimension empty means subsetting all values (here
                # it means all columns).
dat[dat$Species=="virginica", ]

# Inspecting the association between the Petal and Sepal lengths
plot(Sepal.Length ~ Petal.Length, data=dat, pch=19, xlab="Petal Length",
     ylab="Sepal Length")
# Adding colors based on the species.
plot(Sepal.Length ~ Petal.Length, data=dat, pch=19, cex=1.2, xlab="Petal Length",
     ylab="Sepal Length", col=Species)
# Note that although the Species variable is a factor variable, R tries to 
# convert it to numerical because the col argument expects a numeric object.
as.numeric(dat$Species)

# Adding a legend to the figure. Note that the arguments that are used in the 
# plot (or, points) function can be used here for stylize the legend.
legend("topleft", legend = levels(dat$Species), col=1:3, cex=1.2, pch=19, inset=0.01)

# Fitting a linear regression model to inspect the association.
res <- lm(Sepal.Length ~ Petal.Length, data=dat)
res

# Adding the regression line to the figure.
abline(res, lwd=2)

# Redrawing the points in the figure so that they will be over the regression line.
points(Sepal.Length ~ Petal.Length, data=dat, pch=19, cex=1.2, col=Species)

# Getting more details about the regression results.
summary(res)

# Note that the summary function here behaves differently than before.
summary(dat)
summary(res)

# summary is a generic R function and it behaves differently based on the class
# of the objects it is used upon. 
class(dat)  # A data.frame object.
class(res)  # An lm object.

# These different behaviors are referred as methods.
methods(summary)  # Note the summary.data.frame and summary.lm functions.

summary.data.frame
summary.lm

# One can create their own object class and methods for the available generic
# functions.


### R Packages

# R comes with several packages (which may not be loaded into the environment*)
#   * Environment refers to the place where the current collection of objects 
#   --and functions which are also functions themselves-- in R.
ls()      # List of objects available in the current environment.
search()  # Packages that are loaded into the environment.

# Listing all the packages available in the library, i.e., on the computer.  
library()

# Loading a library into the environment to be able to use their functionality.
library(ggplot2)
search()

# Searching among the installed packages for a keyword. 
help.search("mixed-effects")
library(lme4)

# The sos package provides a way to search packages for a keyword including the 
# packages that are not installed already. 
library(sos)
findFn("hierarchical clustering")

# CRAN is the main repository for R packages and all the packages available can
# be seen here: https://cran.r-project.org/web/packages/available_packages_by_name.html
# The packages on CRAN can be installed with the install.packages function.
install.packages("cluster")
library(cluster)

# Bioconductor is another repository where mainly R packages for biological
# research are available.
# https://www.bioconductor.org/

# In addition, R packages can be stored on GitHub; however, be aware that the 
# packages stored on GitHub may not have gone through the inspection steps made 
# by the main repositories. 

