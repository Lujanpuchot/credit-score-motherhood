# The child penalty in the credit market: project outline

Working outline, January 2025. It records the motivation, the hypotheses and the reading list the project started from. The hypothesis has moved since; the section at the end says how, and the results are in the README.

## Motivation

Borrowing lets households smooth spending on health, education, housing and other goods that matter most for people who have children in their care. For lower-income households, who hold little savings, credit is a substitute for savings, and they usually get it on worse terms.

Whether a household can borrow depends to a large extent on its credit score, which determines how much it can borrow, at what interest rate and for what amounts. Without a good score, people have fewer options or must accept terms that can perpetuate their economic vulnerability.

Women already face lower incomes and a heavier care burden, so it is natural to ask whether they also face worse borrowing conditions when they have children. The question matters because when one parent raises a child alone, that parent is most often a woman. If so, single mothers combine the costs of raising a child with more difficulty in using financial markets to smooth consumption. The other side of this is that marriage or cohabitation may bring a better score and easier access to credit for people with children.

A last angle is the role of public policy, either by providing goods for which people commonly go into debt, which raises the probability of default, or by making access to credit more equal.

## Hypotheses

Main hypothesis: single women with children have lower credit scores, and therefore less access to affordable credit, than single men with children. Living with a partner attenuates the difference, and public policy can do so as well.

More specific hypotheses, in order:

1. Having children affects the score: a child penalty that remains after controlling for income.
2. Having children while married or cohabiting allows couples to share housework and, often, expenses, which shows up as a better score with which to borrow against unexpected health, education or housing expenses.
3. These effects differ between men and women.
4. The effects differ by race and ethnicity.
5. Some public policies can reduce these disparities. A relevant one is the expansion of Medicaid under the Affordable Care Act (2010), in force since 2014, which extended health coverage to low-income adults, including parents, and was funded largely by the federal government.

## Framing

The project belongs to family economics and the economics of gender. There is a large literature on the child penalty in the labor market and little on a child penalty in the credit system. The first task is to establish whether living with a partner and having children are related to the credit score, and then to measure the gap between men and women.

## Data

The Survey of Consumer Expectations (SCE) of the Federal Reserve Bank of New York is a monthly survey with information on respondents' demographics (age, gender, education, income, household composition) and their expectations about inflation, income, unemployment and the labor market. The project draws on the core survey for 2013-2019 and on two of its modules: the SCE Credit Access Survey, on recent experiences with credit, including applications, approvals and rejections, the credit score band and the use of credit cards, mortgages and student loans, and the SCE Household Spending Survey, on recent and expected household spending, which the code does not use yet. All of them are available from the New York Fed's Center for Microeconomic Data: <https://www.newyorkfed.org/microeconomics/sce>.

## Reading list

Credit scores, discrimination and credit access

- Avery, Brevoort and Canner (2010), "Does Credit Scoring Produce a Disparate Impact?". Whether the variables in a score act as proxies for age, race or gender.
- Arya, Eckel and Wichman (2011), "Anatomy of the Credit Score". Relates the score to experimental measures of impulsivity, time preference, risk attitudes and trust.
- Bhutta, Hizmo and Ringo (2022), "How Much Does Racial Bias Affect Mortgage Lending? Evidence from Human and Algorithmic Credit Decisions". Almost all of the racial gap in approvals is explained by observable risk factors; useful for separating statistical from taste-based discrimination.
- Gerardi, Willen and Zhang (2021), "Mortgage Prepayment, Race, and Monetary Policy".
- Hertzberg, Liberman and Paravisini (2016), "Adverse Selection on Maturity: Evidence from Online Consumer Credit".
- Akey and Heimer (2017), "Politicizing Consumer Credit".
- Fonseca, Strair and Zafar, "Access to Credit and Financial Health: Evaluating the Impact of Debt Collection".
- Brevoort, Grodzicki and Hackmann (2020), "The Credit Consequences of Unpaid Medical Bills". How the Medicaid expansion reduced medical debt in collection and improved credit terms; the closest reference for the policy hypothesis.

Credit scores outside credit markets

- Cortés, Glover and Tasci (2020), "The Unintended Consequences of Employer Credit Check Bans for Labor Markets".
- Friedberg, Hynes and Pattison (2021), "Who Benefits from Bans on Employer Credit Checks?".
- Volpone et al. (2014), "Exploring the Use of Credit Scores in Selection Processes: Beware of Adverse Impact".

Family, fertility and credit

- Dettling and Kearney (2013), "House Prices and Birth Rates: The Impact of the Real Estate Market on the Decision to Have a Baby".
- Dettling and Hsu (2017), "Returning to the Nest: Debt and Parental Co-residence among Young Adults".
- Kim, Lee and Lee, "Do Credit Supply Shocks Affect Fertility Choices?".
- Reynoso (2024), "The Impact of Divorce Laws on the Equilibrium in the Marriage Market".
- Chiappori and Lewbel (2024), "Gary Becker's 'A Theory of the Allocation of Time' Revisited".
- Pitt and Khandker (1998), "The Impact of Group-Based Credit Programs on Poor Households in Bangladesh: Does the Gender of Participants Matter?".
- Berger, "Giving Women Credit: The Strengths and Limitations of Credit as a Tool for Alleviating Poverty".

The child penalty in the labor market

- Kleven, Landais and Sogaard (2019), "Children and Gender Inequality: Evidence from Denmark". The event study around a first birth that the credit version of this question would want to imitate.
- Kleven, Landais, Posch, Steinhauer and Zweimuller (2019), "Child Penalties across Countries: Evidence and Explanations".
- Adda, Dustmann and Stevens (2017), "The Career Costs of Children".

## Where it stands now

September 2026, twenty months after the outline above. The first four hypotheses were tested and the results are in the README. The gap between a mother and a father raising children alone is there and survives the controls. The second hypothesis, that a partner attenuates it, does not survive them: what looks like the effect of a partner is mostly the income and the home that come with one.

What was not anticipated is where the gap sits. The original hypotheses treat the score as a summary of whether a household is currently able to meet its obligations, which would show up as missed payments. It does not. Mothers and fathers raising children alone miss payments at the same rate, and the gap between them is larger among the respondents who paid everything on time. It is the balance carried against the limit that differs, and it absorbs a third of the gap.

That changes what the project is about. A penalty for failing to pay and a penalty for borrowing are different objects: the first is a record of a past event and ages off the file, the second is mechanical and lasts as long as the borrowing does, and it feeds on itself because a lower score means a lower limit and a lower limit means a higher ratio at the same balance. The natural reading is that motherhood does not push households into default, it pushes them into persistent revolving use, which is what one would expect if the labor market child penalty arrives exactly when spending is least postponable.

The fifth hypothesis, on the Medicaid expansion, is untouched and now has a sharper prediction attached to it: if the mechanism is the balance rather than the missed payment, the expansion should show up in how much of the limit is used before it shows up in delinquency.

The project is parked here while I finish my M.A. thesis. What it turned into, and what picking it up again would take, is in [a_paper_from_this.md](a_paper_from_this.md).
