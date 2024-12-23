rm(list=ls())
# Header: ----

# Script name: proj008_step0_full_run_prod_processing.R

# Purpose of script: To run all prod and processing files for project 008

# Location of script: 

# Location of project management: 

# Author: Japbir S Gill MBA MSEd

# Date Created: 2024-12-02

# Copyright (c) Japbir S Gill, 2024
# Email: japbir.gill@gmail.com

# Notes: ----

# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

files <- list.files(
  path = dirname(rstudioapi::getActiveDocumentContext()$path),
  pattern = "_step[12]_",
  full.names = TRUE
)
files


for (file_iter in files) {
  
  print(file_iter)
  
  source(file_iter)
  
}