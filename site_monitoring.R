# site_monitoring.R
# Calculates risk scores for sites and creates a dashboard

required_pkgs <- c("dplyr", "gt", "readr", "lubridate")
for (p in required_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

library(dplyr)
library(gt)
library(readr)
library(lubridate)

args <- commandArgs(trailingOnly = FALSE)
script_path <- normalizePath(sub('^--file=', '', args[grep('^--file=', args)]))
script_dir <- dirname(script_path)
metrics_path <- file.path(script_dir, "site_metrics.csv")
output_csv <- file.path(script_dir, "site_risk_scores.csv")
output_html <- file.path(script_dir, "Site_Monitoring_Dashboard.html")

metrics <- read_csv(metrics_path)

# Calculate risk components
metrics <- metrics %>%
  mutate(
    DaysSinceVisit = as.integer(Sys.Date() - ymd(LAST_VISIT_DATE)),
    QueryScore = QUERIES_OPEN * 1,
    DeviationScore = PROTOCOL_DEVIATIONS * 2,
    VisitScore = ifelse(DaysSinceVisit > 30, 2, 0),
    AERScore = ifelse(AE_REPORTING_RATE > 0.05, 2, 0),
    DrugAcctScore = ifelse(tolower(DRUG_ACCOUNTABILITY) == "no", 1, 0),
    TotalScore = QueryScore + DeviationScore + VisitScore + AERScore + DrugAcctScore
  ) %>%
  mutate(RiskLevel = case_when(
    TotalScore >= 6 ~ "HIGH",
    TotalScore >= 3 ~ "MEDIUM",
    TRUE ~ "LOW"
  ))

# Write CSV
write_csv(metrics, output_csv)

# Create HTML dashboard with color coding
metrics %>%
  gt() %>%
  fmt_number(columns = vars(DaysSinceVisit), decimals = 0) %>%
  tab_style(
    style = cell_fill(color = "orange"),
    locations = cells_body(columns = vars(RiskLevel), rows = RiskLevel == "HIGH")
  ) %>%
  tab_style(
    style = cell_fill(color = "yellow"),
    locations = cells_body(columns = vars(RiskLevel), rows = RiskLevel == "MEDIUM")
  ) %>%
  tab_style(
    style = cell_fill(color = "green"),
    locations = cells_body(columns = vars(RiskLevel), rows = RiskLevel == "LOW")
  ) %>%
  gtsave(output_html)

cat("Site risk scores written to", output_csv, "and dashboard", output_html, "\n")
