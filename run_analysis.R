## ------ Step 1a download and load original data locally -------

print("Initialise data...")

# Download zip data into temporary directory
zipDataFolder <- tempdir()
zipDataFile <- tempfile(tmpdir=zipDataFolder,fileext=".zip")
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",zipDataFile)

# Unzip train and test files to the data folder
activity_labels <- read.table(unz(zipDataFile,"UCI HAR Dataset/activity_labels.txt"), col.names = c("Id","Activity"))
features <- read.table(unz(zipDataFile,"UCI HAR Dataset/features.txt"), col.names = c("Id","Feature"))

subject_train <- read.table(unz(zipDataFile,"UCI HAR Dataset/train/subject_train.txt"), col.names = c("Subject_Id"))
X_train <- read.table(unz(zipDataFile,"UCI HAR Dataset/train/X_train.txt"), col.names = features$Feature)
Y_train <- read.table(unz(zipDataFile,"UCI HAR Dataset/train/y_train.txt"), col.names = c("Activity"))

subject_test <- read.table(unz(zipDataFile,"UCI HAR Dataset/test/subject_test.txt"), col.names = c("Subject_Id"))
X_test <- read.table(unz(zipDataFile,"UCI HAR Dataset/test/X_test.txt"), col.names = features$Feature)
Y_test <- read.table(unz(zipDataFile,"UCI HAR Dataset/test/y_test.txt"), col.names = c("Activity"))

# match activity labels to y sets numeric labeling so that it is more intuitive
Y_test <- activity_labels[Y_test$Activity,"Activity"]
Y_train <- activity_labels[Y_train$Activity,"Activity"]

# Delete temporary directory
unlink(zipDataFile)
unlink(zipDataFolder)

## ------ Step 1b merge original data into single dataset -------

print("Merge train and test data sets...")

# Merge train files
trainSet <- data.frame(Subject_ID = subject_train, X_train, Activity = Y_train)

# Merge test files
testSet <- data.frame(Subject_ID = subject_test, X_test, Activity = Y_test)

# Merge train and test data rows
fullDataSet <- rbind(trainSet,testSet)

# Remove from memory the data that are not needed (Optional)
#rm(subject_train,X_train,Y_train,
#   subject_test,X_test,Y_test,
#   activity_labels,features,
#   testSet, trainSet)

## ------ Step 2 Extract measurements on the mean and std for each measurement -------

print("Extract mean & std columns to new data set...")

# get mean and std measuerements and keep the Subject_Id
meanStdFeatures <- names(fullDataSet)[grep("mean|std",names(fullDataSet))]

# keep only those in the data set
fullDataSet <- fullDataSet[,c("Subject_Id","Activity",meanStdFeatures)]


## ------ Step 3 & 4 Appropriate activity names and labels. -------

# These were given during the creation of the data sets using activity_labels and features


## ------ Step 5 Tidy data set with the average of each variable for each activity and each subject -------

print("Create new tidy data set and save...")

library(plyr)
# get colMeans grouped by Subject and Activity
tidyDataSet <- ddply(fullDataSet, c("Subject_Id","Activity"), function(df) colMeans(df[,meanStdFeatures]))

# save data set locally in a txt file separated by comma
write.table(tidyDataSet,"tidyDataSet.txt", sep=",", col.names= TRUE, row.names = FALSE)

# the data can be read in a table using the following command:
# read.table("tidyDataSet.txt",sep=",", header=TRUE)
