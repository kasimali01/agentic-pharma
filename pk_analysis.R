# pk_analysis.R
# Calculates PK parameters and creates summary tables/plots

# Install required packages if missing
pkgs <- c("dplyr", "ggplot2", "gt", "readr")
for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

library(dplyr)
library(ggplot2)
library(gt)
library(readr)

args <- commandArgs(trailingOnly = FALSE)
script_path <- normalizePath(sub('^--file=', '', args[grep('^--file=', args)]))
script_dir <- dirname(script_path)
data_path <- file.path(script_dir, "pk_data.csv")
pk_params_path <- file.path(script_dir, "PK_parameters.csv")
summary_html <- file.path(script_dir, "PK_Table_Summary.html")
plot_path <- file.path(script_dir, "PK_Concentration_Time_Curve.png")

# Read data
pk_data <- read_csv(data_path)

# Function to calculate AUC using trapezoidal rule
calc_auc <- function(time, conc) {
  sum(diff(time) * (head(conc, -1) + tail(conc, -1)) / 2)
}

# Compute parameters per subject
pk_results <- pk_data %>%
  group_by(SubjectID) %>%
  arrange(Time_hr) %>%
  summarise(
    Cmax = max(Concentration),
    Tmax = Time_hr[which.max(Concentration)],
    AUC = calc_auc(Time_hr, Concentration),
    half_life = NA_real_
      )

# Write PK parameters CSV
write_csv(pk_results, pk_params_path)

# Create summary HTML using gt
pk_results %>%
  gt() %>%
  gtsave(summary_html)

# Plot concentration-time curves
p <- ggplot(pk_data, aes(x = Time_hr, y = Concentration, color = SubjectID)) +
  geom_line() +
  geom_point() +
  labs(title = "PK Concentration-Time Curves", x = "Time (hours)", y = "Concentration") +
  theme_minimal()

ggsave(plot_path, plot = p, width = 8, height = 5)

cat("PK analysis completed. Outputs written to", pk_params_path, summary_html, plot_path, "\n")
