# ABS labour force report automation   
![](https://img.shields.io/badge/Language-R-blue) ![](https://img.shields.io/badge/Open%20dataset-ABS-brightgreen)

This repository contains a minimal viable example of an R data visualisation and report generation workflow using ABS labour force open data.   

<p align="center">  
<img src="https://github.com/erikaduan/abs_labour_force_report/blob/main/project_workflow.svg"
width="500"></center>  
</p>  

The contents of this repository have been created to support the [Automating R Markdown report generation - Part 2](https://github.com/erikaduan/r_tips/blob/master/tutorials/p-automating_rmd_reports/p-automating_rmd_reports_part_2.md) tutorial in my [`r_tips`](https://github.com/erikaduan/r_tips) repository.   

## Updates  

+ **[May 2025]** [Deprecation of `actions/cache@v1`](https://github.com/actions/cache/discussions/1510`) in March 2025. Initially switched to using `actions/cache@v4` but then discovered [r-lib/actions/setup-renv@v2](https://github.com/r-lib/actions/tree/v2-branch/setup-renv), which installs required R packages from the `renv.lock` file and caches them automatically.   
+ **[May 2025]** Using `r-lib/actions/setup-renv@v2` rendered the previously custom step `Restore R packages` redundant. This step manually ran `renv::restore()` in Rscript.       
+ **[May 2025]** Using `r-lib/actions/setup-renv@v2` rendered the previously custom environment variables in `# Retrieves secrets from GitHub and set renv root path` redundant. I experimented with retaining `env: GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}` but this had no effect on the R package cache (as my Github actions workflow does not deploy automatic code committing or pulling).                   
+ **[May 2025]** Renamed and moved the step `Install libcurl from libcurl4-openssl-dev` to be run before `r-lib/actions/setup-renv@v2` as `libcurl` is a dependency for the R package `curl`.     
+ **[May 2025]** Updated from `actions/checkout@v2` to [`actions/checkout@v4`](https://github.com/actions/checkout).      

## Rmd tips  
+ As referenced in [this GitHub issue](https://github.com/rstudio/rmarkdown/issues/2365), path handling by `rmarkdown::render()` is currently not ideal as the `output_dir` argument creates an absolute path for rendered figures. This can be resolved by using `xfun::in_dir("code", ...)` to render inside `.\code` and then moving the outputs into `.\output`.    

## CI/CD automation tips  
+ Use `renv` to manage package version and commit your `renv.lock` file with your repository. The `renv` package will automatically create a second `.gitignore` file in `~/renv`, which prevents the private project library `~/renv/library` from being committed.  
+ Load the minimum set of packages required i.e. load `dplyr` instead of `tidyverse` if you are just performing simple data transformations and avoid using `pacman::p_load()`.  
+ The package `renv` uses static analysis to determine which packages are used i.e. by scanning your code for calls to `library(pkg)`, `require(pkg)` or `pkg::`. Due to this functionality, avoid mapping package loading with `lapply(packages, library, character.only = TRUE)` as described [here](https://statsandr.com/blog/an-efficient-way-to-install-and-load-r-packages/#more-efficient-way).    

    ```
    # Recommended due to renv static analysis approach 
    library("here")  
    library("readr")  

    # Also recommmended for extra code reproducibility
    here::here(...)
    readr::read_csv(...)
    
    # Not recommended 
    packages <- c("here", "readr")
    invisible(lapply(packages, library, character.only = TRUE))
    ```
+ The first requirement for our Github actions workflow is to check a copy of our Github repository into our temporary virtual environment. Under the hood, git must then be configured to trust this temporary repository as being safe.     

  ```
  steps:
      # Checks out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v4
  ```

+ The `pandoc` package is not bundled with the `rmarkdown` package (`pandoc` is provided by RStudio) so the correct version of `pandoc` needs to be manually specified in the YAML pipeline.    

    ```
    steps:
      # Sets up pandoc which is required for knitting HTML reports  
      - uses: r-lib/actions/setup-pandoc@v2
        with:
          pandoc-version: '2.17.1' 
    ```

+ A virtual R environment needs to first be set up.   

  ```   
  steps:
    - name: Setup R version 4.1.2
      uses: r-lib/actions/setup-r@v2
      with:
        r-version: '4.1.2' 
  ```    

+ The Ubuntu `libcurl` package is a dependency for the R package `curl` and needs to be installed before R packages are installed and cached.  

  ```
  steps:  
    - name: Install libcurl from libcurl4-openssl-dev 
      run: sudo apt-get install -y --no-install-recommends libcurl4-openssl-dev
  ```

+ The simplest method to automatically install R packages and configure them to use the Github cache is to use the action `r-lib/actions/setup-renv@v2` as described [here](https://rstudio.github.io/renv/articles/ci.html). There is an alternate method which uses `r-lib/actions/setup-r-dependencies@v2`. This method does not require `renv` and is useful for R package developers following CRAN package development requirements. An example can be found [here](https://github.com/jdjohn215/milwaukee-weather/blob/main/.github/workflows/UpdateGraphs.yml).       

  ```
  steps:  
    - name: Install and cache R packages
      uses: r-lib/actions/setup-renv@v2
  ```

+ Write scripts that are self-contained. This means using one script to separately load all R libraries should be avoided, to minimise errors in case one job cannot access the outputs of another job.  

+ I personally prefer running scripts as separate steps, for better job progress monitoring.  

    ```
    steps:  
      # Execute R scripts
      - name: Extract data from ABS labour force data API
        run: Rscript code/01_extract_data.R

      - name: Clean raw labour force data
        run: Rscript code/02_clean_data.R  
    ```  