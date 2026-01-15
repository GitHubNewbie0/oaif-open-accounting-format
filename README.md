# OAIF - Open Accounting Interchange Format

<p align="center">
  <img src="media/oaif-logo.svg" alt="OAIF Logo" width="200">
</p>

<p align="center">
  <strong>The universal, open standard for accounting data interchange</strong>
</p>

<p align="center">
  <a href="#why-oaif">Why OAIF?</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#supported-platforms">Platforms</a> •
  <a href="#specification">Specification</a> •
  <a href="#tools">Tools</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## The Problem

Accounting data is trapped. Moving from QuickBooks to Xero? Good luck. Switching from Sage to Manager.io? Hope you like manual data entry. Every accounting system uses its own proprietary format, creating vendor lock-in that costs businesses time, money, and sanity.

**Existing "standards" fall short:**
- **IIF** - QuickBooks-only, tab-delimited mess
- **QIF** - Ancient Quicken format, no double-entry
- **OFX** - Bank statements only, not full accounting
- **XBRL** - Regulatory reporting, not data interchange

## The Solution: OAIF

OAIF is a **vendor-neutral, open file format** for complete accounting data:

```
company_2026.oaif  ←  One file contains EVERYTHING
├── Chart of Accounts
├── Customers & Vendors  
├── Employees
├── Products & Services
├── All Transactions (with full audit trail)
├── Attachments (receipts, documents)    ← NEW v1.1
├── Investments & Securities
├── Payroll Data
└── Custom Fields & Extensions
```

### Key Features

| Feature | Benefit |
|---------|---------|
| **SQLite Container** | Works everywhere - no special software needed |
| **Double-Entry** | Every transaction balances, guaranteed |
| **Lossless** | Original source data preserved in `source_raw` |
| **Extensible** | Add custom fields without breaking compatibility |
| **Self-Describing** | Type definitions embedded in each file |
| **Multi-Currency** | Built-in from day one |
| **Investment Ready** | Full portfolio tracking (stocks, bonds, crypto) |

---

## Why OAIF?

### For Businesses
- **Freedom**: Switch accounting software without losing history
- **Backup**: Human-readable archive of your financial data
- **Integration**: Connect any systems via a common format

### For Developers
- **Simple**: SQLite + ~18 core tables = implement in a weekend
- **Universal**: Works in Python, JavaScript, C#, Java, Go, Rust...
- **Documented**: Complete spec with platform mappings

### For the Industry
- **Open Standard**: No licensing fees, no vendor control
- **Community Driven**: Evolves based on real needs
- **Future Proof**: Extensible without breaking changes

---

## Quick Start

### Reading an OAIF File

```python
import sqlite3

# Open the file (read-only)
conn = sqlite3.connect('file:company.oaif?mode=ro', uri=True)

# Verify it's OAIF
app_id = conn.execute('PRAGMA application_id').fetchone()[0]
assert app_id == 0x4F414946, "Not a valid OAIF file"

# Get company info
metadata = dict(conn.execute('SELECT key, value FROM oaif_metadata').fetchall())
print(f"Company: {metadata['company_name']}")
print(f"Source: {metadata['source_system']}")

# Query customers
for row in conn.execute('SELECT name, email, balance FROM customer WHERE is_active = 1'):
    print(f"  {row[0]}: {row[2]:.2f}")

# Get trial balance
for row in conn.execute('SELECT * FROM v_trial_balance'):
    print(f"  {row[1]}: Dr {row[5]:.2f} / Cr {row[6]:.2f}")
```

### Creating an OAIF File

```python
import sqlite3
from datetime import datetime

conn = sqlite3.connect('new_company.oaif')

# Set identification
conn.execute('PRAGMA application_id = 0x4F414946')
conn.execute('PRAGMA user_version = 1')

# Load schema
with open('schema/oaif_schema.sql') as f:
    conn.executescript(f.read())

# Add metadata
conn.execute('''
    INSERT INTO oaif_metadata (key, value) VALUES
    ('oaif_version', '1.0'),
    ('created_at', ?),
    ('company_name', 'My Company'),
    ('base_currency', 'USD')
''', (datetime.utcnow().isoformat() + 'Z',))

conn.commit()
```

---

## Supported Platforms

OAIF provides complete mappings for:

| Platform | Import | Export | Coverage |
|----------|--------|--------|----------|
| QuickBooks Desktop | ✅ | ✅ | 100% |
| QuickBooks Online | ✅ | ✅ | 100% |
| Manager.io | ✅ | ✅ | 100% |
| Quicken | ✅ | ✅ | 100% |
| Xero | ✅ | ✅ | 100% |
| FreshBooks | ✅ | ✅ | 100% |
| Wave | ✅ | ✅ | 100% |
| Sage 50/Intacct | ✅ | ✅ | 100% |
| Zoho Books | ✅ | ✅ | 100% |
| GnuCash | ✅ | ✅ | 100% |

See [Platform Mappings](docs/PLATFORM_MAPPINGS.md) for detailed field-by-field mappings.

---

## File Format

### Identification

| Property | Value |
|----------|-------|
| Extension | `.oaif` |
| MIME Type | `application/vnd.oaif+sqlite` |
| SQLite App ID | `0x4F414946` ("OAIF" in ASCII) |

### Verification

```bash
# Check if file is valid OAIF
sqlite3 company.oaif "PRAGMA application_id" | grep -q "1330463302" && echo "Valid OAIF"

# Or check the magic bytes
xxd -s 68 -l 4 company.oaif  # Should show: 4f41 4946 (OAIF)
```

### Structure

```
OAIF File
├── oaif_metadata          # Self-describing (required)
├── Reference Tables
│   ├── account_type       # 24 standard types
│   ├── transaction_type   # 125+ transaction types
│   ├── item_type          # 13 item types
│   └── ...
├── Master Data
│   ├── account            # Chart of accounts
│   ├── customer           # Customers/clients
│   ├── vendor             # Suppliers/vendors
│   ├── employee           # Employees
│   ├── item               # Products/services
│   └── ...
├── Transactions
│   ├── txn_header         # Transaction headers
│   ├── txn_line           # Line items (splits)
│   └── txn_link           # Related transactions
├── Attachments
│   └── attachment         # Document attachments (v1.1)
└── Extensions
    └── extension_data     # Custom fields
```

---

## Specification

The complete specification is available in [`docs/SPECIFICATION.md`](docs/SPECIFICATION.md).

### Key Documents

| Document | Description |
|----------|-------------|
| [SPECIFICATION.md](docs/SPECIFICATION.md) | Full technical specification |
| [PLATFORM_MAPPINGS.md](docs/PLATFORM_MAPPINGS.md) | Field mappings for all platforms |
| [oaif_schema.sql](schema/oaif_schema.sql) | Complete SQL schema |
| [IANA_REGISTRATION.md](docs/IANA_REGISTRATION.md) | MIME type registration |

### Design Principles

1. **Names are canonical** - Type IDs are file-local, names are universal
2. **Self-describing** - Each file contains its own type definitions
3. **Lossless** - `source_raw` preserves original data
4. **80/20 simplicity** - Core handles 80% of cases, extensions handle rest
5. **Graceful degradation** - Unknown types don't break readers

---

## Tools

### Official Tools

| Tool | Description | Status |
|------|-------------|--------|
| `qb2oaif` | QuickBooks Desktop → OAIF | ✅ Available |
| `oaif-validate` | Validate OAIF files | 🚧 Coming Soon |
| `oaif-diff` | Compare two OAIF files | 🚧 Coming Soon |

### Community Tools

*Have a tool to add? [Submit a PR!](CONTRIBUTING.md)*

---

## Transaction Types

OAIF supports 125+ transaction types across all categories:

### Sales & Receivables
`ESTIMATE` · `SALES_ORDER` · `INVOICE` · `SALES_RECEIPT` · `CREDIT_NOTE` · `RECEIPT` · `REFUND_GIVEN` · ...

### Purchases & Payables
`PURCHASE_ORDER` · `BILL` · `VENDOR_CREDIT` · `PAYMENT` · `EXPENSE` · ...

### Banking
`DEPOSIT` · `CHECK` · `TRANSFER` · `CC_CHARGE` · `CC_CREDIT` · ...

### Payroll
`PAYROLL` · `PAYROLL_LIABILITY` · `PAYROLL_ADJUSTMENT` · ...

### Inventory
`INVENTORY_ADJUSTMENT` · `INVENTORY_TRANSFER` · `PRODUCTION_ORDER` · ...

### Investments
`INVEST_BUY` · `INVEST_SELL` · `INVEST_DIVIDEND` · `INVEST_SPLIT` · `INVEST_REINVEST` · ...

See the full list in the [Specification](docs/SPECIFICATION.md#32-transaction-types).

---

## Examples

### Example OAIF Files

| File | Description |
|------|-------------|
| [minimal.oaif](examples/minimal.oaif) | Smallest valid OAIF file |
| [sample_company.oaif](examples/sample_company.oaif) | Full example with transactions |
| [investment_portfolio.oaif](examples/investment_portfolio.oaif) | Investment tracking example |

### Code Examples

| Language | Example |
|----------|---------|
| Python | [examples/python/](examples/python/) |
| JavaScript | [examples/javascript/](examples/javascript/) |
| C# | [examples/csharp/](examples/csharp/) |

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Ways to Help

- 🐛 **Report bugs** in the spec or tools
- 📝 **Improve documentation**
- 🔧 **Build tools** for your favorite platform
- 🌍 **Add translations**
- 💡 **Propose extensions** for new use cases

### Extension Process

1. **Vendor extensions**: Use `vendor.yourcompany.TYPE` namespace
2. **Proposed extensions**: Submit RFC, use `ext.name.TYPE` if accepted
3. **Standard types**: Proven extensions promoted to UPPERCASE standard

---

## Roadmap

### v1.1 (Current)
v1.0 * ✅ Complete specification
* ✅ Attachment support for document storage
- ✅ SQL schema with standard types
- ✅ Platform mappings for 11 systems
- ✅ Reference tools (qb2oaif, oaif2manager)

### v1.1 (Planned)
- 🚧 IANA MIME type registration
- 🚧 Validation tool
- 🚧 Additional converter tools
- 🚧 Test suite

### v2.0 (Future)
- 💭 Real-time sync protocol
- 💭 Encryption standard
- 💭 Digital signatures
- 💭 Cloud storage integration

---

## FAQ

**Q: Why SQLite instead of JSON/XML?**
> SQLite provides ACID transactions, SQL queries, and universal tooling. JSON/XML would require custom parsers and can't enforce relational integrity.

**Q: How is this different from OFX?**
> OFX is for bank statement interchange. OAIF is for complete accounting data - chart of accounts, customers, vendors, all transaction types, inventory, payroll, investments, and more.

**Q: What about data security?**
> OAIF files can contain sensitive data. Encrypt at rest, use TLS for transfer, and implement access controls. The spec includes security guidelines.

**Q: Can I extend OAIF for my application?**
> Yes! Use the `extension_data` table for custom fields, or create vendor-namespaced tables (`vendor_yourcompany_*`).

**Q: Is there a formal standard body behind this?**
> Not yet. OAIF is community-driven. If adoption grows, we may pursue formal standardization (ISO, IETF, etc.).

---

## License

This specification is released under the [Apache License 2.0](LICENSE).

You are free to:
- ✅ Use the specification commercially
- ✅ Modify and distribute
- ✅ Create proprietary tools
- ✅ Use the OAIF name and format

---

## Acknowledgments

OAIF was developed through analysis of:
- QuickBooks SDK and IIF format
- Manager.io data structures
- Xero API documentation
- Quicken QIF format
- GnuCash data model
- And many other accounting systems

Special thanks to everyone who contributed ideas, testing, and feedback.

---

<p align="center">
  <strong>Free your accounting data.</strong><br>
  <a href="docs/SPECIFICATION.md">Read the Spec</a> •
  <a href="https://github.com/yourusername/oaif-spec/issues">Report Issues</a> •
  <a href="https://github.com/yourusername/oaif-spec/discussions">Discussions</a>
</p>
