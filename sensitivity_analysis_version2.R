## Sensitivity Analysis 


## SMLB

SA_SMLB_5 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 5,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_SMLB_5_daily <- summarize_daily_operational_balance (SA_SMLB_5)
write.csv(SA_SMLB_5_daily, "SA_SMLB_5_daily.csv", row.names = FALSE)

SA_SMLB_10 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 10,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_SMLB_10_daily <- summarize_daily_operational_balance (SA_SMLB_10)
write.csv(SA_SMLB_10_daily, "SA_SMLB_10_daily.csv", row.names = FALSE)

SA_SMLB_21 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 21,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_SMLB_21_daily <- summarize_daily_operational_balance (SA_SMLB_21)
write.csv(SA_SMLB_21_daily, "SA_SMLB_21_daily.csv", row.names = FALSE)


## BCM/PCM

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
  end_date = "2025-3-28"
)

SA_BCM_PCM_1_1_daily <- summarize_daily_operational_balance (SA_BCM_PCM_1_1)
write.csv(SA_BCM_PCM_1_1_daily, "SA_BCM_PCM_1_1_daily.csv", row.names = FALSE)

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
  end_date = "2025-3-28"
)

SA_BCM_PCM_2_1_daily <- summarize_daily_operational_balance (SA_BCM_PCM_2_1)
write.csv(SA_BCM_PCM_2_1_daily, "SA_BCM_PCM_2_1_daily.csv", row.names = FALSE)

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
  end_date = "2025-3-28"
)

SA_BCM_PCM_1_2_daily <- summarize_daily_operational_balance (SA_BCM_PCM_1_2)
write.csv(SA_BCM_PCM_1_2_daily, "SA_BCM_PCM_1_2_daily.csv", row.names = FALSE)

## Balance Percentile/Payment Percentile

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
  end_date = "2025-3-28"
)

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
  end_date = "2025-3-28"
)

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
  end_date = "2025-3-28"
)

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
  end_date = "2025-3-28"
)

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
  end_date = "2025-3-28"
)

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
  end_date = "2025-3-28"
)

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
  end_date = "2025-3-28"
)

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
  end_date = "2025-3-28"
)

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
  end_date = "2025-3-28"
)

SA_BP_PP_95_95_daily <- summarize_daily_operational_balance (SA_BP_PP_95_95)
write.csv(SA_BP_PP_95_95_daily, "SA_BP_PP_95_95_daily.csv", row.names = FALSE)

## BLB/PLB

SA_BLB_PLB_3_1 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 3,                           
  PLB = 1,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_3_1_daily <- summarize_daily_operational_balance (SA_BLB_PLB_3_1)
write.csv(SA_BLB_PLB_3_1_daily, "SA_BLB_PLB_3_1_daily.csv", row.names = FALSE)

SA_BLB_PLB_3_2 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 3,                           
  PLB = 2,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_3_2_daily <- summarize_daily_operational_balance (SA_BLB_PLB_3_2)
write.csv(SA_BLB_PLB_3_2_daily, "SA_BLB_PLB_3_2_daily.csv", row.names = FALSE)

SA_BLB_PLB_3_3 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 3,                           
  PLB = 3,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_3_3_daily <- summarize_daily_operational_balance (SA_BLB_PLB_3_3)
write.csv(SA_BLB_PLB_3_3_daily, "SA_BLB_PLB_3_3_daily.csv", row.names = FALSE)

SA_BLB_PLB_6_1 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 1,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_6_1_daily <- summarize_daily_operational_balance (SA_BLB_PLB_6_1)
write.csv(SA_BLB_PLB_6_1_daily, "SA_BLB_PLB_6_1_daily.csv", row.names = FALSE)

SA_BLB_PLB_6_2 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 2,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_6_2_daily <- summarize_daily_operational_balance (SA_BLB_PLB_6_2)
write.csv(SA_BLB_PLB_6_2_daily, "SA_BLB_PLB_6_2_daily.csv", row.names = FALSE)

SA_BLB_PLB_6_3 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 6,                           
  PLB = 3,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_6_3_daily <- summarize_daily_operational_balance (SA_BLB_PLB_6_3)
write.csv(SA_BLB_PLB_6_3_daily, "SA_BLB_PLB_6_3_daily.csv", row.names = FALSE)


SA_BLB_PLB_9_1 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 9,                           
  PLB = 1,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_9_1_daily <- summarize_daily_operational_balance (SA_BLB_PLB_9_1)
write.csv(SA_BLB_PLB_9_1_daily, "SA_BLB_PLB_9_1_daily.csv", row.names = FALSE)

SA_BLB_PLB_9_2 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 9,                           
  PLB = 2,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_9_2_daily <- summarize_daily_operational_balance (SA_BLB_PLB_9_2)
write.csv(SA_BLB_PLB_9_2_daily, "SA_BLB_PLB_9_2_daily.csv", row.names = FALSE)

SA_BLB_PLB_9_3 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 9,                           
  PLB = 3,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_9_3_daily <- summarize_daily_operational_balance (SA_BLB_PLB_9_3)
write.csv(SA_BLB_PLB_9_3_daily, "SA_BLB_PLB_9_3_daily.csv", row.names = FALSE)

SA_BLB_PLB_9_6 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 9,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_9_6_daily <- summarize_daily_operational_balance (SA_BLB_PLB_9_6)
write.csv(SA_BLB_PLB_9_6_daily, "SA_BLB_PLB_9_6_daily.csv", row.names = FALSE)


SA_BLB_PLB_12_1 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 12,                           
  PLB = 1,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_12_1_daily <- summarize_daily_operational_balance (SA_BLB_PLB_12_1)
write.csv(SA_BLB_PLB_12_1_daily, "SA_BLB_PLB_12_1_daily.csv", row.names = FALSE)

SA_BLB_PLB_12_2 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 12,                           
  PLB = 2,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_12_2_daily <- summarize_daily_operational_balance (SA_BLB_PLB_12_2)
write.csv(SA_BLB_PLB_12_2_daily, "SA_BLB_PLB_12_2_daily.csv", row.names = FALSE)

SA_BLB_PLB_12_3 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 12,                           
  PLB = 3,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_12_3_daily <- summarize_daily_operational_balance (SA_BLB_PLB_12_3)
write.csv(SA_BLB_PLB_12_3_daily, "SA_BLB_PLB_12_3_daily.csv", row.names = FALSE)

SA_BLB_PLB_12_6 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 12,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_12_6_daily <- summarize_daily_operational_balance (SA_BLB_PLB_12_6)
write.csv(SA_BLB_PLB_12_6_daily, "SA_BLB_PLB_12_6_daily.csv", row.names = FALSE)

SA_BLB_PLB_12_12 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 12,                           
  PLB = 12,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_12_12_daily <- summarize_daily_operational_balance (SA_BLB_PLB_12_12)
write.csv(SA_BLB_PLB_12_12_daily, "SA_BLB_PLB_12_12_daily.csv", row.names = FALSE)

SA_BLB_PLB_18_1 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 18,                           
  PLB = 1,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_18_1_daily <- summarize_daily_operational_balance (SA_BLB_PLB_18_1)
write.csv(SA_BLB_PLB_18_1_daily, "SA_BLB_PLB_18_1_daily.csv", row.names = FALSE)

SA_BLB_PLB_18_2 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 18,                           
  PLB = 2,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_18_2_daily <- summarize_daily_operational_balance (SA_BLB_PLB_18_2)
write.csv(SA_BLB_PLB_18_2_daily, "SA_BLB_PLB_18_2_daily.csv", row.names = FALSE)

SA_BLB_PLB_18_3 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 18,                           
  PLB = 3,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_18_3_daily <- summarize_daily_operational_balance (SA_BLB_PLB_18_3)
write.csv(SA_BLB_PLB_18_3_daily, "SA_BLB_PLB_18_3_daily.csv", row.names = FALSE)

SA_BLB_PLB_18_6 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 18,                           
  PLB = 6,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_18_6_daily <- summarize_daily_operational_balance (SA_BLB_PLB_18_6)
write.csv(SA_BLB_PLB_18_6_daily, "SA_BLB_PLB_18_6_daily.csv", row.names = FALSE)

SA_BLB_PLB_18_12 <- calculate_operational_balance_v2 (
  raw_data_consol,
  Balance_Cushion_Multiplier = 2,  
  Payment_Cushion_Multiplier = 2, 
  cash_management_horizon = 1,       
  choice = 0,                       
  BLB = 18,                           
  PLB = 12,                           
  Balance_Percentile = 85,         
  Payment_Percentile = 95,         
  smoothing = 1,                     
  adjustment_factor = 1,   
  eligibility_months = 3,
  start_date = "2020-01-01",
  end_date = "2025-3-28"
)

SA_BLB_PLB_18_12_daily <- summarize_daily_operational_balance (SA_BLB_PLB_18_12)
write.csv(SA_BLB_PLB_18_12_daily, "SA_BLB_PLB_18_12_daily.csv", row.names = FALSE)