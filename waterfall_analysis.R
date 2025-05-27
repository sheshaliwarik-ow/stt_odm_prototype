## waterfall Variations

## Step 1 

WF_Step_1 <- calculate_operational_balance_v2 (
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

intra_daily_WF_Step_1 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_1, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_WF_Step_1 <- calculate_daily_totals(intra_daily_WF_Step_1)
write.csv(intra_WF_Step_1, "INTRA_WF_Step_1.csv", row.names = FALSE)

mdl_daily_WF_Step_1 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_1, 
  '2025-03-31', 
  'Multi-Day Low'
)

mdl_WF_Step_1 <- calculate_daily_totals(mdl_daily_WF_Step_1)
write.csv(mdl_WF_Step_1, "MDL_WF_Step_1.csv", row.names = FALSE)

mdh_daily_WF_Step_1 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_1, 
  '2025-03-31', 
  'Multi-Day High'
)

mdh_WF_Step_1 <- calculate_daily_totals(mdh_daily_WF_Step_1)
write.csv(mdh_WF_Step_1, "MDH_WF_Step_1.csv", row.names = FALSE)

## Step 2

WF_Step_2 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 18,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_WF_Step_2 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_2, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_WF_Step_2 <- calculate_daily_totals(intra_daily_WF_Step_2)
write.csv(intra_WF_Step_2, "INTRA_WF_Step_2.csv", row.names = FALSE)

mdl_daily_WF_Step_2 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_2, 
  '2025-03-31', 
  'Multi-Day Low'
)

mdl_WF_Step_2 <- calculate_daily_totals(mdl_daily_WF_Step_2)
write.csv(mdl_WF_Step_2, "MDL_WF_Step_2.csv", row.names = FALSE)

mdh_daily_WF_Step_2 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_2, 
  '2025-03-31', 
  'Multi-Day High'
)

mdh_WF_Step_2 <- calculate_daily_totals(mdh_daily_WF_Step_2)
write.csv(mdh_WF_Step_2, "MDH_WF_Step_2.csv", row.names = FALSE)

## Step 3 

WF_Step_3 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 18,                           
  PLB = 18,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_WF_Step_3 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_3, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_WF_Step_3 <- calculate_daily_totals(intra_daily_WF_Step_3)
write.csv(intra_WF_Step_3, "INTRA_WF_Step_3.csv", row.names = FALSE)

mdl_daily_WF_Step_3 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_3, 
  '2025-03-31', 
  'Multi-Day Low'
)

mdl_WF_Step_3 <- calculate_daily_totals(mdl_daily_WF_Step_3)
write.csv(mdl_WF_Step_3, "MDL_WF_Step_3.csv", row.names = FALSE)

mdh_daily_WF_Step_3 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_3, 
  '2025-03-31', 
  'Multi-Day High'
)

mdh_WF_Step_3 <- calculate_daily_totals(mdh_daily_WF_Step_3)
write.csv(mdh_WF_Step_3, "MDH_WF_Step_3.csv", row.names = FALSE)

## Step 4

WF_Step_4 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 0, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 18,                           
  PLB = 18,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_WF_Step_4 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_4, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_WF_Step_4 <- calculate_daily_totals(intra_daily_WF_Step_4)
write.csv(intra_WF_Step_4, "INTRA_WF_Step_4.csv", row.names = FALSE)

mdl_daily_WF_Step_4 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_4, 
  '2025-03-31', 
  'Multi-Day Low'
)

mdl_WF_Step_4 <- calculate_daily_totals(mdl_daily_WF_Step_4)
write.csv(mdl_WF_Step_4, "MDL_WF_Step_4.csv", row.names = FALSE)

mdh_daily_WF_Step_4 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_4, 
  '2025-03-31', 
  'Multi-Day High'
)

mdh_WF_Step_4 <- calculate_daily_totals(mdh_daily_WF_Step_4)
write.csv(mdh_WF_Step_4, "MDH_WF_Step_4.csv", row.names = FALSE)

## Step 5

WF_Step_5 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 0,  
  Payment_Cushion_Multiplier = 0, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 18,                           
  PLB = 18,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-31"
)

intra_daily_WF_Step_5 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_5, 
  '2025-03-31', 
  'INTRA-DAY'
)

intra_WF_Step_5 <- calculate_daily_totals(intra_daily_WF_Step_5)
write.csv(intra_WF_Step_5, "INTRA_WF_Step_5.csv", row.names = FALSE)

mdl_daily_WF_Step_5 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_5, 
  '2025-03-31', 
  'Multi-Day Low'
)

mdl_WF_Step_5 <- calculate_daily_totals(mdl_daily_WF_Step_5)
write.csv(mdl_WF_Step_5 , "MDL_WF_Step_5.csv", row.names = FALSE)

mdh_daily_WF_Step_5 <- process_operational_balances_with_behavioral_groups(
  existing_ODM_results, 
  WF_Step_5, 
  '2025-03-31', 
  'Multi-Day High'
)

mdh_WF_Step_5 <- calculate_daily_totals(mdh_daily_WF_Step_5)
write.csv(mdh_WF_Step_5, "MDH_WF_Step_5.csv", row.names = FALSE)


WF_Step_2_daily <- summarize_daily_operational_balance (WF_Step_2)
write.csv(WF_Step_2_daily, "WF_Step_2_daily.csv", row.names = FALSE)
WF_Step_3_daily <- summarize_daily_operational_balance (WF_Step_3)
write.csv(WF_Step_3_daily, "WF_Step_3_daily.csv", row.names = FALSE)
WF_Step_4_daily <- summarize_daily_operational_balance (WF_Step_4)
write.csv(WF_Step_4_daily, "WF_Step_4_daily.csv", row.names = FALSE)
WF_Step_5_daily <- summarize_daily_operational_balance (WF_Step_5)
write.csv(WF_Step_5_daily, "WF_Step_5_daily.csv", row.names = FALSE)


