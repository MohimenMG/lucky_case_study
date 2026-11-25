# Lucky Data & Insights Case Study

## Part 1 | Triage

I’d handle Marketing first for Tuesday’s budget lock, then the CPGO for Thursday’s board pack, CVM before next week’s send, and Finance before next month’s policy change. For requests with similar deadlines, I’d prioritize the decision with greater impact or more teams waiting on it. I’d confirm the CVM and Finance decision deadlines today.

1. **Performance Marketing:** “I’ll verify the Meta and Google Ads CPI figures before Tuesday’s lock. For December, is the priority more installs or more users who verify their account and make a first deposit?”
2. **CPGO:** “I’ll send the Q3 snapshot for Thursday and verify the EGP 59M headline. Could you point me to the team or report it came from?”
3. **CVM:** “I’ll verify the August lift and come back with a recommendation on next week’s send.”
4. **Finance:** “I’ll check the reported increase, look at which borrowers are falling behind, and recommend where to adjust limits to protect fee income and reduce losses.”

## Part 2 | Data quality log

> Before trusting any number, check the data. List every issue you find in a table: issue, how you detected it, how many rows/users it affects, how you handled it, and its impact on the results. Include the logic you used to map raw `utm_source` values to channels.

| Issue | How we found it | Affected | Fix and impact |
|---|---|---|---|
| Apparent QA accounts | Matched normalized names against six reviewed test names and checked linked transactions | 30 users and 682 transactions after deduplication | Excluded by user ID. Removed **EGP 38.59M** from successful Q3 UTC deposits. |
| Exact transaction duplicates | Compared all transaction fields | 577 extra rows out of 42,378 | Kept one copy of each transaction. Removed **EGP 991,800** from successful Q3 UTC deposits. |
| Inconsistent UTM formatting | Compared original values with trimmed, lowercased values | 1,274 cleaned users | Preserved the originals and used normalized values for channel mapping. |
| Missing acquisition source | Counted blank source values | 794 raw users and 764 after QA exclusion | Kept users in overall KPIs and classified their source as **Unknown** for channel reporting. |
| September 3 deposit concentration | Grouped successful deposits by Cairo date and inspected the transaction rows | **EGP 10.30M** across **89 deposits**, about **52%** of Q3 volume | Kept the deposits in the **EGP 19.89M** total because they met the reporting rules. The cause remains unverified. Excluding that day would leave **EGP 9.60M**. |

**Reporting time zone.** Using the case’s fixed Cairo offset of UTC+2 reduced Q3 deposit volume by **EGP 2,300** compared with UTC.

> QA account discovery. While investigating duplicate transactions, I linked the affected user IDs to the users table and noticed names that looked like test accounts. I then used an LLM to review an exported list of distinct user names and flag likely QA names. The notebook applies six reviewed name patterns to identify matching user IDs and exclude those accounts and their transactions. QA status was inferred from the names.

**QA exclusion rule.** After trimming surrounding spaces and ignoring case, match the full name exactly against `qa lucky`, `test user`, `test qa`, `test test`, `تجربه تطبيق`, or `تجربة`. Exclude matching accounts and their transactions by user ID.

### Acquisition channel mapping

Trim whitespace and lowercase the raw `utm_source`, then apply this mapping.

| Channel | Normalized aliases |
|---|---|
| Meta | `meta`, `facebook ads`, `facebook`, `fb`, `instagram`, `ig` |
| Google Ads | `google`, `google ads`, `adwords`, `gads` |
| TikTok | `tiktok`, `tt` |
| Referral | `referral`, `ref`, `invite` |
| Organic | `organic` |
| Direct | `(direct)` |
| Unknown | Blank, null, or any value outside the alias list |

The paid-channel comparison groups Referral, Organic, and Direct as **Other**.

### Validation and findings

The cleaned exports contain **6,200 users** and **41,119 transactions**. Loans, Plus subscriptions, CVM assignments, and marketing spend retained all **1,310**, **111**, **697**, and **276** rows, respectively.

The validation cell found zero missing key values, repeated keys, or unmatched user links across the tables checked. All **137** holdout assignments had blank send timestamps, as expected. The **82** blank Plus end dates indicate subscriptions open at extract. Blank KYC verification and last repayment dates were preserved.

**What carries into the analysis.** QA exclusions explain most of the deposit correction. The KPI notebook shows how sensitive the headline is to September 3, the marketing notebook keeps install and activation measures separate, and the credit notebook compares loans at the same repayment checkpoint. Missing UTMs remain an unresolved attribution issue.

## Part 3 | Analysis

### 3.1 Q3 KPI snapshot

**Q3 deposits were EGP 19.89M.** The reported EGP 59M is consistent with the raw successful deposit total, which included apparent test-account activity and extra copies of transactions. The reconciliation also applies the Cairo reporting window.

| KPI | Q3 result |
|---|---|
| Signups | **6,191** |
| Activation | **38.07%** (2,357 of 6,191 signups) |
| Monthly active users | **702 in July, 1,391 in August, and 2,048 in September** |
| Deposit volume | **EGP 19.89M** |
| Loans disbursed | **1,310**, totaling **EGP 1.72M** in principal |
| Mature DPD30 default rate | **7.31%** (76 of 1,040 mature loans), with September higher than July and August |
| Lucky Plus subscribers | **93 unique users** with a subscription active at any point in Q3 |

**How the KPIs were counted.** The cleaned extract contains 6,200 users. Of those, 6,191 signed up during Q3 on the Cairo calendar. The other nine signed up outside that reporting window. An activated user had verified KYC by the extract date and made at least one successful deposit within seven days of signup. A monthly active user made at least one successful transaction of any type in that Cairo calendar month. Deposit volume sums successful deposit rows in the Cairo Q3 window after removing extra copies and excluding apparent QA accounts.

### 3.2 Performance Marketing

**Meta buys installs more cheaply than Google Ads. Google Ads delivers activated users more cheaply.** Meta's reported CPI was **EGP 43.33**, versus **EGP 93.46** for Google Ads. Cost per activated user was **EGP 231.48** on Google Ads and **EGP 279.56** on Meta. The gap is already visible at verification. **44.41%** of attributed Meta signups verified KYC, compared with **76.31%** for Google Ads.

**Keep the December budget at Q3 shares.** Allocate **EGP 61,159 to Meta, EGP 70,897 to Google Ads, and EGP 17,944 to TikTok**. Moving budget to Meta lowers modeled CPI but yields fewer activations at Q3 unit costs. Use cost per activated user to guide the budget and investigate where Meta users stop during verification. Google's cost per activation moved in opposite directions in the daily and weekly spend comparisons. Test whether a higher Google Ads budget can deliver additional activated users cost-effectively before changing the mix.

### 3.3 CVM uplift

**The August push lifted the 30-day Plus subscription rate by 6.11 percentage points**, from **6.57% in the randomized holdout to 12.68% in treatment**. Nine holdout users subscribed, so use the lift as a planning estimate for the next send.

Send again to reachable users with at least three successful transactions and no active Plus subscription. Keep a randomized holdout. If August rates repeat, sending to **1,211 eligible users** would generate about **74 additional subscriptions**. Run a separate, parallel experiment among less-active users before expanding to the entire base.

### 3.4 Credit risk

**September's observed mature DPD30 rate was higher**, rising from **6.54% in July to 9.63% in September**. Finance's reported rate of about **12%** is consistent with the **11.72%** of September loans that had yet to repay the full principal plus fee by the November 5 extract. This calculation covers all September disbursals. The **9.63%** DPD30 rate covers only loans that had reached 30 days after their due date and measures whether they were still short at that checkpoint.

**Keep current limits while we review where defaults are concentrated.** Borrowers acquired through Meta accounted for **41 of the 76 DPD30 defaults**. Look at who took out those loans and how they were approved. Then test limit changes for specific groups based on how reliably they repay and how much they can afford. The credit notebook shows the repayment groups and losses by channel.

## Part 5 | Communication

### Part 5.1 | CPGO summary

#### Q3 board snapshot

**Q3 deposits were EGP 19.89M.** The original headline is consistent with a raw total that included apparent test-account activity and extra copies of transactions. A large share of the corrected total came from an early September spike. The deposits meet the reporting rules and are included. Finance should confirm what drove the spike.

**Lucky Plus.** The August push raised the subscription rate by **6.11 percentage points** versus a randomized holdout. Send it again to eligible users and test less-active users separately before expanding.

**Credit.** September’s mature default rate was **9.63%**, higher than in July or August. Keep current limits while Finance reviews who took out the loans and how they were approved in the groups where losses were concentrated.

**Decision requested.** Approve EGP 19.89M for the Q3 board pack with a footnote flagging the September 3 spike pending Finance verification.

### Part 5.2 | Marketing Slack reply

#### Slack reply to Performance Marketing

Thanks for pulling the CPI numbers together. I confirmed Meta at EGP 43.33 per install versus EGP 93.46 for Google Ads. Google still delivers activated users at a lower cost, and the conversion gap is already visible at verification. About 44% of Meta signups verified versus 76% on Google.

I’d hold off on moving most of Google’s budget to Meta. Let’s keep December at EGP 61,159 for Meta, EGP 70,897 for Google Ads, and EGP 17,944 for TikTok. We can investigate where Meta users get stuck and test whether a higher weekly Google budget brings in additional activated users at an acceptable cost.

## Part 6 | What's next?

> Name three data points you wish you had and why. Then outline one experiment that would settle the channel question for good.

1. **In-app activity logs.** Link screen views, actions, and errors to users and acquisition sources to identify where users stop between signup, verification, and their first deposit.
2. **Ad-set spend and attribution.** Link spend to activation outcomes to see which audiences and ads deliver activated users at the lowest cost.
3. **User-level net contribution.** Compare what each channel's users generate after credit losses and other costs over the same follow-up period.

**Experiment.** Randomly assign several weeks to Google Ads' current weekly budget or a higher one. Keep other campaign settings consistent and allow each signup cohort seven days to deposit. Compare the extra spend with the extra activated users it generates. Track CPI and cost per verified user alongside activation. Increase Google's allocation only if the additional activations are cost-effective.
