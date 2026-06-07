library(tidyverse)

# Constants
study_id <- "DIAB2024"

# Helper to safely read SDTM files
read_sdtm <- function(file) {
  read_csv(file, col_types = cols())
}

# ---- Read SDTM files ----
DM <- read_sdtm("C:/Users/kasim/Desktop/SDTM_DM.csv")
AE <- read_sdtm("C:/Users/kasim/Desktop/SDTM_AE.csv")
LB <- read_sdtm("C:/Users/kasim/Desktop/SDTM_LB.csv")

# ---- ADSL (Subject-Level) ----
ADSL <- DM %>%
  transmute(
    STUDYID = STUDYID,
    USUBJID = USUBJID,
    AGE = AGE,
    AGEGR1 = case_when(
      AGE < 65 ~ "<65",
      TRUE ~ ">=65"
    ),
    SEX = SEX,
    RACE = RACE,
    TRT01P = if_else(!is.na(ACTARM), ACTARM, NA_character_),
    TRT01A = TRT01P, # Assuming intended treatment equals planned for this demo
    SAFFL = "Y", # All subjects considered safety population for demo purposes
    ITTFL = "Y", # Intent-to-treat flag
    # Placeholder for AECNT, will be added after ADSL creation
    DTHFL = if ("DTHDT" %in% colnames(DM)) if_else(!is.na(DTHDT), "Y", "N") else "N"
  )

ae_counts <- AE %>%
  group_by(USUBJID) %>%
  summarise(AECNT = n())

ADSL <- ADSL %>%
  left_join(ae_counts, by = "USUBJID") %>%
  mutate(AECNT = replace_na(AECNT, 0))

write_csv(ADSL, "C:/Users/kasim/Desktop/ADSL.csv")

# ---- ADLB (Analysis Lab) ----
# Create baseline (first visit) and change variables
baseline <- LB %>%
  filter(VISITNUM == 1) %>%
  select(USUBJID, LBTESTCD, LBSTRESN) %>%
  rename(BASE = LBSTRESN)

adlb <- LB %>%
  left_join(baseline, by = c("USUBJID", "LBTESTCD")) %>%
  left_join(DM %>% select(USUBJID, ACTARM), by = "USUBJID") %>%
  mutate(
    PARAM = LBTEST,
    PARAMCD = LBTESTCD,
    AVAL = LBSTRESN,
    AVALU = LBSTRESU,
    BASE = BASE,
    CHG = ifelse(!is.na(BASE) & !is.na(LBSTRESN), LBSTRESN - BASE, NA_real_),
    PCHG = ifelse(!is.na(BASE) & !is.na(LBSTRESN) & BASE != 0, (LBSTRESN - BASE) / BASE * 100, NA_real_),
    TRT01P = ACTARM,
    SAFFL = "Y",
    ANL01FL = "Y"
  ) %>%
  select(STUDYID, USUBJID, PARAM, PARAMCD, VISIT, VISITNUM, AVAL, AVALU, BASE, CHG, PCHG, TRT01P, SAFFL, ANL01FL)

write_csv(adlb, "C:/Users/kasim/Desktop/ADLB.csv")

# ---- ADAE (Analysis AE) ----
ADAE <- AE %>%
  left_join(ADSL %>% select(USUBJID, TRT01P, SAFFL), by = "USUBJID") %>%
  transmute(
    STUDYID = STUDYID,
    USUBJID = USUBJID,
    AEBODSYS = AESOC,
    AEDECOD = AEDECOD,
    AESEV = AESEV,
    AESER = AESER,
    AEREL = if_else(AESER == "Y", "RELATED", "NOT_RELATED"),
    TRTEMFL = if_else(AEDECOD %in% c("Placebo", "Active"), "Y", "N"), # placeholder logic
    TRT01P = TRT01P,
    SAFFL = SAFFL,
    AESTDTC = AESTDTC,
    AEENDTC = AEENDTC
  )

write_csv(ADAE, "C:/Users/kasim/Desktop/ADAE.csv")
