here::i_am("code/01_make_datasets.R")

# List of packages
required_packages <- c(
  "gtsummary", "haven", "flextable", "labelled", "naniar", "pcaMethods", "ISLR", "pls", "glmnet", 
  "FactoMineR", "factoextra", "car", "corrplot", "VIM", "mice",  "quantreg", "lqr","tidyverse", "dplyr"
)

# Check and load required packages
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}


# List of datasets and their corresponding file names
datasets <- list(k23data = "k23data", k23dataLAB = "k23dataLAB", k23issues = "k23issues",
                 k23households = "k23households", kAMdataLAB = "kAMdataLAB",
                 kPMdataLAB = "kPMdataLAB", oheard = "oheard", 
                 oheardLAB = "oheardLAB", oheardissues = "oheardissues", 
                 oheardhouseholds = "oheardhouseholds", 
                 oAMdataLAB = "oAMdataLAB", oPMdataLAB = "oPMdataLAB")

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


#### Dataset 3 Urine ####

# K23
kData3_URINE_AM <- k23dataLAB %>%
  filter(TIME_OF_DAY == "am") %>%
  select(
    VISIT, SID, URINE_GLUCOSE, URINE_BILIRUBIN, URINE_KETONES,
    URINE_BLOOD, URINE_PH, URINE_PROTEIN, URINE_UROBILIRUBIN, URINE_NITRATES,
    URINE_LEUKOCYTES, URINE_SG_ATAGO
  ) %>%
  rename(USG_ATAGO = URINE_SG_ATAGO) 

kData3_URINE_PM <- k23dataLAB %>%
  filter(TIME_OF_DAY == "pm") %>%
  select(
    VISIT, SID, URINE_GLUCOSE, URINE_BILIRUBIN, URINE_KETONES,
    URINE_BLOOD, URINE_PH, URINE_PROTEIN, URINE_UROBILIRUBIN, URINE_NITRATES,
    URINE_LEUKOCYTES, URINE_SG_ATAGO, USG_ATAGO_DIFF
  ) %>%
  rename(USG_ATAGO = URINE_SG_ATAGO) 

# Combine AM and PM URINE data
kData3_URINE <- full_join(kData3_URINE_AM, kData3_URINE_PM, by = c("VISIT", "SID"), suffix = c("_am", "_pm"))


# Create USG_AM_GE1020 and USG_PM_GE1020 columns
kData3_URINE$USG_AM_GE1020 <- if_else(kData3_URINE$USG_ATAGO_am < 1.020, 0, 1)
kData3_URINE$USG_PM_GE1020 <- if_else(kData3_URINE$USG_ATAGO_pm < 1.020, 0, 1)

# Reorder columns
kData3_URINE <- kData3_URINE[, c(1, 2, 3, 13, 4, 14, 5, 15, 6, 16, 7, 17, 8, 18, 9, 19, 10, 20, 11, 21, 12, 22, 23, 24, 25)]

# OHEARD
oData3_URINE <- oheardLAB%>%
  select(
    VISIT, SID, URINE_GLUCOSE, URINE_BILIRUBIN, URINE_KETONES,
    URINE_BLOOD, URINE_PH, URINE_PROTEIN, URINE_UROBILIRUBIN, URINE_NITRATES,
    URINE_LEUKOCYTES, USG_ATAGO_AM, USG_ATAGO_PM, USG_ATAGO_DIFF
  ) %>%
  rename(USG_ATAGO_am = USG_ATAGO_AM, USG_ATAGO_pm=USG_ATAGO_PM, URINE_GLUCOSE_pm=URINE_GLUCOSE, 
         URINE_BILIRUBIN_pm=URINE_BILIRUBIN, URINE_KETONES_pm=URINE_KETONES,
         URINE_BLOOD_pm=URINE_BLOOD, URINE_PH_pm=URINE_PH, URINE_PROTEIN_pm=URINE_PROTEIN, 
         URINE_UROBILIRUBIN_pm=URINE_UROBILIRUBIN, URINE_NITRATES_pm=URINE_NITRATES,
         URINE_LEUKOCYTES_pm=URINE_LEUKOCYTES) 

# Create USG_AM_GE1020 and USG_PM_GE1020 columns
oData3_URINE$USG_AM_GE1020 <- if_else(oData3_URINE$USG_ATAGO_am < 1.020, 0, 1)
oData3_URINE$USG_PM_GE1020 <- if_else(oData3_URINE$USG_ATAGO_pm < 1.020, 0, 1)


# ALL SETS
Data3_URINE <- plyr::rbind.fill(kData3_URINE, oData3_URINE)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))
# Data3_URINE_PM <- rbind(kData3_URINE_PM, oData3_URINE_PM)%>%
#   mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))
# Data3_URINE_AM <- rbind(kData3_URINE_AM, oData3_URINE_AM)%>%
#   mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))


#### Dataset 4 AKI ####  
kData4_AKI <- k23dataLAB %>%  
  filter(TIME_OF_DAY == "pm") %>%
  select(VISIT, SID, AKI_STG, AKI_YN)  
oData4_AKI <- oheard %>%  
  filter(TIME_OF_DAY == "pm") %>%
  select(VISIT, SID, AKI_STG, AKI_YN)
Data4_AKI <- rbind(kData4_AKI, oData4_AKI)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))


#### Dataset 5 Blood/Serum ####
kData5_SERUM_AM <- k23dataLAB %>%
  filter(TIME_OF_DAY == "am") %>%
  select(
    VISIT, SID, SERUM_SODIUM, SERUM_POTASSIUM, SERUM_CL, SERUM_ICA, SERUM_TCO2, SERUM_GLUCOSE, SERUM_BUN, SERUM_CREATININE, 
    SERUM_HEMATOCRIT, SERUM_HEMOGLOBIN, SERUM_ANGAP
  )

kData5_SERUM_PM <- k23dataLAB %>%
  filter(TIME_OF_DAY == "pm") %>%
  select(
    VISIT, SID, EGFR_AM, EGFR_PM, EGFR_DIFF, SERUM_SODIUM, SODIUM_DIFF, SERUM_POTASSIUM, POTASSIUM_DIFF, SERUM_CL, SERUM_ICA, SERUM_TCO2, 
    SERUM_GLUCOSE, SERUM_BUN, BUN_DIFF, SERUM_CREATININE, CREATININE_DIFF,
    CREATININE_GT1, RATIO_CREATININE_POSTPRE, 
    SERUM_HEMATOCRIT, SERUM_HEMOGLOBIN, SERUM_ANGAP,  
    SERUM_OSM_MC_PM, SERUM_OSM_MC_DIFF, NCRATIO_PM, NCRATIO_DIFF
  )

kData5_SERUM <- full_join(kData5_SERUM_AM, kData5_SERUM_PM, by = c("VISIT", "SID"), suffix = c("_am", "_pm"))

kData5_SERUM <- select(kData5_SERUM, 
                       VISIT, SID, EGFR_AM, EGFR_PM, EGFR_DIFF, 
                       SERUM_CREATININE_am, SERUM_CREATININE_pm, CREATININE_DIFF
                       # SERUM_SODIUM_am, SERUM_SODIUM_pm, SODIUM_DIFF, SERUM_POTASSIUM_am, SERUM_POTASSIUM_pm, POTASSIUM_DIFF, 
                       # SERUM_CL_am, SERUM_CL_pm, SERUM_ICA_am, SERUM_ICA_pm, SERUM_TCO2_am, SERUM_TCO2_pm, 
                       # SERUM_GLUCOSE_am, SERUM_GLUCOSE_pm, SERUM_BUN_am,  SERUM_BUN_pm, BUN_DIFF, 
                       #  RATIO_CREATININE_POSTPRE, 
                       # SERUM_HEMATOCRIT_am, SERUM_HEMATOCRIT_pm, SERUM_HEMOGLOBIN_am, SERUM_HEMOGLOBIN_pm, SERUM_ANGAP_am, SERUM_ANGAP_pm, 
                       # SERUM_OSM_MC_PM, SERUM_OSM_MC_DIFF, NCRATIO_PM, NCRATIO_DIFF
)


oData5_SERUM <- oheardLAB %>%
  select(
    VISIT, SID, EGFR_AM, EGFR_PM, EGFR_DIFF, CREATININE_AM, CREATININE_PM, CREATININE_DIFF
  ) %>%
  rename(SERUM_CREATININE_am=CREATININE_AM, SERUM_CREATININE_pm=CREATININE_PM, CREATININE_DIFF=CREATININE_DIFF)

Data5_SERUM <- rbind(kData5_SERUM, oData5_SERUM)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))
# Data5_SERUM_AM <- rbind(kData5_SERUM_AM, oData5_SERUM_AM)%>%
#   mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))
# Data5_SERUM_PM <- rbind(kData5_SERUM_PM, oData5_SERUM_PM)%>%
#   mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))


#### Dataset 6 Beverages on Workday ####
kData6_WorkdayBev = kPMdataLAB %>% 
  select(VISIT, SID, WATER_TOT, COFFEE_TOT, TEA_TOT, JUICE_TOT, SPORTSDRINK_TOT, SODA_TOT, DSODA_TOT, 
         ENERGY_DRINK_TOT, ALCOHOL_TOT, SUGARY_TOT, BEVERAGES_TOT)
#make y/n for each beverage
kData6_WorkdayBev$WATER_YN[kData6_WorkdayBev$WATER_TOT==0]<-"No"
kData6_WorkdayBev$WATER_YN[kData6_WorkdayBev$WATER_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$WATER_YN)="Reported Drinking: WATER"

kData6_WorkdayBev$COFFEE_YN[kData6_WorkdayBev$COFFEE_TOT==0]<-"No"
kData6_WorkdayBev$COFFEE_YN[kData6_WorkdayBev$COFFEE_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$COFFEE_YN)="Reported Drinking: COFFEE"

kData6_WorkdayBev$TEA_YN[kData6_WorkdayBev$TEA_TOT==0]<-"No"
kData6_WorkdayBev$TEA_YN[kData6_WorkdayBev$TEA_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$TEA_YN)="Reported Drinking: TEA"

kData6_WorkdayBev$JUICE_YN[kData6_WorkdayBev$JUICE_TOT==0]<-"No"
kData6_WorkdayBev$JUICE_YN[kData6_WorkdayBev$JUICE_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$JUICE_YN)="Reported Drinking: JUICE"

kData6_WorkdayBev$SPORTSDRINK_YN[kData6_WorkdayBev$SPORTSDRINK_TOT==0]<-"No"
kData6_WorkdayBev$SPORTSDRINK_YN[kData6_WorkdayBev$SPORTSDRINK_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$SPORTSDRINK_YN)="Reported Drinking: SPORTSDRINK"

kData6_WorkdayBev$SODA_YN[kData6_WorkdayBev$SODA_TOT==0]<-"No"
kData6_WorkdayBev$SODA_YN[kData6_WorkdayBev$SODA_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$SODA_YN)="Reported Drinking: SODA"

kData6_WorkdayBev$DSODA_YN[kData6_WorkdayBev$DSODA_TOT==0]<-"No"
kData6_WorkdayBev$DSODA_YN[kData6_WorkdayBev$DSODA_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$DSODA_YN)="Reported Drinking: DSODA"

kData6_WorkdayBev$ENERGY_DRINK_YN[kData6_WorkdayBev$ENERGY_DRINK_TOT==0]<-"No"
kData6_WorkdayBev$ENERGY_DRINK_YN[kData6_WorkdayBev$ENERGY_DRINK_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$ENERGY_DRINK_YN)="Reported Drinking: ENERGY_DRINK"

kData6_WorkdayBev$ALCOHOL_YN[kData6_WorkdayBev$ALCOHOL_TOT==0]<-"No"
kData6_WorkdayBev$ALCOHOL_YN[kData6_WorkdayBev$ALCOHOL_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$ALCOHOL_YN)="Reported Drinking: ALCOHOL"

kData6_WorkdayBev$SUGARY_YN[kData6_WorkdayBev$SUGARY_TOT==0]<-"No"
kData6_WorkdayBev$SUGARY_YN[kData6_WorkdayBev$SUGARY_TOT>0]<-"Yes"
var_label(kData6_WorkdayBev$SUGARY_YN)="Reported Drinking: SUGARY DRINKS"

#re-order
kData6_WorkdayBev=kData6_WorkdayBev %>%
  select(VISIT, SID, WATER_TOT, WATER_YN,COFFEE_TOT, COFFEE_YN,TEA_TOT, TEA_YN,JUICE_TOT, JUICE_YN,
         SPORTSDRINK_TOT,SPORTSDRINK_YN,SODA_TOT, SODA_YN,	DSODA_TOT, DSODA_YN,ENERGY_DRINK_TOT,ENERGY_DRINK_YN,ALCOHOL_TOT, ALCOHOL_YN,
         SUGARY_TOT, SUGARY_YN,BEVERAGES_TOT)


oData6_WorkdayBev = oPMdataLAB %>% 
  select(VISIT, SID, WATER_TOT, COFFEE_TOT, TEA_TOT, JUICE_TOT, SPORTSDRINK_TOT, SODA_TOT, DSODA_TOT, 
         ENERGY_DRINK_TOT, ALCOHOL_TOT, SUGARY_TOT, BEVERAGES_TOT)
#make y/n for each beverage
oData6_WorkdayBev$WATER_YN[oData6_WorkdayBev$WATER_TOT==0]<-"No"
oData6_WorkdayBev$WATER_YN[oData6_WorkdayBev$WATER_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$WATER_YN)="Reported Drinking: WATER"

oData6_WorkdayBev$COFFEE_YN[oData6_WorkdayBev$COFFEE_TOT==0]<-"No"
oData6_WorkdayBev$COFFEE_YN[oData6_WorkdayBev$COFFEE_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$COFFEE_YN)="Reported Drinking: COFFEE"

oData6_WorkdayBev$TEA_YN[oData6_WorkdayBev$TEA_TOT==0]<-"No"
oData6_WorkdayBev$TEA_YN[oData6_WorkdayBev$TEA_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$TEA_YN)="Reported Drinking: TEA"

oData6_WorkdayBev$JUICE_YN[oData6_WorkdayBev$JUICE_TOT==0]<-"No"
oData6_WorkdayBev$JUICE_YN[oData6_WorkdayBev$JUICE_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$JUICE_YN)="Reported Drinking: JUICE"

oData6_WorkdayBev$SPORTSDRINK_YN[oData6_WorkdayBev$SPORTSDRINK_TOT==0]<-"No"
oData6_WorkdayBev$SPORTSDRINK_YN[oData6_WorkdayBev$SPORTSDRINK_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$SPORTSDRINK_YN)="Reported Drinking: SPORTSDRINK"

oData6_WorkdayBev$SODA_YN[oData6_WorkdayBev$SODA_TOT==0]<-"No"
oData6_WorkdayBev$SODA_YN[oData6_WorkdayBev$SODA_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$SODA_YN)="Reported Drinking: SODA"

oData6_WorkdayBev$DSODA_YN[oData6_WorkdayBev$DSODA_TOT==0]<-"No"
oData6_WorkdayBev$DSODA_YN[oData6_WorkdayBev$DSODA_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$DSODA_YN)="Reported Drinking: DSODA"

oData6_WorkdayBev$ENERGY_DRINK_YN[oData6_WorkdayBev$ENERGY_DRINK_TOT==0]<-"No"
oData6_WorkdayBev$ENERGY_DRINK_YN[oData6_WorkdayBev$ENERGY_DRINK_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$ENERGY_DRINK_YN)="Reported Drinking: ENERGY_DRINK"

oData6_WorkdayBev$ALCOHOL_YN[oData6_WorkdayBev$ALCOHOL_TOT==0]<-"No"
oData6_WorkdayBev$ALCOHOL_YN[oData6_WorkdayBev$ALCOHOL_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$ALCOHOL_YN)="Reported Drinking: ALCOHOL"

oData6_WorkdayBev$SUGARY_YN[oData6_WorkdayBev$SUGARY_TOT==0]<-"No"
oData6_WorkdayBev$SUGARY_YN[oData6_WorkdayBev$SUGARY_TOT>0]<-"Yes"
var_label(oData6_WorkdayBev$SUGARY_YN)="Reported Drinking: SUGARY DRINKS"

#re-order
oData6_WorkdayBev=oData6_WorkdayBev %>%
  select(VISIT, SID, WATER_TOT, WATER_YN,COFFEE_TOT, COFFEE_YN,TEA_TOT, TEA_YN,JUICE_TOT, JUICE_YN,
         SPORTSDRINK_TOT,SPORTSDRINK_YN,SODA_TOT, SODA_YN,	DSODA_TOT, DSODA_YN,ENERGY_DRINK_TOT,ENERGY_DRINK_YN,ALCOHOL_TOT, ALCOHOL_YN,
         SUGARY_TOT, SUGARY_YN,BEVERAGES_TOT)	

Data6_WorkdayBev <- rbind(kData6_WorkdayBev,oData6_WorkdayBev)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))


#### Dataset 7 Type/Movement during Observed Workday ####
kData7_WorkdayType <- kPMdataLAB %>% 
  select( VISIT, SID,
          WORKTYPE_TODAY, WORKTYPE_TODAY_AGRI_OTHERSP, WORKTYPE_TODAY_NOAGRI_OTHERSP, WORK_ENVIRONMENT_TODAY_OUTSIDE,
          WORK_ENVIRONMENT_TODAY_SHADECL, WORK_ENVIRONMENT_TODAY_NONAIRWH, WORK_ENVIRONMENT_TODAY_GH, WORK_ENVIRONMENT_TODAY_AIRWH,
          VENTILATION_TODAY_FANS, VENTILATION_TODAY_AC, VENTILATION_TODAY_NONE, WORK_TASKS_TODAY_CUTTING, WORK_TASKS_TODAY_LOADING,
          WORK_TASKS_TODAY_MOVEPLANTS, WORK_TASKS_TODAY_WATERING, WORK_TASKS_TODAY_POTTING, WORK_TASKS_TODAY_WEEDING,
          WORK_TASKS_TODAY_SOWING, WORK_TASKS_TODAY_WASHING, WORK_TASKS_TODAY_CLEANAREA, WORK_TASKS_TODAY_OTHER, WORK_MOVEMENT_TODAY_WALKING,
          WORK_MOVEMENT_TODAY_STANDING, WORK_MOVEMENT_TODAY_STOOPING, WORK_MOVEMENT_TODAY_LIFTING, WORK_MOVEMENT_TODAY_SITTING,
          WORK_MOVEMENT_TODAY_SQUATTING, WORK_MOVEMENT_TODAY_OTHER, WORK_SUPERVISOR_TODAY, WORK_MACHINERY_TODAY,
          BREAK_LUNCH_TODAY,
          BREAKS_ADD_TODAY,
          BREAKS_ADD_NO_TODAY,
          URINATED_TODAY,
          BREAK_LUNCH_MINUTES,
          WORK_DURATION_HRS, HR_Median, hr_ge80pct, Activity_Mean, activity_ge80pct
  ) %>% 
  mutate_if(is.factor, as.character) %>%
  rename(HR_MEDIAN = HR_Median) %>%
  rename(HR_GE80PCT = hr_ge80pct) %>%
  rename(ACTIVITY_MEAN=Activity_Mean, ACTIVITY_GE80PCT=activity_ge80pct)

oData7_WorkdayType <- oPMdataLAB %>% 
  select( VISIT,SID,
          WORKTYPE_TODAY, WORKTYPE_TODAY_AGRI_OTHERSP, WORKTYPE_TODAY_NOAGRI_OTHERSP, WORK_ENVIRONMENT_TODAY_OUTSIDE,
          WORK_ENVIRONMENT_TODAY_SHADECL, WORK_ENVIRONMENT_TODAY_NONAIRWH, WORK_ENVIRONMENT_TODAY_GH, WORK_ENVIRONMENT_TODAY_AIRWH,
          VENTILATION_TODAY_FANS, VENTILATION_TODAY_AC, VENTILATION_TODAY_NONE, WORK_TASKS_TODAY_CUTTING, WORK_TASKS_TODAY_LOADING,
          WORK_TASKS_TODAY_MOVEPLANTS, WORK_TASKS_TODAY_WATERING, WORK_TASKS_TODAY_POTTING, WORK_TASKS_TODAY_WEEDING,
          WORK_TASKS_TODAY_SOWING, WORK_TASKS_TODAY_WASHING, WORK_TASKS_TODAY_CLEANAREA, WORK_TASKS_TODAY_OTHER, WORK_MOVEMENT_TODAY_WALKING,
          WORK_MOVEMENT_TODAY_STANDING, WORK_MOVEMENT_TODAY_STOOPING, WORK_MOVEMENT_TODAY_LIFTING, WORK_MOVEMENT_TODAY_SITTING,
          WORK_MOVEMENT_TODAY_SQUATTING, WORK_MOVEMENT_TODAY_OTHER, WORK_SUPERVISOR_TODAY, WORK_MACHINERY_TODAY,
          BREAK_LUNCH_TODAY,
          BREAKS_ADD_TODAY,
          BREAKS_ADD_NO_TODAY,
          URINATED_TODAY,
          BREAK_LUNCH_MINUTES,
          WORK_DURATION_HRS, HR_MEDIAN, HR_GE80PCT, ACTIVITY_MEAN, ACTIVITY_GE80PCT)%>% 
  mutate_if(is.factor, as.character) 

Data7_WorkdayType <- rbind(kData7_WorkdayType, oData7_WorkdayType) %>% mutate_if(is.character, as.factor) %>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed")) %>% 
  mutate(NEW_HR_MEDIAN = case_when(
    HR_GE80PCT == 1 ~ HR_MEDIAN,
    TRUE ~ NA_real_  # Default case, could be another value
  )) %>%
  mutate(NEW_ACTIVITY_MEAN = case_when(
    ACTIVITY_GE80PCT == 1 ~ ACTIVITY_MEAN,
    TRUE ~ NA_real_  # Default case, could be another value
  ))


#### Dataset 8 HRI Symptoms ####
kData8_HRI <- kPMdataLAB %>%
  select(  VISIT,SID,
           SYMP_SWEAT_TODAY, SYMP_HEADACHE_TODAY, SYMP_NAUSEA_TODAY, SYMP_CONFUSION_TODAY, SYMP_DIZZY_TODAY, 
           SYMP_FAINT_TODAY, SYMP_CRAMP_TODAY, SYMP_DYSURIA_TODAY, SYMP_OTHER_TODAY_SPECIFY)
oData8_HRI <- oPMdataLAB %>%
  select( VISIT,SID,
          SYMP_SWEAT_TODAY, SYMP_HEADACHE_TODAY, SYMP_NAUSEA_TODAY, SYMP_CONFUSION_TODAY, SYMP_DIZZY_TODAY, 
          SYMP_FAINT_TODAY, SYMP_CRAMP_TODAY, SYMP_DYSURIA_TODAY, SYMP_OTHER_TODAY_SPECIFY)
Data8_HRI <- rbind(kData8_HRI, oData8_HRI)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed")) %>%
  mutate(SYMPSUM_TODAY = rowSums(select(., SYMP_HEADACHE_TODAY, 
                                        SYMP_NAUSEA_TODAY, 
                                        SYMP_CONFUSION_TODAY, 
                                        SYMP_DIZZY_TODAY, 
                                        SYMP_FAINT_TODAY, 
                                        SYMP_CRAMP_TODAY, 
                                        SYMP_DYSURIA_TODAY) == "Yes", na.rm = TRUE))

#### Dataset 9 General Work Conditions ####
kData9_GenWork <- kPMdataLAB %>%
  select( VISIT,SID,
          ACCESS_TOILET, ACCESS_TOILET_USE, ACCESS_TOILET_OTHERSP, BREAK_LUNCH, BREAKS_ADDITIONAL, TRAIN, 
          PESTICIDES_WORK, PESTICIDES_EXPOSURE
  )
oData9_GenWork <- oPMdataLAB %>%
  select( VISIT,SID,
          ACCESS_TOILET, ACCESS_TOILET_USE, ACCESS_TOILET_OTHERSP, BREAK_LUNCH, BREAKS_ADDITIONAL, TRAIN, 
          PESTICIDES_WORK, PESTICIDES_EXPOSURE
  )
Data9_GenWork <- rbind(kData9_GenWork, oData9_GenWork)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))

#### Dataset 10 General Drinking Habits ####
kData10_GenDrink <- kPMdataLAB %>%
  select( VISIT,SID,
          DRINKS_BL_WATER, DRINKS_BL_COFFEE, DRINKS_BL_TEA, DRINKS_BL_JUICE, DRINKS_BL_SODA, DRINKS_BL_DIETSODA,
          DRINKS_BL_SPORTSDRINKS, DRINKS_BL_ENERGYDRINKS, DRINKS_BL_ALCOHOL,	
          WATER_ACCESS_CLEAN, WATER_DRINK, WATER_DONTDRINK_NOTALWAYSAVAIL, WATER_DONTDRINK_NOTCLEAN, 
          WATER_DONTDRINK_NOTCOLD, WATER_DONTDRINK_TOOFAR, WATER_DONTDRINK_LIMITS, WATER_DONTDRINK_MAKESILL,
          WATER_DONTDRINK_PREFERSOTHER, WATER_DONTDRINK_NOCOLDDRINKS, WATER_DONTDRINK_PREFERSOWN, 
          WATER_DONTDRINK_OTHER, WATER_DONTDRINK_OTHERSP
  )
oData10_GenDrink <- oPMdataLAB %>%
  select( VISIT,SID,
          DRINKS_BL_WATER, DRINKS_BL_COFFEE, DRINKS_BL_TEA, DRINKS_BL_JUICE, DRINKS_BL_SODA, DRINKS_BL_DIETSODA,
          DRINKS_BL_SPORTSDRINKS, DRINKS_BL_ENERGYDRINKS, DRINKS_BL_ALCOHOL,	
          WATER_ACCESS_CLEAN, WATER_DRINK, WATER_DONTDRINK_NOTALWAYSAVAIL, WATER_DONTDRINK_NOTCLEAN, 
          WATER_DONTDRINK_NOTCOLD, WATER_DONTDRINK_TOOFAR, WATER_DONTDRINK_LIMITS, WATER_DONTDRINK_MAKESILL,
          WATER_DONTDRINK_PREFERSOTHER, WATER_DONTDRINK_NOCOLDDRINKS, WATER_DONTDRINK_PREFERSOWN, 
          WATER_DONTDRINK_OTHER, WATER_DONTDRINK_OTHERSP
  )
Data10_GenDrink <- rbind(kData10_GenDrink,oData10_GenDrink)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))

#### Dataset 11 Health Habits and Meds ####
kData11_HealthMeds <- kPMdataLAB %>%
  select( VISIT,SID,
          ALCOHOL, ALCOHOL_DAYS, ALCOHOL_DRINKS, SMOKE_100, SMOKE_CURRENT, SMOKECAT, EXERCISE, EXERCISE_DAYS, 
          PAINMED_NONE, PAINMED_ASPIRIN, PAINMED_IBUPROFEN, PAINMED_CELEBREX, PAINMED_NAPROXEN, PAINMED_OTHER,
          PAINMED_OTHERSP, PAINMED_FREQ, PAINMED_IM_3DAYS, MED_ANYOTHER, MED_ANYOTHER_ALOE, MED_ANYOTHER_CLOVE, 
          MED_ANYOTHER_GINGER, MED_ANYOTHER_OREGANO, MED_ANYOTHER_MACA, MED_ANYOTHER_VALERIAN, MED_ANYOTHER_LOQUAT,
          MED_ANYOTHER_HORSETAIL, MED_ANYOTHER_HERBALIFE, MED_ANYOTHER_WEIGHTLOSSPILLS, MED_ABX_AMPICILINA, 
          MED_ABX_AMPICILINASULB, MED_ABX_CIPROFLOXACINO, MED_ABX_GENTAMICINA, MED_ABX_METRONIDAZOLE,
          MED_ABX_VANCOMICINA, MED_ANYOTHER_ANTIBIOTICS, MED_ANYOTHER_OTHERSP
  ) %>% mutate_if(is.factor, as.character) 
oData11_HealthMeds <- oPMdataLAB %>%
  select( VISIT,SID,
          ALCOHOL, ALCOHOL_DAYS, ALCOHOL_DRINKS, SMOKE_100, SMOKE_CURRENT, SMOKECAT, EXERCISE, EXERCISE_DAYS, 
          PAINMED_NONE, PAINMED_ASPIRIN, PAINMED_IBUPROFEN, PAINMED_CELEBREX, PAINMED_NAPROXEN, PAINMED_OTHER,
          PAINMED_OTHERSP, PAINMED_FREQ, PAINMED_IM_3DAYS, MED_ANYOTHER, MED_ANYOTHER_ALOE, MED_ANYOTHER_CLOVE, 
          MED_ANYOTHER_GINGER, MED_ANYOTHER_OREGANO, MED_ANYOTHER_MACA, MED_ANYOTHER_VALERIAN, MED_ANYOTHER_LOQUAT,
          MED_ANYOTHER_HORSETAIL, MED_ANYOTHER_HERBALIFE, MED_ANYOTHER_WEIGHTLOSSPILLS, MED_ABX_AMPICILINA, 
          MED_ABX_AMPICILINASULB, MED_ABX_CIPROFLOXACINO, MED_ABX_GENTAMICINA, MED_ABX_METRONIDAZOLE,
          MED_ABX_VANCOMICINA, MED_ANYOTHER_ANTIBIOTICS, MED_ANYOTHER_OTHERSP
  ) %>% mutate_if(is.factor, as.character) 
Data11_HealthMeds <- rbind(kData11_HealthMeds, oData11_HealthMeds)	%>% mutate_if(is.character, as.factor) %>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))

#### Dataset 12 Health History: Self ####
kData12_HistorySelf <- kPMdataLAB %>% 
  select( VISIT,SID,
          HEALTH_GENERAL, HISTORY_ER, CVD, CVD_MEDICATION, CVD_MED_ANTIPLATELET,
          CVD_MED_ANTICOAG, CVD_MED_ACEINHIBITORS, CVD_MED_LOSARTAN, CVD_MED_BETABLOCKERS, CVD_MED_CACHBLOCKERS, CVD_MED_STATIN,
          CVD_MED_DIURETICS, CVD_MED_VASODILATORS, CVD_MED_OTHER, CVD_MED_DK, CVD_MED_REFUSED, CVD_MED_OTHERSP, KIDNEY_STONES, UTI,
          GOUT, GOUT_MEDICATION, GOUT_MED_ALLOPURINOL, GOUT_MED_INDOMETHACIN, GOUT_MED_CORTOCOSTEROIDS, GOUT_MED_OTHER, GOUT_MED_DK,
          GOUT_MED_REFUSED, GOUT_MED_OTHERSP
  )
oData12_HistorySelf <- oPMdataLAB %>% 
  select( VISIT,SID,
          HEALTH_GENERAL, HISTORY_ER, CVD, CVD_MEDICATION, CVD_MED_ANTIPLATELET,
          CVD_MED_ANTICOAG, CVD_MED_ACEINHIBITORS, CVD_MED_LOSARTAN, CVD_MED_BETABLOCKERS, CVD_MED_CACHBLOCKERS, CVD_MED_STATIN,
          CVD_MED_DIURETICS, CVD_MED_VASODILATORS, CVD_MED_OTHER, CVD_MED_DK, CVD_MED_REFUSED, CVD_MED_OTHERSP, KIDNEY_STONES, UTI,
          GOUT, GOUT_MEDICATION, GOUT_MED_ALLOPURINOL, GOUT_MED_INDOMETHACIN, GOUT_MED_CORTOCOSTEROIDS, GOUT_MED_OTHER, GOUT_MED_DK,
          GOUT_MED_REFUSED, GOUT_MED_OTHERSP
  )	
Data12_HistorySelf <- rbind(kData12_HistorySelf, oData12_HistorySelf)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))

#### Dataset 13 Health History: Family ####
kData13_HistoryFam <- kPMdataLAB %>%
  select( VISIT,SID,
          FAMILY_HYPERTENSION, FAMILY_CVD, FAMILY_STROKE, FAMILY_DIABETES_TYPE2, FAMILY_KIDNEY_STONES, FAMILY_KIDNEY_DISEASE,
          FAMILY_UTI, FAMILY_GOUT, FAMILY_CANCER
  )
oData13_HistoryFam <- oPMdataLAB %>%
  select( VISIT,SID,
          FAMILY_HYPERTENSION, FAMILY_CVD, FAMILY_STROKE, FAMILY_DIABETES_TYPE2, FAMILY_KIDNEY_STONES, FAMILY_KIDNEY_DISEASE,
          FAMILY_UTI, FAMILY_GOUT, FAMILY_CANCER
  )
Data13_HistoryFam <- rbind(kData13_HistoryFam, oData13_HistoryFam)		%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))

#### Dataset 14 Work Type in last 6 months ####
kData14_Type <- kPMdataLAB %>%
  select( VISIT,SID,
          JOBS_6M_FERNERY, JOBS_6M_NURSERY, JOBS_6M_FV, JOBS_6M_YARDWORK, JOBS_6M_OTHERAG, JOBS_6M_HOUSECLEANING,
          JOBS_6M_CHILDCARE, JOBS_6M_OFFICE, JOBS_6M_RETAIL, JOBS_6M_RESTAURANT, JOBS_6M_PACKINGWAIR, JOBS_6M_PACKINGNOAIR,
          JOBS_6M_CONSTRUCTION, JOBS_6M_PAINTING, JOBS_6M_UNEMPLOYED, JOBS_6M_OTHERNONAG, JOBS_6M_AGRI_OTHERSP,
          JOBS_6M_NOAGRI_OTHERSP, WORK_GT50_AGRI, DAYS_WEEK_AGRI, HOURS_DAY_AGRI, PAYMENT_AGRI, PAYMENT_AGRI_OTHERSP,
          DAYS_WEEK_NONAGRI, HOURS_DAY_NONAGRI, PAYMENT_NONAGRI, PAYMENT_NONAGRI_OTHERSP
  )
oData14_Type <- oPMdataLAB %>%
  select( VISIT,SID,
          JOBS_6M_FERNERY, JOBS_6M_NURSERY, JOBS_6M_FV, JOBS_6M_YARDWORK, JOBS_6M_OTHERAG, JOBS_6M_HOUSECLEANING,
          JOBS_6M_CHILDCARE, JOBS_6M_OFFICE, JOBS_6M_RETAIL, JOBS_6M_RESTAURANT, JOBS_6M_PACKINGWAIR, JOBS_6M_PACKINGNOAIR,
          JOBS_6M_CONSTRUCTION, JOBS_6M_PAINTING, JOBS_6M_UNEMPLOYED, JOBS_6M_OTHERNONAG, JOBS_6M_AGRI_OTHERSP,
          JOBS_6M_NOAGRI_OTHERSP, WORK_GT50_AGRI, DAYS_WEEK_AGRI, HOURS_DAY_AGRI, PAYMENT_AGRI, PAYMENT_AGRI_OTHERSP,
          DAYS_WEEK_NONAGRI, HOURS_DAY_NONAGRI, PAYMENT_NONAGRI, PAYMENT_NONAGRI_OTHERSP
  )%>%
  mutate(PAYMENT_AGRI = recode(PAYMENT_AGRI, `1` = "by the piece", `2` = "by the hour", `3` = "combination piece/hour", `4`= "salary"))
Data14_Type <- rbind(kData14_Type, oData14_Type)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))

#### Dataset 15 Issues ####
kData15_Issues <- k23issues %>% 
  select( VISIT,
          TIME_OF_DAY, ATTENDANCE, DATA_ISSUES, DATA_ISSUE_ZEPHYR, DATA_ISSUE_IBUTTON, DATA_ISSUE_URINE_CLINIC, DATA_ISSUE_BLOOD_CLINIC,
          DATA_ISSUE_URINE_LAB, DATA_ISSUE_BLOOD_LAB, DATA_ISSUE_OTHER, DATA_ISSUE_NONE, DATA_ISSUE_TYPE_OTHERSP, ZEPHYR_ISSUE,
          ZEPHYR_ISSUE_OTHERSP, WAISTIBUTTON_ISSUE, WAISTIBUTTON_ISSUE_OTHERSP, URINE_ISSUE_CLINICAL, URINE_ISSUE_CLINICAL_OTHERSP,
          URINE_ISSUE_LAB, URINE_ISSUE_LAB_OTHERSP, URINE_ISSUE_LAB_TOOLITTLE, BLOOD_ISSUE_CLINICAL, BLOOD_ISSUE_OTHERSP, BLOOD_ISSUE_LAB,
          BLOOD_ISSUE_LAB_TOOLITTLE, BLOOD_ISSUE_LAB_OTHERSP, ATTENDANCE_YES_OTHERSP
  )
oData15_Issues <- oheardissues %>% 
  select( VISIT,
          TIME_OF_DAY, ATTENDANCE, DATA_ISSUES, DATA_ISSUE_ZEPHYR, DATA_ISSUE_IBUTTON, DATA_ISSUE_URINE_CLINIC, DATA_ISSUE_BLOOD_CLINIC,
          DATA_ISSUE_URINE_LAB, DATA_ISSUE_BLOOD_LAB, DATA_ISSUE_OTHER, DATA_ISSUE_NONE, DATA_ISSUE_TYPE_OTHERSP, ZEPHYR_ISSUE,
          ZEPHYR_ISSUE_OTHERSP, WAISTIBUTTON_ISSUE, WAISTIBUTTON_ISSUE_OTHERSP, URINE_ISSUE_CLINICAL, URINE_ISSUE_CLINICAL_OTHERSP,
          URINE_ISSUE_LAB, URINE_ISSUE_LAB_OTHERSP, URINE_ISSUE_LAB_TOOLITTLE, BLOOD_ISSUE_CLINICAL, BLOOD_ISSUE_OTHERSP, BLOOD_ISSUE_LAB,
          BLOOD_ISSUE_LAB_TOOLITTLE, BLOOD_ISSUE_LAB_OTHERSP, ATTENDANCE_YES_OTHERSP
  )
Data15_Issues <- rbind(kData15_Issues, oData15_Issues)%>%
  mutate(VISIT = recode(VISIT, `1` = "Exposed", `10` = "Not Exposed"))



# Households
Households <- rbind(k23households, oheardhouseholds)


MASTER <- Data1_Demog %>%
  full_join(Data2_BaseClin, by = c("VISIT", "SID")) %>%
  full_join(Data3_URINE, by = c("VISIT", "SID")) %>%
  full_join(Data4_AKI, by = c("VISIT", "SID"))  %>%
  full_join(Data5_SERUM, by = c("VISIT", "SID")) %>%
  full_join(Data6_WorkdayBev, by = c("VISIT", "SID"))  %>%
  full_join(Data7_WorkdayType, by = c("VISIT", "SID"))  %>%
  full_join(Data8_HRI, by = c("VISIT", "SID"))  %>%
  full_join(Data9_GenWork, by = c("VISIT", "SID"))  %>%
  full_join(Data10_GenDrink, by = c("VISIT", "SID"))   %>%
  full_join(Data11_HealthMeds, by = c("VISIT", "SID")) %>%
  full_join(Data12_HistorySelf, by = c("VISIT", "SID")) %>%
  full_join(Data13_HistoryFam, by = c("VISIT", "SID")) %>%
  full_join(Data14_Type, by = c("VISIT", "SID"))%>%
  left_join(Households[, c("SID", "HH_MATCHID")], by = c("SID"))






#### SAVE THE DATA #### 
# List of datasets and their corresponding file names
datasets <- list(Data1_Demog = "Data1_Demog", Data2_BaseClin = "Data2_BaseClin", Data3_URINE = "Data3_URINE", Data4_AKI = "Data4_AKI",
                 Data5_SERUM = "Data5_SERUM", Data6_WorkdayBev = "Data6_WorkdayBev", Data7_WorkdayType = "Data7_WorkdayType",
                 Data8_HRI = "Data8_HRI", Data9_GenWork = "Data9_GenWork", Data10_GenDrink = "Data10_GenDrink", Data11_HealthMeds = "Data11_HealthMeds",
                 Data12_HistorySelf = "Data12_HistorySelf", Data13_HistoryFam = "Data13_HistoryFam", Data14_Type = "Data14_Type", Data15_Issues = "Data15_Issues",
                 MASTER = "Data0_MASTER", Households = "Households"
                 )

# Loop through the list and save each dataset
for (name in names(datasets)) {
  saveRDS(get(name), file = here::here(paste0("derived_data/", datasets[[name]], ".rds")))
}





