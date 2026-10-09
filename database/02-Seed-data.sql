INSERT INTO customers (customer_id, customer_name, customer_type) VALUES
('CUST-77219','Meena Raghavan','INDIVIDUAL'),
('CUST-81140','Ganesh Iyer','INDIVIDUAL'),
('CUST-66207','Sunrise Exports Pvt Ltd','CORPORATE');

INSERT INTO customers (customer_id, customer_name, customer_type)
SELECT 'CUST-' || (90000 + n), 'Customer ' || (90000 + n),
       CASE WHEN n % 4 = 0 THEN 'CORPORATE' ELSE 'INDIVIDUAL' END
FROM generate_series(1, 20) AS n;

-- DAY 1 (2026-09-11)
INSERT INTO transactions (transaction_id, transaction_datetime, account_number,
  customer_id, transaction_type, channel, currency, amount,
  counterparty_name, counterparty_country) VALUES
('TXN-99120455','2026-09-11 14:22:07+05:30','00214578','CUST-77219','CARD_PAYMENT','ONLINE','INR',248500.00,'Global Gadgets Online','SG'),
('TXN-99120781','2026-09-11 16:40:55+05:30','00219004','CUST-81140','WIRE_TRANSFER','BRANCH','INR',1150000.00,'Orient Trading FZE','AE'),
('TXN-99121033','2026-09-11 18:05:12+05:30','00221876','CUST-66207','CASH_DEPOSIT','BRANCH','INR',980000.00,'Self','IN');

INSERT INTO transaction_flags (transaction_id, flag_code, flag_reason,
  flagged_at, reviewed_by, review_status, report_status) VALUES
('TXN-99120455','FLG-HIGH-VALUE','Amount above reporting threshold','2026-09-11 14:22:09+05:30','RISK_ANALYST_04','CONFIRMED','PENDING_REPORT'),
('TXN-99120781','FLG-CROSS-BORDER','Cross border transfer to monitored jurisdiction','2026-09-11 16:41:02+05:30','RISK_ANALYST_02','CONFIRMED','PENDING_REPORT'),
('TXN-99121033','FLG-STRUCTURING','Multiple deposits below threshold within 24 hours','2026-09-11 18:05:20+05:30','RISK_ANALYST_07','CONFIRMED','PENDING_REPORT');

-- DAY 2 (2026-09-12): intentionally empty (nil report)

-- DAY 3 (2026-09-13): 5000 generated rows
INSERT INTO transactions (transaction_id, transaction_datetime, account_number,
  customer_id, transaction_type, channel, currency, amount,
  counterparty_name, counterparty_country)
SELECT 'TXN-HV-' || lpad(n::text, 5, '0'),
       TIMESTAMPTZ '2026-09-12 16:00:00+00' + n * INTERVAL '17 seconds',
       lpad((100000 + n)::text, 8, '0'),
       'CUST-' || (90001 + (n % 20)),
       CASE n % 3 WHEN 0 THEN 'CARD_PAYMENT' WHEN 1 THEN 'WIRE_TRANSFER' ELSE 'CASH_DEPOSIT' END,
       'ONLINE', 'INR', 100000 + (n % 97) * 1250.25,
       'Counterparty ' || (n % 50), 'SG'
FROM generate_series(1, 5000) AS n;

INSERT INTO transaction_flags (transaction_id, flag_code, flag_reason,
  flagged_at, reviewed_by, review_status, report_status)
SELECT transaction_id, 'FLG-HIGH-VALUE', 'Amount above reporting threshold',
       transaction_datetime + INTERVAL '2 seconds',
       'RISK_ANALYST_0' || (1 + (right(transaction_id, 5)::int % 7)),
       'CONFIRMED', 'PENDING_REPORT'
FROM transactions WHERE transaction_id LIKE 'TXN-HV-%';

-- Boundary row at the start of day 3's period
INSERT INTO transactions VALUES
('TXN-BND-001','2026-09-12 15:59:58+00','00300001','CUST-90001','WIRE_TRANSFER','BRANCH','INR',50000.00,'Boundary Test Co','IN');
INSERT INTO transaction_flags (transaction_id, flag_code, flag_reason,
  flagged_at, reviewed_by, review_status, report_status) VALUES
('TXN-BND-001','FLG-BOUNDARY','Exact period start boundary','2026-09-12 16:00:00+00','RISK_ANALYST_01','CONFIRMED','PENDING_REPORT');

-- DAY 4 (2026-09-14)
INSERT INTO transactions VALUES
('TXN-BND-002','2026-09-13 15:59:57+00','00400001','CUST-90002','CARD_PAYMENT','ONLINE','INR',75000.00,'Edge Merchant','SG'),
('TXN-D4-002','2026-09-14 02:59:00+00','00400002','CUST-90003','WIRE_TRANSFER','BRANCH','INR',320000.00,'Delta Traders','AE'),
('TXN-D4-003','2026-09-14 10:29:00+00','00400003','CUST-90004','CASH_DEPOSIT','BRANCH','INR',410000.50,'Self','IN');
INSERT INTO transaction_flags (transaction_id, flag_code, flag_reason,
  flagged_at, reviewed_by, review_status, report_status) VALUES
('TXN-BND-002','FLG-BOUNDARY','Exact period end/start boundary','2026-09-13 16:00:00+00','RISK_ANALYST_01','CONFIRMED','PENDING_REPORT'),
('TXN-D4-002','FLG-CROSS-BORDER','Cross border transfer','2026-09-14 03:00:00+00','RISK_ANALYST_02','CONFIRMED','PENDING_REPORT'),
('TXN-D4-003','FLG-STRUCTURING','Repeated deposits below threshold','2026-09-14 10:30:00+00','RISK_ANALYST_03','CONFIRMED','PENDING_REPORT');