-- ============================================================================
-- Open Accounting Interchange Format (OAIF) Schema
-- Version: 1.0
-- ============================================================================

-- File Identification
PRAGMA application_id = 0x4F414946;  -- "OAIF" in ASCII
PRAGMA user_version = 1;
PRAGMA foreign_keys = ON;
PRAGMA encoding = 'UTF-8';

-- ============================================================================
-- METADATA TABLE (Required)
-- ============================================================================

CREATE TABLE oaif_metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- ============================================================================
-- REFERENCE TABLES (Type Lookups)
-- ============================================================================

CREATE TABLE account_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    normal_balance TEXT CHECK(normal_balance IN ('DEBIT', 'CREDIT', 'N/A')),
    category TEXT CHECK(category IN ('ASSET', 'LIABILITY', 'EQUITY', 'INCOME', 'EXPENSE', 'OTHER')),
    is_standard INTEGER DEFAULT 1,
    metadata TEXT
);

CREATE TABLE transaction_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    category TEXT,
    affects_ar INTEGER DEFAULT 0,
    affects_ap INTEGER DEFAULT 0,
    affects_inventory INTEGER DEFAULT 0,
    is_standard INTEGER DEFAULT 1,
    metadata TEXT
);

CREATE TABLE item_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_inventory INTEGER DEFAULT 0,
    is_service INTEGER DEFAULT 0,
    is_standard INTEGER DEFAULT 1,
    metadata TEXT
);

CREATE TABLE entity_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_standard INTEGER DEFAULT 1
);

CREATE TABLE tax_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_standard INTEGER DEFAULT 1
);

CREATE TABLE security_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_standard INTEGER DEFAULT 1
);

CREATE TABLE dimension_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_standard INTEGER DEFAULT 1
);

-- ============================================================================
-- MASTER DATA TABLES
-- ============================================================================

CREATE TABLE currency (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    symbol TEXT,
    decimal_places INTEGER NOT NULL DEFAULT 2,
    is_active INTEGER DEFAULT 1
);

CREATE TABLE account (
    id INTEGER PRIMARY KEY,
    account_type_id INTEGER NOT NULL REFERENCES account_type(id),
    name TEXT NOT NULL,
    full_name TEXT,
    code TEXT,
    description TEXT,
    is_active INTEGER DEFAULT 1,
    is_header INTEGER DEFAULT 0,
    parent_id INTEGER REFERENCES account(id),
    currency_code TEXT REFERENCES currency(code),
    balance DECIMAL(19,6),
    opening_balance DECIMAL(19,6),
    opening_balance_date DATE,
    bank_account_number TEXT,
    bank_routing_number TEXT,
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE customer (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    full_name TEXT,
    company_name TEXT,
    first_name TEXT,
    middle_name TEXT,
    last_name TEXT,
    display_name TEXT,
    title TEXT,
    suffix TEXT,
    email TEXT,
    cc_email TEXT,
    phone TEXT,
    alt_phone TEXT,
    mobile TEXT,
    fax TEXT,
    website TEXT,
    billing_address_line1 TEXT,
    billing_address_line2 TEXT,
    billing_address_line3 TEXT,
    billing_city TEXT,
    billing_state TEXT,
    billing_postal_code TEXT,
    billing_country TEXT,
    shipping_address_line1 TEXT,
    shipping_address_line2 TEXT,
    shipping_address_line3 TEXT,
    shipping_city TEXT,
    shipping_state TEXT,
    shipping_postal_code TEXT,
    shipping_country TEXT,
    currency_code TEXT REFERENCES currency(code),
    credit_limit DECIMAL(19,6),
    balance DECIMAL(19,6),
    terms_id INTEGER REFERENCES terms(id),
    tax_code_id INTEGER REFERENCES tax_code(id),
    resale_number TEXT,
    tax_exempt INTEGER DEFAULT 0,
    notes TEXT,
    is_active INTEGER DEFAULT 1,
    parent_id INTEGER REFERENCES customer(id),
    price_level TEXT,
    sales_rep TEXT,
    preferred_payment_method TEXT,
    preferred_delivery_method TEXT,
    account_number TEXT,
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE vendor (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    full_name TEXT,
    company_name TEXT,
    first_name TEXT,
    middle_name TEXT,
    last_name TEXT,
    display_name TEXT,
    title TEXT,
    email TEXT,
    cc_email TEXT,
    phone TEXT,
    alt_phone TEXT,
    mobile TEXT,
    fax TEXT,
    website TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    address_line3 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    currency_code TEXT REFERENCES currency(code),
    balance DECIMAL(19,6),
    terms_id INTEGER REFERENCES terms(id),
    tax_id TEXT,
    tax_id_type TEXT,
    is_1099 INTEGER DEFAULT 0,
    is_t5018 INTEGER DEFAULT 0,
    default_expense_account_id INTEGER REFERENCES account(id),
    notes TEXT,
    is_active INTEGER DEFAULT 1,
    account_number TEXT,
    credit_limit DECIMAL(19,6),
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE employee (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    first_name TEXT,
    middle_name TEXT,
    last_name TEXT,
    display_name TEXT,
    email TEXT,
    phone TEXT,
    mobile TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    employee_number TEXT,
    hire_date DATE,
    release_date DATE,
    birth_date DATE,
    gender TEXT,
    department TEXT,
    title TEXT,
    ssn_last_four TEXT,
    pay_rate DECIMAL(19,6),
    pay_period TEXT,
    pay_type TEXT,
    hourly_rate DECIMAL(19,6),
    salary DECIMAL(19,6),
    overtime_rate DECIMAL(19,6),
    billing_rate DECIMAL(19,6),
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    notes TEXT,
    is_active INTEGER DEFAULT 1,
    is_officer INTEGER DEFAULT 0,
    is_owner INTEGER DEFAULT 0,
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE item (
    id INTEGER PRIMARY KEY,
    item_type_id INTEGER NOT NULL REFERENCES item_type(id),
    name TEXT NOT NULL,
    full_name TEXT,
    code TEXT,
    barcode TEXT,
    description TEXT,
    purchase_description TEXT,
    is_active INTEGER DEFAULT 1,
    parent_id INTEGER REFERENCES item(id),
    sales_price DECIMAL(19,6),
    purchase_price DECIMAL(19,6),
    markup_percent DECIMAL(9,6),
    income_account_id INTEGER REFERENCES account(id),
    expense_account_id INTEGER REFERENCES account(id),
    asset_account_id INTEGER REFERENCES account(id),
    cogs_account_id INTEGER REFERENCES account(id),
    is_tracked INTEGER DEFAULT 0,
    quantity_on_hand DECIMAL(19,6),
    quantity_on_order DECIMAL(19,6),
    quantity_on_sales_order DECIMAL(19,6),
    reorder_point DECIMAL(19,6),
    max_quantity DECIMAL(19,6),
    average_cost DECIMAL(19,6),
    fifo_cost DECIMAL(19,6),
    lifo_cost DECIMAL(19,6),
    standard_cost DECIMAL(19,6),
    last_cost DECIMAL(19,6),
    unit_of_measure TEXT,
    purchase_uom TEXT,
    purchase_uom_conversion DECIMAL(19,6),
    weight DECIMAL(19,6),
    weight_unit TEXT,
    preferred_vendor_id INTEGER REFERENCES vendor(id),
    manufacturer TEXT,
    manufacturer_part_number TEXT,
    purchase_date DATE,
    purchase_cost DECIMAL(19,6),
    useful_life_months INTEGER,
    salvage_value DECIMAL(19,6),
    depreciation_method TEXT,
    accumulated_depreciation DECIMAL(19,6),
    book_value DECIMAL(19,6),
    location_id INTEGER REFERENCES location(id),
    bin TEXT,
    tax_code_id INTEGER REFERENCES tax_code(id),
    is_taxable INTEGER DEFAULT 1,
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE tax_code (
    id INTEGER PRIMARY KEY,
    tax_type_id INTEGER REFERENCES tax_type(id),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    rate DECIMAL(9,6),
    is_compound INTEGER DEFAULT 0,
    is_inclusive INTEGER DEFAULT 0,
    components TEXT,
    sales_account_id INTEGER REFERENCES account(id),
    purchase_account_id INTEGER REFERENCES account(id),
    country_code TEXT,
    region_code TEXT,
    agency_name TEXT,
    is_active INTEGER DEFAULT 1,
    is_recoverable INTEGER DEFAULT 1,
    effective_date DATE,
    end_date DATE,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE terms (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    due_days INTEGER,
    due_day_of_month INTEGER,
    due_next_month INTEGER DEFAULT 0,
    discount_days INTEGER,
    discount_percent DECIMAL(9,6),
    is_date_driven INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE payment_method (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    payment_type TEXT,
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

-- ============================================================================
-- TRANSACTION TABLES
-- ============================================================================

CREATE TABLE txn_header (
    id INTEGER PRIMARY KEY,
    txn_type_id INTEGER NOT NULL REFERENCES transaction_type(id),
    txn_date DATE NOT NULL,
    doc_number TEXT,
    ref_number TEXT,
    customer_id INTEGER REFERENCES customer(id),
    vendor_id INTEGER REFERENCES vendor(id),
    employee_id INTEGER REFERENCES employee(id),
    account_id INTEGER REFERENCES account(id),
    ap_account_id INTEGER REFERENCES account(id),
    ar_account_id INTEGER REFERENCES account(id),
    currency_code TEXT NOT NULL DEFAULT 'USD' REFERENCES currency(code),
    exchange_rate DECIMAL(19,10) DEFAULT 1,
    subtotal DECIMAL(19,6),
    discount_amount DECIMAL(19,6),
    discount_percent DECIMAL(9,6),
    tax_amount DECIMAL(19,6),
    shipping_amount DECIMAL(19,6),
    total_amount DECIMAL(19,6),
    amount_paid DECIMAL(19,6),
    balance_due DECIMAL(19,6),
    base_currency_total DECIMAL(19,6),
    due_date DATE,
    ship_date DATE,
    ship_method TEXT,
    ship_tracking TEXT,
    fob TEXT,
    is_posted INTEGER DEFAULT 1,
    is_pending INTEGER DEFAULT 0,
    is_paid INTEGER DEFAULT 0,
    is_closed INTEGER DEFAULT 0,
    is_voided INTEGER DEFAULT 0,
    is_cleared INTEGER DEFAULT 0,
    is_reconciled INTEGER DEFAULT 0,
    is_printed INTEGER DEFAULT 0,
    is_emailed INTEGER DEFAULT 0,
    is_to_be_printed INTEGER DEFAULT 0,
    is_to_be_emailed INTEGER DEFAULT 0,
    terms_id INTEGER REFERENCES terms(id),
    tax_code_id INTEGER REFERENCES tax_code(id),
    payment_method_id INTEGER REFERENCES payment_method(id),
    sales_rep TEXT,
    billing_address_line1 TEXT,
    billing_address_line2 TEXT,
    billing_address_line3 TEXT,
    billing_city TEXT,
    billing_state TEXT,
    billing_postal_code TEXT,
    billing_country TEXT,
    shipping_address_line1 TEXT,
    shipping_address_line2 TEXT,
    shipping_address_line3 TEXT,
    shipping_city TEXT,
    shipping_state TEXT,
    shipping_postal_code TEXT,
    shipping_country TEXT,
    memo TEXT,
    private_note TEXT,
    message_on_invoice TEXT,
    message_on_statement TEXT,
    custom_field_1 TEXT,
    custom_field_2 TEXT,
    custom_field_3 TEXT,
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    created_by TEXT,
    modified_by TEXT,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE txn_line (
    id INTEGER PRIMARY KEY,
    txn_header_id INTEGER NOT NULL REFERENCES txn_header(id),
    line_number INTEGER NOT NULL,
    line_type TEXT DEFAULT 'STANDARD',
    account_id INTEGER REFERENCES account(id),
    item_id INTEGER REFERENCES item(id),
    description TEXT,
    quantity DECIMAL(19,6),
    unit_price DECIMAL(19,6),
    amount DECIMAL(19,6) NOT NULL,
    unit_cost DECIMAL(19,6),
    markup_percent DECIMAL(9,6),
    discount_percent DECIMAL(9,6),
    discount_amount DECIMAL(19,6),
    tax_code_id INTEGER REFERENCES tax_code(id),
    tax_amount DECIMAL(19,6),
    is_taxable INTEGER DEFAULT 1,
    customer_id INTEGER REFERENCES customer(id),
    is_billable INTEGER DEFAULT 0,
    is_billed INTEGER DEFAULT 0,
    billable_status TEXT,
    class_id INTEGER REFERENCES class(id),
    location_id INTEGER REFERENCES location(id),
    project_id INTEGER REFERENCES project(id),
    security_id INTEGER REFERENCES security(id),
    shares DECIMAL(19,8),
    price_per_share DECIMAL(19,8),
    commission DECIMAL(19,6),
    lot_id INTEGER REFERENCES investment_lot(id),
    service_date DATE,
    lot_number TEXT,
    serial_number TEXT,
    expiration_date DATE,
    unit_of_measure TEXT,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE txn_link (
    id INTEGER PRIMARY KEY,
    from_txn_id INTEGER NOT NULL REFERENCES txn_header(id),
    from_line_id INTEGER REFERENCES txn_line(id),
    to_txn_id INTEGER NOT NULL REFERENCES txn_header(id),
    to_line_id INTEGER REFERENCES txn_line(id),
    link_type TEXT,
    amount DECIMAL(19,6),
    link_date DATE,
    source_raw TEXT
);

-- ============================================================================
-- CLASSIFICATION/DIMENSION TABLES
-- ============================================================================

CREATE TABLE class (
    id INTEGER PRIMARY KEY,
    dimension_type_id INTEGER REFERENCES dimension_type(id),
    name TEXT NOT NULL,
    full_name TEXT,
    code TEXT,
    description TEXT,
    parent_id INTEGER REFERENCES class(id),
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE location (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT,
    description TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    parent_id INTEGER REFERENCES location(id),
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE project (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customer(id),
    name TEXT NOT NULL,
    code TEXT,
    description TEXT,
    status TEXT,
    start_date DATE,
    end_date DATE,
    due_date DATE,
    budget DECIMAL(19,6),
    estimated_hours DECIMAL(19,6),
    actual_hours DECIMAL(19,6),
    billing_method TEXT,
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

-- ============================================================================
-- INVESTMENT TABLES
-- ============================================================================

CREATE TABLE security (
    id INTEGER PRIMARY KEY,
    security_type_id INTEGER NOT NULL REFERENCES security_type(id),
    symbol TEXT,
    name TEXT NOT NULL,
    cusip TEXT,
    isin TEXT,
    currency_code TEXT REFERENCES currency(code),
    exchange TEXT,
    last_price DECIMAL(19,8),
    last_price_date DATE,
    face_value DECIMAL(19,6),
    coupon_rate DECIMAL(9,6),
    maturity_date DATE,
    call_date DATE,
    underlying_security_id INTEGER REFERENCES security(id),
    strike_price DECIMAL(19,6),
    expiration_date DATE,
    option_type TEXT,
    contract_size INTEGER,
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE security_price (
    id INTEGER PRIMARY KEY,
    security_id INTEGER NOT NULL REFERENCES security(id),
    price_date DATE NOT NULL,
    price DECIMAL(19,8) NOT NULL,
    high DECIMAL(19,8),
    low DECIMAL(19,8),
    open DECIMAL(19,8),
    close DECIMAL(19,8),
    volume DECIMAL(19,2),
    source TEXT,
    UNIQUE(security_id, price_date)
);

CREATE TABLE investment_lot (
    id INTEGER PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id),
    security_id INTEGER NOT NULL REFERENCES security(id),
    lot_number TEXT,
    acquisition_date DATE NOT NULL,
    acquisition_txn_id INTEGER REFERENCES txn_header(id),
    shares_acquired DECIMAL(19,8) NOT NULL,
    cost_per_share DECIMAL(19,8) NOT NULL,
    total_cost DECIMAL(19,6) NOT NULL,
    commission DECIMAL(19,6),
    shares_remaining DECIMAL(19,8) NOT NULL,
    adjusted_cost_basis DECIMAL(19,6),
    holding_period TEXT,
    disposal_date DATE,
    disposal_txn_id INTEGER REFERENCES txn_header(id),
    proceeds DECIMAL(19,6),
    gain_loss DECIMAL(19,6),
    wash_sale_disallowed DECIMAL(19,6),
    source_raw TEXT
);

-- ============================================================================
-- TIME TRACKING TABLES
-- ============================================================================

CREATE TABLE time_entry (
    id INTEGER PRIMARY KEY,
    employee_id INTEGER REFERENCES employee(id),
    customer_id INTEGER REFERENCES customer(id),
    vendor_id INTEGER REFERENCES vendor(id),
    project_id INTEGER REFERENCES project(id),
    item_id INTEGER REFERENCES item(id),
    class_id INTEGER REFERENCES class(id),
    entry_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    duration_minutes INTEGER NOT NULL,
    duration_hours DECIMAL(10,4),
    description TEXT,
    notes TEXT,
    hourly_rate DECIMAL(19,6),
    hourly_cost DECIMAL(19,6),
    total_amount DECIMAL(19,6),
    is_billable INTEGER DEFAULT 1,
    is_billed INTEGER DEFAULT 0,
    is_paid INTEGER DEFAULT 0,
    billable_status TEXT,
    invoice_id INTEGER REFERENCES txn_header(id),
    paycheck_id INTEGER REFERENCES txn_header(id),
    approved_by TEXT,
    approved_at TIMESTAMP,
    source_id TEXT,
    source_raw TEXT
);

-- ============================================================================
-- PAYROLL TABLES
-- ============================================================================

CREATE TABLE payroll_item (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    item_type TEXT NOT NULL,
    wage_type TEXT,
    expense_account_id INTEGER REFERENCES account(id),
    liability_account_id INTEGER REFERENCES account(id),
    rate DECIMAL(19,6),
    rate_type TEXT,
    limit_amount DECIMAL(19,6),
    limit_type TEXT,
    tax_tracking_type TEXT,
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE payroll_line (
    id INTEGER PRIMARY KEY,
    txn_header_id INTEGER NOT NULL REFERENCES txn_header(id),
    employee_id INTEGER NOT NULL REFERENCES employee(id),
    payroll_item_id INTEGER REFERENCES payroll_item(id),
    line_type TEXT NOT NULL,
    hours DECIMAL(10,4),
    rate DECIMAL(19,6),
    amount DECIMAL(19,6) NOT NULL,
    ytd_amount DECIMAL(19,6),
    account_id INTEGER REFERENCES account(id),
    source_raw TEXT
);

-- ============================================================================
-- RECURRING/MEMORIZED TRANSACTIONS
-- ============================================================================

CREATE TABLE recurring_template (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    txn_type_id INTEGER NOT NULL REFERENCES transaction_type(id),
    frequency TEXT,
    interval_count INTEGER DEFAULT 1,
    start_date DATE,
    end_date DATE,
    next_date DATE,
    remaining_count INTEGER,
    auto_create INTEGER DEFAULT 0,
    days_before_due INTEGER,
    template_data TEXT,
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

-- ============================================================================
-- BANKING TABLES
-- ============================================================================

CREATE TABLE bank_reconciliation (
    id INTEGER PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id),
    statement_date DATE NOT NULL,
    statement_ending_balance DECIMAL(19,6) NOT NULL,
    statement_beginning_balance DECIMAL(19,6),
    cleared_balance DECIMAL(19,6),
    register_balance DECIMAL(19,6),
    difference DECIMAL(19,6),
    service_charges DECIMAL(19,6),
    interest_earned DECIMAL(19,6),
    is_reconciled INTEGER DEFAULT 0,
    reconciled_at TIMESTAMP,
    reconciled_by TEXT,
    source_raw TEXT
);

CREATE TABLE bank_import_rule (
    id INTEGER PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id),
    name TEXT NOT NULL,
    rule_order INTEGER,
    match_field TEXT,
    match_operator TEXT,
    match_value TEXT,
    action_type TEXT,
    target_account_id INTEGER REFERENCES account(id),
    target_customer_id INTEGER REFERENCES customer(id),
    target_vendor_id INTEGER REFERENCES vendor(id),
    target_class_id INTEGER REFERENCES class(id),
    memo_template TEXT,
    is_active INTEGER DEFAULT 1,
    source_raw TEXT
);

-- ============================================================================
-- BUDGET TABLES
-- ============================================================================

CREATE TABLE budget (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    fiscal_year INTEGER NOT NULL,
    budget_type TEXT DEFAULT 'STANDARD',
    is_active INTEGER DEFAULT 1,
    source_raw TEXT
);

CREATE TABLE budget_detail (
    id INTEGER PRIMARY KEY,
    budget_id INTEGER NOT NULL REFERENCES budget(id),
    account_id INTEGER NOT NULL REFERENCES account(id),
    customer_id INTEGER REFERENCES customer(id),
    class_id INTEGER REFERENCES class(id),
    period_1 DECIMAL(19,6),
    period_2 DECIMAL(19,6),
    period_3 DECIMAL(19,6),
    period_4 DECIMAL(19,6),
    period_5 DECIMAL(19,6),
    period_6 DECIMAL(19,6),
    period_7 DECIMAL(19,6),
    period_8 DECIMAL(19,6),
    period_9 DECIMAL(19,6),
    period_10 DECIMAL(19,6),
    period_11 DECIMAL(19,6),
    period_12 DECIMAL(19,6),
    total DECIMAL(19,6),
    source_raw TEXT
);

-- ============================================================================
-- ATTACHMENT TABLE
-- ============================================================================

CREATE TABLE attachment (
    id INTEGER PRIMARY KEY,
    parent_table TEXT NOT NULL,
    parent_id INTEGER NOT NULL,
    filename TEXT NOT NULL,
    original_filename TEXT,
    mime_type TEXT,
    description TEXT,
    file_size INTEGER,
    checksum TEXT,
    storage_type TEXT NOT NULL DEFAULT 'external',
    data BLOB,
    external_path TEXT,
    external_url TEXT,
    created_at TIMESTAMP,
    created_by TEXT,
    source_raw TEXT
);

-- ============================================================================
-- AUDIT/HISTORY TABLE
-- ============================================================================

CREATE TABLE audit_log (
    id INTEGER PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id INTEGER NOT NULL,
    action TEXT NOT NULL,
    old_values TEXT,
    new_values TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by TEXT,
    source_raw TEXT
);

-- ============================================================================
-- EXTENSION DATA (Catch-all for custom fields)
-- ============================================================================

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

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_account_type ON account(account_type_id);
CREATE INDEX idx_account_parent ON account(parent_id);
CREATE INDEX idx_account_active ON account(is_active);

CREATE INDEX idx_customer_name ON customer(name);
CREATE INDEX idx_customer_active ON customer(is_active);
CREATE INDEX idx_customer_parent ON customer(parent_id);

CREATE INDEX idx_vendor_name ON vendor(name);
CREATE INDEX idx_vendor_active ON vendor(is_active);

CREATE INDEX idx_employee_name ON employee(name);
CREATE INDEX idx_employee_active ON employee(is_active);

CREATE INDEX idx_item_type ON item(item_type_id);
CREATE INDEX idx_item_name ON item(name);
CREATE INDEX idx_item_code ON item(code);
CREATE INDEX idx_item_active ON item(is_active);

CREATE INDEX idx_txn_header_type ON txn_header(txn_type_id);
CREATE INDEX idx_txn_header_date ON txn_header(txn_date);
CREATE INDEX idx_txn_header_doc_number ON txn_header(doc_number);
CREATE INDEX idx_txn_header_customer ON txn_header(customer_id);
CREATE INDEX idx_txn_header_vendor ON txn_header(vendor_id);
CREATE INDEX idx_txn_header_account ON txn_header(account_id);

CREATE INDEX idx_txn_line_header ON txn_line(txn_header_id);
CREATE INDEX idx_txn_line_account ON txn_line(account_id);
CREATE INDEX idx_txn_line_item ON txn_line(item_id);

CREATE INDEX idx_txn_link_from ON txn_link(from_txn_id);
CREATE INDEX idx_txn_link_to ON txn_link(to_txn_id);

CREATE INDEX idx_extension_parent ON extension_data(parent_table, parent_id);
CREATE INDEX idx_extension_namespace ON extension_data(namespace);

CREATE INDEX idx_security_symbol ON security(symbol);
CREATE INDEX idx_security_type ON security(security_type_id);

CREATE INDEX idx_lot_account ON investment_lot(account_id);
CREATE INDEX idx_lot_security ON investment_lot(security_id);

CREATE INDEX idx_time_employee ON time_entry(employee_id);
CREATE INDEX idx_time_date ON time_entry(entry_date);
CREATE INDEX idx_time_project ON time_entry(project_id);

-- ============================================================================
-- STANDARD REFERENCE DATA POPULATION
-- ============================================================================

-- Account Types
INSERT INTO account_type (id, name, description, normal_balance, category) VALUES
(1, 'BANK', 'Bank accounts', 'DEBIT', 'ASSET'),
(2, 'CASH', 'Cash on hand', 'DEBIT', 'ASSET'),
(3, 'ACCOUNTS_RECEIVABLE', 'Customer balances due', 'DEBIT', 'ASSET'),
(4, 'OTHER_CURRENT_ASSET', 'Prepaid expenses, etc.', 'DEBIT', 'ASSET'),
(5, 'INVENTORY', 'Inventory value', 'DEBIT', 'ASSET'),
(6, 'FIXED_ASSET', 'Property, plant, equipment', 'DEBIT', 'ASSET'),
(7, 'ACCUMULATED_DEPRECIATION', 'Contra-asset for depreciation', 'CREDIT', 'ASSET'),
(8, 'INTANGIBLE_ASSET', 'Patents, goodwill, etc.', 'DEBIT', 'ASSET'),
(9, 'INVESTMENT', 'Securities and investments', 'DEBIT', 'ASSET'),
(10, 'OTHER_ASSET', 'Other long-term assets', 'DEBIT', 'ASSET'),
(11, 'ACCOUNTS_PAYABLE', 'Vendor balances owed', 'CREDIT', 'LIABILITY'),
(12, 'CREDIT_CARD', 'Credit card liability', 'CREDIT', 'LIABILITY'),
(13, 'OTHER_CURRENT_LIABILITY', 'Accrued expenses, etc.', 'CREDIT', 'LIABILITY'),
(14, 'PAYROLL_LIABILITY', 'Payroll taxes and withholdings', 'CREDIT', 'LIABILITY'),
(15, 'SALES_TAX_LIABILITY', 'Collected sales tax payable', 'CREDIT', 'LIABILITY'),
(16, 'LONG_TERM_LIABILITY', 'Loans and mortgages', 'CREDIT', 'LIABILITY'),
(17, 'EQUITY', 'Owner equity and capital', 'CREDIT', 'EQUITY'),
(18, 'RETAINED_EARNINGS', 'Accumulated profit/loss', 'CREDIT', 'EQUITY'),
(19, 'INCOME', 'Operating revenue', 'CREDIT', 'INCOME'),
(20, 'OTHER_INCOME', 'Non-operating income', 'CREDIT', 'INCOME'),
(21, 'COST_OF_SALES', 'Direct costs and COGS', 'DEBIT', 'EXPENSE'),
(22, 'EXPENSE', 'Operating expenses', 'DEBIT', 'EXPENSE'),
(23, 'OTHER_EXPENSE', 'Non-operating expenses', 'DEBIT', 'EXPENSE'),
(24, 'NON_POSTING', 'Non-posting/memo accounts', 'N/A', 'OTHER');

-- Transaction Types (comprehensive list)
INSERT INTO transaction_type (id, name, description, category, affects_ar, affects_ap, affects_inventory) VALUES
-- Sales
(1, 'ESTIMATE', 'Sales quote/estimate', 'SALES', 0, 0, 0),
(2, 'SALES_ORDER', 'Confirmed sales order', 'SALES', 0, 0, 0),
(3, 'INVOICE', 'Sales invoice', 'SALES', 1, 0, 1),
(4, 'SALES_RECEIPT', 'Cash sale receipt', 'SALES', 0, 0, 1),
(5, 'CREDIT_NOTE', 'Customer credit memo', 'SALES', 1, 0, 1),
(6, 'DELIVERY_NOTE', 'Shipping/packing slip', 'SALES', 0, 0, 1),
(7, 'LATE_FEE', 'Finance/late charge', 'SALES', 1, 0, 0),
-- Customer Payments
(10, 'RECEIPT', 'Customer payment received', 'RECEIPT', 1, 0, 0),
(11, 'CUSTOMER_DEPOSIT', 'Advance from customer', 'RECEIPT', 1, 0, 0),
(12, 'REFUND_GIVEN', 'Refund to customer', 'RECEIPT', 1, 0, 0),
-- Purchases
(20, 'PURCHASE_QUOTE', 'Request for quote', 'PURCHASE', 0, 0, 0),
(21, 'PURCHASE_ORDER', 'Order to vendor', 'PURCHASE', 0, 0, 0),
(22, 'BILL', 'Vendor bill/invoice', 'PURCHASE', 0, 1, 1),
(23, 'VENDOR_CREDIT', 'Credit from vendor', 'PURCHASE', 0, 1, 1),
(24, 'ITEM_RECEIPT', 'Receive goods', 'PURCHASE', 0, 0, 1),
(25, 'EXPENSE', 'Direct expense', 'PURCHASE', 0, 0, 0),
-- Vendor Payments
(30, 'PAYMENT', 'Payment to vendor', 'PAYMENT', 0, 1, 0),
(31, 'PAYMENT_CC', 'Credit card payment', 'PAYMENT', 0, 0, 0),
(32, 'VENDOR_DEPOSIT', 'Advance to vendor', 'PAYMENT', 0, 1, 0),
(33, 'REFUND_RECEIVED', 'Refund from vendor', 'PAYMENT', 0, 1, 0),
-- Banking
(40, 'DEPOSIT', 'Bank deposit', 'BANK', 0, 0, 0),
(41, 'CHECK', 'Check/cheque written', 'BANK', 0, 0, 0),
(42, 'CC_CHARGE', 'Credit card charge', 'BANK', 0, 0, 0),
(43, 'CC_CREDIT', 'Credit card credit', 'BANK', 0, 0, 0),
(44, 'TRANSFER', 'Account transfer', 'BANK', 0, 0, 0),
(45, 'BANK_FEE', 'Bank service charge', 'BANK', 0, 0, 0),
(46, 'INTEREST_INCOME', 'Interest earned', 'BANK', 0, 0, 0),
-- General
(50, 'JOURNAL', 'Manual journal entry', 'JOURNAL', 0, 0, 0),
(51, 'OPENING_BALANCE', 'Opening balance entry', 'JOURNAL', 0, 0, 0),
(52, 'YEAR_END_CLOSE', 'Year-end closing entry', 'JOURNAL', 0, 0, 0),
(53, 'ADJUSTMENT', 'General adjustment', 'JOURNAL', 0, 0, 0),
-- Payroll
(60, 'PAYROLL', 'Employee paycheck', 'PAYROLL', 0, 0, 0),
(61, 'PAYROLL_LIABILITY', 'Payroll tax payment', 'PAYROLL', 0, 0, 0),
(62, 'PAYROLL_ADJUSTMENT', 'Payroll adjustment', 'PAYROLL', 0, 0, 0),
-- Inventory
(70, 'INVENTORY_ADJUSTMENT', 'Quantity/value adjustment', 'INVENTORY', 0, 0, 1),
(71, 'INVENTORY_TRANSFER', 'Location transfer', 'INVENTORY', 0, 0, 1),
(72, 'PRODUCTION_ORDER', 'Build assembly', 'INVENTORY', 0, 0, 1),
(73, 'INVENTORY_WRITEOFF', 'Inventory write-off', 'INVENTORY', 0, 0, 1),
-- Fixed Assets
(80, 'DEPRECIATION', 'Depreciation entry', 'ASSET', 0, 0, 0),
(81, 'AMORTIZATION', 'Amortization entry', 'ASSET', 0, 0, 0),
(82, 'ASSET_DISPOSAL', 'Asset sale/disposal', 'ASSET', 0, 0, 0),
(83, 'ASSET_ACQUISITION', 'Asset purchase', 'ASSET', 0, 0, 0),
-- Investments
(90, 'INVEST_BUY', 'Buy securities', 'INVEST', 0, 0, 0),
(91, 'INVEST_SELL', 'Sell securities', 'INVEST', 0, 0, 0),
(92, 'INVEST_DIVIDEND', 'Cash dividend', 'INVEST', 0, 0, 0),
(93, 'INVEST_REINVEST', 'Reinvested dividend', 'INVEST', 0, 0, 0),
(94, 'INVEST_INTEREST', 'Bond interest', 'INVEST', 0, 0, 0),
(95, 'INVEST_CAPITAL_GAIN', 'Capital gain distribution', 'INVEST', 0, 0, 0),
(96, 'INVEST_RETURN_CAPITAL', 'Return of capital', 'INVEST', 0, 0, 0),
(97, 'INVEST_SPLIT', 'Stock split', 'INVEST', 0, 0, 0),
(98, 'INVEST_TRANSFER_IN', 'Shares transferred in', 'INVEST', 0, 0, 0),
(99, 'INVEST_TRANSFER_OUT', 'Shares transferred out', 'INVEST', 0, 0, 0),
(100, 'INVEST_REVALUE', 'Mark-to-market revaluation', 'INVEST', 0, 0, 0),
(101, 'INVEST_SPINOFF', 'Corporate spinoff', 'INVEST', 0, 0, 0),
(102, 'INVEST_MERGER', 'Corporate merger', 'INVEST', 0, 0, 0),
(103, 'INVEST_GRANT', 'Stock grant/RSU', 'INVEST', 0, 0, 0),
(104, 'INVEST_VEST', 'Shares vested', 'INVEST', 0, 0, 0),
(105, 'INVEST_EXERCISE', 'Option exercise', 'INVEST', 0, 0, 0),
-- Tax
(110, 'SALES_TAX_PAYMENT', 'Sales tax remittance', 'TAX', 0, 0, 0),
(111, 'VAT_PAYMENT', 'VAT remittance', 'TAX', 0, 0, 0),
(112, 'WITHHOLDING_RECEIPT', 'Withholding tax certificate', 'TAX', 0, 0, 0),
-- Other
(120, 'BANK_RECONCILIATION', 'Reconciliation record', 'OTHER', 0, 0, 0),
(121, 'EXPENSE_CLAIM', 'Employee expense claim', 'OTHER', 0, 0, 0),
(122, 'BILLABLE_TIME', 'Time entry for billing', 'OTHER', 0, 0, 0),
(123, 'BILLABLE_EXPENSE', 'Expense for rebilling', 'OTHER', 0, 0, 0),
(124, 'RECURRING', 'Recurring transaction', 'OTHER', 0, 0, 0),
(125, 'VOID', 'Void transaction', 'OTHER', 0, 0, 0);

-- Item Types
INSERT INTO item_type (id, name, description, is_inventory, is_service) VALUES
(1, 'SERVICE', 'Labor and services', 0, 1),
(2, 'INVENTORY', 'Tracked inventory item', 1, 0),
(3, 'NON_INVENTORY', 'Non-tracked goods', 0, 0),
(4, 'INVENTORY_ASSEMBLY', 'Manufactured item', 1, 0),
(5, 'INVENTORY_KIT', 'Bundle/group of items', 1, 0),
(6, 'FIXED_ASSET', 'Depreciable fixed asset', 0, 0),
(7, 'INTANGIBLE_ASSET', 'Amortizable intangible', 0, 0),
(8, 'OTHER_CHARGE', 'Freight, handling, etc.', 0, 0),
(9, 'SUBTOTAL', 'Subtotal line item', 0, 0),
(10, 'DISCOUNT', 'Discount line item', 0, 0),
(11, 'PAYMENT', 'Deposit/payment item', 0, 0),
(12, 'SALES_TAX', 'Tax line item', 0, 0),
(13, 'SALES_TAX_GROUP', 'Combined tax group', 0, 0);

-- Entity Types
INSERT INTO entity_type (id, name, description) VALUES
(1, 'CUSTOMER', 'Customer/client'),
(2, 'VENDOR', 'Supplier/vendor'),
(3, 'EMPLOYEE', 'Employee/worker'),
(4, 'OTHER', 'Other party');

-- Tax Types
INSERT INTO tax_type (id, name, description) VALUES
(1, 'SALES_TAX', 'US-style sales tax'),
(2, 'VAT', 'Value-added tax'),
(3, 'GST', 'Goods and services tax'),
(4, 'HST', 'Harmonized sales tax'),
(5, 'PST', 'Provincial sales tax'),
(6, 'WITHHOLDING', 'Withholding tax'),
(7, 'EXCISE', 'Excise tax/duty'),
(8, 'EXEMPT', 'Tax exempt');

-- Security Types
INSERT INTO security_type (id, name, description) VALUES
(1, 'STOCK', 'Common/preferred stock'),
(2, 'BOND', 'Corporate/government bond'),
(3, 'MUTUAL_FUND', 'Mutual fund'),
(4, 'ETF', 'Exchange-traded fund'),
(5, 'MONEY_MARKET', 'Money market fund'),
(6, 'OPTION', 'Stock option'),
(7, 'CRYPTOCURRENCY', 'Digital currency'),
(8, 'REAL_ESTATE', 'REIT/real property'),
(9, 'COMMODITY', 'Gold, oil, etc.'),
(10, 'OTHER_SECURITY', 'Other investment');

-- Dimension Types
INSERT INTO dimension_type (id, name, description) VALUES
(1, 'CLASS', 'Department/class'),
(2, 'LOCATION', 'Warehouse/location'),
(3, 'PROJECT', 'Job/project'),
(4, 'COST_CENTER', 'Cost center'),
(5, 'FUND', 'Fund (nonprofit)'),
(6, 'GRANT', 'Grant (nonprofit)'),
(7, 'PROGRAM', 'Program (nonprofit)');

-- Common Currencies
INSERT INTO currency (code, name, symbol, decimal_places) VALUES
('USD', 'US Dollar', '$', 2),
('EUR', 'Euro', '€', 2),
('GBP', 'British Pound', '£', 2),
('CAD', 'Canadian Dollar', 'C$', 2),
('AUD', 'Australian Dollar', 'A$', 2),
('JPY', 'Japanese Yen', '¥', 0),
('CHF', 'Swiss Franc', 'CHF', 2),
('CNY', 'Chinese Yuan', '¥', 2),
('INR', 'Indian Rupee', '₹', 2),
('MXN', 'Mexican Peso', '$', 2),
('BRL', 'Brazilian Real', 'R$', 2),
('NZD', 'New Zealand Dollar', 'NZ$', 2),
('ZAR', 'South African Rand', 'R', 2),
('SGD', 'Singapore Dollar', 'S$', 2),
('HKD', 'Hong Kong Dollar', 'HK$', 2),
('BTC', 'Bitcoin', '₿', 8),
('ETH', 'Ethereum', 'Ξ', 8);

-- Common Payment Methods
INSERT INTO payment_method (id, name, payment_type) VALUES
(1, 'Cash', 'CASH'),
(2, 'Check', 'CHECK'),
(3, 'Credit Card', 'CREDIT_CARD'),
(4, 'Debit Card', 'DEBIT_CARD'),
(5, 'Bank Transfer', 'BANK_TRANSFER'),
(6, 'ACH', 'ACH'),
(7, 'Wire Transfer', 'WIRE'),
(8, 'PayPal', 'ONLINE'),
(9, 'Stripe', 'ONLINE'),
(10, 'Apple Pay', 'MOBILE'),
(11, 'Google Pay', 'MOBILE'),
(12, 'Venmo', 'MOBILE'),
(13, 'Cryptocurrency', 'CRYPTO');

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

CREATE VIEW v_trial_balance AS
SELECT 
    a.id AS account_id,
    a.name AS account_name,
    a.full_name,
    at.name AS account_type,
    at.normal_balance,
    COALESCE(SUM(CASE WHEN tl.amount > 0 THEN tl.amount ELSE 0 END), 0) AS debits,
    COALESCE(SUM(CASE WHEN tl.amount < 0 THEN ABS(tl.amount) ELSE 0 END), 0) AS credits,
    COALESCE(SUM(tl.amount), 0) AS balance
FROM account a
JOIN account_type at ON a.account_type_id = at.id
LEFT JOIN txn_line tl ON a.id = tl.account_id
LEFT JOIN txn_header th ON tl.txn_header_id = th.id AND th.is_posted = 1 AND th.is_voided = 0
GROUP BY a.id, a.name, a.full_name, at.name, at.normal_balance;

CREATE VIEW v_customer_balance AS
SELECT 
    c.id AS customer_id,
    c.name AS customer_name,
    COALESCE(SUM(CASE WHEN tt.affects_ar = 1 THEN th.total_amount ELSE 0 END), 0) -
    COALESCE(SUM(CASE WHEN tt.name = 'RECEIPT' THEN th.total_amount ELSE 0 END), 0) AS balance
FROM customer c
LEFT JOIN txn_header th ON c.id = th.customer_id AND th.is_posted = 1 AND th.is_voided = 0
LEFT JOIN transaction_type tt ON th.txn_type_id = tt.id
GROUP BY c.id, c.name;

CREATE VIEW v_vendor_balance AS
SELECT 
    v.id AS vendor_id,
    v.name AS vendor_name,
    COALESCE(SUM(CASE WHEN tt.affects_ap = 1 THEN th.total_amount ELSE 0 END), 0) -
    COALESCE(SUM(CASE WHEN tt.name = 'PAYMENT' THEN th.total_amount ELSE 0 END), 0) AS balance
FROM vendor v
LEFT JOIN txn_header th ON v.id = th.vendor_id AND th.is_posted = 1 AND th.is_voided = 0
LEFT JOIN transaction_type tt ON th.txn_type_id = tt.id
GROUP BY v.id, v.name;

CREATE VIEW v_inventory_status AS
SELECT 
    i.id AS item_id,
    i.name AS item_name,
    i.code AS sku,
    it.name AS item_type,
    i.quantity_on_hand,
    i.quantity_on_order,
    i.quantity_on_sales_order,
    i.reorder_point,
    i.average_cost,
    i.quantity_on_hand * i.average_cost AS inventory_value
FROM item i
JOIN item_type it ON i.item_type_id = it.id
WHERE i.is_tracked = 1 AND i.is_active = 1;

CREATE VIEW v_portfolio_summary AS
SELECT 
    a.id AS account_id,
    a.name AS account_name,
    s.symbol,
    s.name AS security_name,
    st.name AS security_type,
    SUM(il.shares_remaining) AS total_shares,
    SUM(il.shares_remaining * il.cost_per_share) AS total_cost,
    s.last_price,
    SUM(il.shares_remaining) * s.last_price AS market_value,
    (SUM(il.shares_remaining) * s.last_price) - SUM(il.shares_remaining * il.cost_per_share) AS unrealized_gain
FROM investment_lot il
JOIN account a ON il.account_id = a.id
JOIN security s ON il.security_id = s.id
JOIN security_type st ON s.security_type_id = st.id
WHERE il.shares_remaining > 0
GROUP BY a.id, a.name, s.symbol, s.name, st.name, s.last_price;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
