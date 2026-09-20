# Credit scores, gender and motherhood

An exploratory project on the child penalty in access to credit, using the Survey of Consumer Expectations of the Federal Reserve Bank of New York. It extends my undergraduate thesis at Universidad de Buenos Aires, *Credit Gaps and Motherhood: Unraveling Gender Disparities in Financial Access* (2024). The project is on hold while I finish my M.A. thesis; what is here is a clean version of the data work and a first set of descriptive regressions.

## Question

The child penalty in the labor market is well documented. Much less is known about credit, even though a credit score determines whether a household can borrow, and at what price, to smooth spending on health, education and housing, which is when children make borrowing most valuable. I ask whether mothers report lower credit scores than fathers and than women without children, whether living with a partner offsets the difference, and whether the pattern varies by race. Motivation, hypotheses and related literature are in [docs/project_outline.md](docs/project_outline.md).

## Data

The Survey of Consumer Expectations (SCE) is a monthly rotating panel of about 1,300 U.S. household heads, who stay in the panel for up to twelve months. I use the core survey for 2013-2019 and the Credit Access module, which is fielded every four months and since February 2014 asks respondents for their credit score in five bands: below 620, 620-679, 680-719, 720-760 and above 760. Demographics and household composition come from each respondent's first interview.

The unit of observation is a person-year. The analysis sample has 11,393 observations from 8,580 respondents between 2014 and 2019. The microdata are public but are not redistributed here; [data/README.md](data/README.md) explains how to get them.

## Preliminary results

![Distribution of credit score bands by gender and children](output/figures/score_bands_by_group.png)

Among women with children under 18 at home, 22% report a score below 620 and 28% a score above 760. Among men with children the shares are 7% and 51%.

Everything below is weighted with the survey weight of the credit module and clustered by respondent. The weights matter little: the gender gap is 0.169 of a band weighted and 0.180 unweighted, so the result is not an artifact of who answers the survey.

### The hypothesis the project started from

A mother raising children on her own should report a lower score than a father doing the same, and a partner should soften the difference. Gender and partnership are crossed into one variable so that each family type is measured against the same reference, respondents without children, and the comparison that matters is a difference between two coefficients rather than a sum of three.

| Against respondents without children | Raw | + income | + controls | + state and year |
|:---|---:|---:|---:|---:|
| Father, partnered | 0.073 (0.061) | -0.313*** (0.056) | -0.136*** (0.053) | -0.139*** (0.052) |
| Father, alone | -0.577** (0.252) | -0.491** (0.216) | -0.231 (0.194) | -0.201 (0.178) |
| Mother, partnered | -0.746*** (0.072) | -0.896*** (0.058) | -0.522*** (0.058) | -0.515*** (0.057) |
| Mother, alone | -1.58*** (0.092) | -1.12*** (0.089) | -0.580*** (0.079) | -0.574*** (0.077) |
| Observations | 11,387 | 11,323 | 11,117 | 11,106 |

In the full specification a mother raising children alone reports **0.373 of a band less than a father in the same situation** (standard error 0.189, p = 0.049). Fathers raising children alone are not distinguishable from people without children once income, homeownership and the rest are held fixed; mothers are, whether they have a partner or not.

The second half of the hypothesis does not survive the controls. Raw, a partner is worth most of a band to a mother, 1.58 against 0.746. With income and homeownership in the regression the two are almost the same, 0.574 against 0.515. What looked like the effect of having a partner is mostly the income and the home that come with one.

An ordered logit, which estimates the cut points instead of assuming the bands are equally spaced, gives the same ordering: mother alone -1.464, mother partnered -1.229, father alone -0.656, father partnered -0.466 ([reg_ordered_logit](output/tables/reg_ordered_logit.md)).

### What does not matter

Among parents, neither the number of children nor the age of the youngest moves the score. A second child is worth -0.008 of a band (standard error 0.034) and having the youngest under six is worth 0.039 (0.093), both indistinguishable from zero, and neither interacts with gender ([reg_children_dose](output/tables/reg_children_dose.md)). The penalty attaches to being a mother, not to how many children there are or how much care they currently need. Among parents alone the gender gap is 0.39 of a band, larger than in the full sample.

### Race

Black respondents report scores between 0.6 and 0.95 of a band lower than the rest, depending on the controls, with a further and less precisely estimated difference for Black women ([reg_race](output/tables/reg_race.md)).

### How to read all of this

These are associations. The score is self-reported in bands, household composition is measured at each respondent's first interview and carried forward, and fertility and partnership are choices correlated with many things that also move credit histories. Nothing here identifies the effect of having a child.

## Next steps

- Survey-design standard errors: the weights are used but the panel structure is handled by clustering, not by the survey design.
- The Medicaid expansion of 2014 as a source of variation in the financial cost of health shocks: compare the gaps in expansion and non-expansion states before and after (the state identifier is already in the sample).
- The Household Spending module of the SCE, to look at medical and education spending by family type.

## Repository

```
code/
  00_config.R            paths
  01_build_sample.R      raw files -> one record per person and year
  02_analysis_sample.R   sample restriction and variable construction
  03_descriptives.R      summary table and figure
  04_regressions.R       regression tables (markdown and LaTeX), weighted
  utils.R                table helpers
data/README.md           how to obtain the microdata
docs/project_outline.md  motivation, hypotheses, literature
output/                  tables and figures produced by the code
```

The code runs in R 4.5 with `dplyr`, `tidyr`, `readxl`, `ggplot2`, `fixest`, `MASS` and `sandwich`. Put the three raw files in `data/raw` (or point `SCE_DATA_DIR` to them) and run the scripts in order from the repository root.

María Luján Puchot
