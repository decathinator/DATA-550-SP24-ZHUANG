# Define phony targets for cleanliness
.PHONY: all clean data reports

# Default target
all: final_report.html

# Final report HTML from R Markdown
final_report.html: final_report.Rmd output/table1.rds output/figure.png code/03_render_report.R
	Rscript code/03_render_report.R

# Import data and create kPMdataLAB and oPMdataLAB datasets
import_data: datasets/k23data.sas7bdat datasets/ohearddata.sas7bdat datasets/formats.sas7bcat code/00_import_data.R
	Rscript code/00_import_data.R

# Use imported data to create Data1_Demog and Data2_BaseClin datasets
process_data: import_data code/01_make_datasets.R
	Rscript code/01_make_datasets.R

# Generate table1 and figure.png from the processed data
output/table1.rds output/figure.png: process_data code/02_make_tables_and_figures.R
	Rscript code/02_make_tables_and_figures.R

# Cleanup task for removing all generated files
clean:
	rm -f derived_data/*.rds output/*.rds output/*.png import_data process_data final_report.html
