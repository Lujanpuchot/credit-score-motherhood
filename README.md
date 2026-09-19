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

The table reports OLS regressions of the score band (1 to 5) on gender, children under 18, living with a spouse or partner, and their interactions. Columns 5 and 6 add age, education, employment status, homeownership, race and ethnicity, and state and year fixed effects; column 6 widens the definition of children to those under 25. Standard errors are clustered by respondent.

|   | (1) | (2) | (3) | (4) | (5) | (6) |
|:---|---:|---:|---:|---:|---:|---:|
| Children | -0.330*** (0.033) | -0.073* (0.042) | -0.308*** (0.039) | -0.735*** (0.090) | -0.413*** (0.084) | -0.436*** (0.076) |
| Female | -0.510*** (0.030) | -0.354*** (0.035) | -0.167*** (0.034) | -0.087 (0.053) | -0.063 (0.048) | -0.037 (0.048) |
| Children x Female |    | -0.516*** (0.066) | -0.415*** (0.060) | -0.279*** (0.065) | -0.251*** (0.060) | -0.209*** (0.058) |
| Children x Partner |    |    |    | 0.461*** (0.086) | 0.300*** (0.078) | 0.289*** (0.070) |
| Female x Partner |    |    |    | -0.174*** (0.065) | -0.040 (0.060) | -0.065 (0.060) |
| Partner |    |    |    | -0.017 (0.048) | -0.151*** (0.045) | -0.150*** (0.045) |
| Household income bracket |    |    | 0.193*** (0.005) | 0.194*** (0.006) | 0.131*** (0.007) | 0.134*** (0.007) |
| Controls, state and year FE | No | No | No | No | Yes | Yes |
| Observations | 11,389 | 11,389 | 11,325 | 11,324 | 11,107 | 11,107 |
| R2 | 0.050 | 0.057 | 0.192 | 0.195 | 0.334 | 0.336 |

Women report scores about half a band lower than men. Household income accounts for roughly a third of that gap, and with the full set of controls it falls to 0.18 of a band ([reg_gender_gap](output/tables/reg_gender_gap.md)). The gap is concentrated among mothers: in column 2, having children at home is associated with a score 0.07 of a band lower for men and 0.59 lower for women, and the interaction remains at a quarter of a band with all controls. Living with a partner offsets part of the difference for parents of either gender. The other tables split the sample by gender ([reg_by_gender](output/tables/reg_by_gender.md)) and look at race ([reg_race](output/tables/reg_race.md)): Black respondents report scores between 0.6 and 0.95 of a band lower than the rest, depending on the controls, with a further, less precisely estimated, difference for Black women.

These are associations. The score is self-reported in bands, household composition is measured at the first interview, the regressions are unweighted, and fertility and partnership are choices correlated with many things that also move credit histories.

## Next steps

- Ordered-response models and survey weights.
- The Medicaid expansion of 2014 as a source of variation in the financial cost of health shocks: compare the gaps in expansion and non-expansion states before and after (the state identifier is already in the sample).
- The Household Spending module of the SCE, to look at medical and education spending by family type.

## Repository

```
code/
  00_config.R            paths
  01_build_sample.R      raw files -> one record per person and year
  02_analysis_sample.R   sample restriction and variable construction
  03_descriptives.R      summary table and figure
  04_regressions.R       regression tables (markdown and LaTeX)
  utils.R                table helpers
data/README.md           how to obtain the microdata
docs/project_outline.md  motivation, hypotheses, literature
output/                  tables and figures produced by the code
```

The code runs in R 4.5 with `dplyr`, `tidyr`, `readxl`, `ggplot2` and `fixest`. Put the three raw files in `data/raw` (or point `SCE_DATA_DIR` to them) and run the scripts in order from the repository root.

María Luján Puchot
