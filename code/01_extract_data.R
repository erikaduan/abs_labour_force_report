# Load required packages -------------------------------------------------------  
# Input package names
packages <- c("here",
              "readr",
              "stringr",
              "janitor",
              "rsdmx",
              "clock",
              "dplyr",
              "magrittr") 

installed_packages <- packages %in% rownames(installed.packages())

# Install new packages
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Load packages individually for detection by renv 
library("here")
library("readr")
library("stringr")
library("janitor")
library("rsdmx")
library("clock")
library("dplyr")
library("magrittr")

# Connect to Labour Force API --------------------------------------------------
data_url <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M2+M1.2+1+3.1599.20+30.AUS.M?startPeriod=2019-01&dimensionAtObservation=AllDimensions"  

# Obtain data as tibble data frame ---------------------------------------------
# If raw_data does not exist, proceed with the first raw data load
if (!file_exists(here("data", "raw_data"))) {
  # Add updated_on column as a data ingestion time stamp  
  raw_data <- readSDMX(data_url) %>%
    as_tibble() %>%
    mutate(INGESTED_ON = Sys.Date())
  
  # Save in data/raw_data as labour_force_raw.csv
  write_csv(raw_data, here("data",
                           "raw_data",
                           "labour_force_raw.csv"))
}

# If raw data 
if file_exists(here("data", "raw_data")) {
  # Load newest data extract 
  new_extract <- readSDMX(data_url) %>%
    as_tibble() %>%
    mutate(INGESTED_ON = Sys.Date())
  
  # Load previous data load and anti join
}