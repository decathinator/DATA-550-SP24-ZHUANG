here::i_am("code/02_make_tables_and_figures.R")

# List of packages
required_packages <- c(
  "gtsummary", "haven", "flextable", "labelled", "tidyverse", "dplyr"
)

# Check and load required packages
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}


# List of datasets and their corresponding file names
datasets <- list(Data1_Demog = "Data1_Demog", Data2_BaseClin = "Data2_BaseClin")

# Loop through the list and load each dataset
for (name in names(datasets)) {
  # Construct the file path
  file_path <- here::here("derived_data", paste0(datasets[[name]], ".rds"))
  
  # Read the RDS file
  dataset <- readRDS(file = file_path)
  
  # Dynamically assign the dataset to a variable with the name specified in 'names(datasets)'
  assign(x = name, value = dataset, envir = .GlobalEnv)
}


#### Making Table 1. Demographics ####
table1 <- gtsummary::tbl_summary(    
  Data1_Demog %>% select(-SID),  
  by = VISIT,
  digits 	= list(all_categorical() ~ 0,	all_continuous() ~ 0),
  type = list(AGRI_YRS_IN_SOUTH ~ 'continuous'),
  statistic = list(	all_continuous() ~ "{median} ({p25}, {p75})",     
                    all_categorical() ~ "{p}% ({n})", 
                    missing = "no"
  ),	
  value = list(
    SEX ~ "Male", 
    MARITAL_STATUS ~"Coupled", 
    INDIGENOUS ~ "Yes",
    LANGUAGE_ENGLISH ~ "Checked",
    LANGUAGE_SPANISH ~ "Checked"),
  label = list(
    SEX~"Male",
    MARITAL_STATUS~"Married/Coupled",
    EDUCATION2~"Education (Years)",
    INDIGENOUS~"Indigenous",
    LANGUAGE_ENGLISH~"Speaks English", 
    LANGUAGE_SPANISH~"Speaks Spanish", 
    AGRI_START~"Age Started Agricultural Work", 
    AGRI_YRS_IN_SOUTH~"Years in Southern Agriculture")
) %>% 
  gtsummary::modify_caption("Table 1. Demographic Characteristics of Indoor and Outdoor Agricultural Workers") %>%	
  gtsummary::modify_spanning_header(c("stat_1", "stat_2") ~ "Agricultural Group") %>%	
  gtsummary::bold_labels() %>%
  gtsummary::add_p()

saveRDS(
  table1, 
  file = here::here("output/table1.rds") 
)


#### Making figure ####
figure <- ggplot(Data2_BaseClin, aes(x = VISIT, y = BP_SYSTOLIC_BL, fill = VISIT)) + 
  geom_boxplot() + 
  labs(title = "Box Plot of Baseline Systolic Blood Pressure by Agricultural Group",
       x = "Agricultural Group",
       y = "Systolic Blood Pressure") +
  scale_fill_brewer(palette = "Set1", name = "Agricultural Group") +
  theme_minimal()

ggsave(
  here::here("output/figure.png"),
  plot = figure,
  device = "png" 
)
