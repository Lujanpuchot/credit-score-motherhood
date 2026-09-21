# 05_mechanism.R
# Where the motherhood gap in credit scores comes from.
#
# Input:  data/derived/analysis_sample.rds
# Output: output/tables/mech_*.md and .tex, output/figures/gap_by_delinquency.png
#
# A credit score is built from payment history, from how much of the available
# limit is used, and from how long and how varied the file is. The regressions in
# 04_regressions.R show a gap that survives income, homeownership, education,
# employment, race and state, and that does not grow with the number of children
# or with how young they are. That pattern is hard to square with a household
# under current strain, and points instead at the file itself.
#
# This script splits the gap the way a score is built. It asks first whether
# mothers report a lower score because they miss payments, and then, among those
# who do not miss any, whether they are closer to their credit limit.

library(dplyr)
library(fixest)
library(ggplot2)

source("code/00_config.R")
source("code/utils.R")

sample <- readRDS(file.path(DIR_DERIVED, "analysis_sample.rds"))

setFixest_dict(c(
  credit_score_band = "Credit score band", maxed_out = "Reached the card limit",
  late_30_days = "Late by 30 days", applied = "Applied for credit", rejected = "Application rejected",
  has_card = "Holds a credit card",
  income_bracket = "Household income bracket", age = "Age", owner = "Homeowner",
  hispanic = "Hispanic", race_black = "Black", partner = "Partner", female = "Female",
  family_type = "", state = "State", year = "Year", userid = "Respondent"
))

controls <- c("age", "education", "employment", "owner", "hispanic", "race_black")

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

# 1. Missed payments are not the channel ----

# Being late is what damages a score most, so the first question is whether
# mothers are late more often. Columns 1 and 2 put delinquency on the left. If
# the gap ran through payments, the same family types that score low here would
# be the ones that report being late.

late <- list(
  feols(late_30_days ~ family_type, sample, weights = ~w),
  feols(xpd(late_30_days ~ family_type + income_bracket + ..ctrl | state + year, ..ctrl = controls),
        sample, weights = ~w)
)
save_table(late, "mech_delinquency")

# The score gap among people who never missed a payment. If it were payment
# behavior, this sample would show no gap. The lateness question is put only to
# respondents who report at least one debt product, so everyone here carries
# some debt and reports having serviced it on time.
clean <- filter(sample, late_30_days == 0)

clean_gap <- list(
  feols(credit_score_band ~ family_type, clean, weights = ~w),
  feols(credit_score_band ~ family_type + income_bracket, clean, weights = ~w),
  feols(xpd(credit_score_band ~ family_type + income_bracket + ..ctrl | state + year, ..ctrl = controls),
        clean, weights = ~w)
)
save_table(clean_gap, "mech_gap_clean_payers")

# The same contrast as in 04_regressions.R, now among people who pay on time.
full <- clean_gap[[3]]
V <- vcov(full, cluster = ~userid)
k <- c("family_typeMother, alone", "family_typeFather, alone")
if (all(k %in% names(coef(full)))) {
  d  <- coef(full)[k[1]] - coef(full)[k[2]]
  se <- sqrt(V[k[1], k[1]] + V[k[2], k[2]] - 2 * V[k[1], k[2]])
  cat(sprintf("\nAmong people who paid on time, mother alone minus father alone: %.3f bands (se %.3f, p %.3f)\n",
              d, se, 2 * pnorm(-abs(d / se))))
}

# 2. How close to the limit ----

# Reaching the limit of a card is the survey's measure of utilization, which
# carries almost as much weight in a score as payment history. It is estimated
# on people who paid on time, so the answer cannot be read as a consequence of
# being late.

# The question is only put to cardholders, so column 1 is the margin before it:
# who holds a card at all, on the whole sample. Columns 2 to 4 are utilization
# among the cardholders who paid on time.
limit <- list(
  feols(xpd(has_card ~ family_type + income_bracket + ..ctrl | state + year, ..ctrl = controls),
        sample, weights = ~w),
  feols(maxed_out ~ family_type, clean, weights = ~w),
  feols(maxed_out ~ family_type + income_bracket, clean, weights = ~w),
  feols(xpd(maxed_out ~ family_type + income_bracket + ..ctrl | state + year, ..ctrl = controls),
        clean, weights = ~w)
)
save_table(limit, "mech_at_limit")

# Adding utilization to the score regression: how much of the gap it absorbs.
absorb <- list(
  feols(xpd(credit_score_band ~ family_type + income_bracket + ..ctrl | state + year, ..ctrl = controls),
        clean, weights = ~w),
  feols(xpd(credit_score_band ~ family_type + maxed_out + income_bracket + ..ctrl | state + year,
            ..ctrl = controls), clean, weights = ~w)
)
save_table(absorb, "mech_absorbed")

# 3. Applying, and being turned down ----

# Whether the gap also shows up on the way in: who asks for credit, and who is
# refused after asking.

access <- list(
  feols(xpd(applied ~ family_type + income_bracket + ..ctrl | state + year, ..ctrl = controls),
        sample, weights = ~w),
  feols(xpd(rejected ~ family_type + income_bracket + ..ctrl | state + year, ..ctrl = controls),
        filter(sample, applied == 1), weights = ~w)
)
save_table(access, "mech_access")

# 4. The figure ----

# Score by family type, split by whether the respondent missed a payment. The
# left panel is the comparison that matters: everyone in it has a clean record.

plot_data <- sample %>%
  filter(!is.na(family_type), !is.na(late_30_days), !is.na(w)) %>%
  group_by(family_type, late_30_days) %>%
  summarise(score = weighted.mean(credit_score_band, w), n = n(), .groups = "drop") %>%
  mutate(panel = factor(late_30_days, levels = c(0, 1),
                        labels = c("Paid on time in the last 12 months",
                                   "Missed a payment by 30 days or more")))

p <- ggplot(plot_data, aes(x = reorder(family_type, score), y = score, fill = family_type)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = sprintf("%.2f", score)), hjust = -0.15, size = 3.2) +
  coord_flip(ylim = c(0, 4.6)) +
  facet_wrap(~panel) +
  scale_fill_manual(values = c("No children" = "#8C8C8C", "Father, partnered" = "#1F3A5F",
                               "Father, alone" = "#4E7CB0", "Mother, partnered" = "#C2717C",
                               "Mother, alone" = "#9B2335"), guide = "none") +
  labs(x = NULL, y = "Mean credit score band (1 to 5)",
       title = "The gap opens among the people who pay on time",
       subtitle = "Weighted means. A missed payment levels everyone down; without one, mothers still report much lower scores.") +
  theme_minimal(base_size = 11) +
  theme(panel.grid.major.y = element_blank(), plot.title = element_text(face = "bold"))

ggsave(file.path(DIR_FIGURES, "gap_by_delinquency.png"), p, width = 9.5, height = 4, dpi = 200)
cat("\nfigure written to", file.path(DIR_FIGURES, "gap_by_delinquency.png"), "\n")
