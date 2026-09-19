# 03_descriptives.R
# Summary statistics by gender and presence of children, and the distribution of
# credit score bands across the same groups.
#
# Input:  data/derived/analysis_sample.rds
# Output: output/tables/summary_by_group.md
#         output/figures/score_bands_by_group.png

library(dplyr)
library(tidyr)
library(ggplot2)

source("code/00_config.R")
source("code/utils.R")

sample <- readRDS(file.path(DIR_DERIVED, "analysis_sample.rds")) %>%
  filter(!is.na(female), !is.na(child_under18)) %>%
  mutate(group = paste(ifelse(female == 1, "Women", "Men"),
                       ifelse(child_under18 == 1, "with children", "without children")),
         group = factor(group, levels = c("Women with children", "Women without children",
                                          "Men with children", "Men without children")))

# Summary table ----

summary_by_group <- sample %>%
  group_by(group) %>%
  summarise(
    `Observations`              = n(),
    `Credit score band (1-5)`   = mean(credit_score_band),
    `Score below 620`           = mean(credit_score_band == 1),
    `Score above 760`           = mean(credit_score_band == 5),
    `Household income bracket (1-11)` = mean(income_bracket, na.rm = TRUE),
    `Married or with a partner` = mean(partner, na.rm = TRUE),
    `Homeowner`                 = mean(owner, na.rm = TRUE),
    `Bachelor's degree or more` = mean(education %in% c("Bachelor's degree", "Graduate degree")),
    `Working full time`         = mean(employment == "Full time", na.rm = TRUE),
    `Age`                       = mean(age, na.rm = TRUE),
    .groups = "drop"
  )

table_out <- summary_by_group %>%
  pivot_longer(-group, names_to = " ") %>%
  mutate(value = case_when(` ` == "Observations" ~ format(round(value), big.mark = ","),
                           ` ` == "Age" ~ sprintf("%.1f", value),
                           TRUE ~ sprintf("%.2f", value))) %>%
  pivot_wider(names_from = group, values_from = value)

write_md_table(table_out, file.path(DIR_TABLES, "summary_by_group.md"))
print(table_out)

# Distribution of score bands ----

band_labels <- c("Below 620", "620-679", "680-719", "720-760", "Above 760")

bands <- sample %>%
  count(group, credit_score_band) %>%
  group_by(group) %>%
  mutate(share = n / sum(n),
         band  = factor(credit_score_band, levels = 1:5, labels = band_labels))

p <- ggplot(bands, aes(x = band, y = share, fill = group)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.75) +
  scale_y_continuous(labels = function(x) paste0(round(100 * x), "%")) +
  scale_fill_manual(values = c("#9B2335", "#D98C95", "#1F3A5F", "#8FA6C4")) +
  labs(x = "Self-reported credit score", y = "Share of group", fill = NULL) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top", panel.grid.major.x = element_blank())

ggsave(file.path(DIR_FIGURES, "score_bands_by_group.png"), p, width = 8, height = 4.5, dpi = 200)
