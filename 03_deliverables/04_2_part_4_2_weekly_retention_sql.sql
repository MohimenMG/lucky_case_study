-- Part 4.2 | Weekly retention by signup-week cohort.

-- Exclude apparent QA accounts, collapse repeated user rows, and calculate Cairo signup time.
WITH clean_users AS (
    SELECT DISTINCT user_id, signup_ts, kyc_verified_ts,
           signup_ts + INTERVAL '2 hours' AS signup_cairo
    FROM lucky_case.users
    WHERE user_id IS NOT NULL
      AND COALESCE(LOWER(TRIM(full_name)), '') NOT IN (
          'qa lucky', 'test user', 'test qa', 'test test',
          'تجربه تطبيق', 'تجربة'
      )
),

-- Keep successful transactions through the extract and collapse exact copies.
successful_transactions AS (
    SELECT DISTINCT txn_id, user_id, txn_ts, txn_type, amount_egp
    FROM lucky_case.transactions
    WHERE status = 'success'
      AND txn_ts < TIMESTAMP '2026-11-06 00:00:00'
),

-- Identify activated Q3 signups and assign each to a Sunday-start Cairo cohort.
activated AS (
    SELECT u.user_id, u.signup_ts,
           DATE_TRUNC('week', signup_cairo + INTERVAL '1 day') - INTERVAL '1 day'
               AS signup_week
    FROM clean_users AS u
    WHERE u.signup_cairo >= TIMESTAMP '2026-07-01 00:00:00'
      AND u.signup_cairo <  TIMESTAMP '2026-10-01 00:00:00'
      AND u.kyc_verified_ts < TIMESTAMP '2026-11-06 00:00:00'
      AND EXISTS (
          SELECT 1
          FROM successful_transactions AS t
          WHERE t.user_id = u.user_id
            AND t.txn_type = 'deposit'
            AND t.txn_ts >= u.signup_ts
            AND t.txn_ts <= u.signup_ts + INTERVAL '7 days'
      )
),

-- Set follow-up windows relative to each user's exact signup time.
-- Week 1 is days [0, 7), week 2 [7, 14), week 4 [21, 28), and week 8 [49, 56).
user_windows AS (
    SELECT *,
           signup_ts + INTERVAL '0 days' AS w1_start,
           signup_ts + INTERVAL '7 days' AS w2_start,
           signup_ts + INTERVAL '14 days' AS w2_end,
           signup_ts + INTERVAL '21 days' AS w4_start,
           signup_ts + INTERVAL '28 days' AS w4_end,
           signup_ts + INTERVAL '49 days' AS w8_start,
           signup_ts + INTERVAL '56 days' AS w8_end
    FROM activated
),

-- Flag completed windows and successful activity once per user per week.
-- The left join preserves activated users with no activity in a follow-up window.
user_flags AS (
    SELECT w.user_id, w.signup_week,
           CASE WHEN w.w2_start <= TIMESTAMP '2026-11-06 00:00:00' THEN 1 ELSE 0 END AS w1_observed,
           CASE WHEN w.w2_end <= TIMESTAMP '2026-11-06 00:00:00' THEN 1 ELSE 0 END AS w2_observed,
           CASE WHEN w.w4_end <= TIMESTAMP '2026-11-06 00:00:00' THEN 1 ELSE 0 END AS w4_observed,
           CASE WHEN w.w8_end <= TIMESTAMP '2026-11-06 00:00:00' THEN 1 ELSE 0 END AS w8_observed,
           MAX(CASE WHEN t.txn_ts >= w.w1_start AND t.txn_ts < w.w2_start THEN 1 ELSE 0 END) AS w1_returned,
           MAX(CASE WHEN t.txn_ts >= w.w2_start AND t.txn_ts < w.w2_end THEN 1 ELSE 0 END) AS w2_returned,
           MAX(CASE WHEN t.txn_ts >= w.w4_start AND t.txn_ts < w.w4_end THEN 1 ELSE 0 END) AS w4_returned,
           MAX(CASE WHEN t.txn_ts >= w.w8_start AND t.txn_ts < w.w8_end THEN 1 ELSE 0 END) AS w8_returned
    FROM user_windows AS w
    LEFT JOIN successful_transactions AS t
        ON t.user_id = w.user_id
       AND t.txn_ts >= w.w1_start
       AND t.txn_ts < w.w8_end
    GROUP BY w.user_id, w.signup_week, w.w2_start, w.w2_end, w.w4_end, w.w8_end
)

-- Report cohort size, observed users, retained users, and retention for each week.
-- A retention rate is NULL when no user has completed that week's window.
SELECT signup_week,
       COUNT(*) AS activated_users,
       SUM(w1_observed) AS w1_observed,
       SUM(w1_returned * w1_observed) AS w1_retained,
       ROUND(100.0 * SUM(w1_returned * w1_observed) / NULLIF(SUM(w1_observed), 0), 2) AS w1_retention_pct,
       SUM(w2_observed) AS w2_observed,
       SUM(w2_returned * w2_observed) AS w2_retained,
       ROUND(100.0 * SUM(w2_returned * w2_observed) / NULLIF(SUM(w2_observed), 0), 2) AS w2_retention_pct,
       SUM(w4_observed) AS w4_observed,
       SUM(w4_returned * w4_observed) AS w4_retained,
       ROUND(100.0 * SUM(w4_returned * w4_observed) / NULLIF(SUM(w4_observed), 0), 2) AS w4_retention_pct,
       SUM(w8_observed) AS w8_observed,
       SUM(w8_returned * w8_observed) AS w8_retained,
       ROUND(100.0 * SUM(w8_returned * w8_observed) / NULLIF(SUM(w8_observed), 0), 2) AS w8_retention_pct
FROM user_flags
GROUP BY signup_week
ORDER BY signup_week;
