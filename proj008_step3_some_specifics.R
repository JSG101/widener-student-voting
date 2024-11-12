# Header ----
#
# Script name: proj008_step3_some_specifics.R
#
# Purpose of script:a deeper dive into the data
#
# Location of script: C:\Users\japbi\Dropbox\Data Science\3_proj\proj_008_pa_voter_rolls\2_code
#
# Author: Japbir Gill, MBA MSEd
#
# Date Created: 2024-11-09
#
# Copyright (c) Japbir Gill, 2024
# Email: Japbir.Gill@gmail.com
#
# Notes ----
#
#   
#

rm(list=ls())

# Working Directories ----

DATA_SRCE <- "C:/Users/japbi/Dropbox/Data Science/1_raw/005_pa_voter_rolls"
DATA_PROJ <- "C:/Users/japbi/Dropbox/Data Science/3_proj/proj_008_pa_voter_rolls/1_data"
OUTPUT <- "C:/Users/japbi/Dropbox/Data Science/3_proj/proj_008_pa_voter_rolls/3_output"

# Formatting and Global Options ----



# Packages ----

library(tidyverse)
library(janitor)
library(purrr)
library(googlesheets4)
library(googledrive)
gs4_auth(email = "japbir.gill@gmail.com")
drive_auth(email = "japbir.gill@gmail.com")

# Functions ----


# Just Swarthmore ----

## Read the data ----

setwd(OUTPUT)
voters_swath <- read.csv("pa_voters_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()

## Filter for Swarthmore ----

voters_swath <- voters_swath %>% 
  filter(zip == "19081")

## Arrange the data by address ----

voters_swath <- voters_swath %>% 
  arrange(street_name,desc(as.numeric(house_number)))
