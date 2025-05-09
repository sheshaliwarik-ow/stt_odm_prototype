
# Function to update balances
handle_balance_spikes <- function(df) {
  spike_cap = 30 * 1000000000
  df <- df %>%
    arrange(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE) %>%
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    mutate(TOTAL_PRIN_BAL_USD = ifelse(TOTAL_PRIN_BAL_USD > spike_cap, lag(TOTAL_PRIN_BAL_USD), TOTAL_PRIN_BAL_USD))
  return(df)
}

# Function to get first and last AS_OF_DATE for each group
get_first_last_dates <- function(df) {
  df %>%
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG) %>%
    summarise(
      first_date = min(as.Date(AS_OF_DATE, format = "%m/%d/%Y")),
      last_date = max(as.Date(AS_OF_DATE, format = "%m/%d/%Y")),
      .groups = 'drop'
    )
}

# Generate date sequence dataframe with additional parameter for specific dates
generate_date_sequence_dataframe <- function(data, date_list) {
  data_with_dates <- data %>%
    mutate(date_sequence = map2(first_date, last_date, ~ seq(from = .x, to = .y, by = "day"))) 
  
  date_sequences <- data_with_dates %>%
    unnest(date_sequence) %>%
    select(ULT_PARENT_CD, REGION, ENTITY_FLAG, date = date_sequence) %>%
    filter(date %in% date_list)  # Filter based on the provided date list
  
  return(date_sequences)
}

# Create dummy rows with additional parameter for specific dates
create_dummy_rows <- function(date_sequences, df, date_list) {
  date_sequences <- date_sequences %>%
    rename(AS_OF_DATE = date)
  
  df <- df %>%
    mutate(AS_OF_DATE = as.Date(AS_OF_DATE, format = "%m/%d/%Y"))
  
  date_sequences <- date_sequences %>%
    mutate(AS_OF_DATE = as.Date(AS_OF_DATE))
  
  result <- df %>%
    full_join(date_sequences, by = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG", "AS_OF_DATE")) %>%
    mutate(
      TOTAL_OUTFLOW = ifelse(is.na(TOTAL_OUTFLOW), 0, TOTAL_OUTFLOW),
      TOTAL_PRIN_BAL_USD = ifelse(is.na(TOTAL_PRIN_BAL_USD), 0, TOTAL_PRIN_BAL_USD)
    ) %>%
    select(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE, TOTAL_OUTFLOW, TOTAL_PRIN_BAL_USD) %>%
    filter(AS_OF_DATE %in% date_list)  # Filter to include only the specified dates
  
  return(result)
}


consolidate_rows <- function(df) {
  
  # Check if the necessary columns exist in the data frame
  if (!all(c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG", "AS_OF_DATE", "TOTAL_PRIN_BAL_USD", "TOTAL_OUTFLOW") %in% colnames(df))) {
    stop("Data frame must contain the required columns: ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE, TOTAL_PRIN_BAL_USD, TOTAL_OUTFLOW")
  }
  
  # Consolidate the rows by summing TOTAL_PRIN_BAL_USD and TOTAL_OUTFLOW
  consolidated_df <- df %>%
    group_by(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE) %>%
    summarise(
      TOTAL_PRIN_BAL_USD = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE),
      TOTAL_OUTFLOW = sum(TOTAL_OUTFLOW, na.rm = TRUE),
      .groups = 'drop'  # Drop the grouping after summarization
    )
  
  return(consolidated_df)
}