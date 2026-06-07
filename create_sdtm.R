library(tidyverse)

# Constants
study_id <- "DIAB2024"
site_id <- "001"

# Helper to generate USUBJID
generate_usubjid <- function(n) {
  sprintf("%s-%s-%03d", study_id, site_id, seq_len(n))
}

# ---- Demographics (DM) ----
raw_dm <- read_csv("C:/Users/kasim/Desktop/raw_demographics.csv", col_types = cols())

# Assume raw_dm has at least a column for subject identification (e.g., SUBJID), age, sex, race, country, arm, actarm, rfstdtc.
# If columns are missing, they will be created as NA.

dm <- raw_dm %>%
  mutate(
    STUDYID = study_id,
    DOMAIN = "DM",
    SITEID = site_id,
    USUBJID = generate_usubjid(n()),
    SUBJID = if ("SUBJID" %in% colnames(.)) as.character(SUBJID) else as.character(row_number()),
    AGE = if ("AGE" %in% colnames(.)) AGE else NA_real_,
    AGEU = "YR",
    SEX = if ("SEX" %in% colnames(.)) SEX else NA_character_,
    RACE = if ("RACE" %in% colnames(.)) RACE else NA_character_,
    COUNTRY = if ("COUNTRY" %in% colnames(.)) COUNTRY else NA_character_,
    ARM = if ("ARM" %in% colnames(.)) ARM else NA_character_,
    ACTARM = if ("ACTARM" %in% colnames(.)) ACTARM else NA_character_,
    RFSTDTC = if ("RFSTDTC" %in% colnames(.)) RFSTDTC else NA_character_
  ) %>%
  select(STUDYID, DOMAIN, USUBJID, SUBJID, SITEID, AGE, AGEU, SEX, RACE, COUNTRY, ARM, ACTARM, RFSTDTC)

write_csv(dm, "C:/Users/kasim/Desktop/SDTM_DM.csv")

# ---- Adverse Events (AE) ----
raw_ae <- read_csv("C:/Users/kasim/Desktop/raw_adverse_events.csv", col_types = cols())

ae <- raw_ae %>%
  mutate(
    STUDYID = study_id,
    DOMAIN = "AE",
    USUBJID = if ("USUBJID" %in% colnames(.)) USUBJID else generate_usubjid(n()),
    AETERM = if ("AETERM" %in% colnames(.)) AETERM else NA_character_,
    AEDECOD = if ("AEDECOD" %in% colnames(.)) AEDECOD else NA_character_,
    AESOC = if ("AESOC" %in% colnames(.)) AESOC else NA_character_,
    AESEV = if ("AESEV" %in% colnames(.)) AESEV else NA_character_,
    AESER = if ("AESER" %in% colnames(.)) AESER else NA_character_,
    AESTDTC = if ("AESTDTC" %in% colnames(.)) AESTDTC else NA_character_,
    AEENDTC = if ("AEENDTC" %in% colnames(.)) AEENDTC else NA_character_,
    AEACN = if ("AEACN" %in% colnames(.)) AEACN else NA_character_
  ) %>%
  select(STUDYID, DOMAIN, USUBJID, AETERM, AEDECOD, AESOC, AESEV, AESER, AESTDTC, AEENDTC, AEACN)

write_csv(ae, "C:/Users/kasim/Desktop/SDTM_AE.csv")

# ---- Laboratory (LB) ----
raw_lb <- read_csv("C:/Users/kasim/Desktop/raw_labs.csv", col_types = cols())

lb <- raw_lb %>%
  mutate(
    STUDYID = study_id,
    DOMAIN = "LB",
    USUBJID = if ("USUBJID" %in% colnames(.)) USUBJID else generate_usubjid(n()),
    LBTESTCD = if ("LBTESTCD" %in% colnames(.)) LBTESTCD else NA_character_,
    LBTEST = if ("LBTEST" %in% colnames(.)) LBTEST else NA_character_,
    LBORRES = if ("LBORRES" %in% colnames(.)) LBORRES else NA_character_,
    LBORRESU = if ("LBORRESU" %in% colnames(.)) LBORRESU else NA_character_,
    LBSTRESN = if ("LBSTRESN" %in% colnames(.)) LBSTRESN else NA_real_,
    LBSTRESU = if ("LBSTRESU" %in% colnames(.)) LBSTRESU else NA_character_,
    LBSTNRLO = if ("LBSTNRLO" %in% colnames(.)) LBSTNRLO else NA_real_,
    LBSTNRHI = if ("LBSTNRHI" %in% colnames(.)) LBSTNRHI else NA_real_,
    LBNRIND = if ("LBNRIND" %in% colnames(.)) LBNRIND else NA_character_,
    VISIT = if ("VISIT" %in% colnames(.)) VISIT else NA_character_,
    VISITNUM = if ("VISITNUM" %in% colnames(.)) VISITNUM else NA_integer_,
    LBDTC = if ("LBDTC" %in% colnames(.)) LBDTC else NA_character_
  ) %>%
  select(STUDYID, DOMAIN, USUBJID, LBTESTCD, LBTEST, LBORRES, LBORRESU, LBSTRESN, LBSTRESU, LBSTNRLO, LBSTNRHI, LBNRIND, VISIT, VISITNUM, LBDTC)

write_csv(lb, "C:/Users/kasim/Desktop/SDTM_LB.csv")
