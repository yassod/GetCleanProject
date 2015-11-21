#Getting and Cleaning Data Project
**Doug Yasso**
November 2015

##Overview
This project uses the human activity data collected using Samsung Galaxy S smartphone by researchers
at UC Irvine for a project called "Smartphone-Based Recognition of Human Activities and Postural Transitions".
Details of the research and data set are at: [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones]()
The codebook for the tidy dataset is in **code\_book.txt**.

##Scripts
The code is all contained in **run_analysis.R**.
###**run_analysis()**
Executes all of the scripts for loading the datasets, tidying the data and saving the tidy to a text file, **human\_activity\_data.txt**.

###**read_datasets()**
Checks for presence of the source data and then performs these tasks:

1. Merge the training and the test sets to create one data set.
2. Extract only the measurements on the mean and standard deviation for each measurement. 
3. Use descriptive activity names to name the activities in the data set
4. Label the data set with descriptive variable names. 

###**make_tidy()** 
Creates a tidy data set with the average of each variable for each activity and each subject.

##### Tidy Format
The final data table has value columns for these variables:

* Mean of Mean
* Mean of Standard Deviation
* Mean of Mean Frequency (*Mean Frequency* is the weighted average of the frequency components)

and rows for each combination of Subject (30 subjects), Activity (6 activities tested), Domain (frequency or time), Source (of acceleration, either Body or Gravity), Measure (Angular Velocity, Angular Velocity Jerk, Linear Acceleration, Linear Acceleration Jerk) and Axis (of motion, either, X, Y, Z or the combined Magnitude).

##### Data Labels
I made the following improvements in data labeling for a casual user to understand the data more easily:

* write out English words within reason
* take out characters that are invalid for R processing of column names
* remove multiple periods (leftover after removing parentheses and dashes) and any 
* periods at end of column names
* take out redundancies like "BodyBody"
* keep the column names distinct
* order the elements consistently in the columns to help in reshaping the data

##### Name Format
 The names will have the format:
* Domain: time or frequency
* Source: body or gravity (all angular velocity comes from body motion, linear acceleration comes from either gravity or the body)
* Measure: Linear Acceleration, Linear Acceleration Jerk, Angular Velocity, Angular Velocity Jerk
* Variable: calculaions of mean, mean frequency, standard deviation
* Axis: X, Y or Z or Magnitude for the combination of the three

##### Data Units
* The units used for the accelerations (total and body) are 'g's (gravity of earth -> 9.80665 m/seg^2).
* The gyroscope angular velocity units are radians/seg.


###**save_output()** 
Saves the tidy dataset to a txt file created with `write.table()` without row names.

The final data file can be read with `read.table(file = "human_activity_data.txt")`

##Data Files Used from UC Irvine Project
    
These are the training and the test data sets to be combined:

 - 'train/X_train.txt': Training set.
 - 'train/y_train.txt': Training labels.
 - 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
 - 'test/X_test.txt': Test set.
 - 'test/y_test.txt': Test labels.
 - 'test/subject_test.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
 - 'activity_labels.txt' : The activity index numbers and names.
 - 'features.txt' : Names of columns in the X\_train and X\_test datasets.


##Libraries Used
**library(plyr)** for data frames manipulation

**library(dplyr)** for data frames manipulation

**library(data.table)** for fread, used to load the source data

**library(reshape2)** to tidy the data with melt and cast