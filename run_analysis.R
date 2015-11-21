#Getting and Cleaning Data
#Course Project
#run_analysis.R
#Doug Yasso, November 2015

#This project uses the human activity data collected using Samsung Galaxy S smartphone by researchers
#at UC Irvine for a project called "Smartphone-Based Recognition of Human Activities and Postural Transitions"
#Details of the research and data set are at http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#An overview of these scripts is in README.md and a codebook for the tidy dataset is in code_book.txt

#This script file performs the following:
# 1_ Merges the training and the test sets to create one data set.
# 2_ Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3_ Uses descriptive activity names to name the activities in the data set
# 4_ Appropriately labels the data set with descriptive variable names. 
# 5_ From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Posted to Github
#Local development working directory
#       setwd("/Users/yasso/Documents/CourseraR/getclean/gcproject/")


read_datasets <- function() {
        #Doug Yasso
        #November 2015
        
        #read_datasets() takes selected columns from a test and training data set, adds human-readable 
        #labels for activities, and adds human-readable column headings that can be decomposed
        #when the data is reshaped.
        
        # These are the training and the test data sets to be combined:
        #  - 'train/X_train.txt': Training set.
        #  - 'train/y_train.txt': Training labels.
        #  - 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
        #  - 'test/X_test.txt': Test set.
        #  - 'test/y_test.txt': Test labels.
        #  - 'test/subject_test.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
        #  - 'activity_labels.txt' : the activity index numbers and names
        #  - 'features.txt' : names of columns in the X_train and X_test datasets
        
        load_file <- function(datafile) {
                #if the file is present then load it
                if (file.exists(datafile)) {
                        fread(datafile)
                        } else {
                        print(paste("Warning:", datafile, "is not present in the working directory"))
                }
                
        } 
        
        
        #read source data and metadata files
        {
                train_set <- load_file("UCI HAR Dataset/train/X_train.txt")
                train_labels <- load_file("UCI HAR Dataset/train/y_train.txt")
                train_subjects <- load_file("UCI HAR Dataset/train/subject_train.txt")
                
                test_set <- load_file("UCI HAR Dataset/test/X_test.txt")
                test_labels <- load_file("UCI HAR Dataset/test/y_test.txt")
                test_subjects <- load_file("UCI HAR Dataset/test/subject_test.txt")
                
                activities <- load_file("UCI HAR Dataset/activity_labels.txt")
                column_names <- load_file("UCI HAR Dataset/features.txt")
        }
        
        #apply column names to data sets
        {
                names(train_set) <- column_names[ , V2]
                names(test_set) <- column_names[ , V2]
        }
        #add the column with the activity codes
        {
                train_set <- cbind(train_labels, train_set)
                test_set <- cbind(test_labels, test_set)
        }
        
        #add the column with the test subject IDs
        {
                train_set <- cbind(train_subjects, train_set)
                test_set <- cbind(test_subjects, test_set)
        }        

        # merge the training and the test sets to create one data set.
        {
                #combine the rows from the two datasets
                dataset <- rbind(train_set, test_set)
        
                #name the first two columns
                names(dataset)[1] <- "Subject_ID"        
                names(dataset)[2] <- "Activity_ID"        
        }        
        
        # 2_ Extract only the measurements on the mean and standard deviation for each measurement. 
        #I interpret this to mean that we only want the columns that have the "mean" or "std" values of measures
        #for that reason, I am excluding the columns that have a calculated angle (e.g., "angle(tBodyAccMean,gravity)")
        {
                #select columns by name; keep the first two columns with Subject_ID and Activity_ID as well as "Mean" and "Std" columns
                dataset2 <- select(dataset, matches('Subject_ID|Activity_ID|mean|std'), -matches('angle'))
 
                #checked for NAs during testing; there were none and I will set the code to remove NAs when reshaping the data
                #all(colSums(is.na(dataset2))==0) #are there no NAs in any column? There are no NAs       
        }

        # 3_ Use descriptive activity names to name the activities in the data set
        {
                #join the two dataframes together on the common activity ID in order to add the English activity name
                dataset3 <- merge(activities, dataset2, by.x = "V1", by.y = "Activity_ID")
                #rename V1 back to "Activity_ID"
                dataset3 <- rename(dataset3, Activity_ID = V1)
                #rename the added column to "ActivityName"
                dataset3 <- rename(dataset3, ActivityName = V2)
      
        }

        # Step 4_ Appropriately label the data set with descriptive variable names.
        
        #I want to make the following improvements for a casual user:
        #   - write out English words within reason
        #   - take out characters that are invalid for R processing of column names
        #   - remove multiple periods (leftover after removing parentheses and dashes) and any 
        #       periods at end of column names
        #   - take out redundancies like "BodyBody"
        #   - keep the column names distinct
        #   - order the elements consistently in the columns to help in reshaping the data
        
        #The names will have the format:
        #       Domain: time or frequency
        #       Source: body or gravity (all angular velocity comes from body motion, linear acceleration comes from either gravity or the body)
        #       Measure: Linear Acceleration, Linear Acceleration Jerk, Angular Velocity, Angular Velocity Jerk
        #       Variable: calculaions of mean, mean frequency, standard deviation
        #       Axis: X, Y or Z or Magnitude for the combination of the three
        
        #- The units used for the accelerations (total and body) are 'g's (gravity of earth -> 9.80665 m/seg2).
        #- The gyroscope angular velocity units are rad/seg.
        
        {
                #remove parentheses, dashes and other invalid characters
                revised_names <- make.names(colnames(dataset3))
        
                #replace multiple periods  with a single .; use a regex
                revised_names <- gsub("\\.+", ".", revised_names, fixed = FALSE)
                #remove single periods at end of the name  (we have X, Y, Z and Magnitude measures)
                revised_names <- gsub("\\.$", "", revised_names, fixed = FALSE)

                #spell out "AngularVelocity" for measures taken from the gyroscope
                #spell out "LinearAcceleration" for measures taken from the accelerometer (both body and gravity compponents)
                revised_names <- gsub("Gyro", ".AngularVelocity", revised_names, fixed = TRUE)
                revised_names <- gsub("Acc", ".LinearAcceleration", revised_names, fixed = TRUE)

                #spell out "Magnitude" when the X, Y and Z are combined
                #put the Magnitude after the variable mean() or std(), so that it is in the same 
                #position as X, Y, Z for later tidying
                revised_names <- gsub("Mag.meanFreq", ".meanFreq.Magnitude", revised_names, fixed = TRUE)
                revised_names <- gsub("Mag.mean", ".mean.Magnitude", revised_names, fixed = TRUE)
                revised_names <- gsub("Mag.std", ".std.Magnitude", revised_names, fixed = TRUE)

                #spell out "time", "frequency"
                revised_names <- gsub("tBody", "time.Body", revised_names, fixed = TRUE)
                revised_names <- gsub("fBody", "frequency.Body", revised_names, fixed = TRUE)
                revised_names <- gsub("tGravity", "time.Gravity", revised_names, fixed = TRUE)

                #remove "BodyBody"
                revised_names <- gsub("BodyBody", "Body", revised_names, fixed = TRUE)
                
                #see how we did :-)
                print(revised_names)
        }        
         
        #apply the column names to the dataset
        dataset4 <- dataset3
        names(dataset4) <- revised_names
        
        return(dataset4)
}


make_tidy <- function(activity) {
        #Doug Yasso
        #November 2015
        
        #make_tidy() creates a tidy data set with the average of each variable for each activity and each subject.
        #this uses the reshape2 library
        
        #melt the data frame to create one row per measure per test subject
        ad1 <- melt(activity, id = 1:3, na.rm = TRUE)

        #aggregate the data to calculate the mean of each variable
        ad2 <- dcast(ad1, Subject_ID + ActivityName~variable, mean)
        
        #melt again to get one row for each subject-activity combination's mean
        ad3 <- melt(ad2, id = c("Subject_ID", "ActivityName"), na.rm = TRUE)
        
        #break apart the 'variable' column; the elements are:
        #       Domain: time or frequency
        #       Source: body or gravity (all angular velocity comes from body motion, linear acceleration comes from either gravity or the body)
        #       Measure: Linear Acceleration, Linear Acceleration Jerk, Angular Velocity, Angular Velocity Jerk
        #       Variable: calculaions of mean, mean frequency, standard deviation
        #       Axis: X, Y or Z or Magnitude for the combination of the three
        ad4 <- colsplit(ad3$variable, '\\.', names =  c('Domain','Source','Measure','Variable','Axis'))
        
        #put the new columns back into the dataset
        ad5 <- cbind(ad4,ad3)

        #remove the consolidated variable name
        ad6 <- select(ad5, -variable)

        ad7 <- arrange(ad6, Subject_ID, ActivityName, Domain, Source, Measure, Axis)
        
        ad8 <- dcast(ad7, Subject_ID+ActivityName+Domain+Source+Measure+Axis~Variable)
        
        ad9 <- rename(ad8, MeanOfMean = mean, MeanOfStdDev = std, MeanOfMeanFrequency = meanFreq)
        return(ad9)
                
}


save_output <- function(activities) {
        #Doug Yasso
        #November 2015
        
        #save_output() saves the tidy dataset to a txt file created with write.table() using row.names=FALSE
        write.table(file = "human_activity_data.txt", activities, row.names=FALSE)
        
}

run_analysis <- function() {
        #Doug Yasso
        #November 2015      

        #run_analysis() executes the code steps for loading the datasets, tidying the data and saving the tidy to a text file, "human_activity_data.txt"
                
        #load libraries
        library(plyr)           #for data frames manipulation
        library(dplyr)          #for data frames manipulation
        library(data.table)     #for fread, used to load the source data
        library(reshape2)       #for melting data and tidying

        #read_datasets() checks for presence of the source data and then performs these tasks:
        # 1_ Merge the training and the test sets to create one data set.
        # 2_ Extract only the measurements on the mean and standard deviation for each measurement. 
        # 3_ Use descriptive activity names to name the activities in the data set
        # 4_ Label the data set with descriptive variable names. 
        activitydata <- read_datasets()
        
        
        # 5_ From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
        activitydata <- make_tidy(activitydata)
        
        # Save output to a txt file created with write.table() using row.name=FALSE
        save_output(activitydata)
        
}