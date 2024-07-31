read_exp_func <- function(inFile){
  if (grepl(".csv",inFile$name)){
    temp_df<-read.csv(inFile$datapath,
                      header = TRUE,
                      sep=",",
                      stringsAsFactors = FALSE,
                      check.names = F)
  } else if (grepl(".xlsx",inFile$name)){
    temp_df<- readxl::read_excel(inFile$datapath,
                                 sheet = NULL,
                                 col_names = TRUE,
                                 na = "")
  } else {
    temp_df<-read.delim(inFile$datapath,
                        header = TRUE,
                        sep="\t",
                        stringsAsFactors = FALSE,
                        check.names = F)
    
    if (ncol(temp_df) == 1){
      temp_df<-read.delim(inFile$datapath,
                          header = TRUE,
                          sep=" ",
                          stringsAsFactors = FALSE,
                          check.names = F)
    }
  }
  return(temp_df)
}

# Function to perform bootstrapping and calculate CIs for each group
boot_mean <- function(data, indices) {
  return(mean(data[indices]))
}

bootstrap_ci <- function(data, abundance, var, group, n_bootstrap = 1000) {
  # Capture the column names as quosures
  var <- dplyr::sym(var)
  group <- dplyr::sym(group)
  # 
  results <- data %>%
    # group_by(!!var, !!group,rowname) %>%
    group_by(!!var, !!group) %>%
    do({
      subset_data <- .[[abundance]]
      if (length(unique(subset_data)) == 1) {
        data.frame(
          mean_abundance = mean(subset_data),
          ci_lower = NA,
          ci_upper = NA
        )
      } else {
        boot_result <- boot::boot(.[[abundance]], statistic = boot_mean, R = n_bootstrap)
        ci <- boot::boot.ci(boot_result, type = "perc")
        data.frame(
          mean_abundance = mean(.[[abundance]]),
          ci_lower = if(!is.null(ci)) ci$percent[4] else NA,
          ci_upper = if(!is.null(ci)) ci$percent[5] else NA
        )
      }
    }) %>%
    ungroup()
  return(results)
}
