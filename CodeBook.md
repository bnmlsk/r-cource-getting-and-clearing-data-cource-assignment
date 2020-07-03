# Resulting data
Consists of 118800 observations.
- **subject_id** (number) -- identifier of a subject performing observed activity (its range is from 1 to 30).
- **activity** (string) -- name of observed activity: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING.
- **feature** (string) -- full name of the feature (only mean() and std() selected from initiial dataset)
- **average** (double) -- average feature value per subject and activity.

# How data is prepared
1) Fetch and upzip data file https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
and remove initial .zip file after unpacking. File is not being downloaded if "UCI HAR Dataset" catalogue
is already present in current working directory.
2) Load *activity_labels.txt* and *features.txt* data into separate datasets to be used 
later to assign readable labels to observations instead of ids.
3) Read data for each dataset (`test` and `train`):
   1) Read *subject_{dataset}.txt* to obtain information about subject of observations. As each
   line relates to single observation, assign "observation_id" field as row number to explicitly
   mark values.
   2) Read *x_{dataset}.txt* to obtain information about activity of observations. Join with activity
   labels by activity id to assign readable label. As each line relates to single observation, assign 
   "observation_id" field as row number to explicitly mark values.
   3) Read *X_{dataset}.txt* to obtain information about calculated features of observations. Each line is read from
   fixed width string (using `readr::read_table` function) as 561 variables with name as its numberic identifier.
   As each line relates to single observation, assign "observation_id" field as row number 
   to explicitly mark values. All but "observation_id" fileds are gathered to a single column 
   with key field "feature_id" (name as number of column automatically converted to integer) 
   and value as "value". Join with feature_labels to assign feature name for each value and filter
   only those rows that are either 'mean()' or 'std()' function (check by regexp).
   4) Join activities, features and features datasets into one by "observation_id" and return only
   "subject_id", "activity", "feature", "value" columns (as the rest are either ids for merging
   records together or labels marks).
4) Merge records of `test` and `train` sets together into a songle dataset.
5) Prepare average dataset by grouping datasaet by "subject_id", "activity" and "feature" columns
and summarizing new field "average" as mean value of average "value" for grouped sets.
6) Write average dataset to *average_dataset.txt* file (in working directory).

# Test environment
* MacOS 10.15.4 (19E287)
* R version 4.0.0 (2020-04-24)
