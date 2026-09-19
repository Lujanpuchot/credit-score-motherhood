# 04_regressions.R
# OLS regressions of the self-reported credit score band on gender, children and
# partnership. Standard errors are clustered by respondent, since about a third
# of respondents are observed in two calendar years.
#
# Input:  data/derived/analysis_sample.rds
# Output: output/tables/reg_*.md and reg_*.tex

library(dplyr)
library(fixest)

source("code/00_config.R")
source("code/utils.R")

sample <- readRDS(file.path(DIR_DERIVED, "analysis_sample.rds"))

setFixest_dict(c(
  credit_score_band = "Credit score band",
  female = "Female", child_under18 = "Children under 18", child_under25 = "Children under 25",
  partner = "Partner", income_bracket = "Household income bracket",
  age = "Age", owner = "Homeowner", hispanic = "Hispanic", race_black = "Black",
  state = "State", year = "Year", userid = "Respondent"
))

controls <- c("age", "education", "employment", "owner", "hispanic", "race_black")

# Education and employment dummies are included as controls but not reported.
save_table <- function(models, name) {
  args <- list(models, cluster = ~userid, digits = 3, digits.stats = 3, fitstat = ~ n + r2,
               drop = "education|employment",
               signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.10))
  tab <- do.call(etable, args)
  etable_to_md(tab, file.path(DIR_TABLES, paste0(name, ".md")))
  do.call(etable, c(args, list(tex = TRUE, replace = TRUE,
                               file = file.path(DIR_TABLES, paste0(name, ".tex")))))
  print(tab)
}

# Gender gap ----

gap <- list(
  feols(credit_score_band ~ female, sample),
  feols(credit_score_band ~ female + income_bracket, sample),
  feols(xpd(credit_score_band ~ female + income_bracket + partner + ..ctrl, ..ctrl = controls), sample),
  feols(xpd(credit_score_band ~ female + income_bracket + partner + ..ctrl | state + year, ..ctrl = controls), sample)
)
save_table(gap, "reg_gender_gap")

# Children, by gender and partnership ----

children <- list(
  feols(credit_score_band ~ child_under18 + female, sample),
  feols(credit_score_band ~ child_under18 * female, sample),
  feols(credit_score_band ~ child_under18 * female + income_bracket, sample),
  feols(credit_score_band ~ child_under18 * female + child_under18 * partner + female * partner +
          income_bracket, sample),
  feols(xpd(credit_score_band ~ child_under18 * female + child_under18 * partner + female * partner +
              income_bracket + ..ctrl | state + year, ..ctrl = controls), sample),
  feols(xpd(credit_score_band ~ child_under25 * female + child_under25 * partner + female * partner +
              income_bracket + ..ctrl | state + year, ..ctrl = controls), sample)
)
save_table(children, "reg_children")

# Split by gender ----

by_gender <- list(
  Women = feols(xpd(credit_score_band ~ child_under18 * partner + income_bracket + ..ctrl | state + year,
                    ..ctrl = controls), filter(sample, female == 1)),
  Men   = feols(xpd(credit_score_band ~ child_under18 * partner + income_bracket + ..ctrl | state + year,
                    ..ctrl = controls), filter(sample, female == 0))
)
save_table(by_gender, "reg_by_gender")

# Race ----

race <- list(
  feols(credit_score_band ~ female * race_black + hispanic, sample),
  feols(xpd(credit_score_band ~ female * race_black + hispanic + income_bracket + partner + child_under18 +
              ..ctrl | state + year, ..ctrl = setdiff(controls, c("hispanic", "race_black"))), sample)
)
save_table(race, "reg_race")
