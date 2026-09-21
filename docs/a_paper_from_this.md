# A paper this survey can carry

Written September 2026, after the descriptive work in the README was done. It
records a question the project ran into rather than set out with, the evidence
for it that is already in [07_information.R](../code/07_information.R), and what
would have to happen next. It is a note to myself, not a draft.

## The question

A credit score is a lender's summary of a household. It is built from how the
household has repaid, how much of its available limit it uses, and how long and
how varied its file is. It contains no measure of whether the household could
find money tomorrow if it had to.

The sections in the README arrive at a household that pays on time, sits close
to its card limit, and has nothing to fall back on. The score sees the first of
those and not the third. That suggests a question which is not about motherhood
at all: **does a household know things about its own credit behavior that its
score leaves out?**

The Survey of Consumer Expectations is an unusually good place to ask, because
it carries on the same household a credit score, what actually happened to that
household, its own probability of missing a payment, its own probability of
being approved, and its own assessment of whether it could raise $2,000. Credit
bureau panels have the file and none of the beliefs. Household surveys have the
beliefs and no score. And a third of respondents are interviewed in two calendar
years, so this year's answers can be set against next year's outcomes.

## What is already there

2,812 respondents appear in two consecutive years. Everything below holds this
year's score band fixed with a full set of dummies, so the coefficient is
whatever is left after a lender's summary statistic has been used.

A household's own stated probability of missing a debt payment over the next
three months predicts whether it misses one over the following year, 0.0041 per
point (standard error 0.0005), and where its score band goes, -0.0037 (0.0009).
The answer alone takes the R-squared on next year's delinquency from 0.19 to
0.29. Its assessment of whether it could raise $2,000 separately predicts next
year's band, 0.0021 (0.0006) ([inf_next_year](../output/tables/inf_next_year.md)).

Two things could account for that and do not.

The first is that the household may simply be restating what already happened to
it, which the score contains. Holding this year's delinquency and this year's
use of the limit fixed as well, the coefficient falls by about a third and stays
where it was in significance, 0.0027 (0.0005).

The second is that the band is what the respondent says it is, so it measures
the real score with error, and a control measured with error leaves room for
anything correlated with the truth. Respondents who checked their score within
the past six months report it with less error than those whose last look was
over a year ago, and attenuation predicts a larger coefficient in the second
group. It is larger, 0.0038 (0.0010) against 0.0026 (0.0006), but the
well-measured group keeps about seventy per cent of it
([inf_measurement](../output/tables/inf_measurement.md)). Measurement error
inflates this result; it does not create it.

The slope is the same for every kind of household. What differs is where they
sit on the question. Mothers raising children alone are 16.8 points above
respondents without children on their own probability of missing a payment,
which at 0.0027 a point is 4.6 points of next year's delinquency that a lender
reading only the score does not see.

## Why it is worth writing

If it holds, it says something about credit allocation rather than about
mothers. A score that omits liquidity misprices the households that have none,
and those households know it. They are not wrong about lenders either: their
expectation of being approved tracks their band almost exactly
([con_expectations](../output/tables/con_expectations.md)). They are right about
the lender and they know something the lender does not.

Motherhood then becomes the application rather than the subject: the clearest
case of a household whose fragility the score cannot see. That is also the
version of the question this survey can support, because it needs the whole
sample rather than the cells that are thin.

## What it still needs

- **More years.** The sample runs from 2014 to 2019 because the core microdata
  on hand stop in 2019, while the credit module already reaches 2023. The Fed
  publishes a 2020 to 2024 core file. Adding it is a download and one line in
  `00_config.R`, and it is worth roughly half a sample again, which is also what
  the thin cells need.
- **A second survey to repeat it on.** The result is one survey and 2,812 pairs.
  The FINRA Foundation's National Financial Capability Study is the obvious
  place to look next: six waves between 2009 and 2024, over 25,000 respondents
  in each, free to download, and built around self-reported financial capability
  rather than around expectations. It is a repeated cross-section, so it cannot
  do the panel test above, but if it carries a self-reported score and a
  question on raising money at short notice, it can say whether the
  cross-sectional facts in the README hold outside this survey, and it has the
  sample size the thin cells here do not. Read its questionnaire before
  assuming any of that.
- **Something with an actual score.** Everything here is a self-reported band.
  The measurement-error check above is a defense, not a solution.
- **A reason for the beliefs.** The paper says households hold information the
  score omits. It does not say what the information is. The buffer is one
  candidate and the survey has it; expected income and job loss are two more and
  the core survey has those too.

## What does not work

- Anything causal about motherhood. Family structure is chosen, and this survey
  observes composition once, at the respondent's first interview.
- The Medicaid expansion as a design. The state identifier is there, but the
  cells by state, year and family type are far too small.
- A utilization ratio. The survey asks for balances and never for limits.
