CREATE TABLE compliance_report_runs (
  run_id              VARCHAR(40) PRIMARY KEY,
  report_type         VARCHAR(20) NOT NULL,
  entity_code         VARCHAR(20) NOT NULL,
  period_start        TIMESTAMPTZ NOT NULL,
  period_end          TIMESTAMPTZ NOT NULL,
  sequence_number     INT NOT NULL,
  is_revision         BOOLEAN DEFAULT FALSE,
  record_count        INT NOT NULL,
  total_amount        DECIMAL(18,2) NOT NULL,
  customer_count      INT,
  completeness_ok     BOOLEAN NOT NULL,
  is_nil_report       BOOLEAN DEFAULT FALSE,
  output_file_path    VARCHAR(300),
  archive_file_path   VARCHAR(300),
  file_checksum       VARCHAR(80),
  notification_status VARCHAR(20),
  triggered_by        VARCHAR(60) NOT NULL,
  run_status          VARCHAR(20) NOT NULL,
  started_at          TIMESTAMPTZ,
  completed_at        TIMESTAMPTZ,
  correlation_id      VARCHAR(50),
  CONSTRAINT uk_report_period
    UNIQUE (report_type, entity_code, period_start, sequence_number)
);

CREATE TABLE compliance_report_control (
  report_type          VARCHAR(20) PRIMARY KEY,
  entity_code          VARCHAR(20) NOT NULL,
  last_reported_upto   TIMESTAMPTZ NOT NULL,
  last_successful_run  VARCHAR(40),
  last_sequence_number INT DEFAULT 0,
  updated_at           TIMESTAMPTZ
);

CREATE TABLE transaction_flags (
  flag_seq        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  transaction_id  VARCHAR(30) NOT NULL,
  flag_code       VARCHAR(30) NOT NULL,
  flag_reason     VARCHAR(255),
  flagged_at      TIMESTAMPTZ NOT NULL,
  reviewed_by     VARCHAR(40),
  review_status   VARCHAR(20),
  report_status   VARCHAR(25) NOT NULL,
  reported_run_id VARCHAR(40),
  CONSTRAINT uk_txn_flag UNIQUE (transaction_id, flag_code)
);
CREATE INDEX idx_flags_period ON transaction_flags (flagged_at, report_status);

CREATE TABLE customers (
  customer_id   VARCHAR(20) PRIMARY KEY,
  customer_name VARCHAR(150) NOT NULL,
  customer_type VARCHAR(20) NOT NULL
);

CREATE TABLE transactions (
  transaction_id       VARCHAR(30) PRIMARY KEY,
  transaction_datetime TIMESTAMPTZ NOT NULL,
  account_number       VARCHAR(20) NOT NULL,
  customer_id          VARCHAR(20) NOT NULL,
  transaction_type     VARCHAR(30) NOT NULL,
  channel              VARCHAR(20) NOT NULL,
  currency             VARCHAR(3)  NOT NULL,
  amount               DECIMAL(18,2) NOT NULL,
  counterparty_name    VARCHAR(150),
  counterparty_country VARCHAR(2)
);

INSERT INTO compliance_report_control
  (report_type, entity_code, last_reported_upto, last_sequence_number)
VALUES ('STR', 'ENT0091', '2026-09-10 16:00:00+00', 0);