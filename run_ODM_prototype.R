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
CDMS_location <- "C:\\Users\\chenqin.pan\\Downloads\\CMDS_CLIENT_ID_ULT_PARENT_MAPPING 1.xlsx"
raw_data_location <- "C:/Users/chenqin.pan/Downloads/raw_data_unclean.rds"
  
CDMS_mapping <- read_excel(CDMS_location)
merged_dataframe <- readRDS(raw_data_location)
unique_dates <- unique(as.Date(merged_dataframe$AS_OF_DATE))

----------------------------------------------------------------------------------------------

source("C:/Users/chenqin.pan/Documents/GitHub/stt_odm_prototype/data_processing_functions.R")

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
source("C:/Users/chenqin.pan/Documents/GitHub/stt_odm_prototype/operational_balance_functions.R")

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
write.csv(baseline_daily, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_CP.csv", row.names = FALSE)
-----------------------------------------------------
  
source("C:/Users/chenqin.pan/Documents/GitHub/stt_odm_prototype/exploratory_analysis_functions.R")

# check differences in the total principal balance between the old model result and new model result 

aggregate_ineligibility_data <- aggregate_ineligibility (baseline_ob)
write.csv(aggregate_ineligibility_data, "C:\\Users\\chenqin.pan\\Downloads\\aggregate_ineligibility_data.csv", row.names = FALSE)


# check differences in the total operational balance between the old model result and new model result 

SSGA000_America_data <- baseline_ob %>%
  filter(REGION == "AMERICAS" & ULT_PARENT_CD == "SSGA000")
write.csv(SSGA000_America_data, "C:\\Users\\chenqin.pan\\Downloads\\SSGA000_America_data.csv", row.names = FALSE)

SCHW000_America_data <- baseline_ob %>%
  filter(REGION == "AMERICAS" & ULT_PARENT_CD == "SCHW000")
write.csv(SCHW000_America_data, "C:\\Users\\chenqin.pan\\Downloads\\SCHW000_America_data.csv", row.names = FALSE)

FEIC000_America_data <- baseline_ob %>%
  filter(REGION == "AMERICAS" & ULT_PARENT_CD == "FEIC000")
write.csv(FEIC000_America_data, "C:\\Users\\chenqin.pan\\Downloads\\FEIC000_America_data.csv", row.names = FALSE)

ISBA000_EMEA_data <- baseline_ob %>%
  filter(REGION == "EMEA" & ULT_PARENT_CD == "ISBA000")
write.csv(ISBA000_EMEA_data, "C:\\Users\\chenqin.pan\\Downloads\\ISBA000_EMEA_data.csv", row.names = FALSE)

ALLI000_EMEA_data <- baseline_ob %>%
  filter(REGION == "EMEA" & ULT_PARENT_CD == "ALLI000")
write.csv(ALLI000_EMEA_data, "C:\\Users\\chenqin.pan\\Downloads\\ALLI000_EMEA_data.csv", row.names = FALSE)


duplicate_dates_check <- raw_data_consol %>%
  group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE) %>%
  summarize(Count = n(), .groups = 'drop') %>%  # Count occurrences of each AS_OF_DATE
  filter(Count > 1)  # Keep only those AS_OF_DATE that occur more than once

# View the results
View(duplicate_dates_check)


-----------------------------------------------------------------------------------------------

# Count Unique UP over time
  
Unique_UP_over_time <-count_Unique_UP_over_time(raw_data_consol)


write.csv(Unique_UP_over_time, "C:\\Users\\chenqin.pan\\Downloads\\Unique_UP_over_time.csv", row.names = FALSE)


# Count Unique Tuples over time

unique_tuples_over_time <- count_unique_tuples_over_time(raw_data_consol)
write.csv(unique_tuples_over_time, "C:\\Users\\chenqin.pan\\Downloads\\unique_tuples_over_time.csv", row.names = FALSE)

# Filter for raw_data_consol after bridging the gaps
first_last_dates <- get_first_last_dates(merged_dataframe)
date_sequences <- generate_date_sequence_dataframe(first_last_dates, unique_dates)
merge_dataframe_no_gaps <- create_dummy_rows(date_sequences, merged_dataframe, unique_dates)

merge_dataframe_no_gaps_consol <- merge_dataframe_no_gaps %>%
  filter(ENTITY_FLAG == "CONSOL") 

Unique_UP_over_time_before_mapping <-count_Unique_UP_over_time(merge_dataframe_no_gaps_consol)
unique_tuples_over_time_before_mapping <- count_unique_tuples_over_time(merge_dataframe_no_gaps_consol)
write.csv(Unique_UP_over_time_before_mapping, "C:\\Users\\chenqin.pan\\Downloads\\Unique_UP_over_time_before_mapping.csv", row.names = FALSE)
write.csv(unique_tuples_over_time_before_mapping, "C:\\Users\\chenqin.pan\\Downloads\\unique_tuples_over_time_before_mapping.csv", row.names = FALSE)

------------------------------------------------------------------------------------------------
# List of the  unique Ultimate Parents that existed on September 29, 2023 (the most recent date before the cliff) but disappeared on October 2, 2023 (the most recent date after the cliff).

# Filter for data before October 1, 2023
raw_data_consol_before_cliff <- raw_data_consol %>%
  filter(AS_OF_DATE == as.Date("2023-09-29"))

# Filter for data on or after October 1, 2023
raw_data_consol_after_cliff <- raw_data_consol %>%
  filter(AS_OF_DATE == as.Date("2023-10-02"))

unique_UP_before_cliff <- list_Unique_UP (raw_data_consol_before_cliff)

unique_UP_after_cliff <- list_Unique_UP (raw_data_consol_after_cliff)

unique_UP_difference <- setdiff(unique_UP_before_cliff, unique_UP_after_cliff)
unique_UP_difference_df <- data.frame(ULT_PARENT_CD = unique_UP_difference)
View(unique_UP_difference_df)


write.csv(unique_UP_difference_df, "C:\\Users\\chenqin.pan\\Downloads\\unique_UP_difference_df.csv", row.names = FALSE)

  
------------------------------------------------------------------------------------------
#SLB X LLB Matrix
baseline_ob_L6S1 <- calculate_operational_balance (
    raw_data_consol,
    short_lookback = 1,
    long_lookback = 6 ,
    cap = 1,
    n = 2,
    start_date = "2020-01-01",
    end_date = "2025-3-28"
  )

baseline_daily_L6S1 <- summarize_daily_operational_balance (baseline_ob_L6S1)

write.csv(baseline_daily_L6S1, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L6S1.csv", row.names = FALSE)



baseline_ob_L6S2 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 2,
  long_lookback = 6 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L6S2 <- summarize_daily_operational_balance (baseline_ob_L6S2)

write.csv(baseline_daily_L6S2, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L6S2.csv", row.names = FALSE)




baseline_ob_L6S3 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 3,
  long_lookback = 6 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L6S3 <- summarize_daily_operational_balance (baseline_ob_L6S3)

write.csv(baseline_daily_L6S3, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L6S3.csv", row.names = FALSE)




baseline_ob_L6S4 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 4,
  long_lookback = 6 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L6S4 <- summarize_daily_operational_balance (baseline_ob_L6S4)

write.csv(baseline_daily_L6S4, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L6S4.csv", row.names = FALSE)



baseline_ob_L6S6 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 6,
  long_lookback = 6 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L6S6 <- summarize_daily_operational_balance (baseline_ob_L6S6)

write.csv(baseline_daily_L6S6, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L6S6.csv", row.names = FALSE)

---------------------------
  
  baseline_ob_L9S1 <- calculate_operational_balance (
    raw_data_consol,
    short_lookback = 1,
    long_lookback = 9 ,
    cap = 1,
    n = 2,
    start_date = "2020-01-01",
    end_date = "2025-3-28"
  )

baseline_daily_L9S1 <- summarize_daily_operational_balance (baseline_ob_L9S1)

write.csv(baseline_daily_L9S1, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L9S1.csv", row.names = FALSE)


baseline_ob_L9S2 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 2,
  long_lookback = 9 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L9S2 <- summarize_daily_operational_balance (baseline_ob_L9S2)

write.csv(baseline_daily_L9S2, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L9S2.csv", row.names = FALSE)


baseline_ob_L9S3 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 3,
  long_lookback = 9 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L9S3 <- summarize_daily_operational_balance (baseline_ob_L9S3)

write.csv(baseline_daily_L9S3, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L9S3.csv", row.names = FALSE)


baseline_ob_L9S4 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 4,
  long_lookback = 9 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L9S4 <- summarize_daily_operational_balance (baseline_ob_L9S4)

write.csv(baseline_daily_L9S4, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L9S4.csv", row.names = FALSE)


baseline_ob_L9S6 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 6,
  long_lookback = 9 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L9S6 <- summarize_daily_operational_balance (baseline_ob_L9S6)

write.csv(baseline_daily_L9S6, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L9S6.csv", row.names = FALSE)


---------------------------
  
  baseline_ob_L15S1 <- calculate_operational_balance (
    raw_data_consol,
    short_lookback = 1,
    long_lookback = 15 ,
    cap = 1,
    n = 2,
    start_date = "2020-01-01",
    end_date = "2025-3-28"
  )

baseline_daily_L15S1 <- summarize_daily_operational_balance (baseline_ob_L15S1)

write.csv(baseline_daily_L15S1, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L15S1.csv", row.names = FALSE)


baseline_ob_L15S2 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 2,
  long_lookback = 15 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L15S2 <- summarize_daily_operational_balance (baseline_ob_L15S2)

write.csv(baseline_daily_L15S2, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L15S2.csv", row.names = FALSE)


baseline_ob_L15S3 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 3,
  long_lookback = 15 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L15S3 <- summarize_daily_operational_balance (baseline_ob_L15S3)

write.csv(baseline_daily_L15S3, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L15S3.csv", row.names = FALSE)


baseline_ob_L15S4 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 4,
  long_lookback = 15 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L15S4 <- summarize_daily_operational_balance (baseline_ob_L15S4)

write.csv(baseline_daily_L15S4, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L15S4.csv", row.names = FALSE)


baseline_ob_L15S6 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 6,
  long_lookback = 15 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L15S6 <- summarize_daily_operational_balance (baseline_ob_L15S6)

write.csv(baseline_daily_L15S6, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L15S6.csv", row.names = FALSE)


---------------------------
  
  baseline_ob_L12S1 <- calculate_operational_balance (
    raw_data_consol,
    short_lookback = 1,
    long_lookback = 12 ,
    cap = 1,
    n = 2,
    start_date = "2020-01-01",
    end_date = "2025-3-28"
  )

baseline_daily_L12S1 <- summarize_daily_operational_balance (baseline_ob_L12S1)

write.csv(baseline_daily_L12S1, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L12S1.csv", row.names = FALSE)


baseline_ob_L12S2 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 2,
  long_lookback = 12 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L12S2 <- summarize_daily_operational_balance (baseline_ob_L12S2)

write.csv(baseline_daily_L12S2, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L12S2.csv", row.names = FALSE)


baseline_ob_L12S3 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 3,
  long_lookback = 12 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L12S3 <- summarize_daily_operational_balance (baseline_ob_L12S3)

write.csv(baseline_daily_L12S3, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L12S3.csv", row.names = FALSE)


baseline_ob_L12S4 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 4,
  long_lookback = 12 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L12S4 <- summarize_daily_operational_balance (baseline_ob_L12S4)

write.csv(baseline_daily_L12S4, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L12S4.csv", row.names = FALSE)


baseline_ob_L12S6 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 6,
  long_lookback = 12 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L12S6 <- summarize_daily_operational_balance (baseline_ob_L12S6)

write.csv(baseline_daily_L12S6, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L12S6.csv", row.names = FALSE)



---------------------------
  
  baseline_ob_L18S1 <- calculate_operational_balance (
    raw_data_consol,
    short_lookback = 1,
    long_lookback = 18 ,
    cap = 1,
    n = 2,
    start_date = "2020-01-01",
    end_date = "2025-3-28"
  )

baseline_daily_L18S1 <- summarize_daily_operational_balance (baseline_ob_L18S1)

write.csv(baseline_daily_L18S1, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L18S1.csv", row.names = FALSE)


baseline_ob_L18S2 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 2,
  long_lookback = 18 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L18S2 <- summarize_daily_operational_balance (baseline_ob_L18S2)

write.csv(baseline_daily_L18S2, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L18S2.csv", row.names = FALSE)


baseline_ob_L18S3 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 3,
  long_lookback = 18 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L18S3 <- summarize_daily_operational_balance (baseline_ob_L18S3)

write.csv(baseline_daily_L18S3, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L18S3.csv", row.names = FALSE)


baseline_ob_L18S4 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 4,
  long_lookback = 18 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L18S4 <- summarize_daily_operational_balance (baseline_ob_L18S4)

write.csv(baseline_daily_L18S4, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L18S4.csv", row.names = FALSE)


baseline_ob_L18S6 <- calculate_operational_balance (
  raw_data_consol,
  short_lookback = 6,
  long_lookback = 18 ,
  cap = 1,
  n = 2,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

baseline_daily_L18S6 <- summarize_daily_operational_balance (baseline_ob_L18S6)

write.csv(baseline_daily_L18S6, "C:\\Users\\chenqin.pan\\Downloads\\baseline_daily_L18S6.csv", row.names = FALSE)
---------------------------------------------------------------------------------------------------------------
# Reported data - Intraday & MDL & MDH

source("C:/Users/chenqin.pan/Documents/GitHub/stt_odm_prototype/existing_ODM_analysis_functions.R")

existing_ODM_results_path = "C:\\Users\\chenqin.pan\\Downloads\\odm_up_bal_2020_2025.sas7bdat"
existing_ODM_results <- read_sas(existing_ODM_results_path)
View(existing_ODM_results)  
  

reported_operational_balances <- process_reported_operational_balances(existing_ODM_results, '2025-03-31')


reported_daily <- consolidate_rows_reported (reported_operational_balances)
View(reported_daily)

write.csv(reported_daily, "C:\\Users\\chenqin.pan\\Downloads\\reported_daily.csv", row.names = FALSE)


reported_daily_region <- consolidate_rows_reported_region (reported_operational_balances)
View(reported_daily_region)
write.csv(reported_daily_region, "C:\\Users\\chenqin.pan\\Downloads\\reported_daily_region.csv", row.names = FALSE)


reported_op_bals_entire_MDH <- reported_operational_balances %>%
  filter(LAST_BEHAVIORAL_GROUP == 'Multi-Day High') %>%
  group_by(AS_OF_DATE) %>%
  summarise(
    PERIOD_ID = min(PERIOD_ID),
    DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD),
    OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD),
    EXCESS_BAL_USD = sum(EXCESS_BAL_USD),
    .groups = 'drop'  # Prevents grouping from being retained
  )        %>%
  mutate( CAPTURE_RATE = ifelse(DAILY_SPOT_BAL_USD <= 0, 0, OPERATIONAL_BAL_USD/DAILY_SPOT_BAL_USD) )
write.csv(reported_op_bals_entire_MDH, "C:\\Users\\chenqin.pan\\Downloads\\reported_op_bals_entire_MDH.csv", row.names = FALSE)

reported_op_bals_entire_MDL <- reported_operational_balances %>%
  filter(LAST_BEHAVIORAL_GROUP == 'Multi-Day Low') %>%
  group_by(AS_OF_DATE) %>%
  summarise(
    PERIOD_ID = min(PERIOD_ID),
    DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD),
    OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD),
    EXCESS_BAL_USD = sum(EXCESS_BAL_USD),
    .groups = 'drop'  # Prevents grouping from being retained
  )        %>%
  mutate( CAPTURE_RATE = ifelse(DAILY_SPOT_BAL_USD <= 0, 0, OPERATIONAL_BAL_USD/DAILY_SPOT_BAL_USD) )
write.csv(reported_op_bals_entire_MDL, "C:\\Users\\chenqin.pan\\Downloads\\reported_op_bals_entire_MDL.csv", row.names = FALSE)


reported_op_bals_entire_Intraday <- reported_operational_balances %>%
  filter(LAST_BEHAVIORAL_GROUP == 'INTRA-DAY') %>%
  group_by(AS_OF_DATE) %>%
  summarise(
    PERIOD_ID = min(PERIOD_ID),
    DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD),
    OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD),
    EXCESS_BAL_USD = sum(EXCESS_BAL_USD),
    .groups = 'drop'  # Prevents grouping from being retained
  )        %>%
  mutate( CAPTURE_RATE = ifelse(DAILY_SPOT_BAL_USD <= 0, 0, OPERATIONAL_BAL_USD/DAILY_SPOT_BAL_USD) )
write.csv(reported_op_bals_entire_Intraday, "C:\\Users\\chenqin.pan\\Downloads\\reported_op_bals_entire_Intraday.csv", row.names = FALSE)


# Model- Intraday MDL MDH

daily_region <- consolidate_rows_region (baseline_ob) 
daily_region_americas<-daily_region %>% filter(REGION == "AMERICAS")
daily_region_EMEA<-daily_region %>% filter(REGION == "EMEA")

write.csv(daily_region_americas, "C:\\Users\\chenqin.pan\\Downloads\\daily_region_americas.csv", row.names = FALSE)
write.csv(daily_region_EMEA, "C:\\Users\\chenqin.pan\\Downloads\\daily_region_EMEA.csv", row.names = FALSE)



daily_region_L18S6 <- consolidate_rows_region (baseline_ob_L18S6) 
daily_region_americas_L18S6<-daily_region_L18S6 %>% filter(REGION == "AMERICAS")
daily_region_EMEA_L18S6<-daily_region_L18S6 %>% filter(REGION == "EMEA")

write.csv(daily_region_americas_L18S6, "C:\\Users\\chenqin.pan\\Downloads\\daily_region_americas_L18S6.csv", row.names = FALSE)
write.csv(daily_region_EMEA_L18S6, "C:\\Users\\chenqin.pan\\Downloads\\daily_region_EMEA_L18S6.csv", row.names = FALSE)

daily_region_L6S1 <- consolidate_rows_region (baseline_ob_L6S1) 
daily_region_americas_L6S1<-daily_region_L6S1 %>% filter(REGION == "AMERICAS")
daily_region_EMEA_L6S1<-daily_region_L6S1 %>% filter(REGION == "EMEA")

write.csv(daily_region_americas_L6S1, "C:\\Users\\chenqin.pan\\Downloads\\daily_region_americas_L6S1.csv", row.names = FALSE)
write.csv(daily_region_EMEA_L6S1, "C:\\Users\\chenqin.pan\\Downloads\\daily_region_EMEA_L6S1.csv", row.names = FALSE)


operational_balance_baseline_w_behavioral_group <- baseline_ob %>% left_join( tuples_last_behavioralgroup, by = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG")  )
operational_balance_baseline_MDH <- operational_balance_baseline_w_behavioral_group %>% filter(LAST_BEHAVIORAL_GROUP == "Multi-Day High")
operational_balance_baseline_MDL <- operational_balance_baseline_w_behavioral_group %>% filter(LAST_BEHAVIORAL_GROUP == "Multi-Day Low")
operational_balance_baseline_Intra <- operational_balance_baseline_w_behavioral_group %>% filter(LAST_BEHAVIORAL_GROUP == "INTRA-DAY")

ob_daily_totals_baseline_MDH <- calculate_daily_totals(operational_balance_baseline_MDH)
ob_daily_totals_baseline_MDL <- calculate_daily_totals(operational_balance_baseline_MDL)
ob_daily_totals_baseline_Intra <- calculate_daily_totals(operational_balance_baseline_Intra)


write.csv(ob_daily_totals_baseline_MDH, "C:\\Users\\chenqin.pan\\Downloads\\OB_baseline_daily_MDH.csv", row.names = FALSE)
write.csv(ob_daily_totals_baseline_MDL, "C:\\Users\\chenqin.pan\\Downloads\\OB_baseline_daily_MDL.csv", row.names = FALSE)  
write.csv(ob_daily_totals_baseline_Intra, "C:\\Users\\chenqin.pan\\Downloads\\OB_baseline_daily_Intra.csv", row.names = FALSE)  
---------------------------------------------
operational_balance_L18S6_w_behavioral_group <- baseline_ob_L18S6 %>% left_join( tuples_last_behavioralgroup, by = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG")  )
operational_balance_L18S6_MDH <- operational_balance_L18S6_w_behavioral_group %>% filter(LAST_BEHAVIORAL_GROUP == "Multi-Day High")
operational_balance_L18S6_MDL <- operational_balance_L18S6_w_behavioral_group %>% filter(LAST_BEHAVIORAL_GROUP == "Multi-Day Low")
operational_balance_L18S6_Intra <- operational_balance_L18S6_w_behavioral_group %>% filter(LAST_BEHAVIORAL_GROUP == "INTRA-DAY")

ob_daily_totals_L18S6_MDH <- calculate_daily_totals(operational_balance_L18S6_MDH)
ob_daily_totals_L18S6_MDL <- calculate_daily_totals(operational_balance_L18S6_MDL)
ob_daily_totals_L18S6_Intra <- calculate_daily_totals(operational_balance_L18S6_Intra)


write.csv(ob_daily_totals_L18S6_MDH, "C:\\Users\\chenqin.pan\\Downloads\\ob_daily_totals_L18S6_MDH.csv", row.names = FALSE)
write.csv(ob_daily_totals_L18S6_MDL, "C:\\Users\\chenqin.pan\\Downloads\\ob_daily_totals_L18S6_MDL.csv", row.names = FALSE)  
write.csv(ob_daily_totals_L18S6_Intra, "C:\\Users\\chenqin.pan\\Downloads\\ob_daily_totals_L18S6_Intra.csv", row.names = FALSE) 
---------------------------------------------
operational_balance_L6S1_w_behavioral_group <- baseline_ob_L6S1 %>% left_join( tuples_last_behavioralgroup, by = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG")  )
operational_balance_L6S1_MDH <- operational_balance_L6S1_w_behavioral_group %>% filter(LAST_BEHAVIORAL_GROUP == "Multi-Day High")
operational_balance_L6S1_MDL <- operational_balance_L6S1_w_behavioral_group %>% filter(LAST_BEHAVIORAL_GROUP == "Multi-Day Low")
operational_balance_L6S1_Intra <- operational_balance_L6S1_w_behavioral_group %>% filter(LAST_BEHAVIORAL_GROUP == "INTRA-DAY")

ob_daily_totals_L6S1_MDH <- calculate_daily_totals(operational_balance_L6S1_MDH)
ob_daily_totals_L6S1_MDL <- calculate_daily_totals(operational_balance_L6S1_MDL)
ob_daily_totals_L6S1_Intra <- calculate_daily_totals(operational_balance_L6S1_Intra)


write.csv(ob_daily_totals_L6S1_MDH, "C:\\Users\\chenqin.pan\\Downloads\\ob_daily_totals_L6S1_MDH.csv", row.names = FALSE)
write.csv(ob_daily_totals_L6S1_MDL, "C:\\Users\\chenqin.pan\\Downloads\\ob_daily_totals_L6S1_MDL.csv", row.names = FALSE)  
write.csv(ob_daily_totals_L6S1_Intra, "C:\\Users\\chenqin.pan\\Downloads\\ob_daily_totals_L6S1_Intra.csv", row.names = FALSE) 



-------------------------------------------------------------------------------
# Reported data - Map level 2 UP to level 1 

reported_result_mapping <- data_preprocessing_reported(existing_ODM_results, CDMS_mapping)
Reported_data_clean<- reported_result_mapping$clean_merge_dataframe
Reported_data_consol <- reported_result_mapping$raw_data_consol
Reported_data_last <- reported_result_mapping$raw_data_last
View(Reported_data_clean)

-----------------------------------------------------------------------------------------
reported_daily_before_mapping_and_bridging <- consolidate_rows_reported_before_mapping_and_bridging (existing_ODM_results)
View(reported_daily_before_mapping_and_bridging)
raw_daily  <-consolidate_rows_raw(raw_data_consol)


