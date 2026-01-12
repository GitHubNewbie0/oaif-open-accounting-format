# Contributing to OAIF

Thank you for your interest in contributing to the Open Accounting Interchange Format! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Ways to Contribute](#ways-to-contribute)
- [Reporting Issues](#reporting-issues)
- [Proposing Changes](#proposing-changes)
- [Extension Process](#extension-process)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Style Guidelines](#style-guidelines)

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [conduct@oaif.org].

---

## Ways to Contribute

### 1. Report Bugs
Found an issue with the specification, schema, or tools? [Open an issue](../../issues/new?template=bug_report.md).

### 2. Suggest Enhancements
Have an idea for improving OAIF? [Start a discussion](../../discussions/new?category=ideas).

### 3. Improve Documentation
- Fix typos or unclear wording
- Add examples
- Translate to other languages
- Improve platform mapping tables

### 4. Build Tools
Create converters, validators, or integrations:
- Import/export tools for accounting software
- Validation utilities
- Language bindings
- IDE plugins

### 5. Add Platform Mappings
Help document field mappings for:
- Accounting software not yet covered
- Regional/localized versions
- Industry-specific systems

### 6. Propose Extensions
See [Extension Process](#extension-process) below.

---

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

1. **Summary**: Clear, concise description
2. **Environment**: OS, SQLite version, tool version
3. **Steps to Reproduce**: Numbered steps
4. **Expected Behavior**: What should happen
5. **Actual Behavior**: What actually happens
6. **Sample File**: If applicable (redact sensitive data!)

### Security Issues

**Do not open public issues for security vulnerabilities.**

Instead, email [security@oaif.org] with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact

We will respond within 48 hours.

---

## Proposing Changes

### Specification Changes

Changes to the core specification require discussion:

1. **Open a Discussion**: Explain the problem and proposed solution
2. **Gather Feedback**: Allow at least 2 weeks for community input
3. **Draft RFC**: Write a formal proposal if there's support
4. **Review Period**: Minimum 30 days for major changes
5. **Vote/Consensus**: Major changes require rough consensus

### Schema Changes

For changes to `oaif_schema.sql`:

1. **Backward Compatibility**: Changes must not break existing files
2. **Migration Path**: Document how to upgrade existing files
3. **Tests**: Include validation queries
4. **Documentation**: Update spec and mappings

### Tool Changes

For tools in the `tools/` directory:

1. **Tests Required**: Include unit tests
2. **Documentation**: Update usage instructions
3. **Cross-Platform**: Test on Linux, macOS, Windows

---

## Extension Process

OAIF supports three levels of extensions:

### Level 1: Vendor Extensions

**Anyone can create these immediately.**

- Namespace: `vendor.yourcompany.TYPE`
- Table prefix: `vendor_yourcompany_`
- No approval needed
- Document in your own repo

Example:
```sql
-- Vendor transaction type
INSERT INTO transaction_type (name, description, is_standard)
VALUES ('vendor.acme.CUSTOM_INVOICE', 'Acme custom invoice type', 0);

-- Vendor table
CREATE TABLE vendor_acme_custom_data (
    id INTEGER PRIMARY KEY,
    txn_header_id INTEGER REFERENCES txn_header(id),
    acme_specific_field TEXT
);
```

### Level 2: Proposed Extensions

**Community-reviewed extensions with broader applicability.**

1. **Submit RFC**: Open issue with `[RFC]` prefix
2. **Required sections**:
   - Problem statement
   - Proposed solution
   - Use cases (minimum 2 different platforms)
   - Schema changes
   - Example data
3. **Review period**: 60 days minimum
4. **Namespace**: `ext.name.TYPE` (assigned after approval)

### Level 3: Standard Types

**Proven extensions promoted to core specification.**

Requirements:
- Active use by 3+ implementations
- 6+ months in production
- No unresolved issues
- Full documentation
- Test coverage

Process:
1. Nominate via issue
2. 90-day review period
3. Consensus approval
4. Promotion to UPPERCASE standard type

---

## Pull Request Guidelines

### Before Submitting

- [ ] Search existing issues/PRs for duplicates
- [ ] For spec changes, ensure discussion has occurred
- [ ] Run any applicable tests
- [ ] Update documentation

### PR Contents

**Title**: Clear, descriptive (e.g., "Add INVEST_SPINOFF transaction type")

**Description**:
```markdown
## Summary
Brief description of changes

## Motivation
Why is this change needed?

## Changes
- List of changes
- In bullet points

## Testing
How was this tested?

## Checklist
- [ ] Spec updated
- [ ] Schema updated
- [ ] Mappings updated
- [ ] Tests pass
```

### Review Process

1. Automated checks must pass
2. At least one maintainer review
3. Address feedback
4. Squash commits if requested
5. Maintainer merges

---

## Style Guidelines

### Specification Documents

- Use Markdown
- One sentence per line (easier diffs)
- Code blocks for SQL, JSON, examples
- Tables for mappings and comparisons

### SQL Schema

```sql
-- Table names: snake_case
CREATE TABLE transaction_type (
    -- Columns: snake_case
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    
    -- Foreign keys at end
    parent_id INTEGER REFERENCES parent_table(id),
    
    -- Metadata columns last
    source_id TEXT,
    source_raw TEXT
);

-- Indexes named: idx_table_column
CREATE INDEX idx_txn_header_date ON txn_header(txn_date);
```

### Type Names

| Type | Convention | Example |
|------|------------|---------|
| Standard | UPPERCASE | `INVOICE`, `JOURNAL` |
| Proposed Extension | ext.name.TYPE | `ext.nonprofit.GRANT` |
| Vendor | vendor.company.TYPE | `vendor.quickbooks.MEMORIZED` |

### Documentation

- Use present tense ("Adds feature" not "Added feature")
- Start descriptions with capital letter
- No period at end of bullet points
- Period at end of complete sentences

---

## Recognition

Contributors are recognized in:

- [CONTRIBUTORS.md](CONTRIBUTORS.md) - All contributors
- Release notes - Significant contributions
- README acknowledgments - Major features

---

## Questions?

- **General questions**: [Discussions](../../discussions)
- **Specification questions**: Open an issue with `[Question]` tag
- **Tool support**: Open an issue in the tool's repository

---

Thank you for contributing to OAIF! Your efforts help free accounting data for everyone. 🎉
