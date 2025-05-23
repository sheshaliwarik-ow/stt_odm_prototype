
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


# Handle balance spike in the reported data 

handle_balance_spikes_reported <- function(df) {
  spike_cap = 30 * 1000000000
  df <- df %>%
    arrange(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE) %>%
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    mutate(DAILY_SPOT_BAL_USD = ifelse(DAILY_SPOT_BAL_USD > spike_cap, lag(DAILY_SPOT_BAL_USD), DAILY_SPOT_BAL_USD))
  return(df)
}


# Consolidate reported data at the portfolio level 
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


# Consolidate reported data at the region level 

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



# Consolidate reported data at the legal entity level 

consolidate_rows_reported_LE <- function(df) {
  
  # Consolidate the rows by summing TOTAL_PRIN_BAL_USD and TOTAL_OUTFLOW
  consolidated_df <- df %>%
    group_by( AS_OF_DATE,ENTITY_FLAG) %>%
    summarise(
      DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD, na.rm = TRUE),
      OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD, na.rm = TRUE),
      
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}


# Consolidate model data at the portfolio level 

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

# Consolidate model data at the region level 

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


# Data processing for the reported data (level 1 level 2 mapping only)
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
    select(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE, TOTAL_PRIN_BAL_USD, Total_Operational_Balance )
  
  
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


# Data processing for the reported data (map the reported data with the tuples_last_behavioralgroup )

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





process_reported_operational_balances_SSBIBT <- function(data, date_limit) {
  # Filter the data based on the specified date limit
  reported_operational_balances <- data %>%
    filter(AS_OF_DATE <= date_limit & (ENTITY_FLAG == "SSBI" | ENTITY_FLAG == "SSBT"))
  
  # Group and summarize the operational balances
  reported_operational_balances <- reported_operational_balances %>%
    group_by(ULT_PARENT_CD, REGION, AS_OF_DATE, ENTITY_FLAG) %>%
    summarise(
      PERIOD_ID = min(PERIOD_ID),
      DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD),
      OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD),
      EXCESS_BAL_USD = sum(EXCESS_BAL_USD),
      BEHAVIORAL_GROUP = min(BEHAVIORAL_GROUP),
      .groups = 'drop'  # Prevents grouping from being retained
    ) %>%
    mutate(
      CAPTURE_RATE = ifelse(DAILY_SPOT_BAL_USD <= 0, 0, OPERATIONAL_BAL_USD / DAILY_SPOT_BAL_USD),
      DAILY_SPOT_BAL_USD = ifelse(DAILY_SPOT_BAL_USD < 0, 0, DAILY_SPOT_BAL_USD)
    ) %>%
    handle_balance_spikes_reported() 
  
  return(reported_operational_balances)
}




# Consolidate six monthly run data at the portfolio level 

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


# Consolidate reported data at the portfolio level before mapping and bridging


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



# Consolidate six monthly run data at the region level
consolidate_rows_raw_region <- function(df) {
  
  
  # Consolidate the rows by summing TOTAL_PRIN_BAL_USD and TOTAL_OUTFLOW
  consolidated_df <- df %>%
    group_by( AS_OF_DATE,REGION) %>%
    summarise(
      TOTAL_PRIN_BAL_USD = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE),
      TOTAL_OUTFLOW = sum(TOTAL_OUTFLOW, na.rm = TRUE),
      
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}


# Consolidate six monthly run data at the behavioral group level

consolidate_rows_raw_behavioralgroup <- function(df) {
  
  
  # Consolidate the rows by summing TOTAL_PRIN_BAL_USD and TOTAL_OUTFLOW
  consolidated_df <- df %>%
    group_by( AS_OF_DATE,LAST_BEHAVIORAL_GROUP) %>%
    summarise(
      TOTAL_PRIN_BAL_USD = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE),
      TOTAL_OUTFLOW = sum(TOTAL_OUTFLOW, na.rm = TRUE),
      
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}


# Consolidate reported data at the behavioral group level

consolidate_rows_reported_behavioralgroup <- function(data, behavioral_group) {
  result <- data %>%
    filter(LAST_BEHAVIORAL_GROUP == behavioral_group) %>%
    group_by(AS_OF_DATE) %>%
    summarise(
      PERIOD_ID = min(PERIOD_ID),
      DAILY_SPOT_BAL_USD = sum(DAILY_SPOT_BAL_USD, na.rm = TRUE),
      OPERATIONAL_BAL_USD = sum(OPERATIONAL_BAL_USD, na.rm = TRUE),
      EXCESS_BAL_USD = sum(EXCESS_BAL_USD, na.rm = TRUE),
      .groups = 'drop'  # Prevents grouping from being retained
    ) %>%
    mutate(CAPTURE_RATE = ifelse(DAILY_SPOT_BAL_USD <= 0, 0, OPERATIONAL_BAL_USD / DAILY_SPOT_BAL_USD))
  
  return(result)  # Return the resulting data frame
}


# Data processing for the model data (map the model data with the tuples_last_behavioralgroup from reported data )

process_operational_balances_with_behavioral_groups <- function(existing_data, baseline_data, date_limit, last_behavioral_group) {
  # Filter the data based on the specified date limit
  reported_operational_balances <- existing_data %>%
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
  
  # Join the last behavioral group back to the baseline data
  operational_balance_baseline_w_behavioral_group <- baseline_data %>%
    left_join(tuples_last_behavioralgroup, by = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG"))
  
  # Filter for the specified LAST_BEHAVIORAL_GROUP
  operational_balance_baseline_filtered <- operational_balance_baseline_w_behavioral_group %>%
    filter(LAST_BEHAVIORAL_GROUP == last_behavioral_group)
  
  # Return only the filtered operational balances
  return(operational_balance_baseline_filtered)
}


#Top n Tuples Ranked by Total Balance Segmented by Behavioral Group as of YYYY-MM-DD

get_top_n_behavioral_group <- function(existing_ODM_results, raw_data_consol, as_of_date, behavioral_group, n = 10) {
  
  # Process operational balances with behavioral groups
  raw_daily_totals_baseline <- process_operational_balances_with_behavioral_groups(
    existing_ODM_results, 
    raw_data_consol, 
    as_of_date, 
    behavioral_group
  )  
  
  # Get the top N entries based on TOTAL_PRIN_BAL_USD for the specified date
  top_n <- raw_daily_totals_baseline %>%
    filter(AS_OF_DATE == as_of_date) %>%
    arrange(desc(TOTAL_PRIN_BAL_USD)) %>%
    slice_head(n = n)  
  
  # Filter the consolidated data for the top N entries
  raw_data_consol_top_n <- raw_daily_totals_baseline %>%
    filter(REGION %in% top_n$REGION & ULT_PARENT_CD %in% top_n$ULT_PARENT_CD)
  
  # Return both top_n and raw_data_consol_top_n as a list
  return(list(top_n = top_n, raw_data_consol_top_n = raw_data_consol_top_n))
}





# Payment trend ratio
calculate_spike_days_stats <- function(raw_data_consol, threshold = 3, start_date = "2023-03-31") {
  
  # Convert the AS_OF_DATE to Date format
  raw_data_consol$AS_OF_DATE <- as.Date(raw_data_consol$AS_OF_DATE)
  
  # Sort the DataFrame by AS_OF_DATE
  raw_data_consol_process <- raw_data_consol %>%
    filter(ULT_PARENT_CD != "0") %>%  # Remove rows where ULT_PARENT_CD is 0
    arrange(AS_OF_DATE)              # Sort the DataFrame by AS_OF_DATE
  
  # Calculate the 125-day moving average for TOTAL_OUTFLOW for each group
  raw_data_consol_process <- raw_data_consol_process %>%
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    mutate(
      day_125_MA = sapply(1:n(), function(i) {
        if (i < 125) {
          return(NA)  # Not enough data for the first 124 entries
        } else {
          return(mean(TOTAL_OUTFLOW[(i-124):i], na.rm = TRUE))  # Calculate mean for the last 125 entries
        }
      }),
      day_125_SD = sapply(1:n(), function(i) {
        if (i < 125) {
          return(NA)  # Not enough data for the first 124 entries
        } else {
          return(sd(TOTAL_OUTFLOW[(i-124):i], na.rm = TRUE))  # Calculate standard deviation for the last 125 entries
        }
      })
    ) %>%
    ungroup()
  
  # Create the new column based on the provided formula
  raw_data_consol_process <- raw_data_consol_process %>%
    mutate(threshold_value = (TOTAL_OUTFLOW - day_125_MA) / day_125_SD)
  
  # Identify spikes based on the threshold
  raw_data_consol_process <- raw_data_consol_process %>%
    mutate(Spike = ifelse(threshold_value > threshold, 1, 0))
  
  raw_data_consol_process <- raw_data_consol_process %>%
    arrange(AS_OF_DATE) %>%  # Ensure data is sorted by date
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    mutate(Spike_process = ifelse(Spike == 1 & (lag(Spike, default = 0) == 0 & lag(Spike, n = 2, default = 0) == 0), 
                                  1, 
                                  0)) %>%
    ungroup()  # Ungroup after processing
  
  
  # Calculate the days between the occurrences of 1 in Spike_process
  spike_days <- raw_data_consol_process %>%
    filter(Spike_process == 1, AS_OF_DATE >= as.Date(start_date)) %>%  # Keep only the rows where Spike_process is 1 and date is on or after the specified start date
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    summarise(spike_dates = list(AS_OF_DATE), .groups = 'drop') %>%
    # Filter to keep only tuples with at least 5 spikes
    filter(length(spike_dates) >= 5) %>%
    mutate(days_between_spikes = lapply(spike_dates, function(dates) {
      if (length(dates) > 1) {
        return(as.numeric(diff(dates)))  # Calculate differences in days
      } else {
        return(NA)  # If there's only one spike, return NA
      }
    })) %>%
    unnest(cols = c(days_between_spikes)) %>%  # Unnest the list to create rows for each difference
    rename(days_between_spike = days_between_spikes)
  
  # Now calculate average and standard deviation of days_between_spikes for each tuple
  spike_days_stats <- spike_days %>%
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    summarise(
      avg_days_between_spikes = mean(days_between_spike, na.rm = TRUE),
      sd_days_between_spikes = sd(days_between_spike, na.rm = TRUE),
      ratio = avg_days_between_spikes / sd_days_between_spikes,
      .groups = 'drop'  # Ungroup after summarizing
    ) %>%
    filter(!is.na(ratio))  # Ensure we only keep valid ratio
  
  return(spike_days_stats)  # Return the final DataFrame
}
