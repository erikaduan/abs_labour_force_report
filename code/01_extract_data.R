# Load required packages -------------------------------------------------------  
# The native pipe operator requires R version 4.1+ 
packages <- c("readr",
              "stringr",
              "janitor",
              "rsdmx",
              "clock",
              "dplyr",
              "magrittr")

installed_packages <- packages %in% rownames(installed.packages())

if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Connect to Labour Force API --------------------------------------------------
# Only extract adjusted time series (TSEST == 20)
data_url <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M2+M1.2+1+3.1599.20.AUS.M?startPeriod=2019-01&dimensionAtObservation=AllDimensions"  

# Obtain data as R data frame --------------------------------------------------
if (!file.exists("data/raw_data/labour_force_raw.csv")) {
  # If labour_force_raw.csv does not exist, proceed with the first raw data load 
  raw_data <- rsdmx::readSDMX(data_url) |> 
    as.data.frame() 
  
  # Remove redundant columns 
  col_unique_values <- purrr::map_dbl(raw_data, ~length(unique(.x)))
  raw_data <- raw_data[col_unique_values != 1]
  
  # Add updated_on column as a data ingestion time stamp
  # Convert SEX into integer type or readr::write_csv() will coerce into double type  
  raw_data <- raw_data %>%
    dplyr::mutate(INGESTED_ON = Sys.Date(),
                  SEX = as.integer(SEX))
} else {
  # If labour_force_raw.csv exists, return data API output as a new extract
  new_extract <- rsdmx::readSDMX(data_url) |> 
    as.data.frame() 
  
  col_unique_values <- purrr::map_dbl(new_extract, ~length(unique(.x)))
  new_extract <- new_extract[col_unique_values != 1]
  
  # Add JOIN_ID to enable anti-joins against previous time series values 
  new_extract <- new_extract |> 
    dplyr::mutate(INGESTED_ON = Sys.Date(),
                  SEX = as.integer(SEX),
                  JOIN_ID = paste(TIME_PERIOD,
                                  MEASURE,
                                  SEX,
                                  round(obsValue*1000),
                                  sep = "-"))
  
  # Load previous data and add JOIN_ID
  previous_data <- readr::read_csv("data/raw_data/labour_force_raw.csv")
  previous_data <- dplyr::mutate(previous_data, 
                                 JOIN_ID = paste(TIME_PERIOD,
                                                 MEASURE,
                                                 SEX,
                                                 round(obsValue*1000),
                                                 sep = "-"))
  
  # Extract records present in new_extract but not previous_data
  new_records <- dplyr::anti_join(new_extract, previous_data, by = "JOIN_ID")
  new_records$JOIN_ID <- NULL
  previous_data$JOIN_ID <- NULL
  
  # Merge as raw data and save in data/raw_data as labour_force_raw.csv
  # This dataset will contain multiple values for an observation if a value has 
  # been retrospectively modified for a specific date.  
  raw_data <- dplyr::bind_rows(new_records, previous_data) 
}

# Save in data/raw_data as labour_force_raw.csv --------------------------------
readr::write_csv(raw_data, "data/raw_data/labour_force_raw.csv")