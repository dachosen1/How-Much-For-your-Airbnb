#------------------------------------------------------------------Set up 
#load Libraries 

library(tidyverse); 
library(caret);
library(randomForest);
library(gbm);
library(plyr);
library(caTools)

# set working directory plyr
setwd("C:\\Users\\anderson_nelson1\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")

#load dataset 
data <- read.csv("cleandata.csv")
data <- select(.data = data, -weekly_price,-monthly_price)
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

y_train <- trainingset$price
x_train <- select(.data = trainingset, - price)

#gradient Boosting 
control <- trainControl(method = "repeatedcv", number = 3, repeats = 3)
grid <- expand.grid(shrinkage = c(.081), 
                    interaction.depth = c(45),
                    n.minobsinnode = c(20),
                    n.trees = c(3000))
tic <- Sys.time()
#Rprof('profiling.out') # Start Profiling
gbm_model <- train(x = x_train, y = y_train, 
                   method = "gbm",
                   trControl=control,tuneGrid = grid,verbose = FALSE)
toc <- Sys.time()
toc - tic

#Rprof(NULL)         # Stop Profiling
#summaryRprof('profiling.out') 

gbm_model


#predicion for gradient Boosting
pred_gbm <- predict(gbm_model, newdata = testset)
sqrt(mean((pred_gbm - testset$price)^2))

#GBM 2

#------------------------------------------------------------------------Applying predicion to dataset  
## read in scoring data and apply model to generate predictions
setwd("C:\\Users\\anderson_nelson1\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")
scoringData = read.csv('cleandata(test).csv')

#load dataset 
scoringData <- select(.data = scoringData,  -weekly_price,-monthly_price)

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


#predicion for gradient Boosting
pred_gbm_score <- predict(gbm_model, newdata = scoringData)

# construct submision from predictions
setwd("C:\\Users\\anderson_nelson1\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Submssion")
submissionFile = data.frame(id = scoringData$id, price = pred_gbm_score)
write.csv(submissionFile, 'sample_submission20.csv',row.names = F)


