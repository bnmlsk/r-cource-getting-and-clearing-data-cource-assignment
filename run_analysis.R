library(dplyr)
library(readr)
library(tidyr)
library(glue)
library(stringr)

if (!file.exists("UCI HAR Dataset")) {
  # to avoid re-fetching data if it already present (helpful if 
  # you need to run script multiple times for debug)
  output <- "data.zip"
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", output)
  unzip(output)
  file.remove(output)
}

# shared information with readable labels to be joined for datasets
activity_labels <- read_table2("UCI HAR Dataset/activity_labels.txt", col_names = c("activity_id", "activity"))
feature_labels <- read_table2("UCI HAR Dataset/features.txt", col_names = c("feature_id", "feature"))

read_dataset <- function(dataset) {
  
  base_dir <- glue("UCI HAR Dataset/{dataset}")
  
  # read subjects who performed activities for observation
  subjects <- read_table(glue("{base_dir}/subject_{dataset}.txt"), col_names = "subject_id") %>%
    mutate(observation_id = row_number(), .before = 1)
  
  # read activities (with readable labels) performed for observation
  activities <- read_table(glue("{base_dir}/y_{dataset}.txt"), col_names = "activity_id") %>%
    inner_join(activity_labels) %>%
    mutate(observation_id = row_number(), .before = 1)
  
  # read features calculated for each observation
  features <- read_table(glue("{base_dir}/X_{dataset}.txt"), col_names = as.character(1:561)) %>%
    mutate(observation_id = row_number(), .before = 1) %>%
    gather(-observation_id, key = "feature_id", value = "value", convert = TRUE) %>%
    left_join(feature_labels) %>%
    filter(grepl("mean\\(\\)|std\\(\\)", feature))
  
  activities %>%
    inner_join(subjects) %>%
    inner_join(features) %>%
    select(subject_id, activity, feature, value)
}

training <- read_dataset("train")
test <- read_dataset("test")
bind_rows(training, test) %>%
  group_by(subject_id, activity, feature) %>%
  summarise(average = mean(value))