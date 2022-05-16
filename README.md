# ABS labour force report automation   

This repository contains a minimal viable example of an R data visualisation and report generation workflow using ABS labour force open data.   

The contents of this repository have been created to support the [Automating R Markdown report generation - Part 2](https://github.com/erikaduan/r_tips/blob/master/tutorials/p-automating_rmd_reports/p-automating_rmd_reports_part_2.md) tutorial in my [`r_tips`](https://github.com/erikaduan/r_tips) repository.   

## CI/CD automation tips  
+ Use `renv` to manage package version and commit your `renv.lock` file with your repository. The `renv` package will automatically create a second `.gitignore` file in `repository/renv`, which prevents the private project library `renv/library` from being committed.  
+ Load the minimum set of packages required i.e. load `dplyr` instead of `tidyverse` if you are just performing simple data transformations.  
+ I personally prefer running scripts as separate steps, for better job progress monitoring. 
+ In Python, I tend to import packages only once in the import script. It's not clear how this should be done in R when using CI/CD.     