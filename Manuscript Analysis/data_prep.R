# Data Processing

# Author: Micah E. Hirsch, Ph.D. (mhirsch@fsu.edu)

# Data: 10/15/2024

# Purpose: To load and format cognitive data and merge it with the cleaned 
# data from https://github.com/micah-hirsch/Listening-Effort-in-Dysarthria

# Loading Needed Packages

library(tidyverse)
library(rio)
library(janitor)

# Setting Working Directory

setwd("D:\\Listening Effort Study\\Raw Data\\Cognitive Data")

file <- list.files()

file <- file[grepl("Assessment Scores", file)]

cog_data <- rio::import(file) |>
  janitor::clean_names() |>
  dplyr::select(pin, inst, uncorrected_standard_score, age_corrected_standard_score) |>
  dplyr::mutate(measure = case_when(grepl("working memory", inst, ignore.case = T) ~ "list_sort",
                                    grepl("flanker", inst, ignore.case = T) ~ "flanker",
                                    grepl("dimensional change", inst, ignore.case = T) ~ "card_sort",
                                    TRUE ~ "pattern"), .after = inst) |>
  dplyr::select(-inst) |>
  tidyr::pivot_longer(cols = uncorrected_standard_score:age_corrected_standard_score,
                      names_to = "type",
                      values_to = "score") |>
  dplyr::mutate(measure = ifelse(grepl("uncorrected", type, ignore.case = T), 
                                  paste(measure, "u", sep = "_"), paste(measure, "c", sep = "_"))) |>
  dplyr::select(-c(type)) |>
  tidyr::pivot_wider(names_from = measure,
                     values_from = score) |>
  dplyr::rename(subject = pin)

rm(file)

# Creating Data Dictionary

library(datadictionary)

labels <- c(
  subject = "Participant ID",
  list_sort_u = "Uncorrected Standardized Working Memory Score",
  list_sort_c = "Age-Corrected Standardized Working Memory Score",
  flanker_u = "Uncorrected Standardized Inhibitory Control Score",
  flanker_c = "Age-Corrected Standardized Inhbitory Control Score",
  card_sort_u = "Uncorrected Standardized Cognitive Flexibility Score",
  card_sort_c = "Age-Correct Standardized Cognitive Flexibility Score",
  pattern_u = "Uncorrected Standardized Processing Speed Score",
  pattern_c = "Age-Corrected Standardized Processing Speed Score"
)

data_dict <- create_dictionary(cog_data, var_labels = labels)

# Importing demographic data

setwd("C:\\Users\\mehirsch\\Documents\\GitHub\\LE-Cognitive-Study\\Manuscript Analysis\\Cleaned Data")

rio::export(cog_data, "cleaned_cog_data.csv")

rio::export(data_dict, "cleaned_cog_data_dictionary.csv")
