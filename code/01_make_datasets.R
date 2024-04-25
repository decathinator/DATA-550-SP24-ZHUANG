here::i_am("code/01_make_datasets.R")

# List of packages
required_packages <- c(
  "dplyr"
)

# Check and load required packages
for (pkg in required_packages) {
  library(pkg, character.only = TRUE)
}


# List of datasets and their corresponding file names
datasets <- list(kPMdataLAB = "kPMdataLAB", oPMdataLAB = "oPMdataLAB")

# Loop through the list and load each dataset
for (name in names(datasets)) {
  # Construct the file path
  file_path <- here::here("derived_data", paste0(datasets[[name]], ".rds"))
  
  # Read the RDS file
  dataset <- readRDS(file = file_path)
  
  # Dynamically assign the dataset to a variable with the name specified in 'names(datasets)'
  assign(x = name, value = dataset, envir = .GlobalEnv)
}


#### Dataset 1 Demographics ####
kData1_Demog <- kPMdataLAB %>% 
  select(
    VISIT, SID, AGE, SEX, MARITAL_STATUS, EDUCATION2,
    NATIONALITY, INDIGENOUS,
    LANGUAGE_ENGLISH, LANGUAGE_SPANISH, 
    AGRI_START, AGRI_YRS_IN_SOUTH
  )
oData1_Demog <- oPMdataLAB %>% 
  select(
    VISIT, SID, AGE, SEX, MARITAL_STATUS, EDUCATION2,
    NATIONALITY, INDIGENOUS,
    LANGUAGE_ENGLISH, LANGUAGE_SPANISH, 
    AGRI_START, AGRI_YRS_IN_SOUTH
  ) %>%
  mutate(MARITAL_STATUS = recode(MARITAL_STATUS, `2` = "Single", `1` = "Coupled"))
Data1_Demog <- rbind(kData1_Demog, oData1_Demog) %>%
  mutate(NATIONALITY = recode(NATIONALITY, 'dk' = "Don't Know"))%>%
  mutate(NATIONALITY = recode(NATIONALITY, 'refused' = "Refused"))%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))

#### Dataset 2 Baseline Clinical ####
kData2_BaseClin <- kPMdataLAB %>%
  select(
    VISIT, SID, BMI, BMICAT, BFAT, A1C, A1C_CAT, BP_SYSTOLIC_BL, BP_DIASTOLIC_BL, 
    BP_3CAT_BL, BP_5CAT_BL, HR_RESTING_BL, 
    CHOLESTEROL, CHOLESTEROL_3CAT, HDL, HDL_3CAT, 
    TRIGLYCERIDES, TRIGLYCERIDES_4CAT, LDL_5CAT
  )
oData2_BaseClin <- oPMdataLAB %>%
  select(
    VISIT, SID, BMI, BMICAT, BFAT, A1C, A1C_CAT, BP_SYSTOLIC_BL, BP_DIASTOLIC_BL, 
    BP_3CAT_BL, BP_5CAT_BL, HR_RESTING_BL, 
    CHOLESTEROL, CHOLESTEROL_3CAT, HDL, HDL_3CAT, 
    TRIGLYCERIDES, TRIGLYCERIDES_4CAT, LDL_5CAT
  )
Data2_BaseClin <- rbind(kData2_BaseClin, oData2_BaseClin)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))



#### SAVE THE DATA #### 
# List of datasets and their corresponding file names
datasets <- list(Data1_Demog = "Data1_Demog", Data2_BaseClin = "Data2_BaseClin"
                 )
# Loop through the list and save each dataset
for (name in names(datasets)) {
  saveRDS(get(name), file = here::here(paste0("derived_data/", datasets[[name]], ".rds")))
}





