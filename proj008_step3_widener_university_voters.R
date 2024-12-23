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

zone_codes <- 
  c(
    #CC 2/2
    "49002002", 
    #CC 2/1
    "49002001",
    #CC 2/3
    "49002003",
    #CC 2/4
    "49002004",
    #CC 1/3
    "49001003",
    #CC 1/4
    "49001004",
    #CC 1/6
    "49001006",
    #Ridley 7/2
    "38007002"
    )

student_ages <- c(18:25)

register_google(key = Sys.getenv("GOOGLE_MAPS_API_KEY"))

# Datasets ----

setwd(DATA_OUTPUT)
prod_voter_info <- read.csv("prod_pa_voter_info_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()
prod_voter_registration <- read.csv("prod_pa_voter_districts_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()
prod_voter_participation <- read.csv("prod_pa_voter_elections_delaware.csv") %>% 
  mutate_all(as.character) %>% clean_names()

# Identify student voters ----

## Pull in voters in the specific districts 

student_voters <- prod_voter_registration %>% 
  filter(zone_code %in% zone_codes) %>% 
  distinct(id_number)

## Identify voting-aged students ----

student_voters <- student_voters %>% 
  left_join(
    prod_voter_info %>% 
      select(id_number, voter_age),
    by = join_by(id_number)
  ) %>% 
  mutate(flag_student_age = ifelse(as.numeric(voter_age) %in% student_ages, 1, 0)) %>% 
  select(-voter_age)
table(student_voters$flag_student_age, useNA = "ifany")

## Identify students in student housing ----
# this is essentially voters who are not living with their parents

student_voters <- student_voters %>% 
  left_join(
    prod_voter_info %>% 
      select(id_number, voter_age, house_number, house_number_suffix, street_name, apartment_number, city, state, zip) %>% 
      group_by(house_number, house_number_suffix, street_name, apartment_number, city, state, zip) %>% 
      mutate(resident_count = n()) %>% 
      mutate(flag_family_house = max(ifelse(voter_age >= 35 & resident_count < 6, 1, 0))) %>% 
      ungroup() %>% 
      mutate(flag_student_housing = ifelse(flag_family_house == 0, 1, 0)) %>% 
      select(id_number, flag_student_housing),
    by = join_by(id_number)
  )
table(student_voters$flag_student_housing, useNA = "ifany")
table(student_voters$flag_student_housing, student_voters$flag_student_age, useNA = "ifany")

## Create a single student voter flag ----

student_voters <- student_voters %>% 
  mutate(flag_student = ifelse(flag_student_age == 1 & flag_student_housing == 1, 1, 0))

## Save the dataset ----

setwd(DATA_OUTPUT)
write.csv(student_voters, "final_widener_student_voters_flags_2024-11.csv", row.names = FALSE)

# Create voter info ----

## Merge student voter dataset with voter information ----

final_voter_info <- prod_voter_info %>% 
  right_join(
    student_voters,
    by = join_by(id_number)
  )

## Formatting text to title case ----

final_voter_info <- final_voter_info %>% 
  mutate(across(c(last_name, first_name, middle_name, suffix, title, city, county, political_party_registration, street_name), 
                ~ str_to_title(.)))

## Getting GIS coordinates for each address ----

final_voter_info <- final_voter_info %>% 
  left_join(
    final_voter_info %>% 
      distinct(house_number, street_name, city, state, zip) %>%
      filter(!is.na(street_name)) %>% 
      mutate(
        gis_geocode = geocode(paste0(house_number, " ", street_name, ", ", city, ", ", state, ", ", zip)),
        latitude = ifelse(!is.na(gis_geocode$lat), gis_geocode$lat, NA),
        longitude = ifelse(!is.na(gis_geocode$lon), gis_geocode$lon, NA) 
      ) ,
    by = join_by(house_number, street_name, city, state, zip)
  )

## Save the dataset ----

setwd(DATA_OUTPUT)
write.csv(final_voter_info, "final_widener_student_voters_info_2024-11.csv", row.names = FALSE)

# Create voter registration ----

## Merge student voter info with voter registration ----

final_voter_registration <- prod_voter_registration %>% 
  right_join(
    student_voters,
    by = join_by(id_number)
  )
n_distinct(final_voter_registration$id_number)

## Formatting text to title case ----

final_voter_registration <- final_voter_registration %>% 
  mutate(across(c(county_name, zone_description), 
                ~ str_to_title(.)))

## Save the dataset ----

setwd(DATA_OUTPUT)
write.csv(final_voter_registration, "final_widener_student_voters_registration_2024-11.csv", row.names = FALSE)

# Create voter participation ----

## Merge student voter info with voter participation ----

final_voter_participation <- prod_voter_participation %>% 
  right_join(
    student_voters,
    by = join_by(id_number)
  )
n_distinct(final_voter_participation$id_number)

## Fix political parties not represented ----

final_voter_participation <- final_voter_participation %>% 
  mutate(political_party_election = 
           ifelse(
             is.na(political_party_election),
             case_when(
               party %in% c("I", "INDd", "INDE") ~ "INDEPENDENT",
               party == "GR" ~ "GREEN", 
               is.na(party) ~ "NO AFFILIATION",
               TRUE ~ "NO AFFILIATION"
             ),
             political_party_election
           )
  )
table(final_voter_participation$political_party_election, useNA = "ifany")

## Formatting text to title case ----

final_voter_participation <- final_voter_participation %>% 
  mutate(across(c(county_name, election_description, political_party_election), 
                ~ str_to_title(.)))

## Save the dataset ----

setwd(DATA_OUTPUT)
write.csv(final_voter_participation, "final_widener_student_voters_participation_2024-11.csv", row.names = FALSE)

