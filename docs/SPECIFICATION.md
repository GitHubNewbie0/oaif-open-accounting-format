# Open Accounting Interchange Format (OAIF)

## Universal Accounting Data Exchange Standard

**Version:** 1.0  
**Date:** January 2026  
**Status:** Draft Specification  

---

## Executive Summary

OAIF (Open Accounting Interchange Format) is an open, vendor-neutral file format for storing and exchanging accounting data between systems. It uses SQLite as its container format, ensuring universal accessibility across all platforms and programming languages without proprietary software dependencies.

### Design Goals

1. **Universal** - Works with any accounting system
2. **Complete** - No data loss during conversion
3. **Simple** - Implementable in 1-2 days
4. **Flexible** - Extensible without breaking compatibility
5. **Verifiable** - Self-describing, self-validating

### Supported Platforms

OAIF is designed to interchange data with:

| Platform | Type | Coverage |
|----------|------|----------|
| QuickBooks Desktop | Desktop | 100% |
| QuickBooks Online | Cloud | 100% |
| Manager.io | Cross-platform | 100% |
| Quicken | Desktop | 100% |
| Xero | Cloud | 100% |
| FreshBooks | Cloud | 100% |
| Wave | Cloud | 100% |
| Sage 50/Intacct | Desktop/Cloud | 100% |
| Zoho Books | Cloud | 100% |
| GnuCash | Desktop | 100% |

---

## Part 1: File Format Identification

### 1.1 File Extension

**Extension:** `.oaif`

**Example:** `company_2026.oaif`

### 1.2 Media Type (MIME)

**Type:** `application/vnd.oaif+sqlite`

### 1.3 SQLite Application ID

```sql
PRAGMA application_id = 0x4F414946;  -- "OAIF" in ASCII
```

**Bytes at offset 68-71:** `4F 41 49 46` (big-endian)

### 1.4 File Identification Algorithm

```python
import sqlite3

def is_oaif_file(filepath):
    """Return True if file is a valid OAIF database."""
    try:
        conn = sqlite3.connect(f'file:{filepath}?mode=ro', uri=True)
        app_id = conn.execute('PRAGMA application_id').fetchone()[0]
        conn.close()
        return app_id == 0x4F414946
    except:
        return False
```

---

## Part 2: Design Principles

### 2.1 Name-Based Type System

**Types are identified by NAME, not ID.** IDs are internal foreign keys within each file; names are the canonical identifiers across all OAIF files.

```sql
-- The NAME is canonical and interoperable
-- The ID is file-local for efficient joins
CREATE TABLE transaction_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,      -- Canonical identifier
    description TEXT,
    is_standard INTEGER DEFAULT 1,  -- 1=OAIF standard, 0=extension
    metadata TEXT                   -- JSON for additional attributes
);
```

**Why this matters:**
- No artificial limits on number of types
- New types can be added without breaking existing files
- Readers look up types from embedded tables, never hardcode

### 2.2 Namespace Convention

| Pattern | Scope | Example |
|---------|-------|---------|
| `UPPERCASE` | OAIF Standard | `INVOICE`, `BILL`, `JOURNAL` |
| `vendor.name.TYPE` | Vendor-specific | `vendor.quickbooks.MEMORIZED_TXN` |
| `ext.name.TYPE` | Proposed extension | `ext.crypto.WALLET_TRANSFER` |

### 2.3 Self-Describing Files

Every OAIF file contains an `oaif_metadata` table with required keys:

```sql
CREATE TABLE oaif_metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- Required keys:
INSERT INTO oaif_metadata (key, value) VALUES
('oaif_version', '1.0'),
('oaif_min_reader', '1.0'),
('created_at', '2026-01-12T15:30:00Z'),
('created_by', 'qb2oaif 1.0'),
('source_system', 'QuickBooks Desktop 2024'),
('company_name', 'Acme Corporation'),
('base_currency', 'USD'),
('fiscal_year_start_month', '1');
```

### 2.4 Lossless Preservation

Every record includes a `source_raw` TEXT field containing the original data as JSON. This ensures:
- No data loss during conversion
- Ability to audit transformations
- Recovery of source-specific fields

### 2.5 Graceful Degradation

**Readers MUST:**
- Read `oaif_metadata` first
- Check `oaif_min_reader` version
- Look up type names from embedded tables
- Handle unknown types gracefully (don't crash)
- Ignore unknown tables/columns

**Writers MUST:**
- Include all required metadata
- Populate all reference tables used
- Maintain double-entry integrity

---

## Part 3: Reference Tables

All reference tables follow this pattern:

```sql
CREATE TABLE [name]_type (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_standard INTEGER DEFAULT 1,
    metadata TEXT
);
```

### 3.1 Account Types

| Name | Description | Normal Balance |
|------|-------------|----------------|
| `BANK` | Bank accounts | Debit |
| `CASH` | Petty cash, cash on hand | Debit |
| `ACCOUNTS_RECEIVABLE` | Customer balances | Debit |
| `OTHER_CURRENT_ASSET` | Prepaid expenses, etc. | Debit |
| `INVENTORY` | Stock value | Debit |
| `FIXED_ASSET` | Property, plant, equipment | Debit |
| `ACCUMULATED_DEPRECIATION` | Contra-asset | Credit |
| `INTANGIBLE_ASSET` | Patents, goodwill, etc. | Debit |
| `INVESTMENT` | Securities, investments | Debit |
| `OTHER_ASSET` | Other long-term assets | Debit |
| `ACCOUNTS_PAYABLE` | Vendor balances | Credit |
| `CREDIT_CARD` | Credit card liability | Credit |
| `OTHER_CURRENT_LIABILITY` | Accrued expenses, etc. | Credit |
| `PAYROLL_LIABILITY` | Tax/benefit withholdings | Credit |
| `SALES_TAX_LIABILITY` | Collected tax payable | Credit |
| `LONG_TERM_LIABILITY` | Loans, mortgages | Credit |
| `EQUITY` | Owner's equity, capital | Credit |
| `RETAINED_EARNINGS` | Accumulated P&L | Credit |
| `INCOME` | Revenue | Credit |
| `OTHER_INCOME` | Non-operating income | Credit |
| `COST_OF_SALES` | Direct costs, COGS | Debit |
| `EXPENSE` | Operating expenses | Debit |
| `OTHER_EXPENSE` | Non-operating expenses | Debit |
| `NON_POSTING` | Memorized, non-GL | N/A |

### 3.2 Transaction Types

#### Sales Transactions

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `ESTIMATE` | Estimate | Sales Quote | Quote | Price quote |
| `SALES_ORDER` | Sales Order | Sales Order | - | Confirmed order |
| `INVOICE` | Invoice | Sales Invoice | ACCREC | Customer billing |
| `SALES_RECEIPT` | Sales Receipt | Receipt | - | Cash sale |
| `CREDIT_NOTE` | Credit Memo | Credit Note | ACCRECCREDIT | Customer credit |
| `DELIVERY_NOTE` | Packing Slip | Delivery Note | - | Shipping document |
| `LATE_FEE` | Finance Charge | Late Payment Fee | - | Overdue penalty |

#### Customer Payments

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `RECEIPT` | Receive Payment | Receipt | Payment | Money received |
| `CUSTOMER_DEPOSIT` | - | Receipt | Prepayment | Advance payment |
| `REFUND_GIVEN` | AR Refund Check | Payment | - | Refund to customer |

#### Purchase Transactions

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `PURCHASE_QUOTE` | - | Purchase Quote | - | RFQ from vendor |
| `PURCHASE_ORDER` | Purchase Order | Purchase Order | PurchaseOrder | Order to vendor |
| `BILL` | Bill | Purchase Invoice | ACCPAY | Vendor billing |
| `VENDOR_CREDIT` | Vendor Credit | Debit Note | ACCPAYCREDIT | Credit from vendor |
| `ITEM_RECEIPT` | Item Receipt | Goods Receipt | - | Receive goods |

#### Vendor Payments

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `PAYMENT` | Bill Payment | Payment | BatchPayment | Pay vendor |
| `VENDOR_DEPOSIT` | - | Payment | Prepayment | Advance to vendor |
| `REFUND_RECEIVED` | Bill Refund | Receipt | - | Refund from vendor |

#### Banking Transactions

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `DEPOSIT` | Deposit | Receipt | - | Bank deposit |
| `CHECK` | Check | Payment | - | Check/payment |
| `CC_CHARGE` | CC Charge | Payment | - | Credit card purchase |
| `CC_CREDIT` | CC Credit | Receipt | - | Credit card refund |
| `TRANSFER` | Transfer | Inter Account Transfer | Transfer | Between accounts |
| `EXPENSE` | - | (via Payment) | Spend | Direct expense |

#### General & Adjustments

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `JOURNAL` | General Journal | Journal Entry | ManualJournal | Manual GL entry |
| `OPENING_BALANCE` | - | Journal Entry | - | Opening balances |
| `YEAR_END_CLOSE` | - | Journal Entry | - | Period close |

#### Payroll Transactions

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `PAYROLL` | Paycheck | Payslip | - | Employee payment |
| `PAYROLL_LIABILITY` | Payroll Liab Check | Payment | - | Tax/benefit payment |
| `PAYROLL_ADJUSTMENT` | YTD Adjustment | Journal Entry | - | Payroll correction |

#### Inventory Transactions

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `INVENTORY_ADJUSTMENT` | Inventory Adjust | Inventory Write-off | - | Qty/value change |
| `INVENTORY_TRANSFER` | - | Inventory Transfer | - | Between locations |
| `PRODUCTION_ORDER` | Build Assembly | Production Order | - | Manufacturing |

#### Asset Transactions

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `DEPRECIATION` | - | Depreciation Entry | Depreciation | Fixed asset depreciation |
| `AMORTIZATION` | - | Amortization Entry | - | Intangible amortization |
| `ASSET_DISPOSAL` | - | Journal Entry | - | Sell/dispose asset |

#### Investment Transactions (Quicken)

| Name | Quicken | Description |
|------|---------|-------------|
| `INVEST_BUY` | Buy | Purchase securities |
| `INVEST_SELL` | Sell | Sell securities |
| `INVEST_DIVIDEND` | Div | Cash dividend |
| `INVEST_REINVEST` | ReinvDiv | Reinvested dividend |
| `INVEST_INTEREST` | IntInc | Bond interest |
| `INVEST_CAPITAL_GAIN` | CGLong/Short | Distributed gains |
| `INVEST_RETURN_CAPITAL` | RtrnCap | Return of capital |
| `INVEST_SPLIT` | StkSplit | Stock split |
| `INVEST_TRANSFER_IN` | XIn | Shares in |
| `INVEST_TRANSFER_OUT` | XOut | Shares out |
| `INVEST_REVALUE` | - | Mark-to-market |

#### Tax Transactions

| Name | QB | Manager | Xero | Description |
|------|----|---------|----- |-------------|
| `SALES_TAX_PAYMENT` | Sales Tax Payment | Payment | - | Remit sales tax |
| `VAT_PAYMENT` | - | Payment | - | Remit VAT |
| `WITHHOLDING_RECEIPT` | - | Withholding Tax Receipt | - | Tax certificate |

#### Other

| Name | Description |
|------|-------------|
| `BANK_RECONCILIATION` | Reconciliation record |
| `EXPENSE_CLAIM` | Employee reimbursement |
| `BILLABLE_TIME` | Time entry for billing |
| `BILLABLE_EXPENSE` | Expense for rebilling |

## 3.3 Attachments

OAIF v1.1 adds support for document attachments linked to transactions.

### Purpose

Store receipts, contracts, and supporting documents directly in the OAIF file. This ensures complete data portability - when migrating between accounting systems, users keep their supporting documentation.

### Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| attachment_id | INTEGER | Auto | Primary key |
| txn_id | INTEGER | No | Link to transaction (NULL for standalone) |
| filename | TEXT | **Yes** | Original filename with extension |
| mime_type | TEXT | No | MIME type (e.g., 'application/pdf') |
| file_size | INTEGER | No | Size in bytes |
| file_data | BLOB | * | Binary file data (embedded) |
| external_path | TEXT | * | Local filesystem path |
| external_url | TEXT | * | Cloud storage URL |
| checksum | TEXT | No | SHA-256 hash for verification |
| description | TEXT | No | User-provided description |
| document_date | TEXT | No | Document date (may differ from upload) |
| uploaded_at | TEXT | Auto | When attachment was added |
| source_id | TEXT | No | ID from source system |
| source_system | TEXT | No | Name of source system |
| source_raw | TEXT | No | Original metadata as JSON |

\* One of file_data, external_path, or external_url should be populated.

### Storage Modes

| Mode | Field | Portable? | Use Case |
|------|-------|-----------|----------|
| **Embedded** | file_data | ✅ Yes | Default - complete portability |
| **Local** | external_path | ❌ No | Large files, temporary |
| **Cloud** | external_url | ⚠️ Depends | Cloud-native systems |

**Recommendation:** Embedded storage is strongly preferred for interchange.

### Size Guidelines

- Individual file: 10 MB recommended max
- Total per transaction: 25 MB recommended max
- Warning threshold: 500 MB total OAIF file size

### 3.4 Item Types

| Name | Description |
|------|-------------|
| `SERVICE` | Labor, services |
| `INVENTORY` | Tracked stock item |
| `NON_INVENTORY` | Untracked goods |
| `INVENTORY_ASSEMBLY` | Manufactured item |
| `INVENTORY_KIT` | Bundle/group |
| `FIXED_ASSET` | Depreciable asset |
| `INTANGIBLE_ASSET` | Amortizable asset |
| `OTHER_CHARGE` | Freight, handling |
| `SUBTOTAL` | Invoice subtotal line |
| `DISCOUNT` | Discount line |
| `PAYMENT` | Deposit/payment item |
| `SALES_TAX` | Tax line item |
| `SALES_TAX_GROUP` | Combined tax |

### 3.5 Entity Types

| Name | Description |
|------|-------------|
| `CUSTOMER` | Buyer |
| `VENDOR` | Supplier |
| `EMPLOYEE` | Worker |
| `OTHER` | Other party |

### 3.6 Tax Types

| Name | Description |
|------|-------------|
| `SALES_TAX` | US-style sales tax |
| `VAT` | Value-added tax |
| `GST` | Goods & services tax |
| `HST` | Harmonized sales tax |
| `WITHHOLDING` | Withholding tax |
| `EXCISE` | Excise duty |
| `EXEMPT` | Tax exempt |

### 3.7 Security Types (Investments)

| Name | Description |
|------|-------------|
| `STOCK` | Common/preferred stock |
| `BOND` | Corporate/government bond |
| `MUTUAL_FUND` | Mutual fund |
| `ETF` | Exchange-traded fund |
| `MONEY_MARKET` | Money market fund |
| `OPTION` | Stock option |
| `CRYPTOCURRENCY` | Digital currency |
| `REAL_ESTATE` | REIT or property |
| `COMMODITY` | Gold, oil, etc. |
| `OTHER_SECURITY` | Other investment |

### 3.8 Dimension Types (Classifications)

| Name | QB | Manager | Sage | Description |
|------|----|---------|----- |-------------|
| `CLASS` | Class | Division | Department | Department |
| `LOCATION` | - | Inventory Location | Location | Warehouse/site |
| `PROJECT` | Customer:Job | Project | Project | Job costing |
| `COST_CENTER` | - | - | Cost Center | Cost allocation |
| `FUND` | - | - | Fund | Nonprofit fund |

---

## Part 4: Core Tables

### 4.1 Required Tables (~18 core)

```
OAIF Database Structure
├── oaif_metadata          -- REQUIRED: Self-describing
├── Reference Tables
│   ├── account_type
│   ├── transaction_type  
│   ├── item_type
│   ├── entity_type
│   ├── tax_type
│   └── security_type
├── Master Data
│   ├── currency
│   ├── account
│   ├── customer
│   ├── vendor
│   ├── employee
│   ├── item
│   ├── tax_code
│   └── terms
├── Transactions
│   ├── txn_header
│   ├── txn_line
│   └── txn_link
└── Extensions
    └── extension_data     -- Catch-all for custom fields
```

### 4.2 oaif_metadata (Required)

```sql
CREATE TABLE oaif_metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
```

**Required keys:**
- `oaif_version` - Specification version (e.g., "1.0")
- `oaif_min_reader` - Minimum reader version needed
- `created_at` - ISO 8601 timestamp
- `created_by` - Tool that created file
- `source_system` - Original software
- `company_name` - Business name
- `base_currency` - ISO 4217 currency code

**Optional keys:**
- `source_version` - Source software version
- `company_tax_id` - Tax identification number
- `company_country` - ISO 3166-1 alpha-2
- `fiscal_year_start_month` - 1-12
- `extensions_used` - Comma-separated list
- `vendor_extensions_used` - Comma-separated list

### 4.3 currency

```sql
CREATE TABLE currency (
    code TEXT PRIMARY KEY,          -- ISO 4217: USD, EUR, GBP
    name TEXT NOT NULL,
    symbol TEXT,                    -- $, €, £
    decimal_places INTEGER NOT NULL DEFAULT 2,
    is_active INTEGER DEFAULT 1
);
```

### 4.4 account

```sql
CREATE TABLE account (
    id INTEGER PRIMARY KEY,
    account_type_id INTEGER NOT NULL REFERENCES account_type(id),
    name TEXT NOT NULL,
    full_name TEXT,                 -- Hierarchical: "Assets:Bank:Checking"
    code TEXT,                      -- Account number
    description TEXT,
    is_active INTEGER DEFAULT 1,
    parent_id INTEGER REFERENCES account(id),
    currency_code TEXT REFERENCES currency(code),
    
    -- Current balance (optional, for import convenience)
    balance DECIMAL(19,6),
    
    -- Timestamps
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    
    -- Source preservation
    source_id TEXT,
    source_raw TEXT
);
```

### 4.5 customer

```sql
CREATE TABLE customer (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    full_name TEXT,                 -- For jobs: "Customer:Project"
    company_name TEXT,
    first_name TEXT,
    last_name TEXT,
    display_name TEXT,
    
    -- Contact
    email TEXT,
    phone TEXT,
    mobile TEXT,
    fax TEXT,
    website TEXT,
    
    -- Addresses (JSON for flexibility)
    billing_address TEXT,           -- JSON
    shipping_address TEXT,          -- JSON
    
    -- Financial
    currency_code TEXT REFERENCES currency(code),
    credit_limit DECIMAL(19,6),
    balance DECIMAL(19,6),
    
    -- Terms & Tax
    terms_id INTEGER REFERENCES terms(id),
    tax_code_id INTEGER REFERENCES tax_code(id),
    resale_number TEXT,
    tax_exempt INTEGER DEFAULT 0,
    
    -- Status
    is_active INTEGER DEFAULT 1,
    parent_id INTEGER REFERENCES customer(id), -- For jobs
    
    -- Timestamps
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    
    -- Source
    source_id TEXT,
    source_raw TEXT
);
```

### 4.6 vendor

```sql
CREATE TABLE vendor (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    full_name TEXT,
    company_name TEXT,
    first_name TEXT,
    last_name TEXT,
    display_name TEXT,
    
    -- Contact
    email TEXT,
    phone TEXT,
    mobile TEXT,
    fax TEXT,
    website TEXT,
    
    -- Address
    address TEXT,                   -- JSON
    
    -- Financial
    currency_code TEXT REFERENCES currency(code),
    balance DECIMAL(19,6),
    
    -- Terms & Tax
    terms_id INTEGER REFERENCES terms(id),
    tax_id TEXT,                    -- Vendor's tax ID
    tax_id_type TEXT,               -- 'EIN', 'VAT', 'GST'
    is_1099 INTEGER DEFAULT 0,
    default_expense_account_id INTEGER REFERENCES account(id),
    
    -- Status
    is_active INTEGER DEFAULT 1,
    
    -- Timestamps
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    
    -- Source
    source_id TEXT,
    source_raw TEXT
);
```

### 4.7 employee

```sql
CREATE TABLE employee (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    display_name TEXT,
    
    -- Contact
    email TEXT,
    phone TEXT,
    mobile TEXT,
    address TEXT,                   -- JSON
    
    -- Employment
    employee_number TEXT,
    hire_date DATE,
    termination_date DATE,
    department TEXT,
    title TEXT,
    
    -- Payroll
    ssn_last_four TEXT,             -- Last 4 digits only for privacy
    pay_rate DECIMAL(19,6),
    pay_frequency TEXT,             -- WEEKLY, BIWEEKLY, MONTHLY, etc.
    
    -- Status
    is_active INTEGER DEFAULT 1,
    
    -- Timestamps
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    
    -- Source
    source_id TEXT,
    source_raw TEXT
);
```

### 4.8 item

```sql
CREATE TABLE item (
    id INTEGER PRIMARY KEY,
    item_type_id INTEGER NOT NULL REFERENCES item_type(id),
    name TEXT NOT NULL,
    full_name TEXT,                 -- Hierarchical
    code TEXT,                      -- SKU
    description TEXT,
    
    -- Status
    is_active INTEGER DEFAULT 1,
    parent_id INTEGER REFERENCES item(id),
    
    -- Pricing
    sales_price DECIMAL(19,6),
    purchase_price DECIMAL(19,6),
    
    -- Accounts
    income_account_id INTEGER REFERENCES account(id),
    expense_account_id INTEGER REFERENCES account(id),
    asset_account_id INTEGER REFERENCES account(id),
    cogs_account_id INTEGER REFERENCES account(id),
    
    -- Inventory
    is_tracked INTEGER DEFAULT 0,
    quantity_on_hand DECIMAL(19,6),
    quantity_on_order DECIMAL(19,6),
    quantity_on_sales_order DECIMAL(19,6),
    reorder_point DECIMAL(19,6),
    average_cost DECIMAL(19,6),
    
    -- Fixed Assets
    purchase_date DATE,
    purchase_cost DECIMAL(19,6),
    useful_life_months INTEGER,
    salvage_value DECIMAL(19,6),
    depreciation_method TEXT,
    accumulated_depreciation DECIMAL(19,6),
    
    -- Tax
    tax_code_id INTEGER REFERENCES tax_code(id),
    is_taxable INTEGER DEFAULT 1,
    
    -- Timestamps
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    
    -- Source
    source_id TEXT,
    source_raw TEXT
);
```

### 4.9 tax_code

```sql
CREATE TABLE tax_code (
    id INTEGER PRIMARY KEY,
    tax_type_id INTEGER REFERENCES tax_type(id),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    rate DECIMAL(9,6),              -- 0.0825 = 8.25%
    
    -- For compound/multi-rate taxes
    is_compound INTEGER DEFAULT 0,
    components TEXT,                -- JSON array of component rates
    
    -- Accounts
    sales_account_id INTEGER REFERENCES account(id),
    purchase_account_id INTEGER REFERENCES account(id),
    
    -- Jurisdiction
    country_code TEXT,
    region_code TEXT,
    agency_name TEXT,
    
    -- Status
    is_active INTEGER DEFAULT 1,
    is_recoverable INTEGER DEFAULT 1,
    
    -- Source
    source_id TEXT,
    source_raw TEXT
);
```

### 4.10 terms

```sql
CREATE TABLE terms (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    due_days INTEGER,
    discount_days INTEGER,
    discount_percent DECIMAL(9,6),
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);
```

### 4.11 txn_header

```sql
CREATE TABLE txn_header (
    id INTEGER PRIMARY KEY,
    txn_type_id INTEGER NOT NULL REFERENCES transaction_type(id),
    txn_date DATE NOT NULL,
    
    -- Reference numbers
    doc_number TEXT,                -- Invoice #, Check #, etc.
    ref_number TEXT,                -- Reference/PO number
    
    -- Parties (only one typically populated per transaction)
    customer_id INTEGER REFERENCES customer(id),
    vendor_id INTEGER REFERENCES vendor(id),
    employee_id INTEGER REFERENCES employee(id),
    
    -- Primary account (bank for payments, AR for invoices, etc.)
    account_id INTEGER REFERENCES account(id),
    
    -- Currency
    currency_code TEXT NOT NULL DEFAULT 'USD' REFERENCES currency(code),
    exchange_rate DECIMAL(19,10) DEFAULT 1,
    
    -- Amounts (in transaction currency)
    subtotal DECIMAL(19,6),
    discount_amount DECIMAL(19,6),
    tax_amount DECIMAL(19,6),
    total_amount DECIMAL(19,6),
    
    -- Amounts (in base currency, if different)
    base_currency_total DECIMAL(19,6),
    
    -- Dates
    due_date DATE,
    ship_date DATE,
    
    -- Status flags
    is_posted INTEGER DEFAULT 1,
    is_paid INTEGER DEFAULT 0,
    is_closed INTEGER DEFAULT 0,
    is_voided INTEGER DEFAULT 0,
    is_cleared INTEGER DEFAULT 0,
    
    -- Terms & Tax
    terms_id INTEGER REFERENCES terms(id),
    tax_code_id INTEGER REFERENCES tax_code(id),
    
    -- Addresses (JSON for flexibility)
    billing_address TEXT,
    shipping_address TEXT,
    
    -- Memo & Notes
    memo TEXT,
    private_note TEXT,
    
    -- Timestamps
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    
    -- Source
    source_id TEXT,
    source_raw TEXT
);
```

### 4.12 txn_line

```sql
CREATE TABLE txn_line (
    id INTEGER PRIMARY KEY,
    txn_header_id INTEGER NOT NULL REFERENCES txn_header(id),
    line_number INTEGER NOT NULL,
    
    -- What (at least one of account_id or item_id required)
    account_id INTEGER REFERENCES account(id),
    item_id INTEGER REFERENCES item(id),
    description TEXT,
    
    -- Amount (SIGNED: positive=debit, negative=credit)
    quantity DECIMAL(19,6),
    unit_price DECIMAL(19,6),
    amount DECIMAL(19,6) NOT NULL,
    
    -- For inventory transactions
    unit_cost DECIMAL(19,6),
    
    -- Tax
    tax_code_id INTEGER REFERENCES tax_code(id),
    tax_amount DECIMAL(19,6),
    is_taxable INTEGER DEFAULT 1,
    
    -- Billable (for expense rebilling)
    customer_id INTEGER REFERENCES customer(id),
    is_billable INTEGER DEFAULT 0,
    is_billed INTEGER DEFAULT 0,
    
    -- Investment transactions
    security_id INTEGER REFERENCES security(id),
    shares DECIMAL(19,8),
    price_per_share DECIMAL(19,8),
    lot_id INTEGER REFERENCES investment_lot(id),
    
    -- Service date (for time-based billing)
    service_date DATE,
    
    -- Source
    source_id TEXT,
    source_raw TEXT
);
```

### 4.13 txn_link

Links related transactions (payment to invoice, receipt to bill, etc.)

```sql
CREATE TABLE txn_link (
    id INTEGER PRIMARY KEY,
    from_txn_id INTEGER NOT NULL REFERENCES txn_header(id),
    to_txn_id INTEGER NOT NULL REFERENCES txn_header(id),
    link_type TEXT,                 -- 'payment', 'receipt', 'fulfillment'
    amount DECIMAL(19,6),           -- Amount applied
    source_raw TEXT
);
```

### 4.14 extension_data

Catch-all for custom fields and vendor-specific data:

```sql
CREATE TABLE extension_data (
    id INTEGER PRIMARY KEY,
    parent_table TEXT NOT NULL,     -- 'customer', 'txn_header', etc.
    parent_id INTEGER NOT NULL,
    namespace TEXT NOT NULL,        -- 'oaif', 'vendor.quickbooks', etc.
    field_name TEXT NOT NULL,
    field_type TEXT,                -- 'string', 'number', 'date', 'boolean', 'json'
    field_value TEXT,
    UNIQUE(parent_table, parent_id, namespace, field_name)
);
```

---

## Part 5: Optional Tables

### 5.1 Classifications

```sql
CREATE TABLE class (
    id INTEGER PRIMARY KEY,
    dimension_type_id INTEGER REFERENCES dimension_type(id),
    name TEXT NOT NULL,
    full_name TEXT,
    code TEXT,
    parent_id INTEGER REFERENCES class(id),
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE location (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT,
    address TEXT,                   -- JSON
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
    status TEXT,                    -- ACTIVE, COMPLETED, CANCELLED
    start_date DATE,
    end_date DATE,
    budget DECIMAL(19,6),
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

-- Link transactions to classifications (many-to-many)
CREATE TABLE txn_dimension (
    txn_header_id INTEGER NOT NULL REFERENCES txn_header(id),
    class_id INTEGER REFERENCES class(id),
    location_id INTEGER REFERENCES location(id),
    project_id INTEGER REFERENCES project(id),
    PRIMARY KEY (txn_header_id)
);

CREATE TABLE txn_line_dimension (
    txn_line_id INTEGER NOT NULL REFERENCES txn_line(id),
    class_id INTEGER REFERENCES class(id),
    location_id INTEGER REFERENCES location(id),
    project_id INTEGER REFERENCES project(id),
    PRIMARY KEY (txn_line_id)
);
```

### 5.2 Investments

```sql
CREATE TABLE security (
    id INTEGER PRIMARY KEY,
    security_type_id INTEGER NOT NULL REFERENCES security_type(id),
    symbol TEXT,
    name TEXT NOT NULL,
    cusip TEXT,
    isin TEXT,
    currency_code TEXT REFERENCES currency(code),
    
    -- Current pricing
    last_price DECIMAL(19,8),
    last_price_date DATE,
    
    -- For bonds
    face_value DECIMAL(19,6),
    coupon_rate DECIMAL(9,6),
    maturity_date DATE,
    
    -- For options
    underlying_security_id INTEGER REFERENCES security(id),
    strike_price DECIMAL(19,6),
    expiration_date DATE,
    option_type TEXT,               -- CALL, PUT
    
    is_active INTEGER DEFAULT 1,
    source_id TEXT,
    source_raw TEXT
);

CREATE TABLE security_price (
    id INTEGER PRIMARY KEY,
    security_id INTEGER NOT NULL REFERENCES security(id),
    price_date DATE NOT NULL,
    price DECIMAL(19,8) NOT NULL,
    source TEXT,
    UNIQUE(security_id, price_date)
);

CREATE TABLE investment_lot (
    id INTEGER PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id),
    security_id INTEGER NOT NULL REFERENCES security(id),
    acquisition_date DATE NOT NULL,
    acquisition_txn_id INTEGER REFERENCES txn_header(id),
    shares_acquired DECIMAL(19,8) NOT NULL,
    cost_per_share DECIMAL(19,8) NOT NULL,
    total_cost DECIMAL(19,6) NOT NULL,
    shares_remaining DECIMAL(19,8) NOT NULL,
    disposal_date DATE,
    disposal_txn_id INTEGER REFERENCES txn_header(id),
    source_raw TEXT
);
```

### 5.3 Time Tracking

```sql
CREATE TABLE time_entry (
    id INTEGER PRIMARY KEY,
    employee_id INTEGER REFERENCES employee(id),
    customer_id INTEGER REFERENCES customer(id),
    project_id INTEGER REFERENCES project(id),
    item_id INTEGER REFERENCES item(id),        -- Service item
    entry_date DATE NOT NULL,
    duration_minutes INTEGER NOT NULL,
    description TEXT,
    hourly_rate DECIMAL(19,6),
    is_billable INTEGER DEFAULT 1,
    is_billed INTEGER DEFAULT 0,
    invoice_id INTEGER REFERENCES txn_header(id),
    source_id TEXT,
    source_raw TEXT
);
```

### 5.4 Attachments

```sql
CREATE TABLE attachment (
    id INTEGER PRIMARY KEY,
    parent_table TEXT NOT NULL,
    parent_id INTEGER NOT NULL,
    filename TEXT NOT NULL,
    mime_type TEXT,
    description TEXT,
    file_size INTEGER,
    checksum TEXT,                  -- SHA-256
    storage_type TEXT NOT NULL,     -- 'embedded', 'external', 'url'
    data BLOB,                      -- If embedded
    external_path TEXT,             -- If external
    external_url TEXT,              -- If URL
    created_at TIMESTAMP,
    source_raw TEXT
);
```

### 5.5 Budgets

```sql
CREATE TABLE budget (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    fiscal_year INTEGER NOT NULL,
    account_id INTEGER NOT NULL REFERENCES account(id),
    period_type TEXT,               -- 'MONTHLY', 'QUARTERLY', 'YEARLY'
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
    class_id INTEGER REFERENCES class(id),
    customer_id INTEGER REFERENCES customer(id),
    source_raw TEXT
);
```

### 5.6 Bank Reconciliations

```sql
CREATE TABLE bank_reconciliation (
    id INTEGER PRIMARY KEY,
    account_id INTEGER NOT NULL REFERENCES account(id),
    statement_date DATE NOT NULL,
    statement_balance DECIMAL(19,6) NOT NULL,
    cleared_balance DECIMAL(19,6),
    difference DECIMAL(19,6),
    is_reconciled INTEGER DEFAULT 0,
    reconciled_at TIMESTAMP,
    reconciled_by TEXT,
    source_raw TEXT
);
```

---

## Part 6: Data Integrity

### 6.1 Double-Entry Balance

Every transaction must balance. The sum of all line amounts must equal zero:

```sql
-- Validation query - should return no rows
SELECT txn_header_id, SUM(amount) as balance
FROM txn_line
GROUP BY txn_header_id
HAVING ABS(balance) > 0.005;
```

### 6.2 Trial Balance

The sum of all transaction lines across all transactions must equal zero:

```sql
-- Should return approximately 0.00
SELECT SUM(amount) as trial_balance FROM txn_line;
```

### 6.3 Referential Integrity

```sql
PRAGMA foreign_keys = ON;
```

### 6.4 Decimal Precision

All monetary amounts use `DECIMAL(19,6)`:
- 19 total digits
- 6 decimal places
- Handles values up to $9,999,999,999,999.999999

Exchange rates and share prices use `DECIMAL(19,8)` or `DECIMAL(19,10)` for additional precision.

---

## Part 7: Versioning & Evolution

### 7.1 Schema Versioning

```sql
PRAGMA user_version = 1;  -- Schema version 1.0
```

### 7.2 Version Compatibility

| oaif_version | user_version | Changes |
|--------------|--------------|---------|
| 1.0 | 1 | Initial release |
| 1.1 | 2 | (future) New standard types |
| 2.0 | 10 | (future) Breaking changes |

### 7.3 Extension Lifecycle

```
Vendor Extension → Proposed Extension → Standard
vendor.foo.TYPE      ext.community.TYPE     TYPE
```

---

## Part 8: Security Considerations

### 8.1 Sensitive Data

OAIF files may contain:
- Bank account details
- Customer personal information
- Employee payroll data
- Tax identification numbers
- Investment holdings

### 8.2 Recommendations

- Encrypt files at rest
- Use secure transfer (TLS)
- Implement access controls
- Redact SSN to last 4 digits
- Use parameterized queries when reading

### 8.3 SQL Injection Prevention

Applications reading OAIF files MUST use parameterized queries:

```python
# CORRECT
cursor.execute("SELECT * FROM customer WHERE name = ?", (user_input,))

# WRONG - vulnerable to injection
cursor.execute(f"SELECT * FROM customer WHERE name = '{user_input}'")
```

---

## Part 9: IANA Registration

### Media Type Registration

**Type name:** application  
**Subtype name:** vnd.oaif+sqlite  
**Required parameters:** None  
**Optional parameters:** None  
**Encoding considerations:** binary  
**Security considerations:** See Part 8  
**Interoperability considerations:** SQLite 3.x compatible  
**Published specification:** This document  
**File extension(s):** .oaif  
**Magic number(s):**  
- Bytes 0-15: `SQLite format 3\0`  
- Bytes 68-71: `0x4F414946`  

---

## Appendix A: Complete Schema SQL

See accompanying file: `oaif_schema.sql`

## Appendix B: Platform Mapping Tables

See accompanying file: `oaif_platform_mappings.md`

## Appendix C: Example Code

### Creating an OAIF file (Python)

```python
import sqlite3
import json
from datetime import datetime

def create_oaif_file(filepath, company_name, source_system):
    conn = sqlite3.connect(filepath)
    
    # Set identification
    conn.execute('PRAGMA application_id = 0x4F414946')
    conn.execute('PRAGMA user_version = 1')
    conn.execute('PRAGMA foreign_keys = ON')
    
    # Create schema (load from oaif_schema.sql)
    # ...
    
    # Set metadata
    conn.execute('''
        INSERT INTO oaif_metadata (key, value) VALUES
        ('oaif_version', '1.0'),
        ('oaif_min_reader', '1.0'),
        ('created_at', ?),
        ('created_by', 'my_converter 1.0'),
        ('source_system', ?),
        ('company_name', ?),
        ('base_currency', 'USD')
    ''', (datetime.utcnow().isoformat() + 'Z', source_system, company_name))
    
    conn.commit()
    return conn
```

### Reading an OAIF file (Python)

```python
def read_oaif_file(filepath):
    conn = sqlite3.connect(f'file:{filepath}?mode=ro', uri=True)
    
    # Verify it's OAIF
    app_id = conn.execute('PRAGMA application_id').fetchone()[0]
    if app_id != 0x4F414946:
        raise ValueError('Not a valid OAIF file')
    
    # Get metadata
    metadata = dict(conn.execute(
        'SELECT key, value FROM oaif_metadata'
    ).fetchall())
    
    # Check version compatibility
    min_reader = metadata.get('oaif_min_reader', '1.0')
    if min_reader > '1.0':  # Compare versions properly
        raise ValueError(f'File requires reader version {min_reader}')
    
    # Build type lookup from embedded tables (never hardcode!)
    txn_types = dict(conn.execute(
        'SELECT id, name FROM transaction_type'
    ).fetchall())
    
    return conn, metadata, txn_types
```

---

## Appendix D: Acknowledgments

[To be completed]

---

## Appendix E: Change History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01 | Initial specification |

---

*End of Specification*
