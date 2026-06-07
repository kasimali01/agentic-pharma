# sap_formatter.R
# Reads the SAP draft text file and creates a formatted Word document using officer

# Install required packages if missing
if (!requireNamespace("officer", quietly = TRUE)) {
  install.packages("officer", repos = "https://cloud.r-project.org")
}
if (!requireNamespace("magrittr", quietly = TRUE)) {
  install.packages("magrittr", repos = "https://cloud.r-project.org")
}

library(officer)
library(magrittr)

# Define paths
args <- commandArgs(trailingOnly = FALSE)
script_path <- normalizePath(sub("^--file=", "", args[grep("^--file=", args)]))
script_dir <- dirname(script_path)
input_path <- file.path(script_dir, "sap_draft.txt")
output_path <- file.path(script_dir, "SAP_Draft.docx")

# Read SAP draft
sap_text <- readLines(input_path, warn = FALSE)

# Create a new Word document
doc <- read_docx()

# Add title
doc <- doc %>%
  body_add_par("Statistical Analysis Plan (SAP)", style = "heading 1") %>%
  body_add_par(paste0("Study ID: ", "DIAB2024"), style = "Normal") %>%
  body_add_par("\n")

# Add content, split by double newline into sections
sections <- unlist(strsplit(paste(sap_text, collapse = "\n"), "\n\n+"))
for (sec in sections) {
  # Assume first line is a heading if it ends with ':' or is a short line
  lines <- unlist(strsplit(sec, "\n"))
  heading <- lines[1]
  body <- paste(lines[-1], collapse = "\n")
  doc <- doc %>%
    body_add_par(heading, style = "heading 2") %>%
    body_add_par(body, style = "Normal") %>%
    body_add_par("\n")
}

print(doc, target = output_path)
cat("SAP Word document written to", output_path, "\n")
