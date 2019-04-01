#Set Working Directory 
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Raw Data")

#import Libraries 
#import Libraries 
library(tidyverse); library(lm.beta); library(lubridate);
library(caret); library(corrplot);library(car);library(carData); library(caTools); 
library(leaps); library(glmnet); library(xgboost)

dataset <- read.csv("analysisData.csv")
dataset2 <- select(id,host_id,zipcode,room_type,property_type,accommodates,host_since,host_response_time,
                   bathrooms,bedrooms,beds,bed_type,price,neighbourhood_cleansed,neighbourhood_group_cleansed,
                   availability_30,availability_60,availability_90,availability_365,number_of_reviews,is_business_travel_ready,cleaning_fee,host_is_superhost,
                   review_scores_communication,reviews_per_month,review_scores_rating,review_scores_accuracy,
                   review_scores_cleanliness,review_scores_checkin , review_scores_communication , 
                   review_scores_location ,review_scores_value,weekly_price,monthly_price,calendar_updated,
                   calculated_host_listings_count,require_guest_phone_verification,require_guest_profile_picture,
                   cancellation_policy,instant_bookable,last_review,first_review,maximum_nights,
                   minimum_nights,extra_people,guests_included,latitude,longitude,amenities,
                   .data = dataset)

Zip_Code <- read.csv("Zip_Code.csv")
names(Zip_Code) <- c("zipcode", "zipcode_Rank")

#----------------------------------------------------Data Cleaning 

#-----beds
dataset2$beds[is.na(dataset2$beds)] <- median(dataset2$beds,na.rm = TRUE)

#-----zipcode
dataset2 <- merge(x = dataset2,y = Zip_Code, by = "zipcode")

#-----price 
nrow(dataset2[dataset2$price == 0,]) / nrow(dataset2)
count_row <- nrow(dataset2)
dataset2 <- dataset2[!dataset2$price == 0,]
count_row - nrow(dataset2)

#-----host_since
dataset2$host_since <- ymd(dataset2$host_since)

#-----First Reviews
dataset2$first_review <- ymd(dataset2$first_review)

#-----Last Review 
dataset2$last_review <- ymd(dataset2$last_review)

#-----property Type
dataset2$property_type[!dataset2$property_type == "Apartment" & !dataset2$property_type =="House" &
                        !dataset2$property_type =="Loft" & !dataset2$property_type =="Condominium"& 
                        !dataset2$property_type =="Townhouse"] <- "Other"
dataset2$property_type<- droplevels(dataset2$property_type)
dataset2$cleaning_fee[is.na(dataset2$cleaning_fee)] <- 0

#-----bathroom
histogram(dataset2$bathrooms)
dataset2%>%
 select(bathrooms)%>%
 group_by(bathrooms)%>%
 count(bathrooms)

#dataset2$bathrooms[dataset2$bathrooms > 4] <- 5

#-----Bedrooms 
histogram(dataset2$bedrooms)

dataset2%>%
 select(bedrooms, price)%>%
 group_by(bedrooms)%>%
 ggplot(aes(x = bedrooms, y = price)) + geom_smooth() 

dataset2%>%
 filter(bedrooms == 0)%>%
 select(room_type)%>%
 count(room_type)

#dataset2$bedrooms[dataset2$bedrooms >= 3] <- 3 
#dataset2$bedrooms[dataset2$bedrooms == 0] <- 1

#cleaning fee
#histogram(dataset2$cleaning_fee)
#dataset2$cleaning_fee[dataset2$cleaning_fee > 250] <- 250

dataset2%>%
 select(cleaning_fee, price)%>%
 group_by(cleaning_fee)%>%
 ggplot(aes(x = cleaning_fee, y = price)) + geom_smooth() 

#Customer Review
dataset2$review_scores_sum <- dataset2$review_scores_accuracy + dataset2$review_scores_communication + 
 dataset2$review_scores_rating + dataset2$review_scores_checkin + dataset2$review_scores_cleanliness + 
 dataset2$review_scores_location + dataset2$review_scores_value

dataset2%>%
 select(review_scores_sum, price)%>%
 group_by(review_scores_sum)%>%
 ggplot(aes(x = review_scores_sum, y = price)) + geom_smooth() 

#transoforming categorical variables into numeric
#dataset2$bed_type <- as.numeric(dataset2$bed_type)
#dataset2$neighbourhood_group_cleansed <- as.numeric(dataset2$neighbourhood_group_cleansed)
#dataset2$property_type <- as.numeric(dataset2$property_type)
#dataset2$room_type <- as.numeric(dataset2$room_type)
#dataset2$is_business_travel_ready <- as.numeric(dataset2$is_business_travel_ready)
#dataset2 <- select(.data = dataset2, -amenities)

# Days since review
dataset2$days_since_review <- dataset2$last_review - dataset2$first_review

#-------------------------------------------Data Transformation 
week <- select(dataset2, - amenities,-zipcode,-price, -monthly_price)

#-----------------------------------------Weekly price
#convert categorical to numerical 
week$room_type <- as.numeric(week$room_type)
week$property_type <- as.numeric(week$property_type)
week$host_since <- as.numeric(week$host_since)
week$host_response_time <- as.numeric(week$host_response_time)
week$bed_type <- as.numeric(week$bed_type)
week$neighbourhood_cleansed <- as.numeric(week$neighbourhood_cleansed)
week$neighbourhood_group_cleansed <- as.numeric(week$neighbourhood_group_cleansed)
week$host_is_superhost <- as.numeric(week$host_is_superhost)
week$neighbourhood_group_cleansed <- as.numeric(week$neighbourhood_group_cleansed)
week$is_business_travel_ready <- as.numeric(week$is_business_travel_ready)
week$host_is_superhost <- as.numeric(week$host_is_superhost)
week$require_guest_phone_verification <- as.numeric(week$require_guest_phone_verification)
week$calendar_updated <- as.numeric(week$calendar_updated)
week$require_guest_profile_picture <- as.numeric(week$require_guest_profile_picture)
week$cancellation_policy <- as.numeric(week$cancellation_policy)
week$instant_bookable <- as.numeric(week$instant_bookable)
week$last_review <- as.numeric(week$last_review)
week$first_review <- as.numeric(week$first_review)
week$days_since_review <- as.numeric(week$days_since_review)

#training and test 
set.seed(158)
weekly_price_NA <- week[is.na(week$weekly_price),]
weekly_price <- week[!is.na(week$weekly_price),]
split_1 <- sample.split(Y = weekly_price$weekly_price, SplitRatio = 0.85)
train_1 <- weekly_price[split_1,]
test_1 <- weekly_price[-split_1,]

#Xtreme gradient boosting 
#Xgboost model 
xgboost <- xgboost(data = as.matrix(train_1[-30]), label = train_1$weekly_price, nrounds = 25)

#predicion for regressor
pred2 <- predict(xgboost, newdata = as.matrix(test_1[-30]))
sqrt(mean((pred2 - test_1$weekly_price)^2))


#immpute NA
pred3 <- predict(xgboost, newdata = as.matrix(weekly_price_NA[-30]))
dataset2$weekly_price[is.na(dataset2$weekly_price)] <- pred3

#-----------------------------------------monthly price
month <- select(dataset2, - amenities,-zipcode,-price, -weekly_price)

#convert categorical to numerical 
month$room_type <- as.numeric(month$room_type)
month$property_type <- as.numeric(month$property_type)
month$host_since <- as.numeric(month$host_since)
month$host_response_time <- as.numeric(month$host_response_time)
month$bed_type <- as.numeric(month$bed_type)
month$neighbourhood_cleansed <- as.numeric(month$neighbourhood_cleansed)
month$neighbourhood_group_cleansed <- as.numeric(month$neighbourhood_group_cleansed)
month$host_is_superhost <- as.numeric(month$host_is_superhost)
month$neighbourhood_group_cleansed <- as.numeric(month$neighbourhood_group_cleansed)
month$is_business_travel_ready <- as.numeric(month$is_business_travel_ready)
month$host_is_superhost <- as.numeric(month$host_is_superhost)
month$require_guest_phone_verification <- as.numeric(month$require_guest_phone_verification)
month$calendar_updated <- as.numeric(month$calendar_updated)
month$require_guest_profile_picture <- as.numeric(month$require_guest_profile_picture)
month$cancellation_policy <- as.numeric(month$cancellation_policy)
month$instant_bookable <- as.numeric(month$instant_bookable)
month$last_review <- as.numeric(month$last_review)
month$first_review <- as.numeric(month$first_review)
month$days_since_review <- as.numeric(month$days_since_review)

#training and test 
set.seed(158)
monthly_price_NA <- month[is.na(month$monthly_price),]
monthly_price <- month[!is.na(month$monthly_price),]
split_2 <- sample.split(Y = monthly_price$monthly_price, SplitRatio = 0.85)
train_2 <- monthly_price[split_2,]
test_2 <- monthly_price[-split_2,]

#Xtreme gradient boosting 
#Xgboost model 
xgboost2 <- xgboost(data = as.matrix(train_2[-30]), label = train_2$monthly_price, nrounds = 25)

#predicion for regressor
pred4 <- predict(xgboost2, newdata = as.matrix(test_2[-30]))
sqrt(mean((pred4 - test_2$monthly_price)^2))

#immpute NA
pred5 <- predict(xgboost, newdata = as.matrix(monthly_price_NA[-30]))
dataset2$monthly_price[is.na(dataset2$monthly_price)] <- pred5

#------------------------------------------------------------------------Submission 
dataset3 <- select(dataset2, - amenities,-zipcode)

# construct submision from predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")
write.csv(dataset3, 'cleandata.csv',row.names = F)
