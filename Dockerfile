FROM rocker/r-ubuntu as base 

RUN apt-get update
RUN apt-get install -y pandoc

RUN mkdir /report
WORKDIR /report

RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE renv/.cache

RUN R -e "renv::restore()"

###### DO NOT EDIT STAGE 1 BUILD LINES ABOVE ######

FROM rocker/r-ubuntu
RUN apt-get update
RUN apt-get install -y pandoc # Ensure Pandoc is installed in the final image


WORKDIR /report
COPY --from=base /report .

COPY Makefile .
COPY final_report.Rmd .

RUN mkdir code 
RUN mkdir output 
RUN mkdir derived_data 
RUN mkdir datasets 
RUN mkdir final_report

RUN touch code/.keep 
RUN touch output/.keep 
RUN touch derived_data/.keep 
RUN touch datasets/.keep 
RUN touch final_report/.keep


COPY datasets/k23data.sas7bdat datasets/k23data.sas7bdat
COPY datasets/k23households.sas7bdat datasets/k23households.sas7bdat
COPY datasets/k23issues.sas7bdat datasets/k23issues.sas7bdat
COPY datasets/ohearddata.sas7bdat datasets/ohearddata.sas7bdat
COPY datasets/oheardhouseholds.sas7bdat datasets/oheardhouseholds.sas7bdat
COPY datasets/oheardissues.sas7bdat datasets/oheardissues.sas7bdat
COPY datasets/formats.sas7bcat datasets/formats.sas7bcat

COPY code/00_import_data.R code/00_import_data.R
COPY code/01_make_datasets.R code/01_make_datasets.R
COPY code/02_make_tables_and_figures.R code/02_make_tables_and_figures.R
COPY code/03_render_report.R code/03_render_report.R

CMD make final_report.html
