# edc_queries.R
# Detects data quality issues in eCRF data

required_pkgs <- c("dplyr", "jsonlite", "gt", "readr")
for (p in required_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

library(dplyr)
library(jsonlite)
library(gt)
library(readr)

args <- commandArgs(trailingOnly = FALSE)
script_path <- normalizePath(sub('^--file=', '', args[grep('^--file=', args)]))
script_dir <- dirname(script_path)
input_path <- file.path(script_dir, "ecrf_data.csv")
report_csv <- file.path(script_dir, "query_report.csv")
report_json <- file.path(script_dir, "query_report.json")

data <- read_csv(input_path, na = c("", "NA"))

# Critical: missing HbA1c at post-baseline (i.e., Visit != "Screening")
critical_missing_hba1c <- data %>%
  filter(Visit != "Screening" & is.na(HbA1c)) %>%
  mutate(Query = "Missing HbA1c at post-baseline visit", Severity = "CRITICAL")

# Critical: out-of-range BP values (systolic or diastolic outside 60-200)
critical_bp <- data %>%
  filter(BP_Systolic < 60 | BP_Systolic > 200 | BP_Diastolic < 40 | BP_Diastolic > 130) %>%
  mutate(Query = "Blood Pressure out of plausible range", Severity = "CRITICAL")

# Moderate: AE reported flag requires confirmation (any Yes)
moderate_ae <- data %>%
  filter(tolower(AE_Reported) == "yes") %>%
  mutate(Query = "AE reported flag needs confirmation", Severity = "MODERATE")

all_queries <- bind_rows(critical_missing_hba1c, critical_bp, moderate_ae)

# Write CSV and JSON
write_csv(all_queries, report_csv)
write_json(all_queries, report_json, pretty = TRUE, auto_unbox = TRUE)

# Create HTML dashboard with color coding
html_path <- file.path(script_dir, "EDC_Query_Dashboard.html")
all_queries %>%
  mutate(Color = ifelse(Severity == "CRITICAL", "orange", "yellow")) %>%
  gt() %>%
  fmt_markdown(columns = vars(Query)) %>%
  tab_style(
    style = cell_fill(color = "orange"),
    locations = cells_body(columns = vars(Severity), rows = Severity == "CRITICAL")
  ) %>%
  tab_style(
    style = cell_fill(color = "yellow"),
    locations = cells_body(columns = vars(Severity), rows = Severity == "MODERATE")
  ) %>%
  gtsave(html_path)

cat("EDC query report written to", report_csv, report_json, "and dashboard", html_path, "\n")
