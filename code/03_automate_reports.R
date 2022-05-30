# Load required packages -------------------------------------------------------  
# Input package names
packages <- c("here",
              "readr",
              "stringr", 
              "clock",
              "dplyr",
              "ggplot2",
              "rmarkdown",
              "knitr", 
              "magrittr",
              "glue") 

installed_packages <- packages %in% rownames(installed.packages())

# Install new packages
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Load new packages silently  
invisible(lapply(packages, library, character.only = TRUE))

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
    output_format = github_document(), 
    params = list(sex = params_df[i, 1],
                  measure = params_df[i, 2]),
    output_dir = here("output"), 
    output_file = here("output",
                       glue::glue("{params_df[i, 1]}_{params_df[i, 2]}_report.md"))
  )
}