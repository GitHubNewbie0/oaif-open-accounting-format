-- =============================================================================
-- Minimal OAIF Example
-- =============================================================================
-- This script creates a minimal valid OAIF file for testing.
-- Run with: sqlite3 minimal.oaif < create_minimal.sql
-- =============================================================================

-- Set OAIF identification
PRAGMA application_id = 0x4F414946;
PRAGMA user_version = 1;
PRAGMA foreign_keys = ON;
PRAGMA encoding = 'UTF-8';

-- =============================================================================
-- Metadata (Required)
-- =============================================================================

CREATE TABLE oaif_metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

INSERT INTO oaif_metadata (key, value) VALUES
('oaif_version', '1.0'),
('oaif_min_reader', '1.0'),
('created_at', '2026-01-12T00:00:00Z'),
('created_by', 'oaif-minimal-example'),
('source_system', 'Manual Entry'),
('company_name', 'Minimal Example Inc.'),
('base_currency', 'USD');

-- =============================================================================
-- Minimal Reference Tables
-- =============================================================================

CREATE TABLE account_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    normal_balance TEXT,
    is_standard INTEGER DEFAULT 1
);

INSERT INTO account_type (id, name, description, normal_balance) VALUES
(1, 'BANK', 'Bank accounts', 'DEBIT'),
(2, 'ACCOUNTS_RECEIVABLE', 'Customer balances', 'DEBIT'),
(3, 'ACCOUNTS_PAYABLE', 'Vendor balances', 'CREDIT'),
(4, 'EQUITY', 'Owner equity', 'CREDIT'),
(5, 'INCOME', 'Revenue', 'CREDIT'),
(6, 'EXPENSE', 'Expenses', 'DEBIT');

CREATE TABLE transaction_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_standard INTEGER DEFAULT 1
);

INSERT INTO transaction_type (id, name, description) VALUES
(1, 'INVOICE', 'Sales invoice'),
(2, 'RECEIPT', 'Payment received'),
(3, 'BILL', 'Vendor bill'),
(4, 'PAYMENT', 'Payment to vendor'),
(5, 'JOURNAL', 'Journal entry');

-- =============================================================================
-- Minimal Master Data
-- =============================================================================

CREATE TABLE currency (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    symbol TEXT,
    decimal_places INTEGER DEFAULT 2
);

INSERT INTO currency (code, name, symbol) VALUES
('USD', 'US Dollar', '$');

CREATE TABLE account (
    id INTEGER PRIMARY KEY,
    account_type_id INTEGER NOT NULL REFERENCES account_type(id),
    name TEXT NOT NULL,
    code TEXT,
    balance DECIMAL(19,6) DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

INSERT INTO account (id, account_type_id, name, code, balance) VALUES
(1, 1, 'Checking Account', '1000', 10000.00),
(2, 2, 'Accounts Receivable', '1200', 1500.00),
(3, 3, 'Accounts Payable', '2000', 500.00),
(4, 4, 'Owner Equity', '3000', 10000.00),
(5, 5, 'Service Revenue', '4000', 2000.00),
(6, 6, 'Office Expenses', '5000', 500.00);

CREATE TABLE customer (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    balance DECIMAL(19,6) DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

INSERT INTO customer (id, name, email, balance) VALUES
(1, 'Acme Corporation', 'billing@acme.com', 1500.00);

CREATE TABLE vendor (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    balance DECIMAL(19,6) DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

INSERT INTO vendor (id, name, email, balance) VALUES
(1, 'Office Supplies Co', 'orders@officesupplies.com', 500.00);

-- =============================================================================
-- Minimal Transaction Tables
-- =============================================================================

CREATE TABLE txn_header (
    id INTEGER PRIMARY KEY,
    txn_type_id INTEGER NOT NULL REFERENCES transaction_type(id),
    txn_date DATE NOT NULL,
    doc_number TEXT,
    customer_id INTEGER REFERENCES customer(id),
    vendor_id INTEGER REFERENCES vendor(id),
    account_id INTEGER REFERENCES account(id),
    currency_code TEXT DEFAULT 'USD' REFERENCES currency(code),
    total_amount DECIMAL(19,6),
    memo TEXT,
    is_posted INTEGER DEFAULT 1,
    is_voided INTEGER DEFAULT 0,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE txn_line (
    id INTEGER PRIMARY KEY,
    txn_header_id INTEGER NOT NULL REFERENCES txn_header(id),
    line_number INTEGER NOT NULL,
    account_id INTEGER REFERENCES account(id),
    amount DECIMAL(19,6) NOT NULL,
    description TEXT,
    source_id TEXT,
    source_raw TEXT
);

-- Sample invoice
INSERT INTO txn_header (id, txn_type_id, txn_date, doc_number, customer_id, 
                        total_amount, memo) 
VALUES (1, 1, '2026-01-10', 'INV-001', 1, 1500.00, 'Consulting services');

INSERT INTO txn_line (txn_header_id, line_number, account_id, amount, description) VALUES
(1, 1, 2, 1500.00, 'Accounts Receivable'),
(1, 2, 5, -1500.00, 'Service Revenue');

-- Sample bill
INSERT INTO txn_header (id, txn_type_id, txn_date, doc_number, vendor_id,
                        total_amount, memo)
VALUES (2, 3, '2026-01-05', 'BILL-001', 1, 500.00, 'Office supplies');

INSERT INTO txn_line (txn_header_id, line_number, account_id, amount, description) VALUES
(2, 1, 6, 500.00, 'Office Expenses'),
(2, 2, 3, -500.00, 'Accounts Payable');

-- =============================================================================
-- Extension Data Table
-- =============================================================================

CREATE TABLE extension_data (
    id INTEGER PRIMARY KEY,
    parent_table TEXT NOT NULL,
    parent_id INTEGER NOT NULL,
    namespace TEXT NOT NULL,
    field_name TEXT NOT NULL,
    field_type TEXT,
    field_value TEXT,
    UNIQUE(parent_table, parent_id, namespace, field_name)
);

-- =============================================================================
-- Trial Balance View
-- =============================================================================

CREATE VIEW v_trial_balance AS
SELECT 
    a.id AS account_id,
    a.name AS account_name,
    at.name AS account_type,
    at.normal_balance,
    COALESCE(SUM(CASE WHEN tl.amount > 0 THEN tl.amount ELSE 0 END), 0) AS debits,
    COALESCE(SUM(CASE WHEN tl.amount < 0 THEN ABS(tl.amount) ELSE 0 END), 0) AS credits,
    COALESCE(SUM(tl.amount), 0) AS balance
FROM account a
JOIN account_type at ON a.account_type_id = at.id
LEFT JOIN txn_line tl ON a.id = tl.account_id
LEFT JOIN txn_header th ON tl.txn_header_id = th.id AND th.is_posted = 1 AND th.is_voided = 0
GROUP BY a.id, a.name, at.name, at.normal_balance;

-- =============================================================================
-- Verification
-- =============================================================================

-- This should output the OAIF application ID (1330463302 = 0x4F414946)
-- SELECT 'Application ID: ' || (SELECT * FROM pragma_application_id);

-- This should show balanced transactions (sum = 0 for each)
-- SELECT txn_header_id, SUM(amount) as balance FROM txn_line GROUP BY txn_header_id;
