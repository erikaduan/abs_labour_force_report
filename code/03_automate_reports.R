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
              "glue",
              "xfun",
              "fs") 

installed_packages <- packages %in% rownames(installed.packages())

# Install new packages
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Load packages individually for detection by renv 
library("here")
library("readr")
library("stringr")
library("clock")
library("dplyr")
library("ggplot2")
library("rmarkdown")
library("knitr")
library("magrittr")
library("glue")
library("xfun")
library("fs")

# Load clean data --------------------------------------------------------------  
labour_force <- readr::read_csv(here("data",
                                     "clean_data",
                                     "labour_force_clean.csv"))    

# Empty ~/output folder to recreate reports ------------------------------------
fs::dir_delete(xfun::from_root("output"))
fs::dir_create(xfun::from_root("output"))

# Create for loop to automate report generation --------------------------------
# Create data frame of the dot product of all parameter values 
params_df <- expand.grid(unique(labour_force$sex), unique(labour_force$measure),
                         stringsAsFactors = FALSE)  

# Input template report and parameters list to render Rmd reports 
for (i in 1:nrow(params_df)) {
  # Temporarily change wd to ~/code with xfun::in_dir() and render Rmd inside
  # Avoid inputting relative path names using here::here() with render()
  xfun::in_dir(
    "code", 
    rmarkdown::render(
      input = "02_create_report_template.Rmd",
      output_format = github_document(html_preview = FALSE), 
      params = list(sex = params_df[i, 1],
                    measure = params_df[i, 2]),
      output_file = glue::glue("{params_df[i, 1]}_{params_df[i, 2]}_report.md")
    )
  )
}

# Move output files from ~/code to ~/output
# Extract all files which do not end in .R or .Rmd
code_files <- fs::dir_ls(xfun::from_root("code"),
                         regexp = "\\.R|(Rmd)$", 
                         invert = TRUE)

# Create location of output files
output_files <- gsub("code/", "output/", code_files)

# Move output files into ~/output 
fs::file_move(code_files, output_files)