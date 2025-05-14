
# check differences in the total principal balance between the old model result and new model result 

aggregate_ineligibility <- function(df) {
  
  # Consolidate the rows by summing TOTAL_PRIN_BAL_USD and Total_Operational_Balance
  consolidated_df <- df %>%
    filter(eligibility == 0) %>%  # Filter rows where eligibility is 0
    group_by(AS_OF_DATE) %>%
    summarise(
      TOTAL_PRIN_BAL_USD = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE),
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}



# Count Unique UP over time

count_Unique_UP_over_time <- function(data) {
  filtered_data <- data %>%
    filter(!is.na(ULT_PARENT_CD) & ULT_PARENT_CD != 0)  # Exclude rows where ULT_PARENT_CD is 0 or NA
  
  # Group by the specified columns and count unique ULT_PARENT_CD
  counted_data <- filtered_data %>%
    group_by(AS_OF_DATE) %>%
    summarize(UP_Count = n_distinct(ULT_PARENT_CD), .groups = 'drop')  # Count unique ULT_PARENT_CD
  
  return(counted_data)
}

# Count Unique Tuples over time

count_unique_tuples_over_time <- function(data) {
  filtered_data <- data %>%
    filter(!is.na(ULT_PARENT_CD) & ULT_PARENT_CD != 0)  # Exclude rows where ULT_PARENT_CD is 0 or NA
  
  # Group by AS_OF_DATE and count unique combinations of REGION, ENTITY_FLAG, and ULT_PARENT_CD
  counted_data <- filtered_data %>%
    group_by(AS_OF_DATE) %>%
    summarize(Unique_Tuple_Count = n_distinct(paste(REGION, ENTITY_FLAG, ULT_PARENT_CD)), .groups = 'drop')  # Count unique tuples
  
  return(counted_data)
}

# List Unique UP
list_Unique_UP <- function(data) {
  # Filter out rows where ULT_PARENT_CD is NA or 0
  filtered_data <- data %>%
    filter(!is.na(ULT_PARENT_CD) & ULT_PARENT_CD != 0)
  
  # Get unique ULT_PARENT_CD values
  unique_UP <- filtered_data %>%
    distinct(ULT_PARENT_CD) %>%
    pull(ULT_PARENT_CD)  # Extract the ULT_PARENT_CD column as a vector
  
  return(unique_UP)
}


handle_balance_spikes_reported <- function(df) {
  spike_cap = 30 * 1000000000
  df <- df %>%
    arrange(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE) %>%
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    mutate(DAILY_SPOT_BAL_USD = ifelse(DAILY_SPOT_BAL_USD > spike_cap, lag(DAILY_SPOT_BAL_USD), DAILY_SPOT_BAL_USD))
  return(df)
}


consolidate_rows_reported <- function(df) {
  
  
  # Consolidate the rows by summing TOTAL_PRIN_BAL_USD and TOTAL_OUTFLOW
  consolidated_df <- df %>%
    group_by( AS_OF_DATE) %>%
    summarise(
      DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD, na.rm = TRUE),
      OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD, na.rm = TRUE),
      
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}



consolidate_rows_reported_region <- function(df) {
  
  # Consolidate the rows by summing TOTAL_PRIN_BAL_USD and TOTAL_OUTFLOW
  consolidated_df <- df %>%
    group_by( AS_OF_DATE,REGION) %>%
    summarise(
      DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD, na.rm = TRUE),
      OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD, na.rm = TRUE),
      
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}



calculate_daily_totals <- function (result) {
  
  required_columns <- c("AS_OF_DATE", "operational_balance", "TOTAL_PRIN_BAL_USD")
  
  daily_totals <- result %>%
    group_by(AS_OF_DATE) %>%
    summarise (
      total_operational_balance = sum(operational_balance, na.rm = TRUE), 
      total_principal_balance = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE)
    )
  
  return(daily_totals)
}


consolidate_rows_region <- function(df) {
  
  consolidated_df <- df %>%
    group_by( AS_OF_DATE,REGION) %>%
    summarise(
      total_principal_balance = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE),
      total_operational_balance = sum(operational_balance, na.rm = TRUE),
      
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}


data_preprocessing_reported <- function(existing_ODM_results, CDMS_mapping) {
  
  # Clean and process the merged dataframe
  clean_merge_dataframe <- existing_ODM_results %>%
    mutate(Is_Level_2 = ifelse(ULT_PARENT_CD %in% CDMS_mapping$CUST_CD, "Y", "N"),
           Level_1_Mapping = ifelse(Is_Level_2 == "N",
                                    ULT_PARENT_CD,
                                    CDMS_mapping$ULT_PARENT_CD[match(ULT_PARENT_CD, CDMS_mapping$CUST_CD)])) %>%
    mutate(Level_1_Mapping = ifelse(is.na(Level_1_Mapping), ULT_PARENT_CD, Level_1_Mapping),
           TOTAL_PRIN_BAL_USD = ifelse(DAILY_SPOT_BAL_USD < 0, 0, DAILY_SPOT_BAL_USD)) %>%
    handle_balance_spikes() 
  
  clean_merge_dataframe_report <- clean_merge_dataframe %>%
    group_by(Level_1_Mapping, REGION, ENTITY_FLAG, AS_OF_DATE) %>%
    summarize(
      TOTAL_PRIN_BAL_USD = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE), 
      Total_Operational_Balance = sum(OPERATIONAL_BAL_USD, na.rm = TRUE), 
      .groups = 'drop'
    ) %>%
    rename(ULT_PARENT_CD = Level_1_Mapping)%>%
    select(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE, TOTAL_PRIN_BAL_USD, Total_Operational_Balance)
  
  
  # Filter for raw_data_consol
  raw_data_consol <- clean_merge_dataframe_report %>%
    filter(ENTITY_FLAG == "CONSOL")
  
  # Filter for raw_data_last
  raw_data_last <- clean_merge_dataframe_report %>%
    filter(AS_OF_DATE >= as.Date("2023-10-01") &
             AS_OF_DATE <= as.Date("2025-03-31") &
             ENTITY_FLAG %in% c("SSBI", "SSBT"))
  
  return(list(clean_merge_dataframe = clean_merge_dataframe_report ,raw_data_consol = raw_data_consol, raw_data_last = raw_data_last))
}


process_reported_operational_balances <- function(data, date_limit) {
  # Filter the data based on the specified date limit
  reported_operational_balances <- data %>%
    filter(AS_OF_DATE <= date_limit)
  
  # Group and summarize the operational balances
  reported_operational_balances <- reported_operational_balances %>%
    group_by(ULT_PARENT_CD, REGION, AS_OF_DATE) %>%
    summarise(
      PERIOD_ID = min(PERIOD_ID),
      DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD),
      OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD),
      EXCESS_BAL_USD = sum(EXCESS_BAL_USD),
      ENTITY_FLAG = "CONSOL",
      BEHAVIORAL_GROUP = min(BEHAVIORAL_GROUP),
      .groups = 'drop'  # Prevents grouping from being retained
    ) %>%
    mutate(
      CAPTURE_RATE = ifelse(DAILY_SPOT_BAL_USD <= 0, 0, OPERATIONAL_BAL_USD / DAILY_SPOT_BAL_USD),
      DAILY_SPOT_BAL_USD = ifelse(DAILY_SPOT_BAL_USD < 0, 0, DAILY_SPOT_BAL_USD)
    ) %>%
    handle_balance_spikes_reported() 
  
  # Get the last behavioral group for each unique tuple
  tuples_last_behavioralgroup <- reported_operational_balances %>%
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    summarize(LAST_AS_OF_DATE = max(AS_OF_DATE), .groups = 'drop')
  
  # Join to get the last behavioral group
  tuples_last_behavioralgroup <- reported_operational_balances %>%
    left_join(tuples_last_behavioralgroup, by = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG")) %>%
    filter(AS_OF_DATE == LAST_AS_OF_DATE) %>%
    rename(LAST_BEHAVIORAL_GROUP = BEHAVIORAL_GROUP) %>%
    select(c('ULT_PARENT_CD', 'REGION', 'ENTITY_FLAG', 'LAST_AS_OF_DATE', 'LAST_BEHAVIORAL_GROUP'))
  
  # Join the last behavioral group back to the reported operational balances
  reported_operational_balances <- reported_operational_balances %>%
    left_join(tuples_last_behavioralgroup, by = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG"))
  
  return(reported_operational_balances)
}
consolidate_rows_raw <- function(df) {
  
  
  # Consolidate the rows by summing TOTAL_PRIN_BAL_USD and TOTAL_OUTFLOW
  consolidated_df <- df %>%
    group_by( AS_OF_DATE) %>%
    summarise(
      TOTAL_PRIN_BAL_USD = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE),
      TOTAL_OUTFLOW = sum(TOTAL_OUTFLOW, na.rm = TRUE),
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}

consolidate_rows_reported_before_mapping_and_bridging <- function(df) {
  
  # Consolidate the rows by summing TOTAL_PRIN_BAL_USD and TOTAL_OUTFLOW
  consolidated_df <- df %>%
    group_by( AS_OF_DATE) %>%
    summarise(
      DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD, na.rm = TRUE),
      OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD, na.rm = TRUE),
      
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}
