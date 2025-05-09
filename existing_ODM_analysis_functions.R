# Function to join two data frames containing results
join_results_dataframes <- function(baseline_ob, existing_ODM_results) {
  
  # Perform the join operation
  result_df <- baseline_ob %>%
    left_join(existing_ODM_results %>% select(ULT_PARENT_CD, REGION, ENTITY_FLAG, AS_OF_DATE, bheavuor_flag, xx), 
              by = c("ULT_PARENT_CD", "REGION", "ENTITY_FLAG", "AS_OF_DATE"))
  
  return(result_df)
}