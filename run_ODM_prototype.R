library (dplyr)
library (haven)
library(ggplot2)
library(tidyr)
library(lubridate) 
library(readxl)
library(progress)
library(purrr)
library(data.table)
library(haven)

---------------------------------------------------------------------------------------------

raw_data_location = "C:\\Users\\sheshali.warik\\OneDrive - MMC\\Gertz, Olivier's files - STT - Liquidity Management\\D. ODM\\09. Sample Data\\ODM Prototype Data\\raw_data_unclean.rds"
CDMS_location = "C:\\Users\\sheshali.warik\\OneDrive - MMC\\Gertz, Olivier's files - STT - Liquidity Management\\D. ODM\\09. Sample Data\\ODM Prototype Data\\CMDS_CLIENT_ID_ULT_PARENT_MAPPING 1.xlsx"

CDMS_mapping <- read_excel(CDMS_location)
merged_dataframe <- readRDS(raw_data_location)
unique_dates <- unique(as.Date(merged_dataframe$AS_OF_DATE))

----------------------------------------------------------------------------------------------

source("data_processing_functions.R")

data_preprocessing <- function(merged_dataframe, CDMS_mapping, unique_dates) {
  
  # Main processing steps
  first_last_dates <- get_first_last_dates(merged_dataframe)
  date_sequences <- generate_date_sequence_dataframe(first_last_dates, unique_dates)
  merge_dataframe_no_gaps <- create_dummy_rows(date_sequences, merged_dataframe, unique_dates)
  
  clean_merge_dataframe <- merge_dataframe_no_gaps %>%
    mutate(Is_Level_2 = ifelse(ULT_PARENT_CD %in% CDMS_mapping$CUST_CD, "Y", "N"),
           Level_1_Mapping = ifelse(Is_Level_2 == "N",
                                    ULT_PARENT_CD,
                                    CDMS_mapping$ULT_PARENT_CD[match(ULT_PARENT_CD, CDMS_mapping$CUST_CD)])) %>%
    mutate(Level_1_Mapping = ifelse(is.na(Level_1_Mapping), ULT_PARENT_CD, Level_1_Mapping),
           TOTAL_PRIN_BAL_USD = ifelse(TOTAL_PRIN_BAL_USD < 0, 0, TOTAL_PRIN_BAL_USD)) %>%
    handle_balance_spikes()
  
  # Filter for raw_data_consol
  raw_data_consol <- clean_merge_dataframe %>%
    filter(ENTITY_FLAG == "CONSOL") %>%
    mutate(ULT_PARENT_CD = Level_1_Mapping)
  
  # Filter for raw_data_last
  raw_data_last <- clean_merge_dataframe %>%
    filter(AS_OF_DATE >= as.Date("2023-10-01") &
             AS_OF_DATE <= as.Date("2025-03-31") &
             ENTITY_FLAG %in% c("SSBI", "SSBT"))
  
  return(list(raw_data_consol = raw_data_consol, raw_data_last = raw_data_last))
}


result <- data_preprocessing(merged_dataframe, CDMS_mapping, unique_dates)

# Access the results
raw_data_consol <- consolidate_rows(result$raw_data_consol)
raw_data_last <- consolidate_rows(result$raw_data_last)
-----------------------------------------------------------------------------------------
source("operational_balance_functions.R")

baseline_ob <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 3,
  long_lookback = 12,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily <- summarize_daily_operational_balance (baseline_ob)
write.csv(baseline_daily, "baseline_daily_SW.csv", row.names = FALSE)
-------------------------------------------------------------------------------
source('existing_ODM_analysis_functions.R')

existing_ODM_results_path = "C:\\Users\\sheshali.warik\\OneDrive - MMC\\Gertz, Olivier's files - STT - Liquidity Management\\D. ODM\\09. Sample Data\\ODM Prototype Data\\odm_up_bal_2020_2025.sas7bdat"
existing_ODM_results <- read_sas(existing_ODM_results_path)
