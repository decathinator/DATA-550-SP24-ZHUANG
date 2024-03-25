final_report.html: final_report.Rmd output/table1.rds output/figure.png code/03_render_report.R
	Rscript code/03_render_report.R

derived_data/kPMdataLAB.rds derived_data/oPMdataLAB.rds&: \ 
	datasets/k23data.sas7bdat datasets/ohearddata.sas7bdat datasets/formats.sas7bcat
	Rscript code/00_import_data.R
	
	
derived_data/Data1_Demog.rds derived_data/Data2_BaseClin.rds&: \
	derived_data/kPMdataLAB.rds derived_data/oPMdataLAB.rds
	Rscript code/01_make_datasets.R

output/table1.rds output/figure.png&: \
	derived_data/Data1_Demog.rds derived_data/Data2_BaseClin.rds
	Rscript code/02_make_tables_and_figures.R