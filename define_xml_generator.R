# define_xml_generator.R
# Generates a CSV metadata file documenting all variables in given SDTM and ADaM files

required_pkgs <- c("readr", "dplyr")
for (p in required_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

library(readr)
library(dplyr)

args <- commandArgs(trailingOnly = FALSE)
script_path <- normalizePath(sub('^--file=', '', args[grep('^--file=', args)]))
script_dir <- dirname(script_path)
output_path <- file.path(script_dir, "DIAB2024_eCTD_Submission", "m5", "datasets", "define_metadata.csv")

# List of dataset files (relative to Desktop)
desktop <- file.path(Sys.getenv("USERPROFILE"), "Desktop")
files <- c(
  file.path(desktop, "SDTM_DM.csv"),
  file.path(desktop, "SDTM_AE.csv"),
  file.path(desktop, "SDTM_LB.csv"),
  file.path(desktop, "ADSL.csv"),
  file.path(desktop, "ADLB.csv"),
  file.path(desktop, "ADAE.csv")
)

metadata <- data.frame()

for (f in files) {
  if (!file.exists(f)) next
  df <- read_csv(f, col_types = cols(.default = "c"))
  vars <- colnames(df)
  ds_name <- tools::file_path_sans_ext(basename(f))
  meta <- data.frame(
    dataset = ds_name,
    variable = vars,
    stringsAsFactors = FALSE
  )
  metadata <- bind_rows(metadata, meta)
}

# Write metadata CSV
write_csv(metadata, output_path)
cat("DEFINE metadata written to", output_path, "\n")
