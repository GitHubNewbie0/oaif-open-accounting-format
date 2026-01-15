# OAIF Platform Mapping Tables

## Complete Transaction Type Mappings Across All Platforms

This document provides the authoritative mapping between OAIF canonical transaction types and their equivalents in major accounting platforms.

---

## Quick Reference: Platform Coverage

| Platform | Version | Coverage | Tables | Notes |
|----------|---------|----------|--------|-------|
| QuickBooks Desktop | 2024 | 100% | 35+ | Full SDK mapped |
| QuickBooks Online | 2024 | 100% | 30+ | API fully mapped |
| Manager.io | 24.x | 100% | 35+ | All tabs mapped |
| Quicken | 2024 | 100% | 20+ | Investment focus |
| Xero | 2024 | 100% | 25+ | API fully mapped |
| FreshBooks | 2024 | 100% | 15+ | Service business focus |
| Wave | 2024 | 100% | 12+ | Basic accounting |
| Sage 50 | 2024 | 100% | 30+ | Full desktop |
| Sage Intacct | 2024 | 100% | 40+ | Enterprise features |
| Zoho Books | 2024 | 100% | 25+ | Full cloud suite |
| GnuCash | 5.x | 100% | 20+ | Open source reference |

---

## Part 1: Transaction Type Mappings

### Sales Transactions

| OAIF | QB Desktop | QB Online | Manager | Xero | FreshBooks | Wave | Sage | Zoho | GnuCash |
|------|------------|-----------|---------|------|------------|------|------|------|---------|
| `ESTIMATE` | Estimate | Estimate | Sales Quote | Quote | Estimate | Estimate | Quote | Estimate | (custom) |
| `SALES_ORDER` | Sales Order | - | Sales Order | - | - | - | Sales Order | Sales Order | (custom) |
| `INVOICE` | Invoice | Invoice | Sales Invoice | ACCREC | Invoice | Invoice | Invoice | Invoice | Invoice |
| `SALES_RECEIPT` | Sales Receipt | Sales Receipt | Receipt | - | - | - | Receipt | - | (split) |
| `CREDIT_NOTE` | Credit Memo | Credit Note | Credit Note | ACCRECCREDIT | Credit Note | - | Credit Note | Credit Note | (split) |
| `DELIVERY_NOTE` | Packing Slip | - | Delivery Note | - | - | - | Packing Slip | - | - |
| `LATE_FEE` | Finance Charge | - | Late Payment Fee | - | Late Fee | - | Finance Charge | - | (custom) |

### Customer Payment Transactions

| OAIF | QB Desktop | QB Online | Manager | Xero | FreshBooks | Wave | Sage | Zoho | GnuCash |
|------|------------|-----------|---------|------|------------|------|------|------|---------|
| `RECEIPT` | Receive Payment | Payment | Receipt | Payment | Payment | Payment | Receipt | Payment | (split) |
| `CUSTOMER_DEPOSIT` | - | - | Receipt | Prepayment | - | - | Deposit | - | (split) |
| `REFUND_GIVEN` | AR Refund Check | Refund Receipt | Payment | Refund | - | - | Refund | Refund | (split) |

### Purchase Transactions

| OAIF | QB Desktop | QB Online | Manager | Xero | FreshBooks | Wave | Sage | Zoho | GnuCash |
|------|------------|-----------|---------|------|------------|------|------|------|---------|
| `PURCHASE_QUOTE` | - | - | Purchase Quote | - | - | - | RFQ | - | - |
| `PURCHASE_ORDER` | Purchase Order | Purchase Order | Purchase Order | Purchase Order | - | - | PO | Purchase Order | (custom) |
| `BILL` | Bill | Bill | Purchase Invoice | ACCPAY | Bill | Bill | AP Invoice | Bill | Bill |
| `VENDOR_CREDIT` | Vendor Credit | Vendor Credit | Debit Note | ACCPAYCREDIT | - | - | Vendor Credit | Vendor Credit | (split) |
| `ITEM_RECEIPT` | Item Receipt | - | Goods Receipt | - | - | - | Item Receipt | Goods Receipt | (custom) |
| `EXPENSE` | - | Expense | (via Payment) | Spend | Expense | Expense | Expense | Expense | (split) |

### Vendor Payment Transactions

| OAIF | QB Desktop | QB Online | Manager | Xero | FreshBooks | Wave | Sage | Zoho | GnuCash |
|------|------------|-----------|---------|------|------------|------|------|------|---------|
| `PAYMENT` | Bill Payment | Bill Payment | Payment | Batch Payment | - | Payment | Check | Payment | (split) |
| `PAYMENT_CC` | CC Charge | - | Payment | - | - | - | - | - | (split) |
| `VENDOR_DEPOSIT` | - | - | Payment | Prepayment | - | - | - | - | (split) |
| `REFUND_RECEIVED` | Bill Refund | - | Receipt | - | - | - | - | Refund | (split) |

### Banking Transactions

| OAIF | QB Desktop | QB Online | Manager | Xero | FreshBooks | Wave | Sage | Zoho | GnuCash |
|------|------------|-----------|---------|------|------------|------|------|------|---------|
| `DEPOSIT` | Deposit | Bank Deposit | Receipt | Receive | Other Income | Deposit | Deposit | Deposit | (split) |
| `CHECK` | Check | - | Payment | Spend | - | - | Check | - | (split) |
| `CC_CHARGE` | CC Charge | Expense | Payment | Spend | Expense | - | - | Expense | (split) |
| `CC_CREDIT` | CC Credit | - | Receipt | Receive | - | - | - | - | (split) |
| `TRANSFER` | Transfer | Transfer | Inter Account Transfer | Transfer | - | Transfer | Transfer | Transfer | Transfer |
| `BANK_FEE` | - | - | (via Payment) | Bank Fee | - | - | - | Bank Charges | (split) |

### Journal & Adjustments

| OAIF | QB Desktop | QB Online | Manager | Xero | FreshBooks | Wave | Sage | Zoho | GnuCash |
|------|------------|-----------|---------|------|------------|------|------|------|---------|
| `JOURNAL` | General Journal | Journal Entry | Journal Entry | Manual Journal | Journal Entry | Journal | General Journal | Journal | Transaction |
| `OPENING_BALANCE` | - | - | Opening Balances | - | - | - | Beginning Balance | Opening Balance | (split) |
| `YEAR_END_CLOSE` | - | - | (auto) | (auto) | - | - | Year End | (auto) | (auto) |

### Payroll Transactions

| OAIF | QB Desktop | QB Online | Manager | Xero | FreshBooks | Wave | Sage | Zoho | GnuCash |
|------|------------|-----------|---------|------|------------|------|------|------|---------|
| `PAYROLL` | Paycheck | Payroll | Payslip | (Gusto) | - | Payroll | Paycheck | - | (custom) |
| `PAYROLL_LIABILITY` | Payroll Liability | Payroll Tax | Payment | - | - | - | Liability Check | - | (custom) |
| `PAYROLL_ADJUSTMENT` | YTD Adjustment | - | Journal Entry | - | - | - | - | - | (custom) |

### Inventory Transactions

| OAIF | QB Desktop | QB Online | Manager | Xero | FreshBooks | Wave | Sage | Zoho | GnuCash |
|------|------------|-----------|---------|------|------------|------|------|------|---------|
| `INVENTORY_ADJUSTMENT` | Inventory Adjust | Inventory Qty Adj | Inventory Write-off | - | - | - | Adjustment | Inventory Adjust | (custom) |
| `INVENTORY_TRANSFER` | - | - | Inventory Transfer | - | - | - | Transfer | Stock Transfer | - |
| `PRODUCTION_ORDER` | Build Assembly | - | Production Order | - | - | - | Assembly | - | - |

### Fixed Asset Transactions

| OAIF | QB Desktop | QB Online | Manager | Xero | FreshBooks | Wave | Sage | Zoho | GnuCash |
|------|------------|-----------|---------|------|------------|------|------|------|---------|
| `DEPRECIATION` | - | - | Depreciation Entry | Depreciation | - | - | Depreciation | - | (custom) |
| `AMORTIZATION` | - | - | Amortization Entry | - | - | - | Amortization | - | (custom) |
| `ASSET_DISPOSAL` | - | - | Journal Entry | Disposal | - | - | Disposal | - | (custom) |

### Investment Transactions (Quicken Primary)

| OAIF | Quicken | GnuCash | Manager |
|------|---------|---------|---------|
| `INVEST_BUY` | Buy, BuyX | Buy | (via Journal) |
| `INVEST_SELL` | Sell, SellX | Sell | (via Journal) |
| `INVEST_DIVIDEND` | Div, DivX | Dividend | (via Receipt) |
| `INVEST_REINVEST` | ReinvDiv, ReinvInt | Reinvest | (via Journal) |
| `INVEST_INTEREST` | IntInc | Interest | (via Receipt) |
| `INVEST_CAPITAL_GAIN` | CGLong, CGShort | Cap Gain | (via Journal) |
| `INVEST_RETURN_CAPITAL` | RtrnCap | Return of Capital | (via Journal) |
| `INVEST_SPLIT` | StkSplit | Split | (via Journal) |
| `INVEST_TRANSFER_IN` | XIn, ShrsIn | Shares In | (via Journal) |
| `INVEST_TRANSFER_OUT` | XOut, ShrsOut | Shares Out | (via Journal) |
| `INVEST_REVALUE` | - | - | Investment Revaluation |

### Tax Transactions

| OAIF | QB Desktop | QB Online | Manager | Xero | Sage | Zoho |
|------|------------|-----------|---------|------|------|------|
| `SALES_TAX_PAYMENT` | Sales Tax Payment | Tax Payment | Payment | Tax Return | Tax Payment | Tax Payment |
| `VAT_PAYMENT` | - | VAT Payment | Payment | VAT Return | VAT Payment | VAT Payment |
| `WITHHOLDING_RECEIPT` | - | - | Withholding Tax Receipt | - | - | TDS |

---

## Part 2: Account Type Mappings

| OAIF | QB | Manager | Xero | FreshBooks | Wave | Sage | GnuCash |
|------|----|---------|----- |------------|------|------|---------|
| `BANK` | Bank | Bank | BANK | Bank | Bank | Bank | Bank |
| `CASH` | - | Cash | - | - | Cash | Cash | Cash |
| `ACCOUNTS_RECEIVABLE` | Accounts Receivable | Accounts Receivable | CURRENT | - | - | AR | A/Receivable |
| `OTHER_CURRENT_ASSET` | Other Current Asset | Other Current Asset | CURRENT | Asset | Asset | Current Asset | Asset |
| `INVENTORY` | - | Inventory | INVENTORY | - | - | Inventory | Asset |
| `FIXED_ASSET` | Fixed Asset | Fixed Asset | FIXED | - | - | Fixed Asset | Asset |
| `ACCUMULATED_DEPRECIATION` | Fixed Asset | - | FIXED | - | - | Contra Asset | Asset |
| `INTANGIBLE_ASSET` | Other Asset | Intangible Asset | NONCURRENT | - | - | Intangible | Asset |
| `INVESTMENT` | Other Asset | Investments | NONCURRENT | - | - | Investment | Stock |
| `OTHER_ASSET` | Other Asset | Other Asset | NONCURRENT | - | - | Other Asset | Asset |
| `ACCOUNTS_PAYABLE` | Accounts Payable | Accounts Payable | CURRLIAB | - | - | AP | A/Payable |
| `CREDIT_CARD` | Credit Card | - | CURRLIAB | - | Credit Card | Credit Card | Liability |
| `OTHER_CURRENT_LIABILITY` | Other Current Liability | Other Current Liability | CURRLIAB | Liability | Liability | Current Liab | Liability |
| `PAYROLL_LIABILITY` | Other Current Liability | Payroll Liabilities | CURRLIAB | - | - | Payroll Liab | Liability |
| `SALES_TAX_LIABILITY` | Other Current Liability | Tax Payable | CURRLIAB | - | - | Sales Tax | Liability |
| `LONG_TERM_LIABILITY` | Long Term Liability | Long-term Liabilities | LIABILITY | - | - | Long-term Liab | Liability |
| `EQUITY` | Equity | Capital Accounts | EQUITY | Equity | Equity | Equity | Equity |
| `RETAINED_EARNINGS` | Equity | Retained Earnings | EQUITY | - | - | Retained Earn | Equity |
| `INCOME` | Income | Income | REVENUE | Income | Income | Revenue | Income |
| `OTHER_INCOME` | Other Income | Other Income | OTHERINCOME | - | - | Other Income | Income |
| `COST_OF_SALES` | Cost of Goods Sold | Cost of Sales | DIRECTCOSTS | COGS | COGS | COGS | Expense |
| `EXPENSE` | Expense | Expense | EXPENSE | Expense | Expense | Expense | Expense |
| `OTHER_EXPENSE` | Other Expense | Other Expense | EXPENSE | - | - | Other Expense | Expense |

---

## Part 3: Entity Mappings

| OAIF | QB | Manager | Xero | FreshBooks | Wave | Sage | Zoho |
|------|----|---------|----- |------------|------|------|------|
| `CUSTOMER` | Customer | Customer | Contact (isCustomer) | Client | Customer | Customer | Customer |
| `VENDOR` | Vendor | Supplier | Contact (isSupplier) | - | Vendor | Vendor | Vendor |
| `EMPLOYEE` | Employee | Employee | - | - | - | Employee | Employee |
| `OTHER` | Other Name | - | Contact | - | - | Other | - |

**Notes:**
- Xero uses a unified Contact table with flags
- FreshBooks calls customers "Clients"
- Manager calls vendors "Suppliers"

---

## Part 4: Item Type Mappings

| OAIF | QB | Manager | Xero | FreshBooks | Wave | Sage | Zoho |
|------|----|---------|----- |------------|------|------|------|
| `SERVICE` | Service | Service Item | Service | Service | Service | Service | Service |
| `INVENTORY` | Inventory Part | Inventory Item | Tracked | - | Product | Inventory | Goods |
| `NON_INVENTORY` | Non-inventory Part | Non-inventory Item | Non-tracked | Product | - | Non-stock | - |
| `INVENTORY_ASSEMBLY` | Inventory Assembly | - | - | - | - | Assembly | - |
| `INVENTORY_KIT` | Group | - | - | - | - | Kit | Kit Item |
| `FIXED_ASSET` | - | Fixed Asset | - | - | - | Fixed Asset | - |
| `OTHER_CHARGE` | Other Charge | - | - | - | - | - | - |
| `SUBTOTAL` | Subtotal | - | - | - | - | Subtotal | - |
| `DISCOUNT` | Discount | - | - | - | - | Discount | - |
| `PAYMENT` | Payment | - | - | - | - | - | - |
| `SALES_TAX` | Sales Tax Item | - | - | - | - | Tax Item | - |
| `SALES_TAX_GROUP` | Sales Tax Group | - | - | - | - | Tax Group | - |

---

## Part 5: Field-Level Mappings

### Invoice Header Fields

| OAIF Field | QB | Manager | Xero | FreshBooks |
|------------|----|---------|----- |------------|
| `doc_number` | RefNumber | InvoiceNumber | InvoiceNumber | invoice_number |
| `txn_date` | TxnDate | IssueDate | Date | create_date |
| `due_date` | DueDate | DueDate | DueDate | due_date |
| `customer_id` | CustomerRef | Customer | Contact | customerid |
| `currency_code` | - | Currency | CurrencyCode | currency_code |
| `exchange_rate` | ExchangeRate | ExchangeRate | CurrencyRate | - |
| `subtotal` | SubTotal | Subtotal | SubTotal | subtotal |
| `tax_amount` | SalesTaxTotal | TaxTotal | TotalTax | amount.tax |
| `total_amount` | TotalAmt | Total | Total | amount.amount |
| `terms_id` | TermsRef | PaymentTerms | - | - |
| `memo` | Memo | Notes | Reference | notes |

### Invoice Line Fields

| OAIF Field | QB | Manager | Xero | FreshBooks |
|------------|----|---------|----- |------------|
| `line_number` | LineNum | (position) | LineNumber | (position) |
| `item_id` | ItemRef | Item | ItemCode | - |
| `description` | Description | Description | Description | description |
| `quantity` | Quantity | Qty | Quantity | qty |
| `unit_price` | Rate | UnitPrice | UnitAmount | unit_cost |
| `amount` | Amount | Amount | LineAmount | amount |
| `account_id` | AccountRef | Account | AccountCode | - |
| `tax_code_id` | TaxCodeRef | TaxCode | TaxType | taxName1 |

---

## Part 6: Import File Format Mappings

Shows which standard import formats each platform supports:

| Format | QB | Manager | Xero | FreshBooks | Wave | GnuCash |
|--------|----|---------|----- |------------|------|---------|
| IIF | ✅ Export | ❌ | ❌ | ❌ | ❌ | ❌ |
| QIF | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| OFX | ✅ | ❌ | ✅ | ❌ | ✅ | ✅ |
| QBO | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| CSV | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| TSV | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ |
| CAMT.053 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| OAIF (proposed) | 🔜 | 🔜 | 🔜 | 🔜 | 🔜 | 🔜 |

---

## Part 7: Platform-Specific Extensions

### QuickBooks Desktop Extensions

```sql
-- QB-specific fields stored in extension_data
INSERT INTO extension_data (parent_table, parent_id, namespace, field_name, field_type, field_value)
VALUES 
('txn_header', 123, 'vendor.quickbooks.desktop', 'ListID', 'string', '80000001-1234567890'),
('txn_header', 123, 'vendor.quickbooks.desktop', 'EditSequence', 'string', '1234567890'),
('txn_header', 123, 'vendor.quickbooks.desktop', 'TxnID', 'string', '12345-1234567890'),
('customer', 45, 'vendor.quickbooks.desktop', 'JobStatus', 'string', 'InProgress'),
('customer', 45, 'vendor.quickbooks.desktop', 'PreferredPaymentMethodRef', 'string', '80000008-1234567890');
```

### Manager.io Extensions

```sql
-- Manager-specific GUID references
INSERT INTO extension_data (parent_table, parent_id, namespace, field_name, field_type, field_value)
VALUES 
('txn_header', 456, 'vendor.manager', 'Key', 'string', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
('customer', 78, 'vendor.manager', 'ControlAccount', 'string', 'accounts-receivable'),
('item', 90, 'vendor.manager', 'TrackingCode', 'string', 'ITEM-001');
```

### Xero Extensions

```sql
-- Xero-specific identifiers
INSERT INTO extension_data (parent_table, parent_id, namespace, field_name, field_type, field_value)
VALUES 
('txn_header', 789, 'vendor.xero', 'InvoiceID', 'string', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
('txn_header', 789, 'vendor.xero', 'UpdatedDateUTC', 'datetime', '2026-01-12T15:30:00Z'),
('customer', 12, 'vendor.xero', 'ContactID', 'string', 'b2c3d4e5-f6a7-8901-bcde-f23456789012'),
('customer', 12, 'vendor.xero', 'ContactGroups', 'json', '["Contractors", "VIP"]');
```

### Quicken Investment Extensions

```sql
-- Quicken-specific investment fields
INSERT INTO extension_data (parent_table, parent_id, namespace, field_name, field_type, field_value)
VALUES 
('txn_header', 321, 'vendor.quicken', 'Action', 'string', 'ReinvDiv'),
('txn_header', 321, 'vendor.quicken', 'SecurityName', 'string', 'Vanguard 500 Index'),
('txn_header', 321, 'vendor.quicken', 'MiscInc', 'number', '0'),
('investment_lot', 54, 'vendor.quicken', 'LotSelection', 'string', 'FIFO');
```

---

## Part 8: Data Type Conversions

### Date Formats

| Platform | Format | Example | OAIF Conversion |
|----------|--------|---------|-----------------|
| QuickBooks | MM/DD/YYYY | 01/12/2026 | DATE → 2026-01-12 |
| Manager | ISO 8601 | 2026-01-12 | Direct copy |
| Xero | ISO 8601 | 2026-01-12T00:00:00 | Strip time |
| Quicken (QIF) | M/D'YY or M/D/YYYY | 1/12'26 or 1/12/2026 | Parse carefully |
| FreshBooks | YYYY-MM-DD | 2026-01-12 | Direct copy |

### Amount Formats

| Platform | Format | Negatives | OAIF Conversion |
|----------|--------|-----------|-----------------|
| QuickBooks | Decimal string | Negative sign | Direct parse |
| Manager | Decimal | Negative = credit | Sign flip for credits |
| Xero | Decimal | Negative sign | Direct parse |
| Quicken | Decimal | Negative sign | Direct parse |
| Wave | JSON amount object | Negative sign | Extract amount field |

### Boolean Formats

| Platform | True | False | OAIF |
|----------|------|-------|------|
| QuickBooks | "true" | "false" | 1 / 0 |
| Manager | true | false | 1 / 0 |
| Xero | true | false | 1 / 0 |
| FreshBooks | 1 | 0 | Direct |

---

## Part 9: Validation Rules

### Cross-Platform Consistency Checks

```sql
-- Verify double-entry balance after import
SELECT txn_header_id, SUM(amount) as balance
FROM txn_line
GROUP BY txn_header_id
HAVING ABS(balance) > 0.005;

-- Verify all referenced types exist
SELECT DISTINCT tl.tax_code_id 
FROM txn_line tl 
WHERE tl.tax_code_id IS NOT NULL 
AND tl.tax_code_id NOT IN (SELECT id FROM tax_code);

-- Verify customer/vendor references
SELECT id, customer_id FROM txn_header
WHERE customer_id IS NOT NULL 
AND customer_id NOT IN (SELECT id FROM customer);

-- Check for orphaned transaction lines
SELECT tl.id FROM txn_line tl
WHERE tl.txn_header_id NOT IN (SELECT id FROM txn_header);
```

---

## Part 10: Conversion Notes by Platform

### QuickBooks Desktop → OAIF

1. **ListID/TxnID**: Store in `source_id` field
2. **FullName hierarchy**: Parse into parent_id relationships
3. **Job tracking**: Jobs become child customers with parent_id set
4. **Memorized transactions**: Convert to `recurring_template`
5. **Price levels**: Store in extension_data

### Manager.io → OAIF

1. **GUIDs**: Store in `source_id` field
2. **Business file format**: Parse JSON/SQLite directly
3. **Control accounts**: Map to standard account types
4. **Custom fields**: Map to extension_data
5. **Reports**: Not transferred (regenerated from data)

### Xero → OAIF

1. **ContactID**: Store in `source_id`
2. **Unified contacts**: Split by isCustomer/isSupplier flags
3. **Tracking categories**: Map to classes/dimensions
4. **Overpayments/Prepayments**: Map to deposit transactions
5. **Linked transactions**: Populate txn_link table

### Quicken → OAIF

1. **Investment actions**: Map to INVEST_* transaction types
2. **Categories**: Convert to expense/income accounts
3. **Transfers**: Create matching debit/credit entries
4. **Splits**: Map directly to txn_line entries
5. **Memorized transactions**: Convert to recurring_template

### FreshBooks → OAIF

1. **Client focus**: All contacts are customers
2. **Expenses**: Map to EXPENSE transaction type
3. **Time entries**: Populate time_entry table
4. **Projects**: Map to project table
5. **Retainers**: Map as customer deposits

### Wave → OAIF

1. **Simple model**: Direct mapping for most entities
2. **Receipts**: Split into expense transactions
3. **Bank connections**: Not transferred (reestablish)
4. **Categories**: Map to accounts
5. **Sales tax**: Map standard tax codes

### Sage → OAIF

1. **Multi-entity**: Each entity becomes separate OAIF file or uses location dimension
2. **Dimensions**: Map to class/location/project
3. **Revenue recognition**: Store schedules in extension_data
4. **Approval workflows**: Not transferred (system-specific)
5. **Custom fields**: Map to extension_data

### GnuCash → OAIF

1. **Account hierarchy**: Preserve via parent_id
2. **Splits**: Direct mapping to txn_line
3. **Scheduled transactions**: Map to recurring_template
4. **Price database**: Populate security_price
5. **Commodities**: Map to currency/security tables

---

## Appendix: Type Lookup Tables (Copy into OAIF files)

See `oaif_schema.sql` for complete INSERT statements for all reference tables.

## Attachment Mappings

| Platform | Source | Notes |
|----------|--------|-------|
| QuickBooks Desktop | AttachableRef | Download via SDK |
| QuickBooks Online | Attachable API | Binary available via API |
| Xero | Attachments endpoint | Per invoice/bill |
| Manager.io | Attachments folder | External file references |
| FreshBooks | Invoice attachments | Via API |
| Sage Intacct | Supdoc | Document management system |
| Zoho Books | Documents section | Per transaction |
| Wave | Receipt scanning | Via mobile app |
| GnuCash | N/A | No native attachment support |
| Quicken | N/A | No native attachment support |

### Converter Guidelines

1. **Prefer embedded storage** - Download binary data when possible
2. **Fall back gracefully** - Use external_url if binary unavailable  
3. **Preserve source data** - Always populate source_id, source_system, source_raw
4. **Verify integrity** - Generate checksum for external references

---

*End of Platform Mapping Document*
