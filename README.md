# ABS labour force report automation   

This repository contains a minimal viable example of an R data visualisation and report generation workflow using ABS labour force open data.   

The contents of this repository have been created to support the [Automating R Markdown report generation - Part 2](https://github.com/erikaduan/r_tips/blob/master/tutorials/p-automating_rmd_reports/p-automating_rmd_reports_part_2.md) tutorial in my [`r_tips`](https://github.com/erikaduan/r_tips) repository.   

## CI/CD automation tips  
+ Use `renv` to manage package version and commit your `renv.lock` file with your repository. The `renv` package will automatically create a second `.gitignore` file in `repository/renv`, which prevents the private project library `renv/library` from being committed.  
+ Load the minimum set of packages required i.e. load `dplyr` instead of `tidyverse` if you are just performing simple data transformations and avoid using `pacman::p_load()`. Use `lapply(packages, library, character.only = TRUE)` as described [here](https://statsandr.com/blog/an-efficient-way-to-install-and-load-r-packages/#more-efficient-way) instead.      
+ The `pandoc` package is not bundled with the `rmarkdown` package (`pandoc` is provided by RStudio) so the correct version of `pandoc` needs to be manually specified.  

    ```
    steps:
      # Checks out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2

      # Sets up pandoc which is required for knitting HTML reports  
      - uses: r-lib/actions/setup-pandoc@v2
        with:
          pandoc-version: '2.17.1' 
    ```

+ I personally prefer running scripts as separate steps, for better job progress monitoring.  

    ```
      # Execute R scripts
      - name: Extract and clean ABS labour force data 
        run: Rscript code/01_extract_and_clean_data.R

      - name: Knit ABS labour force reports
        run: Rscript code/03_automate_reports.R  
    ```

+ In Python, I tend to import packages only once in the import script. It's not clear how this should be done in R when using CI/CD.  

