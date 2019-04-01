#------------------------------------------------------------------Set up 
#load Libraries 

library(tidyverse); 
library(caret);
library(randomForest);
library(gbm);
library(plyr);
library(caTools)

# set working directory plyr
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")

#load dataset 
data <- read.csv("cleandata.csv")
#data <- select(.data = data, - id, -host_id)

#convert categorical to numerical 
data$room_type <- as.numeric(data$room_type)
data$property_type <- as.numeric(data$property_type)
data$host_since <- as.numeric(data$host_since)
data$host_response_time <- as.numeric(data$host_response_time)
data$bed_type <- as.numeric(data$bed_type)
data$neighbourhood_cleansed <- as.numeric(data$neighbourhood_cleansed)
data$neighbourhood_group_cleansed <- as.numeric(data$neighbourhood_group_cleansed)
data$host_is_superhost <- as.numeric(data$host_is_superhost)
data$neighbourhood_group_cleansed <- as.numeric(data$neighbourhood_group_cleansed)
data$is_business_travel_ready <- as.numeric(data$is_business_travel_ready)
data$host_is_superhost <- as.numeric(data$host_is_superhost)
data$require_guest_phone_verification <- as.numeric(data$require_guest_phone_verification)
data$calendar_updated <- as.numeric(data$calendar_updated)
data$require_guest_profile_picture <- as.numeric(data$require_guest_profile_picture)
data$cancellation_policy <- as.numeric(data$cancellation_policy)
data$instant_bookable <- as.numeric(data$instant_bookable)
data$last_review <- as.numeric(data$last_review)
data$first_review <- as.numeric(data$first_review)

#Training and test Set 
set.seed(100)
split <- sample.split(Y = data$price,SplitRatio = .80)
trainingset <- data[split,]
testset <- data[!split,]

#random forest 
myGrid <- expand.grid(mtry = c(2,4,6,8,10,12,14),splitrule = "variance",
                     min.node.size =c( 5,50,100,200))

#random forest 
myGrid2 <- expand.grid(mtry = c(2,4,6,8,10,12,14))

myControl <- trainControl(method = "repeatedcv", number = 10,search = "grid",repeats = 3)

# Fit a model with a custom tuning grid
set.seed(42)
random_forest <- train(price ~ ., data = trainingset, method = "rf",
                 tuneGrid = myGrid2,trControl = myControl)

write.csv(trainingset, "trainingset.csv")

#gradiant boosting
#Creating grid
# Set up the resampling, here repeated CV
#Gradient Boosing
set.seed(100)
boost = gbm(price~.,data=trainingset,distribution="gaussian",
            n.trees = 20000,interaction.depth = 3,shrinkage = 0.001)
predBoostTrain = predict(boost,newdata = testset,n.trees = 20000)
rmseBoostTrain = sqrt(mean((predBoostTrain-testset$price)^2)); rmseBoostTrain

summary(boost)


#Xtreme gradient boosting 
xgboost <- xgboost(data = as.matrix(trainingset[-10]), label = trainingset$price, nrounds = 25)

#predicion for regressor
pred4 <- predict(xgboost, newdata = as.matrix(testset[-10]))
sqrt(mean((pred4 - testset$price)^2))


#------------------------------------------------------------------------Applying predicion to dataset  
## read in scoring data and apply model to generate predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")
scoringData = read.csv('cleandata(test).csv')

#load dataset 
scoringData <- select(.data = scoringData, - id, -host_id)

#convert categorical to numerical 
scoringData$room_type <- as.numeric(scoringData$room_type)
scoringData$property_type <- as.numeric(scoringData$property_type)
scoringData$host_since <- as.numeric(scoringData$host_since)
scoringData$host_response_time <- as.numeric(scoringData$host_response_time)
scoringData$bed_type <- as.numeric(scoringData$bed_type)
scoringData$neighbourhood_cleansed <- as.numeric(scoringData$neighbourhood_cleansed)
scoringData$neighbourhood_group_cleansed <- as.numeric(scoringData$neighbourhood_group_cleansed)
scoringData$host_is_superhost <- as.numeric(scoringData$host_is_superhost)
scoringData$neighbourhood_group_cleansed <- as.numeric(scoringData$neighbourhood_group_cleansed)
scoringData$is_business_travel_ready <- as.numeric(scoringData$is_business_travel_ready)
scoringData$host_is_superhost <- as.numeric(scoringData$host_is_superhost)
scoringData$require_guest_phone_verification <- as.numeric(scoringData$require_guest_phone_verification)
scoringData$calendar_updated <- as.numeric(scoringData$calendar_updated)
scoringData$require_guest_profile_picture <- as.numeric(scoringData$require_guest_profile_picture)
scoringData$cancellation_policy <- as.numeric(scoringData$cancellation_policy)
scoringData$instant_bookable <- as.numeric(scoringData$instant_bookable)
scoringData$last_review <- as.numeric(scoringData$last_review)
scoringData$first_review <- as.numeric(scoringData$first_review)

predBoostTrain_train = predict(boost,newdata = scoringData,n.trees = 20000)

# construct submision from predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Submssion")
submissionFile = data.frame(id = scoringData$id, price = predBoostTrain_train)
write.csv(submissionFile, 'sample_submission16.csv',row.names = F)


