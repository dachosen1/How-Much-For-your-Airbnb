#Set Working Directory 
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Raw Data")

#import Libraries 
library(tidyverse); library(lm.beta); library(lubridate);
library(caret); library(corrplot);library(car);library(carData); library(caTools); 
library(leaps); library(glmnet); library(MASS)


dataset <- read.csv("analysisData.csv")

#----------------------------------------------------Data Cleaning 
dataset2 <- dataset

# removing columns that do not add value to the problem or are incorporate bias into the 
# algorithm 
dataset2$listing_url <- NULL
dataset2$scrape_id <- NULL
dataset2$name <- NULL
dataset2$host_name <- NULL
dataset2$last_scraped <- NULL
dataset2$summary <- NULL
dataset2$description <- NULL
dataset2$experiences_offered <- NULL
dataset2$transit <- NULL
dataset2$notes <- NULL
dataset2$neighborhood_overview <- NULL
dataset2$thumbnail_url <- NULL
dataset2$medium_url <- NULL
dataset2$xl_picture_url <- NULL
dataset2$picture_url <- NULL
dataset2$space <- NULL
dataset2$notes <- NULL
dataset2$transit <- NULL
dataset2$access <- NULL
dataset2$interaction <- NULL
dataset2$house_rules <- NULL
dataset2$host_url <- NULL
dataset2$host_about <- NULL
dataset2$host_thumbnail_url <- NULL
dataset2$host_picture_url <- NULL
dataset2$host_has_profile_pic <- NULL
dataset2$host_verifications <- NULL
dataset2$latitude <- NULL
dataset2$longitude <- NULL
dataset2$host_location <- NULL
dataset2$street <- NULL
dataset2$neighbourhood <- NULL
dataset2$host_total_listings_count  <- NULL # duplicate with host_total_listings_count
dataset2$amenities <- NULL
dataset2$host_neighbourhood <-  NULL #duplicate
dataset2$host_response_time <- NULL # measure by other factor
dataset2$host_response_rate <- NULL  # measure by other factor
dataset2$host_acceptance_rate <- NULL #all values N/A
dataset2$city <- NULL 
dataset2$state <- NULL
dataset2$country <- NULL
dataset2$market <- NULL
dataset2$host_id <- NULL
dataset2$requires_license <- NULL #all false 
dataset2$require_guest_phone_verification <- NULL
dataset2$require_guest_profile_picture <- NULL
dataset2$host_id <- NULL
dataset2$calendar_updated <- NULL
dataset2$calendar_last_scraped <- NULL
dataset2$jurisdiction_names <- NULL
dataset2$license <- NULL
dataset2$is_location_exact <- NULL
dataset2$host_since <- NULL
dataset2$first_review <- NULL
dataset2$country_code <- NULL
dataset2$has_availability <- NULL
dataset2$smart_location <- NULL
dataset2$has_availability <- NULL
dataset2$host_listings_count <- NULL
dataset2$square_feet <- NULL
dataset2$maximum_nights <- NULL
dataset2$extra_people <- NULL
dataset2$monthly_price <- NULL 
dataset2$weekly_price <- NULL
dataset2$zipcode <- NULL
rm(dataset)

#Data structure 
dataset3 <- dataset2
dataset3$host_is_superhost <- as.factor(dataset3$host_is_superhost) 
dataset3$host_identity_verified <- as.factor(dataset3$host_identity_verified)
dataset3$neighbourhood_cleansed <- as.factor(dataset3$neighbourhood_cleansed)
dataset3$neighbourhood_group_cleansed <- as.factor(dataset3$neighbourhood_group_cleansed)
dataset3$property_type <- as.factor(dataset3$property_type)
dataset3$room_type <- as.factor(dataset3$room_type)
dataset3$bed_type <- as.factor(dataset3$bed_type)
dataset3$is_business_travel_ready <- as.factor(dataset3$is_business_travel_ready)
dataset3$cancellation_policy <- as.factor(dataset3$cancellation_policy)
dataset3$instant_bookable <- as.factor(dataset3$instant_bookable)
dataset3$last_review <- ymd(dataset3$last_review)

#data cleaning 
dataset3$security_deposit[is.na(dataset3$security_deposit)] <- 0
dataset3$cleaning_fee[is.na(dataset3$cleaning_fee)] <- 0
dataset3$beds[is.na(dataset3$beds)] <- 1
dataset3$bathrooms[dataset3$bathrooms > 5] <- 5
dataset3$property_type[!dataset3$property_type == "Apartment" & !dataset3$property_type =="House" &
                        !dataset3$property_type =="Loft" & !dataset3$property_type =="Condominium"] <- "Other"
dataset3$property_type<- droplevels(dataset3$property_type)
dataset3$bathrooms[dataset3$bathrooms == 0] <- 1
dataset3$bedrooms[dataset3$bedrooms == 0] <- 1
dataset3 <- dataset3[!dataset3$price == 0,] 
dataset3$minimum_nights[dataset3$minimum_nights > 5] <- 6

#converting categorical variables into numeric 

dataset4<- dataset3%>%
            mutate_if(is.factor, as.numeric)


# construct submision from predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")
write.csv(dataset4, 'cleandata.csv',row.names = F)