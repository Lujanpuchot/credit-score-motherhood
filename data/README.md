# Data

The microdata of the Survey of Consumer Expectations are published by the Federal Reserve Bank of New York, Center for Microeconomic Data, and can be downloaded free of charge from <https://www.newyorkfed.org/microeconomics/sce> (core survey: "Complete microdata"; the Credit Access and Household Spending surveys: "Microdata" under each survey's own page). They are not redistributed in this repository.

Source: Survey of Consumer Expectations, © Federal Reserve Bank of New York (FRBNY). The SCE data are available without charge at the address above and may be used subject to the license terms posted there. FRBNY disclaims any responsibility for this analysis and interpretation of Survey of Consumer Expectations data.

The code expects these files in `data/raw`, with the names they have on the website:

| File | Content |
|---|---|
| `SCE-Public-Microdata-Complete-2013-2016.xlsx` | Core monthly survey, June 2013 to December 2016 |
| `SCE-Public-Microdata-Complete 2017-2019.xlsx` | Core monthly survey, 2017 to 2019 |
| `SCE-Credit-Access-complete_microdata.xlsx` | Credit Access Survey, October 2013 onwards (sheet `Data`) |
| `Household-Spending- Microdata.xlsx` | Household Spending Survey, December 2014 onwards (sheet `Data`) |

The file names are the ones the website uses, including the space in the middle of the spending file.

The questionnaires of the core survey and of the Credit Access module are on the same site. The variables used here are:

| Variable | Question |
|---|---|
| `N22` | Credit score band (1 below 620, 2 620-679, 3 680-719, 4 720-760, 5 above 760, 6 don't know) |
| `Q33` | Gender (1 female, 2 male) |
| `Q34`, `Q35_1`-`Q35_6` | Hispanic, Latino or Spanish origin; race (several answers allowed) |
| `Q38` | Married or living with a partner |
| `Q45new_1`-`Q45new_5` | People living in the household: partner, children 25 or older, 18 to 24, 6 to 17, 5 or younger |
| `Q47` | Household income in eleven brackets |
| `Q32`, `Q36`, `Q43`, `Q10_1`-`Q10_10`, `_STATE` | Age, education, home tenure, employment situation, state of residence |

The credit module has skip patterns that matter for how the answers are read. `N3` is put only to respondents who report holding a credit card in `N1`, `N15` only to those who report at least one debt product, and `N9` only for the first five items of `N4`, so `N9_6` is empty for everyone and a refusal to refinance is recorded in `N11` instead.

| Variable | Question |
|---|---|
| `N1_1`, `N2_1` | Holds a credit card; dollars owed on cards |
| `N3` | Reached the limit of a credit card in the past twelve months |
| `N4_1`-`N4_7` | Applied for each kind of credit in the past twelve months |
| `N6_1`-`N6_8`, `N7_1`-`N7_7` | Needed a kind of credit and did not apply, expecting to be turned down (the same question in two formats) |
| `N9_1`-`N9_7`, `N11` | How each request ended; whether a refinancing was granted |
| `N14_1`-`N14_4` | Accounts closed and credit limits cut during the year |
| `N15`, `N16` | Late on a loan payment by more than 30 and more than 90 days |
| `N21_1`, `N21_4` | Percent chance that a new card, or an increase in a card limit, would be granted |
| `N23` | When the score was last checked |
| `N24`, `N25` | Percent chance of needing $2,000 for an unexpected expense, and of being able to come up with it |
| `qsp5_1`-`qsp5_9` | Share of monthly household spending by category |
| `qsp14new`, `qsp15new` | How variable household income is from month to month, and by how much |

The Household Spending file does not carry its own survey weight, so the columns built from it are weighted with the credit module's.
