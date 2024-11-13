# Header ----
#
# Script name: proj008_step1_fve_data_processing.R
#
# Purpose of script: Using PA voter data to find out who our real friends are
#
# Location of script:C:\Users\japbi\Dropbox\Data Science\3_proj\proj_008_pa_voter_rolls\2_code
#
# Author: Japbir Gill, MBA MSEd
#
# Date Created: 2024-11-06
#
# Copyright (c) Japbir Gill, 2024
# Email: Japbir.Gill@gmail.com
#
# Notes ----
#
#   
#

rm(list=ls())

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("proj008_step0_workingdrives_libraries.R")

# Working Directories ----

# Formatting and Global Options ----

# Packages ----

# Functions ----

# Sources ----

# Loop ----

for (iter_file in fve_files) {
  
  print(iter_file)
  
  # Loading dataset
  setwd(DATA_SRCE)
  data_iter <- read.delim(iter_file, header = FALSE) %>% 
    purrr::set_names(fve_fields) %>% 
    mutate_all(as.character) %>% clean_names()
  print("data read")
  
  # Getting county name
  county_iter <- tolower(sapply(str_split(iter_file, " "), `[`, 1))
  
  # Save dataset
  ## To Dropbox 
  setwd(DATA_PROJ)
  write.csv(data_iter, paste0("pa_voter_export_", county_iter,".csv"), row.names = FALSE)
  print("saved to Dropbox")
  ## To Google Drive
  ### Method 1: saving directly to drive folder
  # drive_put(media = paste0("pa_voters_", county_iter,".csv"), path = as_id(folder_id), name = paste0("pa_voters_", county_iter))
  ### Method 2: saving in drive then moving to folder
  # ss <- gs4_create(paste0("pa_voters_", county_iter), sheets = list(county_iter = data_iter))
  # drive_mv(ss$id, path = as_id(folder_id))
  ### Method 3: creating file in folder, then loading with data
  # ss <- drive_create(paste0("pa_voters_", county_iter), path = as_id(folder_id), type = "spreadsheet", overwrite = TRUE)
  # sheet_write(data_iter, ss, sheet = county_iter)
  # print("saved to Google Drive")
  
}
