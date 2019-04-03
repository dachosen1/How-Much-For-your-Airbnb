#------------------------------------------------------------------Set up 
# set working directory 
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")

#load libraries 
library(tidyverse); library(caret); library(leaps); library(corrplot);library(randomForest); library(gvlma)

#load dataset 
data <- read.csv("cleandata.csv")
data2 <- data


data2 <- data2[!is.na(data2$zipcode_mod),]

data2$neighbourhood_cleansed <- as.numeric(data2$neighbourhood_cleansed)


#set independent and dependent variable
x <- select(-price, .data = data2)
y <- select(price, .data = data2)

#------------------------------------------------------------------Set up 
#correlation matrix 
#by correlation 
CorrelationMatrix <- cor(x = x, y = y); CorrelationMatrix
findCorrelation(CorrelationMatrix, cutoff = 0.5)


#Training and test Set 
set.seed(178)
split <- createDataPartition(y = data2$price, p = .80,list = F,groups = 100)
trainingset <- data2[split,]
testset <- data2[-split,]

#feature selection 
#step wise 
#forward selection model 
start_mod <- lm(price ~1, data = trainingset)  
empty_mod <- lm(price ~1, data = trainingset) 
full_mod <- lm(price ~., data = trainingset)
forwardStepwise <- step(object = start_mod, 
                        scope = list(upper = full_mod , lower = empty_mod), 
                        direction = 'forward')
summary(forwardStepwise)

#setting up model 
model1 <- lm(price ~ ., data = trainingset);summary(model1)
gvlmamodel <- gvlma(model1); summary(gvlmamodel)

#by importance 
importance <- varImp(model1,scale = FALSE);importance
importance[order(importance,decreasing = TRUE),]

#setting up model 
model2 <- randomForest(price ~ ., data = trainingset,
                       ntree = 150);summary(model2)

#Test all possible subset model 1
subset1 <- regsubsets(price ~ ., 
                      data = trainingset,nvmax = 11); summary(subset1)

subset_measures1 <- data.frame(model1 = 1:length(summary(subset1)$cp),cp = summary(subset1)$cp, 
                              bic = summary(subset1)$bic, 
                              adjr2 = summary(subset1)$adjr2); subset_measures1

subset_measures1 %>%
 gather(key = type, value = value, 2:4) %>%
 ggplot( aes(x = model1 , y = value)) + 
 geom_line()+ 
 geom_point() + 
 facet_grid(type ~. , scales = 'free_y')

#Test all possible subset model 2
subset2 <- regsubsets(price ~ ., 
                      data = trainingset); subset2

subset_measures2 <- data.frame(model2 = 1:length(summary(subset2)$cp),cp = summary(subset2)$cp, 
                               bic = summary(subset2)$bic, 
                               adjr2 = summary(subset2)$adjr2); subset_measures2

subset_measures2 %>%
 gather(key = type, value = value, 2:4) %>%
 ggplot( aes(x = model1 , y = value)) + 
 geom_line()+ 
 geom_point() + 
 facet_grid(type ~. , scales = 'free_y')

#-------------------------------------------------------------------------Prediction 
#prediction for model1 
pred1 <- predict(model1, newdata = testset)
sqrt(mean((pred1 - testset$price)^2))

#predicion for model2
pred2 <- predict(model2, newdata = testset)
sqrt(mean((pred2 - testset$price)^2))



#------------------------------------------------------------------------Model Validation
#model  1

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
                          ntree = 500)
 y_pred = predict(regressor, newdata = test_fold[-4])
 accuracy = sqrt(mean((y_pred - test_fold$price)^2))
 return(accuracy)
})

accuracy2 = mean(as.numeric(cv2));accuracy2


#------------------------------------------------------------------------Applying predicion to dataset  
## read in scoring data and apply model to generate predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Data Cleaning")
scoringData = read.csv('cleandata(test).csv')

pred3 <- predict(model2,newdata=scoringData)

# construct submision from predictions
setwd("C:\\Users\\Anderson\\Dropbox\\Columbia University\\Fall 2018\\Frameworks and Methods\\Assignment\\Kaggle Competition\\Submssion")
submissionFile = data.frame(id = scoringData$id, price = pred3)
write.csv(submissionFile, 'sample_submission8.csv',row.names = F)



layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(model2)


