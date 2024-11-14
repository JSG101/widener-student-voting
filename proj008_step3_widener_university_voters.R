rm(list=ls())
# Header: ----

# Script name: proj008_step3_widener_university_voters.R

# Purpose of script:

# Location of script: 

# Location of project management: 

# Author: Japbir S Gill MBA MSEd

# Date Created: 2024-11-14

# Copyright (c) Japbir S Gill, 2024
# Email: japbir.gill@gmail.com

# Notes: ----

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("proj008_step0_workingdrives_libraries.R")

# Working Directories: ----


# Formatting Options: ----


# Packages: ----


# Functions: ----


# Datasets ----

setwd(DATA_OUTPUT)
prod_voter_info <- read.csv("prod_pa_voter_info_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()
prod_voter_registration <- read.csv("prod_pa_voter_districts_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()
prod_voter_participation <- read.csv("prod_pa_voter_elections_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()

# Using voter info file ----

## Find all voters who participated at CC22 ----

data_1 <- prod_voter_info %>% 
  filter(precinct_code == "49002002")

## Filter for voters who voted in the last election ----

data_1 <- data_1 %>% 
  filter(year(mdy(last_vote_date)) == 2024)

# Using combo registration and participation files ----

## Find all voters who are registered in the district ----

data_2 <- prod_voter_registration %>% 
  filter(zone_code == "49002002") %>% 
  distinct(id_number)

## Merge with voter participation for those who participated in the recent election ----
# The 2024 general election does not seem to be in the dataset, so I am using the 2022 primary for now. 

data_2 <- data_2 %>% 
  left_join(
    prod_voter_participation %>% 
      filter(election_number == "22") %>% 
      select(-election_number),
    by = join_by(id_number)
  )

## Merge with voter info ----

data_2 <- data_2 %>% 
  left_join(
    prod_voter_info,
    by= join_by(id_number)
  )

## Filter for voters in a college student's age range ----

data_2 <- data_2 %>% 
  filter(as.numeric(voter_age) %in% c(18:22))

## Filter for voters on streets generally associated with college students ----


# Save the dataset ----

setwd(DATA_OUTPUT)
write.csv(data_2, "final_widener_student_voters_2024-11.csv", row.names = FALSE)