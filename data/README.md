# Data

The microdata of the Survey of Consumer Expectations are published by the Federal Reserve Bank of New York, Center for Microeconomic Data, and can be downloaded free of charge from <https://www.newyorkfed.org/microeconomics/sce> (core survey: "Complete microdata"; Credit Access Survey: "Microdata" under the survey's own page). They are not redistributed in this repository.

Source: Survey of Consumer Expectations, © Federal Reserve Bank of New York (FRBNY). The SCE data are available without charge at the address above and may be used subject to the license terms posted there. FRBNY disclaims any responsibility for this analysis and interpretation of Survey of Consumer Expectations data.

The code expects these files in `data/raw`, with the names they have on the website:

| File | Content |
|---|---|
| `SCE-Public-Microdata-Complete-2013-2016.xlsx` | Core monthly survey, June 2013 to December 2016 |
| `SCE-Public-Microdata-Complete 2017-2019.xlsx` | Core monthly survey, 2017 to 2019 |
| `SCE-Credit-Access-complete_microdata.xlsx` | Credit Access Survey, October 2013 onwards (sheet `Data`) |

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
