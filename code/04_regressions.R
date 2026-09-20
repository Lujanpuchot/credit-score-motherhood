# 04_regressions.R
# Credit score band on gender, children and partnership.
#
# Input:  data/derived/analysis_sample.rds
# Output: output/tables/reg_*.md and reg_*.tex
#
# Estimates are weighted with the survey weight of the credit module, which is
# what makes the sample representative of U.S. household heads: the sample is
# defined by having answered that module. Standard errors are clustered by
# respondent, because a third of respondents appear in two calendar years.
#
# The outcome is a band, not a number, so ordinary least squares imposes that
# the distance from "below 620" to "620-679" is the same as from "720-760" to
# "above 760". That assumption buys coefficients in units anyone can read, at
# the cost of a restriction the data need not satisfy. Part 5 relaxes it with an
# ordered logit and reports whether the picture changes.

library(dplyr)
library(fixest)

source("code/00_config.R")
source("code/utils.R")

sample <- readRDS(file.path(DIR_DERIVED, "analysis_sample.rds"))

setFixest_dict(c(
  credit_score_band = "Credit score band",
  female = "Female", child_under18 = "Children under 18", child_under25 = "Children under 25",
  partner = "Partner", income_bracket = "Household income bracket",
  n_children_under18 = "Number of children", youngest_under6 = "Youngest under 6",
  age = "Age", owner = "Homeowner", hispanic = "Hispanic", race_black = "Black",
  family_type = "", state = "State", year = "Year", userid = "Respondent"
))

controls <- c("age", "education", "employment", "owner", "hispanic", "race_black")

# Education and employment enter as dummies but are not reported: they are
# controls, not the object of the exercise.
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

# 1. The gender gap ----

# Column 1 is the raw gap. Income is added on its own because it is the obvious
# confounder and it is worth seeing how much of the gap it absorbs. The last two
# columns show what the weights do: the gap is the same weighted and unweighted,
# so the result is not an artifact of who answers the survey.

gap <- list(
  feols(credit_score_band ~ female, sample, weights = ~w),
  feols(credit_score_band ~ female + income_bracket, sample, weights = ~w),
  feols(xpd(credit_score_band ~ female + income_bracket + partner + ..ctrl, ..ctrl = controls),
        sample, weights = ~w),
  feols(xpd(credit_score_band ~ female + income_bracket + partner + ..ctrl | state + year, ..ctrl = controls),
        sample, weights = ~w),
  feols(xpd(credit_score_band ~ female + income_bracket + partner + ..ctrl | state + year, ..ctrl = controls),
        sample)
)
save_table(gap, "reg_gender_gap")

# 2. Children, and whether the penalty differs by gender ----

# The interaction is the point: if children carried the same penalty for both
# parents, it would be zero and the gender gap would sit in the level term.

children <- list(
  feols(credit_score_band ~ child_under18 + female, sample, weights = ~w),
  feols(credit_score_band ~ child_under18 * female, sample, weights = ~w),
  feols(credit_score_band ~ child_under18 * female + income_bracket, sample, weights = ~w),
  feols(credit_score_band ~ child_under18 * female + child_under18 * partner + female * partner +
          income_bracket, sample, weights = ~w),
  feols(xpd(credit_score_band ~ child_under18 * female + child_under18 * partner + female * partner +
              income_bracket + ..ctrl | state + year, ..ctrl = controls), sample, weights = ~w),
  feols(xpd(credit_score_band ~ child_under25 * female + child_under25 * partner + female * partner +
              income_bracket + ..ctrl | state + year, ..ctrl = controls), sample, weights = ~w)
)
save_table(children, "reg_children")

# 3. The four kinds of parent ----

# The hypothesis the project started from is about single mothers, and a set of
# two-way interactions answers it only indirectly: the quantity of interest is a
# sum of three coefficients, and its standard error is not on the table. Crossing
# gender with partnership into one variable puts each group against the same
# reference, respondents without children, and makes the comparison that matters
# --- a mother raising children alone against a father doing the same --- a
# difference between two coefficients that can be tested directly.

family <- list(
  feols(credit_score_band ~ family_type, sample, weights = ~w),
  feols(credit_score_band ~ family_type + income_bracket, sample, weights = ~w),
  feols(xpd(credit_score_band ~ family_type + income_bracket + ..ctrl, ..ctrl = controls),
        sample, weights = ~w),
  feols(xpd(credit_score_band ~ family_type + income_bracket + ..ctrl | state + year, ..ctrl = controls),
        sample, weights = ~w)
)
save_table(family, "reg_family_type")

# The hypothesis in one line: mothers alone against fathers alone, with everything
# else held fixed.
full <- family[[4]]
V <- vcov(full, cluster = ~userid)
k <- c("family_typeMother, alone", "family_typeFather, alone")
stopifnot(all(k %in% names(coef(full))))
d  <- coef(full)[k[1]] - coef(full)[k[2]]
se <- sqrt(V[k[1], k[1]] + V[k[2], k[2]] - 2 * V[k[1], k[2]])
cat(sprintf("\nMother alone minus father alone: %.3f bands (se %.3f, t %.2f, p %.3f)\n",
            d, se, d / se, 2 * pnorm(-abs(d / se))))

# 4. How many children, and how young ----

# Two things the indicator hides. A second child need not cost what the first
# one did, and the age of the youngest is what decides how much care the
# household absorbs. Both are estimated on parents only, so the comparison is
# between households that have children rather than against those that do not.

parents <- filter(sample, child_under18 == 1)

dose <- list(
  feols(credit_score_band ~ n_children_under18 * female + income_bracket, parents, weights = ~w),
  feols(xpd(credit_score_band ~ n_children_under18 * female + income_bracket + partner + ..ctrl |
              state + year, ..ctrl = controls), parents, weights = ~w),
  feols(credit_score_band ~ youngest_under6 * female + income_bracket, parents, weights = ~w),
  feols(xpd(credit_score_band ~ youngest_under6 * female + income_bracket + partner + ..ctrl |
              state + year, ..ctrl = controls), parents, weights = ~w)
)
save_table(dose, "reg_children_dose")

# 5. The band as an ordered outcome ----

# Least squares treats the five bands as equally spaced numbers. An ordered logit
# does not: it estimates the cut points from the data and asks only that the
# bands be ordered. The coefficients are not comparable in size with the ones
# above, so what matters here is whether the signs and the significance survive.
# Standard errors are clustered by respondent, as everywhere else.

ord_data <- sample %>%
  filter(!is.na(family_type), !is.na(income_bracket), !is.na(w)) %>%
  mutate(band = factor(credit_score_band, levels = 1:5, ordered = TRUE))

ord <- MASS::polr(band ~ family_type + income_bracket, data = ord_data,
                  weights = ord_data$w, Hess = TRUE, method = "logistic")

ord_se <- sqrt(diag(sandwich::vcovCL(ord, cluster = ord_data$userid)))
ord_tab <- data.frame(
  Term        = names(coef(ord)),
  Estimate    = sprintf("%.3f", coef(ord)),
  `Std Error` = sprintf("(%.3f)", ord_se[names(coef(ord))]),
  z           = sprintf("%.2f", coef(ord) / ord_se[names(coef(ord))]),
  check.names = FALSE
)
write_md_table(ord_tab, file.path(DIR_TABLES, "reg_ordered_logit.md"))
cat("\nOrdered logit, clustered by respondent:\n")
print(ord_tab, row.names = FALSE)

# 6. Race ----

race <- list(
  feols(credit_score_band ~ female * race_black + hispanic, sample, weights = ~w),
  feols(xpd(credit_score_band ~ female * race_black + hispanic + income_bracket + partner + child_under18 +
              ..ctrl | state + year, ..ctrl = setdiff(controls, c("hispanic", "race_black"))),
        sample, weights = ~w)
)
save_table(race, "reg_race")
