# Function to join two data frames containing results
join_result_dataframes <- function(baseline_ob, existing_ODM_results) {
  # Perform the join operation
  result_df <- baseline_ob %>%
    left_join(existing_ODM_results, 
              by = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG", "AS_OF_DATE"))
  
  return(result_df)
}

handle_balance_spikes_reported <- function(df) {
  spike_cap = 30 * 1000000000
  df <- df %>%
    arrange(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE) %>%
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    mutate(DAILY_SPOT_BAL_USD = ifelse(DAILY_SPOT_BAL_USD > spike_cap, lag(DAILY_SPOT_BAL_USD), DAILY_SPOT_BAL_USD))
  return(df)
}

process_operational_balances_with_behavioral_groups <- function(existing_data, baseline_data, date_limit, last_behavioral_group, entity) {
  
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
      ENTITY_FLAG = entity,
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

calculate_daily_totals <- function (result) {
  required_columns <- c("AS_OF_DATE", "operational_balance_v2", "TOTAL_PRIN_BAL_USD")
  daily_totals <- result %>%
    group_by(AS_OF_DATE) %>%
    summarise (
      total_operational_balance = sum(operational_balance, na.rm = TRUE), 
      total_principal_balance = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE)
    )
  return(daily_totals)
}