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

# Load data/raw_data/labour_force_raw.csv --------------------------------------
# This dataset will contain multiple values for an observation if a value has 
# been retrospectively modified for a specific date.
raw_data <- readr::read_csv("data/raw_data/labour_force_raw.csv")

# Convert column names into snake case -----------------------------------------
clean_data <- janitor::clean_names(raw_data)

# Extract one observation per time period, measure and sex --------------------- 
clean_data <- clean_data |> 
  dplyr::arrange(desc(time_period),
                 desc(ingested_on)) |>  
  dplyr::group_by(time_period, measure, sex) |> 
  dplyr::filter(dplyr::row_number() == 1)

# Clean measure and sex values to output report ready dataset ------------------  
clean_data <- clean_data |> 
  dplyr::mutate(measure = dplyr::case_when(measure == "M1" ~ "full-time",
                                           measure == "M2" ~ "part-time"),
                sex = dplyr::case_when(sex == "1" ~ "male",
                                       sex == "2" ~ "female",
                                       sex == "3" ~ "all"))

# Convert time_period into Date type and create a value change variable --------
clean_data <- clean_data |>   
  dplyr::group_by(measure, sex) |>    
  dplyr::mutate(time_period = as.Date(paste0(time_period, "-01"), format = "%Y-%m-%d"),
                last_obs_value = dplyr::lag(obs_value),
                change_obs_value = dplyr::case_when(
                  is.na(last_obs_value) ~ 0,
                  TRUE ~ obs_value - last_obs_value)) |> 
  dplyr::ungroup()

# Save in data/clean_data as labour_force_clean.csv ----------------------------
readr::write_csv(clean_data, "data/clean_data/labour_force_clean.csv")