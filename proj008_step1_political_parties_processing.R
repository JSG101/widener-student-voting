rm(list=ls())
# Header: ----

# Script name: proj008_step1_political_parties_processing.R

# Purpose of script: Preparing the political party datasets

# Location of script: C:\Users\japbi\Dropbox\Data Science\3_proj\proj_008_pa_voter_rolls\2_code

# Location of project management: 

# Author: Japbir S Gill MBA MSEd

# Date Created: 2024-11-20

# Copyright (c) Japbir S Gill, 2024
# Email: japbir.gill@gmail.com

# Notes: ----

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("proj008_step0_workingdrives_libraries.R")

# Working Directories: ----


# Formatting Options: ----


# Packages: ----


# Functions: ----


# Loading data ----

setwd(DATA_SRCE)
setwd('../')
raw_political_parties <- read.table("Political Party Codes and Descriptions.txt", header = TRUE, sep = "\t") %>% 
  clean_names() %>% mutate_all(as.character)

# Saving the data ----

setwd(DATA_PROJ)
write.csv(raw_political_parties, "pa_political_parties.csv", row.names = FALSE)