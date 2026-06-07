# submission_checklist.R
# Verifies required files exist in eCTD folder and creates an HTML checklist

required_pkgs <- c("gt", "readr", "fs")
for (p in required_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

library(gt)
library(dplyr)
library(readr)
library(fs)

args <- commandArgs(trailingOnly = FALSE)
script_path <- normalizePath(sub('^--file=', '', args[grep('^--file=', args)]))
script_dir <- dirname(script_path)
submission_dir <- file.path(Sys.getenv("USERPROFILE"), "Desktop", "DIAB2024_eCTD_Submission")

required_files <- c(
  "m5/datasets/sdtm/SDTM_DM.csv",
  "m5/datasets/sdtm/SDTM_AE.csv",
  "m5/datasets/sdtm/SDTM_LB.csv",
  "m5/datasets/adam/ADSL.csv",
  "m5/datasets/adam/ADLB.csv",
  "m5/datasets/adam/ADAE.csv",
  "m5/reports/csr/CSR_Draft.docx",
  "m5/tfl/tables/TLF_Table1_Demographics.html",
  "m5/tfl/tables/TLF_Table2_Efficacy.html",
  "m5/tfl/tables/TLF_Table3_AE.html",
  "m5/tfl/figures/TLF_Figure1_HbA1c.png",
  "m5/safety/sae/SAE_narratives.txt",
  "m5/safety/sae/SAE_tracking_report.html",
  "admin/cover-letter/Cover_Letter.txt"
)

check_results <- data.frame(File = required_files, Exists = FALSE, stringsAsFactors = FALSE)

for (i in seq_along(required_files)) {
  full_path <- path(submission_dir, required_files[i])
  check_results$Exists[i] <- file_exists(full_path)
}

# Create HTML report using gt
html_path <- file.path(script_dir, "Submission_Checklist.html")
check_results %>%
  mutate(Color = ifelse(Exists, "green", "red")) %>%
  gt() %>%
  cols_label(File = "Required File", Exists = "Present?") %>%
  tab_style(
    style = cell_fill(color = "green"),
    locations = cells_body(columns = vars(Exists), rows = Exists == TRUE)
  ) %>%
  tab_style(
    style = cell_fill(color = "red"),
    locations = cells_body(columns = vars(Exists), rows = Exists == FALSE)
  ) %>%
  gtsave(html_path)

cat("Submission checklist written to", html_path, "\n")
