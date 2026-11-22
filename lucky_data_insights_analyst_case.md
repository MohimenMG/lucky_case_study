# Lucky Data & Insights — Analyst Case

## About this case

This case mirrors a real week in Lucky's Data & Insights team: several departments, competing requests, imperfect data, and decisions that matter. There is no single right answer. We care as much about how you think, prioritise and communicate as about your numbers.

Lucky is a prepaid card and app offering payments, P2P transfers, a paid Lucky Plus subscription, and short-term micro-loans. The team supports Growth, Performance Marketing, CVM, Product and Finance.

**What you get:** `Lucky_Analyst_Case_Data.xlsx` (6 tables + a README with definitions and business assumptions). The same tables are in `Lucky_Analyst_Case_Data_CSV.zip` if you prefer SQL or Python. All data is synthetic.

**Expected effort:** 5–7 focused hours. A clear, honest partial answer beats a polished guess.

---

## The scenario

It is Sunday morning. You joined the Data & Insights team last week. Your manager is travelling until Wednesday. Four messages are waiting for you.

### 1 — Performance Marketing (Slack)

> "Meta's CPI this quarter was ~43 EGP vs ~94 on Google Ads. We're planning to move most of Google's budget to Meta for December (total budget 150K EGP). Can you confirm the numbers by Tuesday so we can lock it?"

### 2 — CVM lead (email)

> "Our August Lucky Plus push was a big success — users who got it subscribed at dozens of times the rate of everyone else. I want to send it to the entire user base next week. Can you validate the uplift so I can include it in the CPGO update?"

### 3 — Finance (email)

> "Loan default rate went from ~6.5% on July loans to ~12% on September loans. Credit quality is clearly deteriorating. I'm proposing we cut maximum loan limits by 30% for everyone from next month. Do you agree?"

### 4 — Chief Product & Growth Officer (Slack)

> "Need a Q3 KPI snapshot for Thursday's board pack. Headline I've been told is ~59M EGP in Q3 deposits, which is great. Please send the snapshot and confirm the headline."

---

## Your tasks

### Part 1 — Triage (before you analyse; max 200 words)

In what order would you handle the four requests, and why? What would you reply to each person today, before any analysis is done? What would you need to clarify?

### Part 2 — Data quality log

Before trusting any number, check the data. List every issue you find in a table: issue, how you detected it, how many rows/users it affects, how you handled it, and its impact on the results. Include the logic you used to map raw `utm_source` values to channels.

### Part 3 — Analysis

Answer each request with numbers. State every definition and assumption you make.

1. **KPI snapshot (Q3, Jul–Sep):** signups, activation rate, monthly active users, deposit volume, loans disbursed, loan default rate (DPD30), Plus subscribers. Is the 59M deposits headline right? If not, what is, and why the gap?
2. **Marketing:** Is Meta really the better channel? Recommend how to split the 150K EGP December budget across Meta, Google Ads and TikTok. Go beyond CPI.
3. **CVM:** What was the true effect of the August Plus push? Should it go to the entire base next week?
4. **Credit:** Is credit quality deteriorating? Is cutting limits by 30% for everyone the right fix? If not, propose something better.

### Part 4 — SQL

Assume the six tables live in a PostgreSQL/Redshift schema called `lucky_case`. Whatever tool you used for the analysis, write the queries for:

1. Mature DPD30 default rate by disbursal month and acquisition channel (including your channel mapping).
2. Weekly retention by signup-week cohort (share of activated users with a successful transaction in week 1, 2, 4 and 8 after signup).

Queries should be readable (CTEs, comments) and handle the data issues from Part 2.

### Part 5 — Communication

1. A one-page summary for the CPGO: lead with the bottom line, support it with no more than three numbers, and end with one specific decision you need from them.
2. A Slack reply (max 120 words) to the Performance Marketing team on their Meta plan. They are a small, junior team who worked hard on it. Be correct without making them look bad.

### Part 6 — What's next (max 150 words)

Name three data points you wish you had and why. Then outline one experiment that would settle the channel question for good.

---

## Deliverables, timeline and rules

- **Deadline:** 5 days from receiving this case. Reply to the email that sent it.
- **Debrief:** 45 minutes. You present for 20 minutes, then we walk through your work and change some assumptions live.
- **Tools:** Anything you like — Excel, Google Sheets, SQL, Python, R. AI assistants are allowed if you say where and how you used them. You must be able to explain and defend every number and line of code in the debrief.

> Ambiguity is intentional. If something is unclear or the data contradicts a request, say so and explain what you did about it.