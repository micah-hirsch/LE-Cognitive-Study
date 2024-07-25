# Data Processing

# Author: Micah E. Hirsch, Ph.D. (mhirsch@fsu.edu)

# Data: 7/24/2024

# Purpose: To load and format cognitive data and merge it with the cleaned 
# data from https://github.com/micah-hirsch/Listening-Effort-in-Dysarthria

# Loading Needed Packages

library(tidyverse)
library(rio)
library(janitor)

# Setting Working Directory

setwd("~/Documents/LE-Cognitive-Study/Raw Data")

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

# Importing demographic data

setwd("~/Documents/LE-Cognitive-Study/Manuscript Analysis/Cleaned Data")

rio::export(cog_data, "cleaned_cog_data.csv")
