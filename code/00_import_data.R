here::i_am("code/00_import_data.R")


# List of packages
required_packages <- c(
 "gtsummary", "haven", "labelled", 
  "dplyr"
)

# Check and load required packages
for (pkg in required_packages) {
  library(pkg, character.only = TRUE)
}


#### Import data ####

# Define a function to read SAS files more concisely
read_sas_with_format <- function(file_name) {
  absolute_path_to_datasets <- here::here("datasets")
  read_sas(paste0(absolute_path_to_datasets, "/", file_name, ".sas7bdat"),
           paste0(absolute_path_to_datasets, "/formats.sas7bcat"))
}

# Import K23 data
k23data <- read_sas_with_format("k23data")
k23issues <- read_sas_with_format("k23issues")
k23households <- read_sas_with_format("k23households")
k23dataLAB <- k23data %>% haven::as_factor() %>% labelled::to_factor() 
            

# Import OHEaRD data
oheard <- read_sas_with_format("ohearddata") %>% filter(VISIT == 1, LOCATION == 2)
oheardissues <- read_sas_with_format("oheardissues") %>% filter(VISIT == 1) %>%
  filter(SID %in% oheard$SID)
oheardhouseholds <- read_sas_with_format("oheardhouseholds")
oheardLAB <- oheard %>% haven::as_factor() %>% labelled::to_factor()


#### Pre-Process Data ####

# Define a function to process issues datasets
process_issues <- function(data) {
  data %>% 
    as_factor() %>% 
    to_factor() %>%
    rename_with(toupper) %>%
    mutate(TIME_OF_DAY = replace(TIME_OF_DAY, TIME_OF_DAY == "", "BLday"))
}

# Apply the function to datasets
k23issues <- process_issues(k23issues)
oheardissues <- process_issues(oheardissues)

# Define a function for creating PM and AM datasets and processing them
create_time_subset <- function(data, time_of_day, additional_processing = NULL) {
  subsetted_data <- subset(data, TIME_OF_DAY %in% time_of_day)
  
  if (!is.null(additional_processing)) {
    subsetted_data <- additional_processing(subsetted_data)
  }
  
  subsetted_data %>% 
    as_factor() %>% 
    to_factor()
}

# Additional processing for PM data
process_PM_data <- function(data) {
  data %>%
    mutate(EDUCATION2 = ifelse(EDUCATIONN >= 12, ">= 12 years", "<12 years"),
           BMI = round(BMI, 2))
}

# Create PM and AM datasets
kPMdataLAB <- create_time_subset(k23data, c("pm", ""), process_PM_data)
oPMdataLAB <- create_time_subset(oheard, c("pm", ""), process_PM_data)

kAMdataLAB <- create_time_subset(k23data, "am")
oAMdataLAB <- create_time_subset(oheard, "am")



#### SAVE THE DATA #### 
# List of datasets and their corresponding file names
datasets <- list(kPMdataLAB = "kPMdataLAB", oPMdataLAB = "oPMdataLAB")

# Loop through the list and save each dataset
for (name in names(datasets)) {
  saveRDS(get(name), file = here::here(paste0("derived_data/", datasets[[name]], ".rds")))
}




