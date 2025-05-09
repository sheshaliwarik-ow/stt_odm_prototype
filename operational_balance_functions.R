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
  }
  ]
  dt[, long_lookback_start := if (long_lookback >= 1) {
    get(date_col) %m-% months(long_lookback)
  } else {
    get(date_col) - round(long_lookback * 30)
  }
  ]
  
  # Get tuple_start and tuple_end for each group
  dt[, tuple_start := min(get(date_col), na.rm=TRUE), by=group_cols]
  dt[, tuple_end   := max(get(date_col), na.rm=TRUE), by=group_cols]
  
  # Set eligibility as per rule
  dt[, eligibility := as.integer(tuple_start <= long_lookback_start)]
  
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
  #result[, AS_OF_DATE := NULL] # Remove helper column if not needed
  
  t1 <- Sys.time()
  message(sprintf("Operationanl balance calculation complete. Elapsed time: %.2f seconds", as.numeric(difftime(t1, t0, units = "secs"))))
  
  return(result)
}


summarize_daily_operational_balance <- function(dt) {
  
  dt <- as.data.table(dt)
  
  # Aggregate by AS_OF_DATE
  daily_summary <- dt[, .(
    TOTAL_PRIN_BAL_USD = sum(TOTAL_PRIN_BAL_USD, na.rm = TRUE),
    TOTAL_OUTFLOW = sum(TOTAL_OUTFLOW, na.rm = TRUE),
    Operational_Balance = sum(operational_balance, na.rm = TRUE)
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


