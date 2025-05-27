calculate_operational_balance <- function(
    dt,
    short_lookback = 1,
    long_lookback = 3,
    group_cols = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG"),
    date_col = "AS_OF_DATE",
    outflow_col = "TOTAL_OUTFLOW",
    prinbal_col = "TOTAL_PRIN_BAL_USD",
    cap = 1,
    n = 1,
    eligibility_months = 3,          # New parameter for eligibility months
    start_date = NULL,
    end_date = NULL
) {
  
  t0 <- Sys.time()
  message("Starting operational balance calculation...")
  
  dt <- as.data.table(dt)
  dt[, (date_col) := as.Date(get(date_col))]
  
  # Calculate window starts with hybrid logic
  dt[, short_lookback_start := if (short_lookback >= 1) {
    get(date_col) %m-% months(short_lookback)
  } else {
    get(date_col) - round(short_lookback * 30)
  }]
  
  dt[, long_lookback_start := if (long_lookback >= 1) {
    get(date_col) %m-% months(long_lookback)
  } else {
    get(date_col) - round(long_lookback * 30)
  }]
  
  # Get tuple_start and tuple_end for each group
  dt[, tuple_start := min(get(date_col), na.rm=TRUE), by=group_cols]
  dt[, tuple_end   := max(get(date_col), na.rm=TRUE), by=group_cols]
  
  # Set eligibility based on new logic
  dt[, eligibility := as.integer(tuple_start <= (get(date_col) %m-% months(eligibility_months)))]
  
  # Set keys
  setkeyv(dt, c(group_cols, date_col))
  
  message("Calculating rolling statistics...")
  
  # Helper for rolling stats
  rolling_join <- function(start_col, suffix) {
    dt[dt,
       on = c(
         setNames(group_cols, group_cols),
         sprintf("%s >= %s", date_col, start_col),
         sprintf("%s <= %s", date_col, date_col)
       ),
       .(
         avg_balance = mean(get(prinbal_col), na.rm=TRUE),
         avg_payment = mean(get(outflow_col), na.rm=TRUE),
         std_payment = sd(get(outflow_col), na.rm=TRUE)
       ),
       by = .EACHI
    ][, paste0(
      c("avg_balance", "avg_payment", "std_payment"), "_", suffix
    ) := .(avg_balance, avg_payment, std_payment)][
      , .SD, .SDcols = patterns(paste0("_", suffix, "$"))
    ]
  }
  
  # Compute rolling stats
  stats_LLB <- rolling_join("long_lookback_start", "LLB")   # Long LookBack
  stats_SLB <- rolling_join("short_lookback_start", "SLB")  # Short LookBack
  
  message("Rolling statistics calculations complete!")
  
  # Combine results
  dt <- cbind(
    dt,
    stats_LLB,
    stats_SLB
  )
  
  # Compute RAA_BPR
  dt[, RAA_BPR := avg_balance_LLB / (avg_payment_LLB + n * std_payment_LLB)]
  
  # Precompute sum of principal balance for group/date
  dt[, sum_prinbal := sum(get(prinbal_col), na.rm=TRUE), by = c(group_cols, date_col)]
  
  # Compute operational_balance
  dt[, operational_balance := fifelse(
    eligibility == 0, 0,
    pmin(
      pmin(RAA_BPR, cap) * (avg_payment_SLB + n * std_payment_SLB),
      sum_prinbal
    )
  )]
  
  # Select and rename columns for output
  result <- dt[, .(
    ULT_PARENT_CD = get("ULT_PARENT_CD"),
    REGION = get("REGION"),
    ENTITY_FLAG = get("ENTITY_FLAG"),
    AS_OF_DATE = get(date_col),
    tuple_start,
    tuple_end,
    short_lookback_start,
    long_lookback_start,
    eligibility,
    average_balance_LLB = avg_balance_LLB,
    average_payment_LLB = avg_payment_LLB,
    std_payment_LLB = std_payment_LLB,
    average_payment_SLB = avg_payment_SLB,
    std_payment_SLB = std_payment_SLB,
    TOTAL_OUTFLOW = get(outflow_col),
    TOTAL_PRIN_BAL_USD = get(prinbal_col),
    RAA_BPR,
    operational_balance
  )]
  
  # Filter by start_date and end_date if provided
  if (!is.null(start_date)) {
    start_date <- as.Date(start_date)
    result <- result[AS_OF_DATE >= start_date]
  }
  if (!is.null(end_date)) {
    end_date <- as.Date(end_date)
    result <- result[AS_OF_DATE <= end_date]
  }
  
  t1 <- Sys.time()
  message(sprintf("Operational balance calculation complete. Elapsed time: %.2f seconds", as.numeric(difftime(t1, t0, units = "secs"))))
  
  return(result)
}

calculate_operational_balance_v2 <- function(
    dt,
    group_cols = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG"),
    date_col = "AS_OF_DATE",
    outflow_col = "TOTAL_OUTFLOW",
    prinbal_col = "TOTAL_PRIN_BAL_USD",
    Balance_Cushion_Multiplier = 1,  # Renamed parameter
    Payment_Cushion_Multiplier = 1,   # Renamed parameter
    cash_management_horizon = 1,       # New parameter
    choice = 0,                        # New binary parameter
    BLB = 3,                           # New parameter for Balance Lookback (in months)
    PLB = 3,                           # New parameter for Payment Lookback (in months)
    Balance_Percentile = NULL,         # New parameter for Balance Percentile
    Payment_Percentile = NULL,         # New parameter for Payment Percentile
    smoothing = 1,                     # New parameter for smoothing
    adjustment_factor = 1,             # New parameter for adjustment factor
    eligibility_months = 3,            # New parameter for eligibility months
    start_date = NULL,
    end_date = NULL
) {
  
  t0 <- Sys.time()
  message("Starting operational balance calculation v2...")
  
  dt <- as.data.table(dt)
  dt[, (date_col) := as.Date(get(date_col))]
  
  # Calculate BLB and PLB start dates with hybrid logic
  dt[, blb_start := if (BLB >= 1) {
    get(date_col) %m-% months(BLB)
  } else {
    get(date_col) - round(BLB * 30)
  }]
  
  dt[, plb_start := if (PLB >= 1) {
    get(date_col) %m-% months(PLB)
  } else {
    get(date_col) - round(PLB * 30)
  }]
  
  # Get tuple_start and tuple_end for each group
  dt[, tuple_start := min(get(date_col), na.rm=TRUE), by=group_cols]
  dt[, tuple_end   := max(get(date_col), na.rm=TRUE), by=group_cols]
  
  # Set eligibility based on eligibility_months parameter
  dt[, eligibility := as.integer(tuple_start <= (get(date_col) %m-% months(eligibility_months)))]
  
  # Set keys
  setkeyv(dt, c(group_cols, date_col))
  
  message("Calculating smoothing damper...")
  
  # Calculate the smoothing damper
  if (smoothing > 0) {
    dt[, smoothing_damper := frollmean(get(prinbal_col), smoothing, align = "right", na.rm = TRUE), by = group_cols]
  } else {
    dt[, smoothing_damper := 0]  # Set to 0 if smoothing is not positive
  }
  
  message("Calculating rolling statistics...")
  
  # Helper for rolling stats
  rolling_join <- function(start_col, suffix) {
    if (choice == 0) {
      # Calculate average and standard deviation for version 2.1
      dt[dt,
         on = c(
           setNames(group_cols, group_cols),
           sprintf("%s >= %s", date_col, start_col),
           sprintf("%s <= %s", date_col, date_col)
         ),
         .(
           avg_balance = mean(get(prinbal_col), na.rm=TRUE),
           avg_payment = mean(get(outflow_col), na.rm=TRUE),
           std_balance = sd(get(prinbal_col), na.rm=TRUE),
           std_payment = sd(get(outflow_col), na.rm=TRUE)
         ),
         by = .EACHI
      ][, paste0(
        c("avg_balance", "avg_payment", "std_balance", "std_payment"), "_", suffix
      ) := .(avg_balance, avg_payment, std_balance, std_payment)][
        , .SD, .SDcols = patterns(paste0("_", suffix, "$"))
      ]
    } else if (choice == 1) {
      # Calculate percentiles for version 2.2
      dt[dt,
         on = c(
           setNames(group_cols, group_cols),
           sprintf("%s >= %s", date_col, start_col),
           sprintf("%s <= %s", date_col, date_col)
         ),
         .(
           percentile_balance = quantile(get(prinbal_col), Balance_Percentile, na.rm=TRUE),
           percentile_payment = quantile(get(outflow_col), Payment_Percentile, na.rm=TRUE)
         ),
         by = .EACHI
      ][, paste0(
        c("percentile_balance", "percentile_payment"), "_", suffix
      ) := .(percentile_balance, percentile_payment)][
        , .SD, .SDcols = patterns(paste0("_", suffix, "$"))
      ]
    }
  }
  
  if (choice == 0) {
    
    message("Rolling statistics calculations started for version 2.1...")
    # Compute rolling stats for version 2.1
    stats_BLB <- rolling_join("blb_start", "BLB")   # Balance LookBack
    stats_PLB <- rolling_join("plb_start", "PLB")  # Payment LookBack
    
    message("Rolling statistics calculations complete for version 2.1!")
    
    # Combine results
    dt <- cbind(
      dt,
      stats_BLB,
      stats_PLB
    )
    
    # Precompute sum of principal balance for group/date
    dt[, sum_prinbal := sum(get(prinbal_col), na.rm=TRUE), by = c(group_cols, date_col)]
    
    # Compute operational_balance_v2 for version 2.1
    dt[, operational_balance := fifelse(
      eligibility == 0, 0,
      pmin(
        cash_management_horizon * (avg_payment_PLB + Payment_Cushion_Multiplier * std_payment_PLB),
        avg_balance_BLB + Balance_Cushion_Multiplier * std_balance_BLB,
        sum_prinbal,
        smoothing_damper
      ) * adjustment_factor
    )]
    
    # Select and rename columns for output for version 2.1
    result <- dt[, .(
      ULT_PARENT_CD = get("ULT_PARENT_CD"),
      REGION = get("REGION"),
      ENTITY_FLAG = get("ENTITY_FLAG"),
      AS_OF_DATE = get(date_col),
      tuple_start,
      tuple_end,
      blb_start,
      plb_start,
      eligibility,
      average_balance_BLB = avg_balance_BLB,
      average_payment_PLB = avg_payment_PLB,
      simple_BPR = avg_balance_BLB/avg_payment_PLB,
      std_balance_BLB = std_balance_BLB,
      std_payment_PLB = std_payment_PLB,
      TOTAL_OUTFLOW = get(outflow_col),
      TOTAL_PRIN_BAL_USD = get(prinbal_col),
      VA_Payment =  cash_management_horizon * (avg_payment_PLB + Payment_Cushion_Multiplier * std_payment_PLB),
      VA_Balance = (avg_balance_BLB + Balance_Cushion_Multiplier * std_balance_BLB), 
      VA_BPR = (avg_balance_BLB + Balance_Cushion_Multiplier * std_balance_BLB)/(cash_management_horizon * (avg_payment_PLB + Payment_Cushion_Multiplier * std_payment_PLB)),
      operational_balance,
      smoothing = smoothing,
      smoothing_damper = smoothing_damper,
      adjustment_factor = adjustment_factor,
      cash_management_horizon = cash_management_horizon
    )]
    
  } else if (choice == 1) {
    # Compute rolling stats for version 2.2
    stats_BLB <- rolling_join("blb_start", "BLB")   # Balance LookBack
    stats_PLB <- rolling_join("plb_start", "PLB")  # Payment LookBack
    
    message("Rolling statistics calculations complete for version 2.2!")
    
    # Combine results
    dt <- cbind(
      dt,
      stats_BLB,
      stats_PLB
    )
    
    # Precompute sum of principal balance for group/date
    dt[, sum_prinbal := sum(get(prinbal_col), na.rm=TRUE), by = c(group_cols, date_col)]
    
    # Compute operational_balance_v2 for version 2.2
    dt[, operational_balance := fifelse(
      eligibility == 0, 0,
      pmin(
        cash_management_horizon * percentile_payment_PLB,
        percentile_balance_BLB,
        sum_prinbal,
        smoothing_damper
      ) * adjustment_factor
    )]
    
    # Select and rename columns for output for version 2.2
    result <- dt[, .(
      ULT_PARENT_CD = get("ULT_PARENT_CD"),
      REGION = get("REGION"),
      ENTITY_FLAG = get("ENTITY_FLAG"),
      AS_OF_DATE = get(date_col),
      tuple_start,
      tuple_end,
      blb_start,
      plb_start,
      eligibility,
      percentile_balance_BLB,
      percentile_payment_PLB,
      simple_BPR = percentile_balance_BLB/percentile_payment_PLB,
      TOTAL_OUTFLOW = get(outflow_col),
      TOTAL_PRIN_BAL_USD = get(prinbal_col),
      VA_BPR = percentile_balance_BLB/percentile_payment_PLB, 
      operational_balance,
      smoothing = smoothing,
      smoothing_damper = smoothing_damper,
      adjustment_factor = adjustment_factor,
      cash_management_horizon = cash_management_horizon
    )]
  }
  
  # Filter by start_date and end_date if provided
  if (!is.null(start_date)) {
    start_date <- as.Date(start_date)
    result <- result[AS_OF_DATE >= start_date]
  }
  if (!is.null(end_date)) {
    end_date <- as.Date(end_date)
    result <- result[AS_OF_DATE <= end_date]
  }
  
  t1 <- Sys.time()
  message(sprintf("Operational balance calculation v2 complete. Elapsed time: %.2f seconds", as.numeric(difftime(t1, t0, units = "secs"))))
  
  return(result)
}

summarize_daily_operational_balance <- function(dt) {
  
  dt <- as.data.table(dt)
  
  # Identify columns that start with 'operational_balance'
  operational_balance_cols <- grep("^operational_balance", names(dt), value = TRUE)
  
  # Check if any operational balance columns exist
  if (length(operational_balance_cols) == 0) {
    stop("No columns starting with 'operational_balance' found in the provided data.")
  }
  
  # Aggregate by AS_OF_DATE
  daily_summary <- dt[, .(
    TOTAL_PRIN_BAL_USD = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE),
    TOTAL_OUTFLOW = sum(TOTAL_OUTFLOW, na.rm = TRUE),
    Operational_Balance = sum(get(operational_balance_cols), na.rm = TRUE)  # Sum all operational balance columns
  ), by = .(AS_OF_DATE)]
  
  # Calculate Capture Rate
  daily_summary[, Capture_Rate := ifelse(
    TOTAL_PRIN_BAL_USD == 0, NA_real_,
    Operational_Balance / TOTAL_PRIN_BAL_USD * 100
  )]
  
  # Order by date (optional)
  setorder(daily_summary, AS_OF_DATE)
  
  return(daily_summary)
}

# Define the function
calculate_summary_VA_BPR <- function(dataframe) {
  # Filter for the date of interest
  march_31_2025_data <- dataframe %>%
    filter(AS_OF_DATE == "2025-03-31")
  
  ### VA_BPR Summary ###
  
  # 1. Count of unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025
  total_unique_combinations_va_bpr <- march_31_2025_data %>%
    distinct(ULT_PARENT_CD, REGION) %>%
    nrow()
  
  # 2. Count of unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025 with VA_BPR <= 1
  total_unique_combinations_va_bpr_le_1 <- march_31_2025_data %>%
    filter(VA_BPR <= 1) %>%
    distinct(ULT_PARENT_CD, REGION) %>%
    nrow()
  
  # 3. Count of unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025 with VA_BPR > 1 or VA_BPR is NaN
  total_unique_combinations_va_bpr_gt_1_nan <- march_31_2025_data %>%
    filter(VA_BPR > 1 | is.nan(VA_BPR)) %>%
    distinct(ULT_PARENT_CD, REGION) %>%
    nrow()
  
  # 4. Total balance of ULT_PARENT_CD and REGION on March 31st, 2025
  total_balance_va_bpr <- march_31_2025_data %>%
    summarise(Total_Balance = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE))
  
  # 5. Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 with VA_BPR <= 1
  total_balance_va_bpr_le_1 <- march_31_2025_data %>%
    filter(VA_BPR <= 1) %>%
    summarise(Total_Balance = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE))
  
  # 6. Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 with VA_BPR > 1 or VA_BPR is NaN
  total_balance_va_bpr_gt_1_nan <- march_31_2025_data %>%
    filter(VA_BPR > 1 | is.nan(VA_BPR)) %>%
    summarise(Total_Balance = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE))
  
  # Convert balances to billions
  total_balance_va_bpr_in_billions <- total_balance_va_bpr$Total_Balance / 1e9
  total_balance_va_bpr_le_1_in_billions <- total_balance_va_bpr_le_1$Total_Balance / 1e9
  total_balance_va_bpr_gt_1_nan_in_billions <- total_balance_va_bpr_gt_1_nan$Total_Balance / 1e9
  
  # Print the results for VA_BPR
  cat("### VA_BPR Summary ###\n")
  cat("Total unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025:", total_unique_combinations_va_bpr, "\n")
  cat("Total unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025 with VA_BPR <= 1:", total_unique_combinations_va_bpr_le_1, "\n")
  cat("Total unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025 with VA_BPR > 1 or VA_BPR is NaN:", total_unique_combinations_va_bpr_gt_1_nan, "\n")
  
  cat("Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 (in billions):", total_balance_va_bpr_in_billions, "\n")
  cat("Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 with VA_BPR <= 1 (in billions):", total_balance_va_bpr_le_1_in_billions, "\n")
  cat("Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 with VA_BPR > 1 or VA_BPR is NaN (in billions):", total_balance_va_bpr_gt_1_nan_in_billions, "\n")
  
  ### simple_BPR Summary ###
  
  # 1. Count of unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025
  total_unique_combinations_simple_bpr <- march_31_2025_data %>%
    distinct(ULT_PARENT_CD, REGION) %>%
    nrow()
  
  # 2. Count of unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025 with simple_BPR <= 1
  total_unique_combinations_simple_bpr_le_1 <- march_31_2025_data %>%
    filter(simple_BPR <= 1) %>%
    distinct(ULT_PARENT_CD, REGION) %>%
    nrow()
  
  # 3. Count of unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025 with simple_BPR > 1 or simple_BPR is NaN
  total_unique_combinations_simple_bpr_gt_1_nan <- march_31_2025_data %>%
    filter(simple_BPR > 1 | is.nan(simple_BPR)) %>%
    distinct(ULT_PARENT_CD, REGION) %>%
    nrow()
  
  # 4. Total balance of ULT_PARENT_CD and REGION on March 31st, 2025
  total_balance_simple_bpr <- march_31_2025_data %>%
    summarise(Total_Balance = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE))
  
  # 5. Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 with simple_BPR <= 1
  total_balance_simple_bpr_le_1 <- march_31_2025_data %>%
    filter(simple_BPR <= 1) %>%
    summarise(Total_Balance = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE))
  
  # 6. Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 with simple_BPR > 1 or simple_BPR is NaN
  total_balance_simple_bpr_gt_1_nan <- march_31_2025_data %>%
    filter(simple_BPR > 1 | is.nan(simple_BPR)) %>%
    summarise(Total_Balance = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE))
  
  # Convert balances to billions
  total_balance_simple_bpr_in_billions <- total_balance_simple_bpr$Total_Balance / 1e9
  total_balance_simple_bpr_le_1_in_billions <- total_balance_simple_bpr_le_1$Total_Balance / 1e9
  total_balance_simple_bpr_gt_1_nan_in_billions <- total_balance_simple_bpr_gt_1_nan$Total_Balance / 1e9
  
  # Print the results for simple_BPR
  cat("### simple_BPR Summary ###\n")
  cat("Total unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025:", total_unique_combinations_simple_bpr, "\n")
  cat("Total unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025 with simple_BPR <= 1:", total_unique_combinations_simple_bpr_le_1, "\n")
  cat("Total unique combinations of ULT_PARENT_CD and REGION on March 31st, 2025 with simple_BPR > 1 or simple_BPR is NaN:", total_unique_combinations_simple_bpr_gt_1_nan, "\n")
  
  cat("Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 (in billions):", total_balance_simple_bpr_in_billions, "\n")
  cat("Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 with simple_BPR <= 1 (in billions):", total_balance_simple_bpr_le_1_in_billions, "\n")
  cat("Total balance of ULT_PARENT_CD and REGION on March 31st, 2025 with simple_BPR > 1 or simple_BPR is NaN (in billions):", total_balance_simple_bpr_gt_1_nan_in_billions, "\n")
}