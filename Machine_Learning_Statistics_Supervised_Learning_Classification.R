##http://rpubs.com/LuizFelipeBrito/Machine_Learning_Statistics_Supervised_Learning_001
# -----------------------------------------------------------------------------------
# 1� Step - Clear Workspace
# -----------------------------------------------------------------------------------
rm(list = ls())   

# -----------------------------------------------------------------------------------
# 2� Step - Clear console
# -----------------------------------------------------------------------------------
cat("\014")      

# -----------------------------------------------------------------------------------
# 3� Step - The packages below must be installed.
#           Once installed, you can comment this chunk code.
# -----------------------------------------------------------------------------------
#install.packages("e1071")           # Support Vector Machine (SVM)
#install.packages("tree")            # Decision Tree
#install.packages("randomForest")    # Random Forest
#install.packages("caret")           # Classification and Regression Training
#install.packages("dplyr")           # A Grammar of Data Manipulation
#install.packages("ggplot2")         # Create Elegant Data Visualisations Using the Grammar of Graphics

# -----------------------------------------------------------------------------------
# 4� Step - Load libraries.
# -----------------------------------------------------------------------------------
library(e1071)           # Support Vector Machine (SVM)
library(tree)            # Decision Tree
library(randomForest)    # Random Forest
library(caret)           # Classification and Regression Training
library(dplyr)           # A Grammar of Data Manipulation
library(ggplot2)         # Create Elegant Data Visualisations Using the Grammar of Graphics

# -----------------------------------------------------------------------------------
# 5� Step - Set up my work directory.
# -----------------------------------------------------------------------------------
setwd("D:\\Machine_Learning")

# -----------------------------------------------------------------------------------
# 6� Step - Reading my database.
# -----------------------------------------------------------------------------------
database <- read.csv("heart.csv", header = TRUE)

# -----------------------------------------------------------------------------------
# 7� Step - Only 14 attributes are used.
#           Renaming columns in order to make our exploratory analysis easier.
# -----------------------------------------------------------------------------------
#1  (age) 				Age in years 
#2  (sex) 				Sex (1 = male; 0 = female)
#3  (cp) 				  Chest pain type -- Value 0: typical angina -- Value 1: atypical angina -- Value 2: non-anginal pain -- Value 3: asymptomatic
#4  (trestbps) 		Resting blood pressure (in mm Hg on admission to the hospital)
#5  (chol) 				Serum cholestoral in mg/dl
#6  (fbs) 				Fasting blood sugar > 120 mg/dl (1 = true; 0 = false)
#7  (restecg) 		Resting electrocardiographic results -- Value 0: normal 
#                                                      -- Value 1: having ST-T wave abnormality 
#    							                       						 	 -- Value 2: showing probable or definite left ventricular hypertrophy by Estes' criteria 
#8  (thalach) 		 Maximum heart rate achieved
#9  (exang) 			 Exercise induced angina (1 = yes; 0 = no) 
#10 (oldpeak) 		 ST depression induced by exercise relative to rest
#11 (slope) 			 The slope of the peak exercise ST segment -- Value 0: upsloping 
#                                                            -- Value 1: flat 
#                                                            -- Value 2: downsloping
#12 (ca) 				   Number of major vessels (0-3) colored by flourosopy 
#13 (thal) 				 3 = normal; 6 = fixed defect; 7 = reversable defect
#14 (target)       The predicted attribute

names(database)[names(database) == "�..age"]   <- "age"
names(database)[names(database) == "sex"]      <- "sex"
names(database)[names(database) == "cp"]       <- "chest_pain_type"
names(database)[names(database) == "trestbps"] <- "resting_blood_pressure"
names(database)[names(database) == "chol"]     <- "serum_cholestoral"
names(database)[names(database) == "fbs"]      <- "fasting_blood_sugar"
names(database)[names(database) == "restecg"]  <- "resting_cardiographic_results"
names(database)[names(database) == "thalach"]  <- "maximum_heart_rate"
names(database)[names(database) == "exang"]    <- "exercise_induced_angina"
names(database)[names(database) == "oldpeak"]  <- "depression_induced_exercise_rest"
names(database)[names(database) == "slope"]    <- "slope_peak_exercise"
names(database)[names(database) == "ca"]       <- "number_major_vessels"
names(database)[names(database) == "thal"]     <- "thal"
names(database)[names(database) == "target"]   <- "target"

# -----------------------------------------------------------------------------------
# 8� Step - Missing Values
#          Missing Values plays an important role in statistics and data analysis.
#          Often, missing values must not be ignored, but rather they should be
#          carefully studied to see if there is an underlying pattern or cause for
#          their missingness.
# -----------------------------------------------------------------------------------
ncol(database)

nrow(database)

table(is.na.data.frame(database))

# -----------------------------------------------------------------------------------
# 9� Step - After a careful reading of the dataset information it is possible 
#           to infer that the columns below can be transformed into factor types.
#           Factors are used to represent caterorical data. One can think of a ,
#           factor as an integer vector where each integer has a label. 
#           Using factors with labels is better than using integers because factors
#           are self-describing. Have a variable that has values "Male" and "Female"
#           is better than 1 and 2.
# -----------------------------------------------------------------------------------
data_heart        <- database
data_heart$target <- as.factor(data_heart$target)

database$sex                           <- factor(database$sex, levels=c(0, 1), labels=c("female", "male"), ordered = TRUE)
database$chest_pain_type               <- factor(database$chest_pain_type, levels=c(0, 1, 2, 3), labels=c("typical angina", "atypical angina", "non-anginal pain", "asymptomatic"), ordered = TRUE)
database$fasting_blood_sugar           <- factor(database$fasting_blood_sugar, levels=c(0, 1), labels=c(FALSE, TRUE), ordered = TRUE)
database$resting_cardiographic_results <- factor(database$resting_cardiographic_results, levels=c(0, 1, 2), labels=c("normal", "having wave abnormality", "probable ventricular hypertrophy"), ordered = TRUE )
database$exercise_induced_angina       <- factor(database$exercise_induced_angina, levels=c(0, 1), labels=c("No", "Yes"), ordered = TRUE)
database$slope_peak_exercise           <- factor(database$slope_peak_exercise, levels=c(0, 1, 2), labels=c("upsloping", "flat", "downsloping"), ordered = TRUE)
database$number_major_vessels          <- as.numeric(database$number_major_vessels)
database$thal                          <- as.numeric(database$thal)

database$target                        <- factor(database$target, levels=c(0, 1), labels=c("absence", "presence"), ordered = TRUE)

str(database)

summary(database)

# -----------------------------------------------------------------------------------
# 10� Step - Outlier detection and treatment
#            Outliers in data can distort predictions and affect the accuracy, 
#            if you don't detect and handle them appropriately especially in 
#            regression models.
#            Why outliers treatment is important? Because, it can drastically 
#            bias/change the fit estimates and predictions.
#            A handy explanation of Outiliers it can be found in :
#            https://www.r-bloggers.com/outlier-detection-and-treatment-with-r/
# -----------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------
# 10.1� Step - Detect Outliers - Univariate approach
#             For a given continuous variable, outliers are those observations that 
#             lie outside 1.5 * IQR, where IQR, the 'Inter Quartile Range' is the 
#             difference between 75th and 25th quartiles. Look at the points outside 
#             the whiskers in below box plot.
# -----------------------------------------------------------------------------------
summary(database$age)
#age
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  29.00   47.50   55.00   54.37   61.00   77.00 
outlier_values <- boxplot.stats(database$age)$out          # outlier values.
boxplot(database$age, main="Detect Outliers - age", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$sex)
#sex
#female   male 
#    96    207 
outlier_values <- boxplot.stats(database$sex)$out          # outlier values.
boxplot(database$sex, main="Detect Outliers - sex", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$chest_pain_type)
#chest_pain_type
#  typical angina  atypical angina non-anginal pain     asymptomatic 
#             143               50               87               23 
outlier_values <- boxplot.stats(database$chest_pain_type)$out          # outlier values.
boxplot(database$chest_pain_type, main="Detect Outliers - chest_pain_type", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$resting_blood_pressure)			 
#resting_blood_pressure
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   94.0   120.0   130.0   131.6   140.0   200.0 
outlier_values <- boxplot.stats(database$resting_blood_pressure)$out          # outlier values.
boxplot(database$resting_blood_pressure, main="Detect Outliers - resting_blood_pressure", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$serum_cholestoral)
#serum_cholestoral
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  126.0   211.0   240.0   246.3   274.5   564.0 
outlier_values <- boxplot.stats(database$serum_cholestoral)$out          # outlier values.
boxplot(database$serum_cholestoral, main="Detect Outliers - serum_cholestoral", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$fasting_blood_sugar)
#fasting_blood_sugar
#FALSE  TRUE 
#  258    45 
outlier_values <- boxplot.stats(database$fasting_blood_sugar)$out          # outlier values.
boxplot(database$fasting_blood_sugar, main="Detect Outliers - fasting_blood_sugar", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$resting_cardiographic_results)
#resting_cardiographic_results
#normal          having wave abnormality          probable ventricular hypertrophy 
#  147                              152                                  4
outlier_values <- boxplot.stats(database$resting_cardiographic_results)$out          # outlier values.
boxplot(database$resting_cardiographic_results, main="Detect Outliers - resting_cardiographic_results", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$maximum_heart_rate)
#maximum_heart_rate
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   71.0   133.5   153.0   149.6   166.0   202.0 
outlier_values <- boxplot.stats(database$maximum_heart_rate)$out          # outlier values.
boxplot(database$maximum_heart_rate, main="Detect Outliers - maximum_heart_rate", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$exercise_induced_angina)
#exercise_induced_angina
# No Yes 
#204  99 
outlier_values <- boxplot.stats(database$exercise_induced_angina)$out          # outlier values.
boxplot(database$exercise_induced_angina, main="Detect Outliers - exercise_induced_angina", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$depression_induced_exercise_rest)
#depression_induced_exercise_rest
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   0.00    0.00    0.80    1.04    1.60    6.20 
outlier_values <- boxplot.stats(database$depression_induced_exercise_rest)$out          # outlier values.
boxplot(database$depression_induced_exercise_rest, main="Detect Outliers - depression_induced_exercise_rest", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$slope_peak_exercise)
#slope_peak_exercise
#upsloping          flat          downsloping 
#      21            140                 142    
outlier_values <- boxplot.stats(database$slope_peak_exercise)$out          # outlier values.
boxplot(database$slope_peak_exercise, main="Detect Outliers - slope_peak_exercise", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$number_major_vessels)
#number_major_vessels
#     0   1   2   3   4 
#   175  65  38  20   5 
outlier_values <- boxplot.stats(database$number_major_vessels)$out          # outlier values.
boxplot(database$number_major_vessels, main="Detect Outliers - number_major_vessels", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$thal)
#thal
#  0   1   2   3 
#  2  18 166 117 
outlier_values <- boxplot.stats(database$thal)$out          # outlier values.
boxplot(database$thal, main="Detect Outliers - thal", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

summary(database$target)
#target
# absence presence 
#     138      165 
outlier_values <- boxplot.stats(database$target)$out          # outlier values.
boxplot(database$target, main="Detect Outliers - target", boxwex=0.1)
mtext(paste("Outliers: ", paste(outlier_values, collapse=", ")), cex=0.6)

# -----------------------------------------------------------------------------------
# 10.2� Step - We found Outliers only for following continuous variable:
#                              - resting_blood_pressure
#                              - serum_cholestoral
#                              - maximum_heart_rate
#                              - depression_induced_exercise_rest
#              Let's to try a bivariate approach, so that we can visualize in 
#              box-plot of the X and Y, for categorical X' (target).
# -----------------------------------------------------------------------------------
boxplot(resting_blood_pressure ~ target, data=database, main="resting_blood_pressure (continuos var) vs target")

boxplot(serum_cholestoral ~ target, data=database, main="serum_cholestoral (continuos var) vs target")

boxplot(maximum_heart_rate ~ target, data=database, main="maximum_heart_rate (continuos var) vs target")

boxplot(depression_induced_exercise_rest ~ target, data=database, main="depression_induced_exercise_rest (continuos var) vs target")

# -----------------------------------------------------------------------------------
# 11� Step - Identification Of Near Zero Variance Predictors.
#            It diagnoses predictors that have one unique value (i.e. are zero 
#            variance predictors) or predictors that are have both of the following 
#            characteristics: they have very few unique values relative to the number 
#            of samples and the ratio of the frequency of the most common value to 
#            the frequency of the second most common value is large
# -----------------------------------------------------------------------------------
table(nearZeroVar(data_heart))

# -----------------------------------------------------------------------------------
# 12� Step - Exploratory Data Analysis.
#            Statistical Methods for Exploratory Analysis. Theses methods include 
#            clustering and dimension reduction techiques.
#            It comes to visualization a high dimensional or multidimensional data.
#            Clustering organizes things that are close into groups.
#            Probably, the most kind of familiar distance metric is the Euclidean
#            distance which is just kind of the stright-line distance between any
#            two points.
#            Hierarchical Clustering give us an ideia of the relationship between 
#            variables or observation.
# -----------------------------------------------------------------------------------
hc <- hclust(dist(data_heart, method = "euclidean"), method="complete")

plot(hc)

plot(as.dendrogram(hc))   


# -----------------------------------------------------------------------------------
# 13� Step - Analytic Graphics.
#             They help us find patterns in data and understand its properties.
#             They suggest modeling strategies to communicate results.
#                - Show Comparisons.
#                - Show causality, mechanism, explanation, systematic structure.
#                - Shom multivariate data.
#                - Integrate multiple models of evidence.
# -----------------------------------------------------------------------------------

png('plot_machine_learning.png')

par(mfrow=c(2,2))   

plot(x = database$target, y = database$age, col = "black", type = "l", xlab = "Target", ylab = "Age", plot = TRUE)

plot(x = database$target, y = database$sex, col = "black", type = "l",  xlab = "Target", ylab = "Sex", plot = TRUE)

plot(x = database$target , y = database$resting_blood_pressure, col = "black", type = "l", xlab = "", ylab = "Outliers", plot = TRUE)
lines(x = database$target, y = database$serum_cholestoral, col = "red")
lines(x = database$target, y = database$maximum_heart_rate, col = "blue")
legend("topright", lty = "solid", col = c("black", "red", "blue"), legend = c("resting_blood_pressure", "serum_cholestoral", "maximum_heart_rate"), bty = "n")

df <- select(data_heart, target, depression_induced_exercise_rest)
ggplot(df, aes(x=depression_induced_exercise_rest)) + geom_histogram(binwidth=1)

par(mfrow=c(1,1))        # sets the plot window back to normal
dev.off()                # But this will clear your plot history.

# -----------------------------------------------------------------------------------
# 14� Step - Setting Random number seed with Set.seed ensure reproducibility.
#            Always set the random number seed when conducting a simulation.
# -----------------------------------------------------------------------------------
set.seed(1)

# -----------------------------------------------------------------------------------
# 15� Step - The training set is used to fit the models;  
#            the test set is used for assessment of the generalization error of the 
#            final chosen model. 
#            Ideally, the test set should be kept in a "vault," and be brought out 
#            only at the end of the data analysis.
#            It generates randomly the indices for test base. 
#            We split out 30% for testing and 70% for training.
# -----------------------------------------------------------------------------------
indexes = sample(1:nrow(data_heart), size=0.3*nrow(data_heart))

train = data_heart[-indexes,]
test = data_heart[indexes,]

# -----------------------------------------------------------------------------------
# 16� Step - SVM - Support Vector Machines
#           cost or C => Cost of the violations of the restrictions. 
#                        (constant of Lagrange's regularization)
#               Gamma => It defines the distance of influence of the patterns in the 
#                        limits of decision (low values => far, high values => near)
# -----------------------------------------------------------------------------------
system.time(svm_model <- svm(target ~., train, probability =T))
predictionsSVM <- predict(svm_model, test, probability =T)
table(predictionsSVM,test$target)
acuracy = 1 - mean(predictionsSVM != test$target)
acuracy
summary(svm_model)

probabilities = attr(predictionsSVM, "probabilities")
predictionsAndProbabilities = cbind(test$target, predictionsSVM, probabilities)
View(predictionsAndProbabilities)

cm = table(predictionsSVM,test$target); cm           #Metric that evaluates the level of agreement of a classification task
kappa = confusionMatrix(cm)$overall[2]; kappa

confusionMatrix(cm)

# -----------------------------------------------------------------------------------
# 17� Step - Decision Tree 
# -----------------------------------------------------------------------------------
system.time(tree_model <- tree(target ~., train))
predictionsDtree <- predict(tree_model, test, type = "class")
table(predictionsDtree, test$target)
acuracy = 1 - mean(predictionsDtree != test$target)
acuracy
summary(tree_model)
plot(tree_model)
text(tree_model)

cm = table(predictionsDtree,test$target); cm           #Metric that evaluates the level of agreement of a classification task
kappa = confusionMatrix(cm)$overall[2]; kappa

confusionMatrix(cm)

# -----------------------------------------------------------------------------------
# 18� Step - Random Forest
# -----------------------------------------------------------------------------------
system.time(forest_model <- randomForest(target ~., data = train, 
                                         importance = TRUE, 
                                         do.trace = 100))
predictionsForest = predict(forest_model, test)
table(predictionsForest, test$target)
acuracy = 1 - mean(predictionsForest != test$target)
acuracy
plot(forest_model)
legend("topright", legend=c("OOB", "0", "1"),
       col=c("black", "red", "green"), lty=1:1, cex=0.8)

varImpPlot(forest_model)                                #Two measures of importance to rank attributes.

cm = table(predictionsForest,test$target); cm           #Metric that evaluates the level of agreement of a classification task
kappa = confusionMatrix(cm)$overall[2]; kappa

confusionMatrix(cm)

# -----------------------------------------------------------------------------------
# 19� Step - Principal Component Analysis (PCA)
#            The principal components are equal to the right singular values if you
#            first scale(Subtract the mean, divide by the standard deviation) the 
#            variables.
# -----------------------------------------------------------------------------------
train_pca <- train[-14]         # we do not use the "target" column when pca is applied.
train_pca <- scale(train_pca)
pca <- princomp(train_pca)
summary(pca)                    # pca's results (standard deviation, proportional variance and proportion of cumulative variance)
plot(pca)

# -----------------------------------------------------------------------------------
# 19.1� Step - Principal Component Analysis (PCA)
#              We are going to use only The principal components that maintain a 
#              cumulative variance of 100% of the total.
# -----------------------------------------------------------------------------------
vars <- pca$sdev^2
vars <- vars/sum(vars)
cumulativeVariance <- cumsum(vars)
View(as.data.frame(cumulativeVariance)) #==> variance 0.95: Only the first 11 columns

train_pca <- pca$scores[,1:11]
train_pca = as.data.frame(train_pca)
train_pca = cbind(train_pca, train$target)
colnames(train_pca)[ncol(train_pca)] <- "target"

# -----------------------------------------------------------------------------------
# 20� Step - SVM - Support Vector Machines + PCA
# -----------------------------------------------------------------------------------
system.time(svm_model_pca <- svm(target ~., train_pca, probability =T))
predictionsSVM_PCA <- predict(svm_model_pca, train_pca, probability =T)
table(predictionsSVM_PCA,train_pca$target)
acuracy = 1 - mean(predictionsSVM_PCA != train_pca$target)
acuracy
summary(svm_model_pca)

probabilities = attr(predictionsSVM_PCA, "probabilities")
predictionsAndProbabilities = cbind(test$target, predictionsSVM_PCA, probabilities)
View(predictionsAndProbabilities)

cm = table(predictionsSVM_PCA,train_pca$target); cm           #Metric that evaluates the level of agreement of a classification task
kappa = confusionMatrix(cm)$overall[2]; kappa

confusionMatrix(cm)


