# 02_analysis_sample.R
# Restricts the person-year data to respondents who report a credit score band
# and builds the variables used in the tables and regressions.
#
# Input:  data/derived/sce_person_year.rds
# Output: data/derived/analysis_sample.rds

library(dplyr)

source("code/00_config.R")

person_year <- readRDS(file.path(DIR_DERIVED, "sce_person_year.rds"))

# The credit score question was added to the module in February 2014. Band 6 is
# "don't know".
sample <- person_year %>%
  filter(!is.na(credit_score_band), credit_score_band < 6)

sample <- sample %>%
  mutate(
    female = case_when(gender == 1 ~ 1, gender == 2 ~ 0),
    hispanic = case_when(hispanic == 1 ~ 1, hispanic == 2 ~ 0),
    partner  = case_when(partner == 1 ~ 1, partner == 2 ~ 0),
    owner    = case_when(home_tenure == 1 ~ 1, home_tenure == 2 ~ 0),   # "other" left missing

    # Children living in the household. The main definition is children under 18;
    # the wider one adds those aged 18 to 24.
    child_under18 = as.integer(n_children_0_5 >= 1 | n_children_6_17 >= 1),
    child_under6  = as.integer(n_children_0_5 >= 1),
    child_under25 = as.integer(n_children_0_5 >= 1 | n_children_6_17 >= 1 | n_children_18_24 >= 1),
    n_children_under18 = rowSums(across(c(n_children_0_5, n_children_6_17)), na.rm = TRUE),

    # The youngest child is what decides how much care the household absorbs, so
    # a parent of a toddler and a parent of a teenager are kept apart.
    youngest_under6 = if_else(child_under18 == 0, NA_integer_, as.integer(n_children_0_5 >= 1)),

    # The hypothesis the project started from is about single mothers, which
    # needs gender and partnership crossed rather than added. Respondents
    # without children are the reference category.
    family_type = case_when(
      is.na(female) | is.na(child_under18) | is.na(partner) ~ NA_character_,
      child_under18 == 0                    ~ "No children",
      female == 0 & partner == 1            ~ "Father, partnered",
      female == 0 & partner == 0            ~ "Father, alone",
      female == 1 & partner == 1            ~ "Mother, partnered",
      female == 1 & partner == 0            ~ "Mother, alone"
    ),
    family_type = relevel(factor(family_type), ref = "No children"),

    # Credit file, as opposed to payment behavior. Reaching the limit of a card
    # is the survey's closest measure of utilization, which weighs about as much
    # in a score as payment history does. It is asked of cardholders only, so
    # has_card is the margin that comes before it.
    has_card  = as.integer(has_card),
    maxed_out = as.integer(maxed_out),

    # Applied for any of the seven kinds of credit the module asks about. How the
    # request ended is not asked about refinancing, so an application with no
    # answer on that side is left missing rather than counted as not rejected.
    applied       = as.integer(rowSums(across(starts_with("N4_"), ~ .x == 1), na.rm = TRUE) > 0),
    outcome_known = rowSums(!is.na(across(starts_with("N9_")))) > 0,
    rejected      = if_else(applied == 1 & outcome_known,
                            as.integer(rowSums(across(starts_with("N9_"), ~ .x == 3), na.rm = TRUE) > 0),
                            NA_integer_),

    # Five arithmetic questions and one on the real interest rate, scored as the
    # number of correct answers. They are asked as a block, so a respondent who
    # left any of them blank is left missing rather than counted as wrong.
    numeracy = (QNUM1 == 150) + (QNUM2 == 242) + (QNUM3 == 10) +
               (QNUM5 == 100) + (QNUM6 == 5) + (QNUM8 == 3),
    risk_tolerance = QRA1,                     # 1 not willing at all to 7 very willing
    decides_alone  = as.integer(Q46 >= 4),     # makes all of the household's financial decisions

    # What the monthly budget is committed to. Housing, utilities and food are
    # what a household cannot postpone when something happens; recreation and
    # the miscellaneous category are what it can.
    committed_share     = qsp5_1 + qsp5_2 + qsp5_3,
    discretionary_share = qsp5_7 + qsp5_9,
    income_variable     = as.integer(income_variability >= 3),

    # Survey weight. The sample is defined by answering the credit module, so
    # that module's weight is the one that makes it representative. The spending
    # module has its own weight, which is not in the public file, so the columns
    # that use spending variables are weighted with this one too.
    w = weight_credit,

    # Graduate degrees pooled; "other" left missing.
    education = case_when(education %in% 1:5 ~ as.integer(education),
                          education %in% 6:8 ~ 6L),
    education = factor(education, levels = 1:6,
                       labels = c("Less than high school", "High school", "Some college",
                                  "Associate degree", "Bachelor's degree", "Graduate degree")),

    # Employment situation allows several answers; assign one status in this order.
    employment = case_when(if_all(starts_with("emp_"), is.na) ~ NA_character_,
                           emp_full_time == 1 ~ "Full time",
                           emp_part_time == 1 ~ "Part time",
                           emp_retired   == 1 ~ "Retired",
                           emp_looking == 1 | emp_laid_off == 1 ~ "Unemployed",
                           TRUE ~ "Out of the labor force"),
    employment = relevel(factor(employment), ref = "Full time")
  )

# A respondent can be in the sample in two consecutive calendar years.
cat("Observations:", nrow(sample), "\n")
cat("Respondents: ", n_distinct(sample$userid), "\n")
print(table(year = sample$year))

saveRDS(sample, file.path(DIR_DERIVED, "analysis_sample.rds"))
