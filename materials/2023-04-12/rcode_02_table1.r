############################################################################

# Script to create 'Table 1'.

############################################################################

# install (if necessary) package(s) used below
#install.packages(tableone)
#install.packages(labelled)
#install.packages(table1)

# load package(s)
library(tableone)
library(labelled)
library(table1)

############################################################################

# load prepared data
load("data_heart_prep.rdata")

############################################################################

# attach variable labels to the variables in the dataset
var_label(dat) <- list(age       = "Age",
                       sex       = "Sex",
                       chestpain = "Chest pain type",
                       fbs       = "Fasting blood sugar > 120 mg/dl",
                       restecg   = "Resting electrocardiographic result",
                       exang     = "Exercise induced angina",
                       slope     = "Slope of the peak exercise ST segment",
                       ca        = "Number of major vessels colored by flourosopy",
                       thal      = "Thallium stress test result",
                       ahd       = "Angiographic heart disease",
                       restbp    = "Resting blood pressure (in mm Hg)",
                       chol      = "Serum cholestoral (in mg/dl)",
                       maxhr     = "Maximum heart rate achieved (in bpm)",
                       oldpeak   = "ST depression induced by exercise relative to rest")

# create Table 1 and print it
tab <- CreateTableOne(vars=c("sex", "age", "chestpain", "fbs", "restecg",
                             "exang", "slope", "ca", "thal", "restbp", "chol",
                             "maxhr", "oldpeak"),
                      strata="ahd", data=dat)
print(tab, varLabels=TRUE)

# save table as a csv file
out <- print(tab, varLabels=TRUE, quote=FALSE)
write.csv(out, "table1.csv")

# can now import this into Excel, edit if needed, and copy-paste into Word

# the 'table1' package also provides this kind of functionality
table1(~ sex + age + chestpain + fbs + restecg + exang + slope + ca + thal +
       restbp + chol + maxhr + oldpeak | ahd, data=dat)

# this creates an HTML table, which one can copy-paste into Word

############################################################################
