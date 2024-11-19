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

cc22_zone_code <- "49002002"

student_ages <- c(18:23)
student_streets <- c(
  "UNIVERSITY PL", "GLEN TR", "WASHINGTON AVE", "E 16th ST", "E 14TH ST", "E 15TH ST", "MELROSE AVE", "SIEGEL ST", "MACDAM ST", "E 13TH ST"
  )

# Datasets ----

setwd(DATA_OUTPUT)
prod_voter_info <- read.csv("prod_pa_voter_info_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()
prod_voter_registration <- read.csv("prod_pa_voter_districts_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()
prod_voter_participation <- read.csv("prod_pa_voter_elections_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()

## Find all voters who are registered in the district ----

data_cc22 <- prod_voter_registration %>% 
  filter(zone_code == cc22_zone_code) %>% 
  distinct(id_number)

## Merge with voter participation to get the elections voters participated in ----
# Filter it for the most recent general election for each registered voter 

data_cc22 <- data_cc22 %>% 
  left_join(
    prod_voter_participation %>% 
      select(-election_number),
    by = join_by(id_number)
  )  %>% 
  group_by(id_number) %>% 
  filter(mdy(election_date) == max(mdy(election_date)) | is.na(election_date)) %>% 
  ungroup() 

## Merge with voter info ----

data_cc22 <- data_cc22 %>% 
  left_join(
    prod_voter_info,
    by= join_by(id_number)
  )

## Flag for voters in a college student's age range ----

data_cc22 <- data_cc22 %>% 
  mutate(flag_student_age = ifelse(as.numeric(voter_age) %in% student_ages, 1, 0))
table(as.numeric(data_cc22$voter_age), data_cc22$flag_student_age, useNA = "ifany")

## Flag for voters on streets generally associated with college students ----

data_cc22 <- data_cc22 %>%
  mutate(flag_student_street = ifelse(street_name %in% student_streets, 1, 0))
table(data_cc22$street_name, data_cc22$flag_student_street, useNA = "ifany")

## Create single student flag ----

data_cc22 <- data_cc22 %>% 
  mutate(flag_student = ifelse(flag_student_age == 1 | flag_student_street == 1, 1, 0))

# Add other flags ----

data_cc22 <- data_cc22 %>% 
  mutate(
    # base flag
    flag_all = 1,
    # active voters
    flag_active_voter = ifelse(voter_status == "A", 1, 0)
  )
# Save the dataset ----

setwd(DATA_OUTPUT)
write.csv(data_cc22, "final_widener_student_voters_2024-11.csv", row.names = FALSE)