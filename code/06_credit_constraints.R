# 06_credit_constraints.R
# What is rationed, and what the household has to fall back on.
#
# Input:  data/derived/analysis_sample.rds
# Output: output/tables/con_*.md and .tex, output/figures/rationing.png
#
# 05_mechanism.R leaves the gap sitting in how much of the card limit is used.
# Utilization is a ratio, and that result says nothing about which side of it
# moves. This script looks at the parts of the survey that speak to the
# denominator: what each family type asks for, what it is refused, what it says
# it needed and never asked for, and what it could draw on instead.

library(dplyr)
library(fixest)
library(ggplot2)

source("code/00_config.R")
source("code/utils.R")

sample <- readRDS(file.path(DIR_DERIVED, "analysis_sample.rds")) %>%
  filter(!is.na(family_type), !is.na(w))

controls <- c("age", "education", "employment", "owner", "hispanic", "race_black")

wmean <- function(x, w) {
  k <- !is.na(x) & !is.na(w)
  if (!any(k)) return(NA_real_)
  sum(x[k] * w[k]) / sum(w[k])
}

pct <- function(x) ifelse(is.na(x), "", sprintf("%.1f", 100 * x))

# 1. What is rationed ----

# Three things are asked about each kind of credit: whether the respondent
# applied for it (N4), how the request ended (N9, and N11 for a refinancing),
# and whether they needed it and did not apply because they expected to be
# turned down (N6 and N7, which ask the same thing in two formats and are never
# both answered). Read together they separate a refusal from a demand that never
# reaches the lender.

products <- c("New credit card", "Mortgage or home loan", "Auto loan",
              "Card limit increase", "Loan limit increase", "Mortgage refinance",
              "Student loan")

unmet_demand <- function(k) {
  a <- sample[[paste0("N6_", k)]]
  b <- sample[[paste0("N7_", k)]]
  if_else(is.na(a) & is.na(b), NA_integer_,
          as.integer(coalesce(a, 0) == 1 | coalesce(b, 0) == 1))
}

rationing <- lapply(seq_along(products), function(k) {
  asked <- sample[[paste0("N4_", k)]]
  # The refinancing question is followed up in N11 rather than in N9, so N9_6 is
  # empty for everyone.
  ended <- if (k == 6) if_else(sample$refinance_granted == 0, 1L, 0L)
           else as.integer(sample[[paste0("N9_", k)]] == 3)
  sample %>%
    mutate(asked = asked, refused = if_else(asked == 1, ended, NA_integer_),
           unmet = unmet_demand(k)) %>%
    group_by(family_type) %>%
    summarise(product      = products[k],
              n_asked      = sum(asked == 1, na.rm = TRUE),
              n_unmet      = sum(!is.na(unmet)),
              share_asked  = wmean(asked, w),
              share_refused = if (sum(asked == 1, na.rm = TRUE) >= 30) wmean(refused, w) else NA_real_,
              share_unmet  = wmean(unmet, w),
              .groups = "drop")
}) %>% bind_rows()

# Refusal rates are left blank where fewer than thirty people in the cell asked
# for that kind of credit.
tab <- rationing %>%
  transmute(Product = product, Group = as.character(family_type),
            `Asked (%)` = pct(share_asked),
            `Refused when asked (%)` = pct(share_refused),
            `Needed it, did not ask (%)` = pct(share_unmet),
            `N asked` = n_asked, `N unmet` = n_unmet) %>%
  arrange(Product)
write_md_table(tab, file.path(DIR_TABLES, "con_rationing.md"))

cat("\nRationing by product:\n")
print(as.data.frame(tab), row.names = FALSE)

# The same four margins for the card, with the usual controls. The raw gaps in
# the table above are large; most of them do not survive income and
# homeownership, and the cells that carry the refusal rates are small. This is
# the honest version of that panel.
asked_limit   <- sample$N4_4
refused_limit <- if_else(asked_limit == 1, as.integer(sample$N9_4 == 3), NA_integer_)

setFixest_dict(c(
  ask_limit = "Asked for a limit increase", refused_limit = "Refused the increase",
  unmet_limit = "Needed an increase, did not ask", unmet_card = "Needed a card, did not ask",
  raise_2000 = "Could raise $2,000", need_2000 = "Might need $2,000",
  discretionary_share = "Recreation and other, % of spending",
  committed_share = "Housing, utilities and food, % of spending",
  income_variable = "Income varies month to month", card_balance = "Card balance ($)",
  expect_card = "Expects a card to be granted", expect_limit = "Expects an increase to be granted",
  income_bracket = "Household income bracket", age = "Age", owner = "Homeowner",
  hispanic = "Hispanic", race_black = "Black", credit_score_band = "Credit score band",
  family_type = "", state = "State", year = "Year", userid = "Respondent"
))

save_table <- function(models, name) {
  args <- list(models, cluster = ~userid, digits = 3, digits.stats = 3, fitstat = ~ n + r2,
               drop = "education|employment",
               signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.10))
  out <- do.call(etable, args)
  etable_to_md(out, file.path(DIR_TABLES, paste0(name, ".md")))
  do.call(etable, c(args, list(tex = TRUE, replace = TRUE,
                               file = file.path(DIR_TABLES, paste0(name, ".tex")))))
  print(out)
}

card_margin <- sample %>%
  mutate(ask_limit = N4_4, refused_limit = refused_limit,
         unmet_limit = unmet_demand(4), unmet_card = unmet_demand(1))

save_table(list(
  feols(xpd(ask_limit ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        card_margin, weights = ~w),
  feols(xpd(refused_limit ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        card_margin, weights = ~w),
  feols(xpd(unmet_limit ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        card_margin, weights = ~w),
  feols(xpd(unmet_card ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        card_margin, weights = ~w)
), "con_card_margin")

# 2. The denominator ----

# The survey never asks for the credit limit, so it cannot be measured directly.
# What it does give is the balance, and the balance at which a group reports
# having reached the limit is informative about how large the limit is: a
# household that hits the ceiling owing less has a lower ceiling.

cat("\nCard balance among cardholders who paid on time, by whether they reached the limit:\n")
balance <- sample %>%
  filter(has_card == 1, late_30_days == 0, !is.na(maxed_out), !is.na(card_balance)) %>%
  group_by(family_type, maxed_out) %>%
  summarise(median = median(card_balance), n = n(), .groups = "drop")
print(as.data.frame(balance), row.names = FALSE)

write_md_table(
  balance %>%
    transmute(Group = as.character(family_type),
              `At the limit` = ifelse(maxed_out == 1, "yes", "no"),
              `Median balance ($)` = format(median, big.mark = ","), N = n),
  file.path(DIR_TABLES, "con_balance.md"))

# 3. What there is to fall back on ----

# Two questions asked of everyone: the percent chance of needing $2,000 for an
# unexpected expense in the next month, and the percent chance of being able to
# come up with it. The second is the buffer, from any source. A household with
# no buffer is one whose card balance does not come down.

save_table(list(
  feols(xpd(need_2000 ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        sample, weights = ~w),
  feols(xpd(raise_2000 ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        sample, weights = ~w),
  feols(xpd(committed_share ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        sample, weights = ~w),
  feols(xpd(discretionary_share ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        sample, weights = ~w),
  feols(xpd(income_variable ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        sample, weights = ~w)
), "con_buffer")

cat("\nRaw means of the two $2,000 questions and of the budget shares:\n")
print(as.data.frame(sample %>% group_by(family_type) %>%
  summarise(need = wmean(need_2000, w), can_raise = wmean(raise_2000, w),
            committed = wmean(committed_share, w), discretionary = wmean(discretionary_share, w),
            n_2000 = sum(!is.na(raise_2000)), n_budget = sum(!is.na(committed_share)),
            .groups = "drop")), row.names = FALSE, digits = 3)

# 4. Whether the pessimism is warranted ----

# Respondents also give the percent chance that a request of theirs would be
# granted. Column 1 is the raw gap and column 2 adds the score band they report,
# which is what a lender would look at. If the gap goes when the band is held
# fixed, the expectation is in line with the record rather than below it.

save_table(list(
  feols(xpd(expect_card ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        sample, weights = ~w),
  feols(xpd(expect_card ~ family_type + i(credit_score_band) + income_bracket + ..c | state + year,
            ..c = controls), sample, weights = ~w),
  feols(xpd(expect_limit ~ family_type + income_bracket + ..c | state + year, ..c = controls),
        sample, weights = ~w),
  feols(xpd(expect_limit ~ family_type + i(credit_score_band) + income_bracket + ..c | state + year,
            ..c = controls), sample, weights = ~w)
), "con_expectations")

# 5. Figure ----

# The question the figure answers is whether the credit a group is refused is
# the credit it says it needs. Mothers raising children alone against
# respondents without children, which are the two ends of the comparison.

fig <- rationing %>%
  filter(family_type %in% c("Mother, alone", "No children")) %>%
  tidyr::pivot_longer(c(share_refused, share_unmet), names_to = "margin", values_to = "share") %>%
  filter(!is.na(share)) %>%
  mutate(margin = factor(margin, c("share_unmet", "share_refused"),
                         c("Needed it and did not ask", "Refused when they asked")),
         product = factor(product, rev(products)))

p <- ggplot(fig, aes(100 * share, product, colour = family_type)) +
  geom_line(aes(group = product), colour = "grey70", linewidth = 0.6) +
  geom_point(size = 2.8) +
  facet_wrap(~margin, scales = "free_x") +
  scale_colour_manual(values = c("Mother, alone" = "#9B2335", "No children" = "#8C8C8C"),
                      name = NULL) +
  labs(x = "Percent of the group", y = NULL,
       title = "Credit needed and never asked for, and credit refused",
       subtitle = paste("Weighted shares, no controls. Refusal is shown where at least thirty",
                        "people in the cell applied for that kind of credit.")) +
  theme_minimal(base_size = 11) +
  theme(panel.grid.major.y = element_blank(), legend.position = "top",
        plot.title = element_text(face = "bold"))

ggsave(file.path(DIR_FIGURES, "rationing.png"), p, width = 9.5, height = 4.2, dpi = 200)
cat("\nfigure written to", file.path(DIR_FIGURES, "rationing.png"), "\n")
