# set working directory 
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")

#load libraries 
library(tidyverse)

#load dataset 
data <- read.csv("cleandata.csv")
expensive <- data[data$price > 250,]

#-------------------------------------------------------------------Visualization 

#bed type 
ggplot(data = data, aes (x = bed_type, y = price)) + geom_boxplot()

summary(
 lm(formula = price ~., data = data))

#-------------------------------------------------------------------Expensive Data 

#bed set 
ggplot(data = expensive, aes (x = bed_type, y = price)) + geom_boxplot()





