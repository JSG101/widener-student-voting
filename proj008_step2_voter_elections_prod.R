rm(list=ls())
# Header: ----

# Script name: proj008_step2_voter_elections_prod.R

# Purpose of script: Preparing a dataset on voter voting trends by election

# Location of script: C:\Users\japbi\Dropbox\Data Science\3_proj\proj_008_pa_voter_rolls\2_code

# Location of project management: 

# Author: Japbir S Gill MBA MSEd

# Date Created: 2024-11-12

# Copyright (c) Japbir S Gill, 2024
# Email: japbir.gill@gmail.com

# Notes: ----

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("proj008_step0_workingdrives_libraries.R")

# Working Directories: ----


# Formatting Options: ----


# Packages: ----


# Functions: ----

# Test ----

# # Load data
# data_x <- read.csv(file.path(DATA_PROJ, "pa_voter_export_adams.csv")) %>% 
#   mutate_all(as.character) %>% clean_names()
# 
# # Retain fields
# data_x <- data_x %>% 
#   select(id_number, election_1_vote_method:election_40_party)
# 
# # make longer
# data_x <- data_x %>% 
#   pivot_longer(
#     cols = starts_with("election_"),  # Selecting all columns that start with "election_"
#     names_to = c("election_number", ".value"),  # Separate into election_number and the original name ending (vote_method or party)
#     names_pattern = "election_(\\d+)_(.*)"  # Regex to capture the number and the field type
#   )
# 
# # drop elections where the voter did not participate 
# data_x <- data_x %>% 
#   filter(!vote_method == "" & !party == "")
# 
# #  merge with election map datset
# data_x <- data_x %>% 
#   left_join(
#     read.csv(file.path(DATA_PROJ, "pa_election_mapping_adams.csv")) %>% 
#       mutate_all(as.character) %>% clean_names(),
#     by = join_by(election_number)
#   )
# 
# # adjusting data
# data_x <- data_x %>% 
#   mutate(
#      # adjusting vote method
#     vote_method = case_when(
#       vote_method == "AP" ~ "At Polls",
#       vote_method == "AB" ~ "Absentee",
#       vote_method == "MB" ~ "Mail-In Ballot",
#       vote_method == "P" ~ "Provisional",
#       TRUE ~ vote_method
#     )
#   )

# Loop ----

for (file_iter in prod_voter_export_files) {
  
  print(file_iter)
  county_iter <- sub(".*_([^_]+)\\..*", "\\1", file_iter)
 
  # Load data
  data_x <- read.csv(file.path(DATA_PROJ, file_iter)) %>% 
    mutate_all(as.character) %>% clean_names()
  
  # Retain fields
  data_x <- data_x %>% 
    select(id_number, election_1_vote_method:election_40_party)
  
  # make longer
  data_x <- data_x %>% 
    pivot_longer(
      cols = starts_with("election_"),  # Selecting all columns that start with "election_"
      names_to = c("election_number", ".value"),  # Separate into election_number and the original name ending (vote_method or party)
      names_pattern = "election_(\\d+)_(.*)"  # Regex to capture the number and the field type
    )
  
  # drop elections where the voter did not participate 
  data_x <- data_x %>% 
    filter(!vote_method == "" & !party == "")
  
  #  merge with election map datset
  data_x <- data_x %>% 
    left_join(
      read.csv(file.path(DATA_PROJ, paste0("pa_election_mapping_",county_iter, ".csv"))) %>% 
        mutate_all(as.character) %>% clean_names(),
      by = join_by(election_number)
    )
  
  # adjusting data
  data_x <- data_x %>% 
    mutate(
      # adjusting vote method
      vote_method = case_when(
        vote_method == "AP" ~ "At Polls",
        vote_method == "AB" ~ "Absentee",
        vote_method == "MB" ~ "Mail-In Ballot",
        vote_method == "P" ~ "Provisional",
        TRUE ~ vote_method
      )
    )
  
  # save the data
  write.csv(data_x, file.path(DATA_OUTPUT, paste0("prod_pa_voter_elections_", county_iter, ".csv")), row.names = FALSE)
  
}
