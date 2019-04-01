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
data <- select(.data = data, -weekly_price,-monthly_price,-zipcode_Rank,-id,-host_id,-bed_type,-is_business_travel_ready,
               -host_is_superhost,-review_scores_communication,-review_scores_accuracy,-review_scores_location,
               -calculated_host_listings_count,-require_guest_phone_verification,-require_guest_profile_picture,
               -cancellation_policy,-instant_bookable,-first_review)

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


#-------------------------------------------------------------------XGboost algorithm  
library(xgboost)
nrounds <- 1000
# big with lower starting points that they'll mess the scales
tune_grid <- expand.grid(
  nrounds = seq(from = 200, to = nrounds, by = 50),
  eta = c(0.025, 0.05, 0.1, 0.3),
  max_depth = c(2, 3, 4, 5, 6),
  gamma = 0,
  colsample_bytree = 1,
  min_child_weight = 1,
  subsample = 1)

tic <- Sys.time()
tune_control <- caret::trainControl(
  method = "cv", # cross-validation
  number = 3, # with n folds 
  #index = createFolds(tr_treated$Id_clean), # fix the folds
  verboseIter = FALSE, # no training log
  allowParallel = TRUE # FALSE for reproducible results 
)

xgb_tune <- caret::train(
  x = x_train,
  y = y_train,
  trControl = tune_control,
  tuneGrid = tune_grid,
  method = "xgbTree",
  verbose = TRUE
)

toc <- Sys.time()
toc - tic

# helper function for the plots
tuneplot <- function(x, probs = .90) {
  ggplot(x) +
    coord_cartesian(ylim = c(quantile(x$results$RMSE, probs = probs), min(x$results$RMSE))) +
    theme_bw()
}

#tuning grid 2 
tune_grid2 <- expand.grid(
  nrounds = seq(from = 50, to = nrounds, by = 50),
  eta = xgb_tune$bestTune$eta,
  max_depth = ifelse(xgb_tune$bestTune$max_depth == 2,
                     c(xgb_tune$bestTune$max_depth:4),
                     xgb_tune$bestTune$max_depth - 1:xgb_tune$bestTune$max_depth + 1),
  gamma = 0,
  colsample_bytree = 1,
  min_child_weight = c(1, 2, 3),
  subsample = 1
)
tic2 <- Sys.time()

xgb_tune2 <- caret::train(
  x = x_train,
  y = y_train,
  trControl = tune_control,
  tuneGrid = tune_grid2,
  method = "xgbTree",
  verbose = TRUE
)
toc2 <- Sys.time()
toc2 - tic2

tuneplot(xgb_tune2)

#xgbtune 3 
tune_grid3 <- expand.grid(
  nrounds = seq(from = 50, to = nrounds, by = 50),
  eta = xgb_tune$bestTune$eta,
  max_depth = xgb_tune2$bestTune$max_depth,
  gamma = 0,
  colsample_bytree = c(0.4, 0.6, 0.8, 1.0),
  min_child_weight = xgb_tune2$bestTune$min_child_weight,
  subsample = c(0.5, 0.75, 1.0)
)
tic3 <- Sys.time()

xgb_tune3 <- caret::train(
  x = x_train,
  y = y_train,
  trControl = tune_control,
  tuneGrid = tune_grid3,
  method = "xgbTree",
  verbose = TRUE
)
toc3 <- Sys.time()
toc3  - tic3

tuneplot(xgb_tune3, probs = .95)

#tune grid 4 
tune_grid4 <- expand.grid(
  nrounds = seq(from = 50, to = nrounds, by = 50),
  eta = xgb_tune$bestTune$eta,
  max_depth = xgb_tune2$bestTune$max_depth,
  gamma = c(0, 0.05, 0.1, 0.5, 0.7, 0.9, 1.0),
  colsample_bytree = xgb_tune3$bestTune$colsample_bytree,
  min_child_weight = xgb_tune2$bestTune$min_child_weight,
  subsample = xgb_tune3$bestTune$subsample
)

tic4 <- Sys.time()

xgb_tune4 <- caret::train(
  x = x_train,
  y = y_train,
  trControl = tune_control,
  tuneGrid = tune_grid4,
  method = "xgbTree",
  verbose = TRUE
)

toc4 <- Sys.time()
toc4 - tic4

tuneplot(xgb_tune4)

#tunegrid5 
tune_grid5 <- expand.grid(
  nrounds = seq(from = 100, to = 6000, by = 100),
  eta = c(0.01, 0.015, 0.025, 0.05, 0.1),
  max_depth = xgb_tune2$bestTune$max_depth,
  gamma = xgb_tune4$bestTune$gamma,
  colsample_bytree = xgb_tune3$bestTune$colsample_bytree,
  min_child_weight = xgb_tune2$bestTune$min_child_weight,
  subsample = xgb_tune3$bestTune$subsample
)

tic5 <- Sys.time()

xgb_tune5 <- caret::train(
  x = x_train,
  y = y_train,
  trControl = tune_control,
  tuneGrid = tune_grid5,
  method = "xgbTree",
  verbose = TRUE
)
toc5 <- Sys.time()
toc5 - tic5
tuneplot(xgb_tune5)


#final Grid 
(final_grid <- expand.grid(
  nrounds = xgb_tune5$bestTune$nrounds,
  eta = xgb_tune5$bestTune$eta,
  max_depth = xgb_tune5$bestTune$max_depth,
  gamma = xgb_tune5$bestTune$gamma,
  colsample_bytree = xgb_tune5$bestTune$colsample_bytree,
  min_child_weight = xgb_tune5$bestTune$min_child_weight,
  subsample = xgb_tune5$bestTune$subsample
))

tic6 <- Sys.time()

(xgb_model <- caret::train(
  x = x_train,
  y = y_train,
  trControl = tune_control,
  tuneGrid = final_grid,
  method = "xgbTree",
  verbose = TRUE
))

toc6 <- Sys.time()
toc6 - tic6

pred_test <- predict(xgb_model, newdata = testset)

#------------------------------------final Grid part 2 
(final_grid_2 <- expand.grid(
  nrounds = xgb_tune5$bestTune$nrounds,
  eta = 0.001,
  max_depth = xgb_tune5$bestTune$max_depth,
  gamma = xgb_tune5$bestTune$gamma,
  colsample_bytree = xgb_tune5$bestTune$colsample_bytree,
  min_child_weight = xgb_tune5$bestTune$min_child_weight,
  subsample = xgb_tune5$bestTune$subsample
))

tic6 <- Sys.time()

(xgb_model <- caret::train(
  x = x_train,
  y = y_train,
  trControl = tune_control,
  tuneGrid = final_grid_2,
  method = "xgbTree",
  verbose = TRUE
))

toc6 <- Sys.time()
toc6 - tic6

pred_test <- predict(xgb_model, newdata = testset)
sqrt(mean((pred_test - testset$price)^2))


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

pred_gbm_scoring <- predict(gbm_model, newdata = scoringData)


# construct submision from predictions
setwd("C:\\Users\\anderson_nelson1\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Submssion")
submissionFile = data.frame(id = scoringData$id, price = pred_gbm_scoring)
write.csv(submissionFile, 'sample_submission18.csv',row.names = F)


