# 01_build_sample.R
# Person-year dataset from the SCE core survey and its Credit Access module,
# 2013-2019.
#
# Input:  the three Excel files listed in 00_config.R
# Output: data/derived/sce_person_year.rds

library(dplyr)
library(readxl)

source("code/00_config.R")

# Read ----

# The first row of each sheet is a note, not the header. guess_max is raised
# because many columns are empty for the first few thousand rows and would be
# read as logical.
read_sce <- function(file, ...) {
  read_excel(file.path(DIR_RAW, file), skip = 1, guess_max = 100000, ...)
}

core   <- bind_rows(read_sce(FILES_RAW[["core_2013"]]), read_sce(FILES_RAW[["core_2017"]]))
credit <- read_sce(FILES_RAW[["credit"]], sheet = "Data")

# One record per person and year ----

# `date` is YYYYMM. Respondents stay in the panel for up to twelve months and the
# credit module is fielded every four months, so the same person can appear
# several times within a calendar year. The last interview of the year is kept
# in each source, and the two are matched on person and year even if the months
# differ.
add_year <- function(df) {
  df %>% mutate(year  = as.integer(substr(date, 1, 4)),
                month = as.integer(substr(date, 5, 6)))
}

last_of_year <- function(df) {
  out <- df %>%
    group_by(userid, year) %>%
    slice_max(month, n = 1) %>%
    ungroup()
  stopifnot(!any(duplicated(out[c("userid", "year")])))
  out
}

core <- add_year(core)

core_year <- core %>%
  last_of_year() %>%
  select(userid, year, month, weight,
         starts_with("Q10_"),              # employment situation (multiple answers)
         region = `_REGION_CAT`)

credit_year <- credit %>%
  add_year() %>%
  last_of_year() %>%
  select(userid, year,
         month_credit       = month,
         weight_credit      = weight,   # survey weight of the credit module, the one this sample is defined by
         credit_score_band  = N22,   # 1 below 620 ... 5 above 760, 6 don't know
         score_last_checked = N23,
         late_30_days       = N15,   # asked of respondents with at least one debt product
         late_90_days       = N16,
         has_card           = N1_1,  # holds at least one credit card
         maxed_out          = N3,    # reached the limit of a card, asked of cardholders
         starts_with("N4_"),         # applied for each kind of credit
         starts_with("N9_"))         # and how the request ended, for the first five

# Background questions ----

# Demographics and household composition are asked only in a respondent's first
# interview, so they are taken from that record and carried to every year.
background <- core %>%
  arrange(userid, date) %>%
  group_by(userid) %>%
  slice(1) %>%
  ungroup() %>%
  select(userid,
         age               = Q32,
         gender            = Q33,   # 1 female, 2 male
         hispanic          = Q34,   # 1 yes, 2 no
         starts_with("Q35_"),       # race, multiple answers allowed
         education         = Q36,
         partner           = Q38,   # married or living with a partner: 1 yes, 2 no
         state             = `_STATE`,
         home_tenure       = Q43,   # 1 own, 2 rent, 3 other
         n_partner         = Q45new_1,
         n_children_25plus = Q45new_2,
         n_children_18_24  = Q45new_3,
         n_children_6_17   = Q45new_4,
         n_children_0_5    = Q45new_5,
         income_bracket    = Q47)   # household income: 1 under $10,000 ... 11 $200,000 or more

# Merge and save ----

person_year <- core_year %>%
  left_join(credit_year, by = c("userid", "year")) %>%
  left_join(background,  by = "userid") %>%
  rename(emp_full_time = Q10_1, emp_part_time = Q10_2, emp_looking  = Q10_3,
         emp_laid_off  = Q10_4, emp_on_leave  = Q10_5, emp_disabled = Q10_6,
         emp_retired   = Q10_7, emp_student   = Q10_8, emp_homemaker = Q10_9,
         emp_other     = Q10_10,
         race_white = Q35_1, race_black = Q35_2, race_native = Q35_3,
         race_asian = Q35_4, race_pacific = Q35_5, race_other = Q35_6)

stopifnot(nrow(person_year) == nrow(core_year))

cat("Person-years:", nrow(person_year), "\n")
cat("Respondents: ", n_distinct(person_year$userid), "\n")
cat("With a credit module interview in the year:", sum(!is.na(person_year$month_credit)), "\n")

saveRDS(person_year, file.path(DIR_DERIVED, "sce_person_year.rds"))
