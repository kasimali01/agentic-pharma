# create_randomization.R
# Generates a stratified blocked randomization schedule

# Install required packages if missing
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr", repos = "https://cloud.r-project.org")
}
if (!requireNamespace("tidyr", quietly = TRUE)) {
  install.packages("tidyr", repos = "https://cloud.r-project.org")
}
if (!requireNamespace("gt", quietly = TRUE)) {
  install.packages("gt", repos = "https://cloud.r-project.org")
}

library(dplyr)
library(tidyr)
library(gt)

set.seed(12345)

# Parameters
n_total <- 200
ratio <- c(Treatment = 1, Placebo = 1)
block_size <- 4
sites <- paste0("Site_", sprintf("%03d", 1:4))
# Simulate baseline HbA1c values for stratification (categorical: low/high)
HbA1c_cat <- c("Low", "High")

# Create all combinations for stratification
strata <- expand.grid(SITE = sites, HbA1c = HbA1c_cat, stringsAsFactors = FALSE)

# Determine number per stratum (evenly distribute)
participants_per_stratum <- n_total / nrow(strata)

schedule <- data.frame()

for (i in seq_len(nrow(strata))) {
  stratum <- strata[i,]
  n_stratum <- participants_per_stratum
  # Number of blocks required
  n_blocks <- ceiling(n_stratum / block_size)
  # Generate treatment assignments for each block
  # For each block, create balanced assignments and shuffle
  block_assignments <- unlist(lapply(1:n_blocks, function(i) {
    # Create a vector with equal numbers of Treatment and Placebo to fill the block
    reps <- rep(names(ratio), each = block_size / sum(ratio))
    sample(reps, size = block_size, replace = FALSE)
  }))
  # Trim to n_stratum participants
  block_assignments <- block_assignments[1:n_stratum]
  df <- data.frame(
    SITE = stratum$SITE,
    HbA1c = stratum$HbA1c,
    Treatment = block_assignments,
    stringsAsFactors = FALSE
  )
  schedule <- bind_rows(schedule, df)
}

# Add subject IDs
schedule <- schedule %>%
  group_by(SITE) %>%
  mutate(Subject_ID = paste0("DIAB2024-", sprintf("%03d", as.numeric(factor(SITE))), "-", sprintf("%03d", row_number()))) %>%
  ungroup()

# Write CSV
args <- commandArgs(trailingOnly = FALSE)
script_path <- normalizePath(sub('^--file=', '', args[grep('^--file=', args)]))
script_dir <- dirname(script_path)
output_csv <- file.path(script_dir, "randomization_schedule.csv")
write.csv(schedule, output_csv, row.names = FALSE)
cat("Randomization schedule written to", output_csv, "\n")

# Create summary HTML using gt
summary_tbl <- schedule %>%
  group_by(SITE, HbA1c) %>%
  summarise(N = n(), Treatment_A = sum(Treatment == "Treatment"), Treatment_P = sum(Treatment == "Placebo"), .groups = "drop")

html_path <- file.path(script_dir, "Randomization_Summary.html")
summary_tbl %>%
  gt() %>%
  gtsave(html_path)
cat("Randomization summary HTML written to", html_path, "\n")
