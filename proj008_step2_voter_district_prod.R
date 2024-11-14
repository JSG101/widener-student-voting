rm(list=ls())
# Header: ----

# Script name: proj008_step2_voter_district_prod.R

# Purpose of script: Preparing a dataset on voter district information

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

# # read the data
# data_x <- read.csv(file.path(DATA_PROJ, "pa_voter_export_adams.csv")) %>%
#   mutate_all(as.character) %>% clean_names()
# 
# # select fields 
# data_x <- data_x %>% 
#   select(id_number, starts_with("district_"))
# 
# # pivot to longer
# data_x <- data_x %>% 
#   pivot_longer(
#     cols = starts_with("district_"),  # Selecting all columns that start with "district_"
#     names_to = "zone_number",  # The new column name for the number
#     names_prefix = "district_",  # Removing the "district_" part of the names
#     values_to = "zone_code"  # The new column name for the values
#   )
# 
# # filter missing values in zone short name??
# data_x <- data_x %>%
#   filter(!is.na(zone_code))
# 
# # merge with zone type file
# data_x <- data_x %>% 
#   left_join(
#     read.csv(file.path(DATA_PROJ, "pa_zone_types_adams.csv")) %>% 
#       mutate_all(as.character) %>% clean_names() %>% 
#       select(zone_number, zone_long_name),
#     by = join_by(zone_number)
#   )
# 
# # merge with zone codes file
# data_x <- data_x %>% 
#   left_join(
#     read.csv(file.path(DATA_PROJ, "pa_zone_codes_adams.csv")) %>% 
#       mutate_all(as.character) %>% clean_names(),
#     by = join_by(zone_number, zone_code)
#   )

# Loop ----

for (file_iter in prod_voter_export_files) {
  
  print(file_iter)
  county_iter <- sub(".*_([^_]+)\\..*", "\\1", file_iter)
  
  # read the data
  data_x <- read.csv(file.path(DATA_PROJ, file_iter)) %>%
    mutate_all(as.character) %>% clean_names()
  
  # select fields 
  data_x <- data_x %>% 
    select(id_number, starts_with("district_"))
  
  # pivot to longer
  data_x <- data_x %>% 
    pivot_longer(
      cols = starts_with("district_"),  # Selecting all columns that start with "district_"
      names_to = "zone_number",  # The new column name for the number
      names_prefix = "district_",  # Removing the "district_" part of the names
      values_to = "zone_code"  # The new column name for the values
    )
  
  # filter missing values in zone short name??
  data_x <- data_x %>%
    filter(!is.na(zone_code))
  
  # merge with zone type file
  data_x <- data_x %>% 
    left_join(
      read.csv(file.path(DATA_PROJ, paste0("pa_zone_types_", county_iter, ".csv"))) %>% 
        mutate_all(as.character) %>% clean_names() %>% 
        select(zone_number, zone_long_name),
      by = join_by(zone_number)
    )
  
  # merge with zone codes file
  data_x <- data_x %>% 
    left_join(
      read.csv(file.path(DATA_PROJ, paste0("pa_zone_codes_", county_iter, ".csv"))) %>% 
        mutate_all(as.character) %>% clean_names(),
      by = join_by(zone_number, zone_code)
    )
  
  # save the data
  write.csv(data_x, file.path(DATA_OUTPUT, paste0("prod_pa_voter_districts_", county_iter, ".csv")), row.names = FALSE)
  
}