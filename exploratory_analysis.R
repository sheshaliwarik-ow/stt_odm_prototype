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

-------------------------------------------------------------------------------
CDMS_location <- "C:\\Users\\chenqin.pan\\Downloads\\CMDS_CLIENT_ID_ULT_PARENT_MAPPING 1.xlsx"
raw_data_location <- "C:/Users/chenqin.pan/Downloads/raw_data_unclean.rds"
source("C:/Users/chenqin.pan/Documents/GitHub/stt_odm_prototype/existing_ODM_analysis_functions.R")

  
CDMS_mapping <- read_excel(CDMS_location)
merged_dataframe <- readRDS(raw_data_location)
unique_dates <- unique(as.Date(merged_dataframe$AS_OF_DATE))

-------------------------------------------------------------------------------
# Clean 6-Monthly Runs input Data with L1L2 Treatment and Gap Bridging Treatment
  
source("C:/Users/chenqin.pan/Documents/GitHub/stt_odm_prototype/data_processing_functions.R")

result <- data_preprocessing(merged_dataframe, CDMS_mapping, unique_dates)

# Access the results
raw_data_consol <- consolidate_rows(result$raw_data_consol)
raw_data_last <- consolidate_rows(result$raw_data_last)

------------------------------------------------------------------------------
# Count Unique UP over time after bridging the gaps and  L1L2 Mapping (input data)
  
Unique_UP_over_time <-count_Unique_UP_over_time(raw_data_consol)


# Count Unique Tuples over time after bridging the gaps and  L1L2 Mapping
unique_tuples_over_time <- count_unique_tuples_over_time(raw_data_consol)

# Filter for raw_data_consol after bridging the gaps before L1L2 Mapping
first_last_dates <- get_first_last_dates(merged_dataframe)
date_sequences <- generate_date_sequence_dataframe(first_last_dates, unique_dates)
merge_dataframe_no_gaps <- create_dummy_rows(date_sequences, merged_dataframe, unique_dates)

merge_dataframe_no_gaps_consol <- merge_dataframe_no_gaps %>%
  filter(ENTITY_FLAG == "CONSOL") 

# Count Unique UP over time after bridging the gaps before L1L2 Mapping
Unique_UP_over_time_before_mapping <-count_Unique_UP_over_time(merge_dataframe_no_gaps_consol)

# Count Unique Tuples over time after bridging the gaps before L1L2 Mapping
unique_tuples_over_time_before_mapping <- count_unique_tuples_over_time(merge_dataframe_no_gaps_consol)


-------------------------------------------------------------------------------
  # Reported SS data across segments


existing_ODM_results_path = "C:\\Users\\chenqin.pan\\Downloads\\odm_up_bal_2020_2025.sas7bdat"
existing_ODM_results <- read_sas(existing_ODM_results_path)
View(existing_ODM_results)  
  

reported_operational_balances <- process_reported_operational_balances(existing_ODM_results, '2025-03-31')
View(reported_operational_balances)

# Reported data - Consolidated level 

reported_daily <- consolidate_rows_reported (reported_operational_balances)
View(reported_daily)

# Reported data - Region segments

reported_daily_region <- consolidate_rows_reported_region (reported_operational_balances)
View(reported_daily_region)



# Reported data - LE segments


reported_operational_balances_SSBIBT <- process_reported_operational_balances_SSBIBT(existing_ODM_results, '2025-03-31')
reported_daily_LE <-consolidate_rows_reported_LE(reported_operational_balances_SSBIBT)
View(reported_daily_LE)

# Reported data - Intraday & MDL & MDH segments

reported_op_bals_entire_MDH <- consolidate_rows_reported_behavioralgroup(
  reported_operational_balances,
  'Multi-Day High'
)

reported_op_bals_entire_MDL <- consolidate_rows_reported_behavioralgroup(
  reported_operational_balances,
  'Multi-Day Low'
)

reported_op_bals_entire_Intraday <- consolidate_rows_reported_behavioralgroup(
  reported_operational_balances,
  'INTRA-DAY'
)

-------------------------------------------------------------------------------
# Reported data - Map level 2 UP to level 1 UP (No bridging)

reported_result_mapping <- data_preprocessing_reported(existing_ODM_results, CDMS_mapping)
Reported_data_clean<- reported_result_mapping$clean_merge_dataframe
Reported_data_consol <- reported_result_mapping$raw_data_consol
Reported_data_last <- reported_result_mapping$raw_data_last
View(Reported_data_clean)

-------------------------------------------------------------------------------  
# Count Unique UP over time after  L1L2 Mapping (reported data )
  
Unique_UP_over_time_reported <-count_Unique_UP_over_time(Reported_data_consol)

write.csv(Unique_UP_over_time_reported, "C:\\Users\\chenqin.pan\\Downloads\\Unique_UP_over_time_reported.csv", row.names = FALSE)


# Count Unique Tuples over time after  L1L2 Mapping (reported data )
unique_tuples_over_time_reported <- count_unique_tuples_over_time(Reported_data_consol)
write.csv(unique_tuples_over_time_reported, "C:\\Users\\chenqin.pan\\Downloads\\unique_tuples_over_time_reported.csv", row.names = FALSE)


-------------------------------------------------------------------------------
#Top 10 Tuples Ranked by Total Balance Segmented by Behavioral Group as of March 31, 2025

# Multi-Day High
result_mdh <- get_top_n_behavioral_group(existing_ODM_results, raw_data_consol, '2025-03-31', 'Multi-Day High', 10)
View(result_mdh$top_n)
View(result_mdh$raw_data_consol_top_n)

#  Multi-Day Low
result_mdl <- get_top_n_behavioral_group(existing_ODM_results, raw_data_consol, '2025-03-31', 'Multi-Day Low', 10)
View(result_mdl$top_n)
View(result_mdl$raw_data_consol_top_n)

# Intraday
result_intra <- get_top_n_behavioral_group(existing_ODM_results, raw_data_consol, '2025-03-31', 'INTRA-DAY', 10)
View(result_intra$top_n)
View(result_intra$raw_data_consol_top_n)





raw_daily_totals_baseline_MDH <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  raw_data_consol, 
  '2025-03-31', 
  'Multi-Day High'
)  
top_10_mdh_payment <- raw_daily_totals_baseline_MDH %>%
  filter(AS_OF_DATE == '2020-03-30') %>%  # Filter for the specific date
  arrange(desc(TOTAL_OUTFLOW)) %>%   # Arrange in descending order
  slice_head(n = 10)  
raw_data_consol_top10_mdh_payment <- raw_daily_totals_baseline_MDH %>%
  filter(REGION %in% top_10_mdh_payment$REGION & ULT_PARENT_CD %in% top_10_mdh_payment$ULT_PARENT_CD)

View(top_10_mdh_payment)

View(raw_data_consol_top10_mdh_payment)
write.csv(raw_data_consol_top10_mdh_payment, "C:\\Users\\chenqin.pan\\Downloads\\raw_data_consol_top10_mdh_payment.csv", row.names = FALSE)


View(existing_ODM_results)



SSMG_AMER_reported <- reported_operational_balances%>%
  filter(ULT_PARENT_CD == 'SSGM000')
write.csv(SSMG_AMER_reported, "C:\\Users\\chenqin.pan\\Downloads\\SSMG_AMER_reported.csv", row.names = FALSE)


METL_AMER_reported <- reported_operational_balances%>%
  filter(ULT_PARENT_CD == 'METL000')
write.csv(METL_AMER_reported, "C:\\Users\\chenqin.pan\\Downloads\\METL_AMER_reported.csv", row.names = FALSE)


View(raw_data_consol)
--------------------------------------------------------------
# Payment trend ratio analysis
raw_daily_totals_baseline_intra <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  raw_data_consol, 
  '2025-03-31', 
  'INTRA-DAY'
)  



raw_daily_totals_baseline_MDL <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  raw_data_consol, 
  '2025-03-31', 
  'Multi-Day Low'
)  


raw_daily_totals_baseline_MDH <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  raw_data_consol, 
  '2025-03-31', 
  'Multi-Day High'
)  

spike_days_stats <- calculate_spike_days_stats(raw_data_consol, threshold = 4, start_date = "2023-03-31")
spike_days_stats_intra <- calculate_spike_days_stats(raw_daily_totals_baseline_intra, threshold = 4, start_date = "2023-03-31")
spike_days_stats_mdl <- calculate_spike_days_stats(raw_daily_totals_baseline_MDL, threshold = 4, start_date = "2023-03-31")
spike_days_stats_mdh <- calculate_spike_days_stats(raw_daily_totals_baseline_MDH, threshold = 4, start_date = "2023-03-31")



View(spike_days_stats)
View(spike_days_stats_intra)
View(spike_days_stats_mdl)

View(spike_days_stats_mdh)

write.csv(spike_days_stats, "C:\\Users\\chenqin.pan\\Downloads\\spike_days_stats.csv", row.names = FALSE)

write.csv(spike_days_stats_intra, "C:\\Users\\chenqin.pan\\Downloads\\spike_days_stats_intra.csv", row.names = FALSE)

write.csv(spike_days_stats_mdl, "C:\\Users\\chenqin.pan\\Downloads\\spike_days_stats_mdl.csv", row.names = FALSE)

write.csv(spike_days_stats_mdh, "C:\\Users\\chenqin.pan\\Downloads\\spike_days_stats_mdh.csv", row.names = FALSE)
