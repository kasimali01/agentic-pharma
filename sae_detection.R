library(tidyverse)
library(gt)

# Read ADaM files
ADAE <- read_csv("C:/Users/kasim/Desktop/ADAE.csv", col_types = cols())
ADSL <- read_csv("C:/Users/kasim/Desktop/ADSL.csv", col_types = cols())

# Detect Serious Adverse Events (SAE) where AESER == "Y"
SAE <- ADAE %>%
  filter(AESER == "Y") %>%
  left_join(ADSL %>% select(USUBJID, TRT01P, SAFFL), by = "USUBJID", suffix = c(".ae", ".adsl")) %>%
  mutate(
    TRT01P = coalesce(TRT01P.ae, TRT01P.adsl),
    SAFFL = coalesce(SAFFL.ae, SAFFL.adsl),
    AESTDTC_date = as.Date(AESTDTC),
    Reporting_Deadline = AESTDTC_date + 15,
    Overdue = Sys.Date() > Reporting_Deadline
  ) %>%
  select(-TRT01P.ae, -TRT01P.adsl, -SAFFL.ae, -SAFFL.adsl)

# Build tracking report with urgent cases highlighted in orange
report <- SAE %>%
  select(
    STUDYID,
    USUBJID,
    TRT01P,
    AEBODSYS,
    AEDECOD,
    AESTDTC,
    Reporting_Deadline,
    Overdue
  ) %>%
  gt() %>%
  tab_header(
    title = "Serious Adverse Events (SAE) Tracking Report",
    subtitle = "Urgent cases highlighted"
  ) %>%
  fmt_date(columns = vars(AESTDTC, Reporting_Deadline), date_style = 4) %>%
  data_color(
    columns = vars(Overdue),
    colors = scales::col_bin(palette = c("white", "orange"), domain = NULL)
  )

gtsave(report, "C:/Users/kasim/Desktop/SAE_tracking_report.html")
