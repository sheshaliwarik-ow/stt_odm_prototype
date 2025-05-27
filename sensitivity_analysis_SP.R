## Sensitivity Analysis - Sandeep

## BCM/PCM

SA_BCM_PCM_0_0 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 0,  
  Payment_Cushion_Multiplier = 0, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_SA_BCM_PCM_0_0 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  SA_BCM_PCM_0_0, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_SA_BCM_PCM_0_0 <- calculate_daily_totals(intra_daily_SA_BCM_PCM_0_0)
write.csv(intra_SA_BCM_PCM_0_0, "INTRA_SA_BCM_PCM_0_0.csv", row.names = FALSE)

SA_BCM_PCM_0_1 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 0,  
  Payment_Cushion_Multiplier = 1, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_SA_BCM_PCM_0_1 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  SA_BCM_PCM_0_1, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_SA_BCM_PCM_0_1 <- calculate_daily_totals(intra_daily_SA_BCM_PCM_0_1)
write.csv(intra_SA_BCM_PCM_0_1, "INTRA_SA_BCM_PCM_0_1.csv", row.names = FALSE)

SA_BCM_PCM_0_2 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 0,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_SA_BCM_PCM_0_2 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  SA_BCM_PCM_0_2, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_SA_BCM_PCM_0_2 <- calculate_daily_totals(intra_daily_SA_BCM_PCM_0_2)
write.csv(intra_SA_BCM_PCM_0_2, "INTRA_SA_BCM_PCM_0_2.csv", row.names = FALSE)

SA_BCM_PCM_1_0 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 1,  
  Payment_Cushion_Multiplier = 0, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_SA_BCM_PCM_1_0 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  SA_BCM_PCM_1_0, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_SA_BCM_PCM_1_0 <- calculate_daily_totals(intra_daily_SA_BCM_PCM_1_0)
write.csv(intra_SA_BCM_PCM_1_0, "INTRA_SA_BCM_PCM_1_0.csv", row.names = FALSE)

SA_BCM_PCM_1_1 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 1,  
  Payment_Cushion_Multiplier = 1, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_SA_BCM_PCM_1_1 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  SA_BCM_PCM_1_1, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_SA_BCM_PCM_1_1 <- calculate_daily_totals(intra_daily_SA_BCM_PCM_1_1)
write.csv(intra_SA_BCM_PCM_1_1, "INTRA_SA_BCM_PCM_1_1.csv", row.names = FALSE)

SA_BCM_PCM_1_2 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 1,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_SA_BCM_PCM_1_2 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  SA_BCM_PCM_1_2, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_SA_BCM_PCM_1_2 <- calculate_daily_totals(intra_daily_SA_BCM_PCM_1_2)
write.csv(intra_SA_BCM_PCM_1_2, "INTRA_SA_BCM_PCM_1_2.csv", row.names = FALSE)

SA_BCM_PCM_2_0 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 0, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_SA_BCM_PCM_2_0 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  SA_BCM_PCM_2_0, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_SA_BCM_PCM_2_0 <- calculate_daily_totals(intra_daily_SA_BCM_PCM_2_0)
write.csv(intra_SA_BCM_PCM_2_0, "INTRA_SA_BCM_PCM_2_0.csv", row.names = FALSE)

SA_BCM_PCM_2_1 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 1, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_SA_BCM_PCM_2_1 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  SA_BCM_PCM_2_1, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_SA_BCM_PCM_2_1 <- calculate_daily_totals(intra_daily_SA_BCM_PCM_2_1)
write.csv(intra_SA_BCM_PCM_2_1, "INTRA_SA_BCM_PCM_2_1.csv", row.names = FALSE)

SA_BCM_PCM_2_2 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_SA_BCM_PCM_2_2 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  SA_BCM_PCM_2_2, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_SA_BCM_PCM_2_2 <- calculate_daily_totals(intra_daily_SA_BCM_PCM_2_2)
write.csv(intra_SA_BCM_PCM_2_2, "INTRA_SA_BCM_PCM_2_2.csv", row.names = FALSE)





-------------------------------------------------------------------------------------------------
  
  ## Percentile - Balance Percentile/Payment Percentile
  
  SA_BP_PP_85_85 <- calculate_operational_balance_v2 (
    raw_data_consol,
    Balance_Cushion_Multiplier = 2,  
    Payment_Cushion_Multiplier = 2, 
    cash_management_horizon = 1,       
    choice = 1,                       
    BLB = 6,                           
    PLB = 6,                           
    Balance_Percentile = 0.85,         
    Payment_Percentile = 0.85,         
    smoothing = 1,                     
    adjustment_factor = 1,   
    eligibility_months = 3,
    start_date = "2020-01-01",
    end_date = "2025-3-31"
  )

calculate_summary_VA_BPR(SA_BP_PP_85_85)

SA_BP_PP_85_85_daily <- summarize_daily_operational_balance (SA_BP_PP_85_85)
write.csv(SA_BP_PP_85_85_daily, "SA_BP_PP_85_85_daily.csv", row.names = FALSE)

SA_BP_PP_85_90 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.85,         
  Payment_Percentile = 0.90,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_85_90)

SA_BP_PP_85_90_daily <- summarize_daily_operational_balance (SA_BP_PP_85_90)
write.csv(SA_BP_PP_85_90_daily, "SA_BP_PP_85_90_daily.csv", row.names = FALSE)

SA_BP_PP_85_95 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.85,         
  Payment_Percentile = 0.95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_85_95)

SA_BP_PP_85_95_daily <- summarize_daily_operational_balance (SA_BP_PP_85_95)
write.csv(SA_BP_PP_85_95_daily, "SA_BP_PP_85_95_daily.csv", row.names = FALSE)

SA_BP_PP_90_85 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.90,         
  Payment_Percentile = 0.85,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_90_85)

SA_BP_PP_90_85_daily <- summarize_daily_operational_balance (SA_BP_PP_90_85)
write.csv(SA_BP_PP_90_85_daily, "SA_BP_PP_90_85_daily.csv", row.names = FALSE)

SA_BP_PP_90_90 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.90,         
  Payment_Percentile = 0.90,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_90_90)

SA_BP_PP_90_90_daily <- summarize_daily_operational_balance (SA_BP_PP_90_90)
write.csv(SA_BP_PP_90_90_daily, "SA_BP_PP_90_90_daily.csv", row.names = FALSE)

SA_BP_PP_90_95 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.90,         
  Payment_Percentile = 0.95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_90_95)

SA_BP_PP_90_95_daily <- summarize_daily_operational_balance (SA_BP_PP_90_95)
write.csv(SA_BP_PP_90_95_daily, "SA_BP_PP_90_95_daily.csv", row.names = FALSE)

SA_BP_PP_95_85 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.95,         
  Payment_Percentile = 0.85,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_95_85)

SA_BP_PP_95_85_daily <- summarize_daily_operational_balance (SA_BP_PP_95_85)
write.csv(SA_BP_PP_95_85_daily, "SA_BP_PP_95_85_daily.csv", row.names = FALSE)

SA_BP_PP_95_90 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.95,         
  Payment_Percentile = 0.90,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_95_90)

SA_BP_PP_95_90_daily <- summarize_daily_operational_balance (SA_BP_PP_95_90)
write.csv(SA_BP_PP_95_90_daily, "SA_BP_PP_95_90_daily.csv", row.names = FALSE)

SA_BP_PP_95_95 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.95,         
  Payment_Percentile = 0.95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_95_95)

SA_BP_PP_95_95_daily <- summarize_daily_operational_balance (SA_BP_PP_95_95)
write.csv(SA_BP_PP_95_95_daily, "SA_BP_PP_95_95_daily.csv", row.names = FALSE)

----------------------------------------------------------------------------
  
  SA_BP_PP_50_50 <- calculate_operational_balance_v2 (
    raw_data_consol,
    Balance_Cushion_Multiplier = 2,  
    Payment_Cushion_Multiplier = 2, 
    cash_management_horizon = 1,       
    choice = 1,                       
    BLB = 6,                           
    PLB = 6,                           
    Balance_Percentile = 0.50,         
    Payment_Percentile = 0.50,         
    smoothing = 1,                     
    adjustment_factor = 1,   
    eligibility_months = 3,
    start_date = "2020-01-01",
    end_date = "2025-3-31"
  )

calculate_summary_VA_BPR(SA_BP_PP_50_50)

SA_BP_PP_50_50_daily <- summarize_daily_operational_balance (SA_BP_PP_50_50)
write.csv(SA_BP_PP_50_50_daily, "SA_BP_PP_50_50_daily.csv", row.names = FALSE)

SA_BP_PP_50_85 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.50,         
  Payment_Percentile = 0.85,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_50_85)

SA_BP_PP_50_85_daily <- summarize_daily_operational_balance (SA_BP_PP_50_85)
write.csv(SA_BP_PP_50_85_daily, "SA_BP_PP_50_85_daily.csv", row.names = FALSE)

SA_BP_PP_50_90 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.50,         
  Payment_Percentile = 0.90,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_50_90)

SA_BP_PP_50_90_daily <- summarize_daily_operational_balance (SA_BP_PP_50_90)
write.csv(SA_BP_PP_50_90_daily, "SA_BP_PP_50_90_daily.csv", row.names = FALSE)

SA_BP_PP_50_95 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.50,         
  Payment_Percentile = 0.95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_50_95)

SA_BP_PP_50_95_daily <- summarize_daily_operational_balance (SA_BP_PP_50_95)
write.csv(SA_BP_PP_50_95_daily, "SA_BP_PP_50_95_daily.csv", row.names = FALSE)


SA_BP_PP_85_50 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.85,         
  Payment_Percentile = 0.50,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_85_50)

SA_BP_PP_85_50_daily <- summarize_daily_operational_balance (SA_BP_PP_85_50)
write.csv(SA_BP_PP_85_50_daily, "SA_BP_PP_85_50_daily.csv", row.names = FALSE)

SA_BP_PP_90_50 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.90,         
  Payment_Percentile = 0.50,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_90_50)

SA_BP_PP_90_50_daily <- summarize_daily_operational_balance (SA_BP_PP_90_50)
write.csv(SA_BP_PP_90_50_daily, "SA_BP_PP_90_50_daily.csv", row.names = FALSE)

SA_BP_PP_95_50 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 1,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 0.95,         
  Payment_Percentile = 0.50,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

calculate_summary_VA_BPR(SA_BP_PP_95_50)

SA_BP_PP_95_50_daily <- summarize_daily_operational_balance (SA_BP_PP_95_50)
write.csv(SA_BP_PP_95_50_daily, "SA_BP_PP_95_50_daily.csv", row.names = FALSE)

