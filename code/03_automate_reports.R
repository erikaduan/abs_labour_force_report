# Load required packages -------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here, tidyverse)  

# Load clean data --------------------------------------------------------------  
labour_force <- read_csv(here("data",
                              "clean_data",
                              "labour_force_clean.csv"))    

# Create for loop to automate report generation --------------------------------
# Create data frame of the dot product of all parameter values 
params_df <- expand.grid(unique(labour_force$sex), unique(labour_force$measure),
                         stringsAsFactors = FALSE)  

# Input template report and parameters to output all html reports
for (i in 1:nrow(params_df)) {
  rmarkdown::render(
    input = here("code",
                 "02_create_report_template.Rmd"),
    params = list(sex = params_df[i, 1],
                  measure = params_df[i, 2]),
    output_file = here("output",
                       glue::glue("{params_df[i, 1]}_{params_df[i, 2]}_report.html"))
  )
}