# Code Description

To Synchronize Package Repository:
Open make file & “make” the .PHONY rule install to synchronize R packages to versions used to create project

To create final report, type `make final_report.html` into the terminal.

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