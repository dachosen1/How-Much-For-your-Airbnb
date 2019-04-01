# set working directory 
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")

#load libraries 
library(tidyverse)

#load dataset 
data <- read.csv("cleandata.csv")
data2 <- select(data,-square_feet, -neighbourhood_cleansed,-property_type,-bed_type,
                -last_review,-cancellation_policy,-weekly_price,-monthly_price,price)

data3 <- select(data2,neighbourhood_group_cleansed,room_type,accommodates,bathrooms,bedrooms,
                cleaning_fee,availability_30,review_scores_communication,reviews_per_month,price)


#Training and test Set 
set.seed(1185)
split <- createDataPartition(y = data3$price, p = .70,list = F,groups = 100)
trainingset <- data3[split,]
testset <- data3[-split,]

#Test all possible subset 
subsets <- regsubsets(price ~., data = trainingset, nvmax = 10); summary(subsets)

subset_measures <- data.frame(model1 = 1:length(summary(subsets)$cp),cp = summary(subsets)$cp, 
                              bic = summary(subsets)$bic, 
                              adjr2 = summary(subsets)$adjr2)

subset_measures %>%
 gather(key = type, value = value, 2:4) %>%
 ggplot( aes(x = model1 , y = value)) + 
 geom_line()+ 
 geom_point() + 
 facet_grid(type ~. , scales = 'free_y')


# Random Forest Model 
model1 <- lm(formula = price ~., data = trainingset)
library(randomForest)
set.seed(1234)
model1<- randomForest(x = data3[,-10],
                         y = data3$price,
                         ntree = 500)




pred <- predict(model1, newdata = testset)



## read in scoring data and apply model to generate predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Raw Data")
scoringData = read.csv('cleandata(test).csv')
pred2 = predict(model1,newdata=scoringData)

sqrt(mean((pred - testset$price)^2))


# construct submision from predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Submssion")
submissionFile = data.frame(id = scoringData$id, price = pred2)
write.csv(submissionFile, 'sample_submission2.csv',row.names = F)





