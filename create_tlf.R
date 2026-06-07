library(tidyverse)
library(gt)
library(ggplot2)

# Helper to read ADaM files
read_adam <- function(file) {
  read_csv(file, col_types = cols())
}

# Load ADaM datasets
ADSL <- read_adam("C:/Users/kasim/Desktop/ADSL.csv")
ADAE <- read_adam("C:/Users/kasim/Desktop/ADAE.csv")
ADLB <- read_adam("C:/Users/kasim/Desktop/ADLB.csv")

# ---- Table 1: Demographics ----
table1 <- ADSL %>%
  group_by(ARM = TRT01P) %>%
  summarise(
    N = n(),
    Age_Mean = mean(AGE, na.rm = TRUE),
    Age_SD = sd(AGE, na.rm = TRUE),
    Male = sum(SEX == "M", na.rm = TRUE),
    Female = sum(SEX == "F", na.rm = TRUE)
  ) %>%
  gt() %>%
  tab_header(
    title = "Table 1: Demographics",
    subtitle = "Study DIAB2024"
  )

gtsave(table1, "C:/Users/kasim/Desktop/TLF_Table1_Demographics.html")

# ---- Table 2: Efficacy (HbA1c change) ----
# Assuming HbA1c test code is "GLUCOSE" and visit 26 corresponds to VISITNUM == 9 (example)
HbA1c <- ADLB %>%
  filter(PARAMCD == "HbA1c") %>%
  group_by(USUBJID) %>%
  arrange(VISITNUM) %>%
  mutate(BASE = first(AVAL)) %>%
  ungroup() %>%
  filter(VISITNUM == 9) %>%
  mutate(CHANGE = AVAL - BASE)

table2 <- HbA1c %>%
  group_by(TRT01P) %>%
  summarise(
    N = n(),
    Mean_Change = mean(CHANGE, na.rm = TRUE),
    SD_Change = sd(CHANGE, na.rm = TRUE)
  ) %>%
  gt() %>%
  tab_header(
    title = "Table 2: HbA1c Change from Baseline at Week 26",
    subtitle = "Analysis Set"
  )

gtsave(table2, "C:/Users/kasim/Desktop/TLF_Table2_Efficacy.html")

# ---- Table 3: Adverse Events ----
AE_summary <- ADAE %>%
  group_by(AEBODSYS, AEDECOD) %>%
  summarise(N = n()) %>%
  arrange(desc(N)) %>%
  gt() %>%
  tab_header(
    title = "Table 3: Adverse Events by System Organ Class and Preferred Term",
    subtitle = "Study DIAB2024"
  )

gtsave(AE_summary, "C:/Users/kasim/Desktop/TLF_Table3_AE.html")

# ---- Figure 1: Mean HbA1c over Time ----
# Assume VISITNUM corresponds to weeks (e.g., VISITNUM * 2 = week)
HbA1c_time <- ADLB %>%
  filter(PARAMCD == "HbA1c") %>%
  group_by(TRT01P, VISITNUM) %>%
  summarise(Mean_HbA1c = mean(AVAL, na.rm = TRUE))

fig1 <- ggplot(HbA1c_time, aes(x = VISITNUM, y = Mean_HbA1c, color = TRT01P)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Figure 1: Mean HbA1c Over Time by Treatment Arm",
    x = "Visit Number",
    y = "Mean HbA1c",
    color = "Treatment"
  ) +
  theme_minimal()

ggsave("C:/Users/kasim/Desktop/TLF_Figure1_HbA1c.png", fig1, width = 8, height = 6, dpi = 300)
