# Data 550 Final Project Spring 2024  

   
## Creating the Report    
There are two methods in which you can create the report: 

- Locally:  
1. Make sure you have `make` and `R` installed
2. Make sure you have `renv` R package installed  
3. Open a terminal in the project directory  
4. Type `make install` to restore the R package environment using `renv`  
5. Type `make final_report.html` to compile the final report   

OR 

- Using Docker:  
1. Pull the image from [this link (my image on DockerHub)](https://hub.docker.com/repository/docker/decathinator/data-550-sp24-zhuang/general)   
2. Type `make mount-report` in the terminal (This step works for both Windows-OS and a Mac/Linux-OS)  
3. The compiled report should be in your local `\report` folder  
  
   
## Makefile

The following commands can be typed into the terminal:

`make final_report.html` will compile the report

`make import_data` will do the first step in processing data (by running `code/00_import_data.R`)

`make process_data` will do the second step in processing data (by running `code/01_make_datasets.R`)

`make install` will restore the R package environment with `renv`

`make clean` will clear the outputs

`make mount-report` will compile the report


## Code Description

`code/00_import_data.R`
- imports data
- saves two files for the two cohorts: `kPMdataLAB` and `oPMdataLAB` as `.rds` files in the folder `derived_data`
- we will clean this data further in the next step

`code/01_make_datasets.R`
- reads datasets saved by `code/00_import_data.R`
- cleans up data and sorts the needed variables into two datasets
- saves two datasets needed for output later: `Data1_Demog` and `Data2_BaseClin` as `.rds` files in the folder `derived_data`
- the first dataset serves as the dataset for the table
- the second dataset serves as the dataset for the figure

`code/02_make_tables_and_figures.R`
- reads datasets saved by `code/01_make_datasets.R`
- makes table using `Data1_Demog.rds` and saves as `table1.rds` in `output/`
- makes figure using `Data2_BaseClin.rds` and saves as `figure.png` in `output/`

`code/03_render_report.R`
- renders `final_report.Rmd` into an html file

`final_report.Rmd`
- loads `table1.rds` in `output/` and `figure.png` in `output/`
- displays the table and figure along with text/descriptions/intro/etc.