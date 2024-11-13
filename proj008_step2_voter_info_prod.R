rm(list=ls())
# Header: ----

# Script name: proj008_step2_voter_info_prod.R

# Purpose of script: preparing a dataset of voter information such as demographics and their registration information

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

# Loop ----

for (file_iter in prod_voter_export_files) {
  
  print(file_iter)
  county_iter <- sub(".*_([^_]+)\\..*", "\\1", file_iter)

  
  # Read the file
  setwd(DATA_PROJ)
  data_x <- read.csv(file_iter) %>% 
    mutate_all(as.character) %>% clean_names()
  
  # Retain fields
  data_x <- data_x %>% 
    select(id_number:custom_data_1)
  
  # Filters
  data_x <- data_x %>% 
    filter(voter_status == "A")
  
  # Calculate fields
  data_x <- data_x %>% 
    mutate(
      voter_age = floor(as.numeric(difftime(election_date, mdy(dob), units = "days"))/365.25)
    ) %>% 
    group_by(house_number, house_number_suffix, street_name, apartment_number, address_line_2, city, state,zip) %>% 
    mutate(
      pct_dem = sum(party_code == "D")/n(),
      pct_rep = sum(party_code == "R")/n()
    ) %>% 
    ungroup()
  
  # Save the dataset
  setwd(DATA_OUTPUT)
  write.csv(data_x, paste0("prod_pa_voter_info_", county_iter,".csv"), row.names = FALSE)
}
