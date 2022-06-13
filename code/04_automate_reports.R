# Load required packages -------------------------------------------------------  
packages <- c("here",
              "readr",
              "stringr", 
              "clock",
              "dplyr",
              "ggplot2",
              "rmarkdown",
              "knitr", 
              "magrittr",
              "glue",
              "xfun",
              "fs") 

installed_packages <- packages %in% rownames(installed.packages())

if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Load packages required by Rmd template
library(ggplot2)
library(dplyr)

# Load clean data --------------------------------------------------------------  
labour_force <- readr::read_csv("data/clean_data/labour_force_clean.csv")    

# Empty ~/output folder to recreate reports ------------------------------------
fs::dir_delete(xfun::from_root("output"))
fs::dir_create(xfun::from_root("output"))

# Create for loop to automate report generation --------------------------------
# Create data frame of the combination of all parameter values 
params_df <- expand.grid(unique(labour_force$sex), unique(labour_force$measure),
                         stringsAsFactors = FALSE)  

# Input template report and parameters list to render Rmd reports 
for (i in 1:nrow(params_df)) {
  # Temporarily change wd to ~/code with xfun::in_dir() and render Rmd inside here
  # Avoid using relative path names via here::here() for rmarkdown::render()
  xfun::in_dir(
    "code", 
    rmarkdown::render(
      input = "03_create_report_template.Rmd",
      output_format = rmarkdown::github_document(html_preview = FALSE), 
      params = list(sex = params_df[i, 1],
                    measure = params_df[i, 2]),
      output_file = glue::glue("{params_df[i, 1]}_{params_df[i, 2]}_report.md")
    )
  )
}

# Move output files from ~/code to ~/output ------------------------------------
# Extract all files which do not end in .R or .Rmd in ~/code
code_files <- fs::dir_ls(xfun::from_root("code"),
                         regexp = "\\.R|(Rmd)$", 
                         invert = TRUE)

# Create location of output files in ~/output
output_files <- gsub("code/", "output/", code_files)

fs::file_move(code_files, output_files)