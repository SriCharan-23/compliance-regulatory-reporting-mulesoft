SELECT ((f.flagged_at AT TIME ZONE 'Asia/Kolkata') + INTERVAL '2 hours 30 minutes')::date AS report_date,
       COUNT(*) AS record_count,
       SUM(t.amount) AS total_amount,
       COUNT(DISTINCT t.customer_id) AS customer_count
FROM transaction_flags f
JOIN transactions t ON t.transaction_id = f.transaction_id
WHERE f.report_status = 'PENDING_REPORT'
GROUP BY 1 ORDER BY 1;