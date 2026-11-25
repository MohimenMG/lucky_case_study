-- Part 4.1 | Mature DPD30 default rate by disbursal month and acquisition channel.

-- Exclude apparent QA accounts and collapse repeated normalized user/source pairs.
WITH clean_users AS (
    SELECT DISTINCT user_id, LOWER(TRIM(utm_source)) AS source
    FROM lucky_case.users
    WHERE user_id IS NOT NULL
      AND COALESCE(LOWER(TRIM(full_name)), '') NOT IN (
          'qa lucky', 'test user', 'test qa', 'test test',
          'تجربه تطبيق', 'تجربة'
      )
),

-- Map source aliases to acquisition channels. Unresolved sources are Unknown.
user_channels AS (
    SELECT user_id,
           CASE
               WHEN source IN ('meta', 'facebook ads', 'facebook', 'fb', 'instagram', 'ig') THEN 'Meta'
               WHEN source IN ('google', 'google ads', 'adwords', 'gads') THEN 'Google Ads'
               WHEN source IN ('tiktok', 'tt') THEN 'TikTok'
               WHEN source IN ('organic', '(direct)', 'referral', 'ref', 'invite') THEN 'Other'
               ELSE 'Unknown'
           END AS channel
    FROM clean_users
),

-- Join Q3 loans to their borrowers and calculate each loan's checkpoint and amount due.
loan_checkpoints AS (
    SELECT l.loan_id,
           DATE_TRUNC('month', CAST(l.disbursed_date AS DATE)) AS disbursal_month,
           u.channel,
           CAST(l.due_date AS DATE) + INTERVAL '30 days' AS dpd30_date,
           l.principal_egp + l.fee_egp AS amount_due,
           l.amount_repaid_egp,
           CAST(l.last_repayment_date AS DATE) AS last_repayment_date
    FROM lucky_case.loans AS l
    JOIN user_channels AS u ON u.user_id = l.user_id
    WHERE CAST(l.disbursed_date AS DATE) >= DATE '2026-07-01'
      AND CAST(l.disbursed_date AS DATE) <  DATE '2026-10-01'
),

-- Keep loans that reached DPD30 by extract and flag those short at the checkpoint.
mature_loans AS (
    -- Full repayment on the checkpoint date counts as repayment by DPD30.
    SELECT disbursal_month,
           channel,
           CASE
               WHEN amount_repaid_egp >= amount_due - 0.01
                AND last_repayment_date <= dpd30_date
               THEN 0
               ELSE 1
           END AS dpd30_default
    FROM loan_checkpoints
    WHERE dpd30_date <= DATE '2026-11-05'
)

-- Report mature loans, DPD30 defaults, and the rate by month and channel.
SELECT disbursal_month,
       channel,
       COUNT(*) AS mature_loans,
       SUM(dpd30_default) AS dpd30_defaults,
       ROUND(100.0 * SUM(dpd30_default) / COUNT(*), 2) AS dpd30_rate_pct
FROM mature_loans
GROUP BY disbursal_month, channel
ORDER BY disbursal_month, channel;
