# 07_information.R
# What a household knows about itself that its credit score does not.
#
# Input:  data/derived/analysis_sample.rds
# Output: output/tables/inf_*.md and .tex
#
# The sections before this one end at a household that services its debt on
# time, is close to its card limit, and has nothing to fall back on. A credit
# score is built from the first of those and not from the third, which suggests
# a question that is not about motherhood at all: does a household hold
# information about its own credit behavior that its score leaves out?
#
# The survey can answer it because it asks the same people twice. A third of
# respondents appear in two calendar years, so this year's score and this year's
# answers can be set against what happens to them next year.

library(dplyr)
library(fixest)

source("code/00_config.R")
source("code/utils.R")

sample <- readRDS(file.path(DIR_DERIVED, "analysis_sample.rds")) %>%
  filter(!is.na(family_type), !is.na(w))

# Each person-year paired with the same person one year later.
following <- sample %>%
  transmute(userid, year = year - 1,
            late_next  = late_30_days,
            maxed_next = maxed_out,
            band_next  = credit_score_band)

pairs <- inner_join(sample, following, by = c("userid", "year"))

cat("consecutive pairs:", nrow(pairs), " respondents:", n_distinct(pairs$userid), "\n")
print(table(pairs$family_type))

setFixest_dict(c(
  late_next = "Late next year", maxed_next = "At the limit next year",
  band_next = "Score band next year", credit_score_band = "Score band",
  miss_payment_chance = "Own chance of missing a payment", raise_2000 = "Could raise $2,000",
  late_30_days = "Late this year", maxed_out = "At the limit this year",
  state = "State", year = "Year", userid = "Respondent"
))

# etable matches on the printed labels and reads them as regular expressions,
# which is why the buffer is named by its first two words and not by the dollar
# amount in its label.
keep <- c("Own chance", "Could raise", "Late this year", "At the limit this year")

save_table <- function(models, name, data = pairs) {
  args <- list(models, cluster = ~userid, digits = 4, digits.stats = 4,
               keep = keep, fitstat = ~ n + r2,
               signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.10))
  out <- do.call(etable, args)
  etable_to_md(out, file.path(DIR_TABLES, paste0(name, ".md")))
  do.call(etable, c(args, list(tex = TRUE, replace = TRUE,
                               file = file.path(DIR_TABLES, paste0(name, ".tex")))))
  print(out)
}

# 1. Does what they say about themselves predict what happens to them? ----

# Every column holds this year's score band fixed with a full set of dummies, so
# the question is always what is left over once a lender's summary statistic has
# been used. Columns 2 and 4 also hold fixed this year's lateness and this
# year's use of the limit, which is what the answer might otherwise be
# restating.

save_table(list(
  feols(late_next ~ i(credit_score_band) + miss_payment_chance | state + year,
        pairs, weights = ~w),
  feols(late_next ~ i(credit_score_band) + late_30_days + maxed_out + miss_payment_chance |
          state + year, pairs, weights = ~w),
  feols(band_next ~ i(credit_score_band) + miss_payment_chance + raise_2000 | state + year,
        pairs, weights = ~w),
  feols(band_next ~ i(credit_score_band) + late_30_days + maxed_out + miss_payment_chance +
          raise_2000 | state + year, pairs, weights = ~w)
), "inf_next_year")

# 2. Whether it is an artifact of the band being self-reported ----

# The band is what the respondent says it is, so it measures the real score with
# error, and a control measured with error leaves room for anything correlated
# with the truth. That is exactly what this result would look like if there were
# nothing behind it. Respondents who checked their score within the past six
# months report it with less error than those whose last look was over a year
# ago, so attenuation predicts a larger coefficient in the second group. It is
# larger, and the first group still has most of it.

recent <- filter(pairs, score_last_checked <= 2)
stale  <- filter(pairs, score_last_checked >= 4)
cat("\nchecked within six months:", nrow(recent), " last check over a year ago:", nrow(stale), "\n")

save_table(list(
  feols(late_next ~ i(credit_score_band) + late_30_days + maxed_out + miss_payment_chance |
          state + year, recent, weights = ~w),
  feols(late_next ~ i(credit_score_band) + late_30_days + maxed_out + miss_payment_chance |
          state + year, stale, weights = ~w),
  feols(band_next ~ i(credit_score_band) + late_30_days + maxed_out + miss_payment_chance +
          raise_2000 | state + year, recent, weights = ~w)
), "inf_measurement")

# 3. Whose answers carry more of it ----

# If the information were something only some households have, the slope would
# differ across them. It does not, which is the simpler and more useful result:
# every kind of household knows the same amount about itself, and the families
# in the sections above are the ones with more to know.

interacted <- feols(late_next ~ i(credit_score_band) + late_30_days + maxed_out +
                      miss_payment_chance * family_type | state + year,
                    pairs, weights = ~w, cluster = ~userid)
k <- grepl("miss_payment_chance", names(coef(interacted)))
cat("\nSlope of the own probability, by family type:\n")
print(round(rbind(coef = coef(interacted)[k], se = se(interacted)[k]), 4))

# What the coefficient is worth for the families the rest of the repository is
# about: how far apart they sit on the question, times how much a point of it is
# worth for next year's delinquency.
gap <- with(filter(pairs, family_type %in% c("Mother, alone", "No children")),
            tapply(miss_payment_chance, droplevels(family_type), mean, na.rm = TRUE))
slope <- coef(feols(late_next ~ i(credit_score_band) + late_30_days + maxed_out +
                      miss_payment_chance | state + year, pairs,
                    weights = ~w))["miss_payment_chance"]
cat(sprintf("\nMothers alone sit %.1f points above respondents without children on their own\n",
            gap[["Mother, alone"]] - gap[["No children"]]))
cat(sprintf("probability, which at %.4f a point is %.1f points of next year's delinquency\n",
            slope, 100 * slope * (gap[["Mother, alone"]] - gap[["No children"]])))
cat("that a lender reading only the score does not see.\n")
