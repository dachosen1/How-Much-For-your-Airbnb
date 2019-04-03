#------------------------------------------------------------------Set up 
# set working directory 
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")

#load libraries 
library(tidyverse); library(caret); library(leaps); library(corrplot);library(randomForest); 
library(gvlma); library(xgboost)

#load dataset 
data <- read.csv("cleandata.csv")
data <- select(.data = data, -zipcode,-neighbourhood_cleansed,-number_of_reviews,-id,-host_id)
data <- data[!is.na(data$zipcode_mod),]

data$neighbourhood_cleansed <- as.numeric(data$neighbourhood_cleansed)
data$zipcode_mod <- as.numeric(data$zipcode_mod)


#Training and test Set 
set.seed(100)
split <- createDataPartition(y = data$price, p = .85,list = F,groups = 100)
trainingset <- data[split,]
testset <- data[-split,]

#Xgboost model 
Regressor = xgboost(data = as.matrix(trainingset[-9]), label = trainingset$price, nrounds = 20)

#-------------------------------------------------------------------------Prediction 

#predicion for regressor
pred2 <- predict(Regressor, newdata = as.matrix(testset[-9]))
sqrt(mean((pred2 - testset$price)^2))

#------------------------------------------------------------------------Model Validation
#Kfolds cross validation
folds = createFolds(trainingset$price, k = 10)

cv = lapply(folds, function(x) {
 training_fold = trainingset[-x, ]
 test_fold = trainingset[x, ]
 regressor = lm(price ~ ., data = training_fold)
 y_pred = predict(regressor, newdata = test_fold[-4])
 accuracy = sqrt(mean((y_pred - test_fold$price)^2))
 return(accuracy)
})

accuracy = mean(as.numeric(cv));accuracy

#model2
folds = createFolds(trainingset$price, k = 10)

cv2 = lapply(folds, function(x) {
 training_fold = trainingset[-x, ]
 test_fold = trainingset[x, ]
 regressor = randomForest(price ~ ., data = trainingset,
                          ntree = 120)
 y_pred = predict(regressor, newdata = test_fold[-4])
 accuracy = sqrt(mean((y_pred - test_fold$price)^2))
 return(accuracy)
})

accuracy2 = mean(as.numeric(cv2));accuracy2


#------------------------------------------------------------------------Applying predicion to dataset  
## read in scoring data and apply model to generate predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")
scoringData = read.csv('cleandata(test).csv')

scoringData$neighbourhood_cleansed <- as.numeric(scoringData$neighbourhood_cleansed)
scoringData2 <- select(.data = scoringData,-zipcode,-neighbourhood_cleansed,-number_of_reviews,-id,-host_id)
pred3 <- predict(Regressor,newdata=as.matrix(scoringData2))

# construct submision from predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Submssion")
submissionFile = data.frame(id = scoringData$id, price = pred3)
write.csv(submissionFile, 'sample_submission13.csv',row.names = F)

