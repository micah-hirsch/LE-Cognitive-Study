# Data Processing

# Author: Micah E. Hirsch, M.S. (mhirsch@fsu.edu)

# Data: 3/6/2024

# Purpose: To load and format cognitive data and merge it with the pupil
# data for S. Bikulcius' undegraduate thesis. 

# Loading Needed Packages

library(tidyverse)
library(rio)
library(janitor)

# Setting Working Directory

setwd("~/Documents/LE-Cognitive-Study/Raw Data")

# Loading in cognitive data

cog_data <- rio::import("2024-02-26 16.32.44 Assessment Scores.csv") |>
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
  dplyr::mutate(measure1 = ifelse(grepl("uncorrected", type, ignore.case = T), 
                                  paste(measure, "u", sep = "_"), paste(measure, "c", sep = "_"))) |>
  dplyr::select(-c(type, measure)) |>
  tidyr::pivot_wider(names_from = measure1,
                     values_from = score) |>
  dplyr::rename(subject = pin)

# Exporting cleaned data for analysis

setwd("~/Documents/LE-Cognitive-Study/S. Bikulcius Thesis/Data")

rio::export(cog_data, "cleaned_cog_data.csv")
