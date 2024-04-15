
# Final report HTML from R Markdown
final_report.html: final_report.Rmd output/table1.rds output/figure.png code/03_render_report.R
	Rscript code/03_render_report.R

# Import data and create kPMdataLAB and oPMdataLAB datasets
.PHONY: import_data
import_data: derived_data/kPMdataLAB.rds derived_data/oPMdataLAB.rds

derived_data/kPMdataLAB.rds: datasets/k23data.sas7bdat datasets/ohearddata.sas7bdat datasets/formats.sas7bcat code/00_import_data.R
	Rscript code/00_import_data.R

derived_data/oPMdataLAB.rds: datasets/k23data.sas7bdat datasets/ohearddata.sas7bdat datasets/formats.sas7bcat code/00_import_data.R
	Rscript code/00_import_data.R


# Use imported data to create Data1_Demog and Data2_BaseClin datasets
.PHONY: process_data
process_data: derived_data/Data1_Demog.rds derived_data/Data2_BaseClin.rds

derived_data/Data1_Demog.rds: derived_data/kPMdataLAB.rds derived_data/oPMdataLAB.rds code/01_make_datasets.R
	Rscript code/01_make_datasets.R

derived_data/Data2_BaseClin.rds: derived_data/kPMdataLAB.rds derived_data/oPMdataLAB.rds code/01_make_datasets.R
	Rscript code/01_make_datasets.R


# Generate table1 and figure.png from the processed data
output/table1.rds output/figure.png: process_data code/02_make_tables_and_figures.R
	Rscript code/02_make_tables_and_figures.R

# for renv
.PHONY: install
install:
	Rscript -e "renv::restore(prompt=FALSE)"


# Cleanup task for removing all generated files
clean:
	rm -f derived_data/*.rds output/*.rds output/*.png import_data process_data final_report.html
