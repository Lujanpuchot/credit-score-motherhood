# Credit scores, gender and motherhood

Mothers raising children alone report lower credit scores than fathers in the same situation, and the gap is not in their payment record. They are late as often as single fathers are. What differs is how much of their credit line is in use, and how little they have to fall back on if something happens. Following the same households a year later, what a household says about its own chances of missing a payment predicts what happens to it, over and above the score a lender would read. The project ends somewhere it did not start: on what a credit score leaves out, and on whom it leaves out most.

An exploratory project on the child penalty in access to credit, using the Survey of Consumer Expectations of the Federal Reserve Bank of New York. It extends my undergraduate thesis at Universidad de Buenos Aires, *Credit Gaps and Motherhood: Unraveling Gender Disparities in Financial Access* (2024).

Started in January 2025 and parked while I finish my M.A. thesis. Where it was heading when it stopped is in [docs/a_paper_from_this.md](docs/a_paper_from_this.md).

## Question

The child penalty in the labor market is well documented. Much less is known about credit, even though a credit score decides whether a household can borrow, and at what price, to smooth spending on health, education and housing, which is when children make borrowing most valuable.

The project started by asking whether mothers report lower scores than fathers and than women without children, and whether a partner offsets the difference. What changed the question is where the gap turns out to sit. A score is built mostly from two things, the record of past payments and the share of the available limit in use, and the gap is not in the first of them. So the working hypothesis is now about revolving use rather than default: motherhood does not seem to push households into missing payments, it pushes them into carrying a balance they do not pay down. Motivation, hypotheses and literature are in [docs/project_outline.md](docs/project_outline.md).

## Data

The Survey of Consumer Expectations (SCE) is a monthly rotating panel of about 1,300 U.S. household heads, who stay in the panel for up to twelve months. I use the core survey for 2013-2019, the Credit Access module, which is fielded every four months and since February 2014 asks respondents for their credit score in five bands, below 620, 620-679, 680-719, 720-760 and above 760, and the Household Spending module, which carries the composition of monthly spending. Demographics and household composition come from each respondent's first interview.

The unit of observation is a person-year. The analysis sample has 11,393 observations from 8,580 respondents between 2014 and 2019. The microdata are public but are not redistributed here; [data/README.md](data/README.md) explains how to get them.

## Results

Everything below is weighted with the survey weight of the credit module and clustered by respondent. The weights change little: the gender gap is 0.169 of a band weighted and 0.180 unweighted.

### The gap

Gender and partnership are crossed into one variable so that every family type is measured against the same reference, respondents without children, and the comparison that matters is a difference between two coefficients rather than a sum of three.

| Against respondents without children | Raw | + income | + controls | + state and year |
|:---|---:|---:|---:|---:|
| Father, partnered | 0.073 (0.061) | -0.313*** (0.056) | -0.136*** (0.053) | -0.139*** (0.052) |
| Father, alone | -0.577** (0.252) | -0.491** (0.216) | -0.231 (0.194) | -0.201 (0.178) |
| Mother, partnered | -0.746*** (0.072) | -0.896*** (0.058) | -0.522*** (0.058) | -0.515*** (0.057) |
| Mother, alone | -1.58*** (0.092) | -1.12*** (0.089) | -0.580*** (0.079) | -0.574*** (0.077) |
| Observations | 11,387 | 11,323 | 11,117 | 11,106 |

A mother raising children alone reports **0.373 of a band less than a father in the same situation** (standard error 0.189, p = 0.049). Fathers raising children alone are not distinguishable from respondents without children once income and the rest are held fixed; mothers are, with or without a partner. An ordered logit, which estimates the cut points instead of assuming the bands are equally spaced, gives the same ordering ([reg_ordered_logit](output/tables/reg_ordered_logit.md)).

A partner matters less than it looks. Raw, one is worth most of a band to a mother, 1.58 against 0.746; with income and homeownership in the regression the two are almost the same, 0.574 against 0.515.

Neither the number of children nor the age of the youngest moves the score. A second child is worth -0.008 of a band (0.034) and having the youngest under six 0.039 (0.093), and neither interacts with gender ([reg_children_dose](output/tables/reg_children_dose.md)). The penalty attaches to being a mother, not to how much care the children currently need.

### It is not payment history

![Credit score by family type, split by whether the respondent missed a payment](output/figures/gap_by_delinquency.png)

Mothers and fathers raising children alone are late on a loan payment at almost the same rate, 20.9% and 21.1%, against 5.3% among respondents without children. If the gap ran through payment history it would close among the respondents who paid everything on time. It widens: restricted to them, a mother raising children alone reports 0.663 of a band less than a father doing the same (0.183, p < 0.001) against 0.373 in the whole sample ([mech_delinquency](output/tables/mech_delinquency.md), [mech_gap_clean_payers](output/tables/mech_gap_clean_payers.md)).

### It is the balance carried

Among cardholders who paid on time, 35.5% of mothers raising children alone had reached a card limit during the year, against 14.1% of respondents without children and 7.2% of fathers raising children alone. With the full controls the difference is 10 percentage points (0.040), and card holding itself is not where they differ ([mech_at_limit](output/tables/mech_at_limit.md)). That one variable absorbs a third of the score gap ([mech_absorbed](output/tables/mech_absorbed.md)). Being at the limit is an outcome, so this is accounting: it says where the gap sits, not what put it there.

They are not borrowing more. The median balance of someone who reports having reached the limit is $5,000 for a mother raising children alone, $8,000 for a respondent without children and $15,500 for a partnered father ([con_balance](output/tables/con_balance.md)). Hitting the ceiling while owing less is what a lower ceiling looks like. They are not turned away at the door either: they apply for credit 9.6 points more often and are no more likely to be refused ([mech_access](output/tables/mech_access.md)).

### What the household has to fall back on

Respondents give the percent chance of needing $2,000 for an unexpected expense in the next month, and the percent chance of being able to come up with it. Mothers raising children alone put the first at 30.5%, the lowest of any family type, and the second at 38.9% against 72.6% for respondents without children. With income, homeownership, education, employment, race, state and year held fixed, the gap in raising the money is 9.5 points for mothers alone and 9.9 for mothers with a partner, both precisely estimated, while the gap in expecting to need it is zero ([con_buffer](output/tables/con_buffer.md)). The same exposure to a shock and half the capacity to absorb one, which is a reason for a balance that does not come down.

Two things this is not. Their expectation of being approved tracks the band they report almost exactly, so the pessimism is an accurate reading of a low score rather than something added on top of it ([con_expectations](output/tables/con_expectations.md)). And although they report having needed credit and not applied for it more often than anyone, across all seven kinds the module asks about, most of that gap is income once the controls go in ([con_rationing](output/tables/con_rationing.md), [con_card_margin](output/tables/con_card_margin.md)).

### What the household knows and the score does not

The panel side of the survey is what none of the above uses. A third of respondents are interviewed in two calendar years, so this year's answers can be set against next year's outcomes ([07_information.R](code/07_information.R)).

Holding the reported band fixed with a full set of dummies, a household's own stated chance of missing a debt payment over the next three months predicts whether it misses one over the following year, 0.0041 per point (0.0005), and where its band ends up, -0.0037 (0.0009). That one answer takes the R-squared on next year's delinquency from 0.19 to 0.29 ([inf_next_year](output/tables/inf_next_year.md)). It survives holding this year's delinquency and use of the limit fixed, 0.0027 (0.0005), and it survives the objection that a self-reported band is a poor control: among respondents who checked their score within six months the coefficient is 0.0026 (0.0006), against 0.0038 (0.0010) for those whose last look was over a year ago ([inf_measurement](output/tables/inf_measurement.md)). Measurement error inflates this; it does not produce it.

The slope is the same for every family type. What differs is where they sit: mothers raising children alone are 16.8 points higher, which is 4.6 points of next year's delinquency that a lender reading only the score does not see.

### Race

Black respondents report scores between 0.6 and 0.95 of a band lower than the rest, depending on the controls, with a further and less precisely estimated difference for Black women ([reg_race](output/tables/reg_race.md)).

### How to read this

These are associations. Fertility and partnership are choices correlated with many things that also move credit histories, so nothing here identifies the effect of having a child, and household composition is measured at each respondent's first interview and carried forward.

Two things are worth knowing before leaning on any single number. The score is self-reported in five bands, although mothers raising children alone are the group that checked it most recently, 72% within six months against 62% of respondents without children, so if anything their answer is the better informed one. And there are 110 person-years of fathers raising children alone against 468 of mothers, so the comparison the design is built around is the least precisely estimated one in the table: the robust statement is the one against respondents without children.

## What this would add

The child penalty in earnings is well measured, and gender differences in credit have been studied mostly on the extensive margin, on who is approved and at what rate. Three things here would be new: measuring the penalty in the credit record rather than in earnings, since earnings recover after a birth while a file is a stock that carries the shock into the price of future borrowing; splitting the gap into the components a score is built from, because a penalty for failing to pay and a penalty for borrowing have different remedies, and rules that age derogatory marks off a file do nothing about the second; and comparing mothers with fathers raising children alone, which holds household structure fixed and varies only the gender of the parent. Doing it properly needs a credit bureau panel with an event study around a first birth. What this survey can do is say what to look for.

## Next steps

- **The limit itself.** Everything above infers it. A bureau panel measures it next to the balance and turns the indicator for hitting the ceiling into a ratio.
- **Whether it lasts.** The same person can be followed from one year to the next: who is still at the limit, and whether a limit cut predicts being at the ceiling a year later.
- **The mortgage margin.** Mothers raising children alone apply for a mortgage less often than anyone and report needing one and not asking more often than anyone. Staying out of the market that builds equity is a penalty on wealth rather than on the price of credit.
- **Who is answering for the household.** Mothers living with a partner are the least likely of any group to make the household's financial decisions, 29% against 39% of partnered fathers, and the only group whose expectations of being approved sit below what their band implies.
- **Policy.** The Medicaid expansion of 2014 as variation in the financial cost of health shocks, with the state identifier already in the sample. If the mechanism is the balance and not the missed payment, it should show in utilization before it shows in delinquency.

## Repository

```
run_all.R                every script in order
code/
  00_config.R            paths
  01_build_sample.R      raw files -> one record per person and year
  02_analysis_sample.R   sample restriction and variable construction
  03_descriptives.R      summary table and figure
  04_regressions.R       regression tables (markdown and LaTeX), weighted
  05_mechanism.R         payment history against balances: where the gap sits
  06_credit_constraints.R what is rationed, and what the household can fall back on
  07_information.R       what a household knows that its score does not
  utils.R                table helpers
data/README.md           how to obtain the microdata
docs/project_outline.md  motivation, hypotheses and literature, from January 2025
docs/a_paper_from_this.md  the question the project ran into, and what it would need
output/                  tables and figures produced by the code
```

The code runs in R 4.5 with `dplyr`, `tidyr`, `readxl`, `ggplot2`, `fixest`, `MASS` and `sandwich`. Put the four raw files in `data/raw`, or point `SCE_DATA_DIR` at them, and run `run_all.R` from the repository root.

María Luján Puchot
