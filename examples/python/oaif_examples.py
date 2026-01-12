#!/usr/bin/env python3
"""
OAIF Python Examples
====================

This module demonstrates how to read and write OAIF files using Python.
"""

import sqlite3
import json
from datetime import datetime, date
from decimal import Decimal
from pathlib import Path


# =============================================================================
# CONSTANTS
# =============================================================================

OAIF_APPLICATION_ID = 0x4F414946  # "OAIF" in ASCII
OAIF_VERSION = "1.0"


# =============================================================================
# READING OAIF FILES
# =============================================================================

def is_valid_oaif(filepath: str) -> bool:
    """Check if a file is a valid OAIF database."""
    try:
        conn = sqlite3.connect(f'file:{filepath}?mode=ro', uri=True)
        app_id = conn.execute('PRAGMA application_id').fetchone()[0]
        conn.close()
        return app_id == OAIF_APPLICATION_ID
    except Exception:
        return False


def open_oaif(filepath: str, readonly: bool = True) -> sqlite3.Connection:
    """Open an OAIF file and return a connection.
    
    Args:
        filepath: Path to the .oaif file
        readonly: If True, open in read-only mode (default)
    
    Returns:
        sqlite3.Connection object
    
    Raises:
        ValueError: If file is not a valid OAIF database
    """
    mode = '?mode=ro' if readonly else ''
    conn = sqlite3.connect(f'file:{filepath}{mode}', uri=True)
    conn.row_factory = sqlite3.Row  # Enable column access by name
    
    # Verify OAIF format
    app_id = conn.execute('PRAGMA application_id').fetchone()[0]
    if app_id != OAIF_APPLICATION_ID:
        conn.close()
        raise ValueError(f"Not a valid OAIF file: {filepath}")
    
    return conn


def get_metadata(conn: sqlite3.Connection) -> dict:
    """Get all metadata from an OAIF file."""
    return dict(conn.execute('SELECT key, value FROM oaif_metadata').fetchall())


def get_type_lookup(conn: sqlite3.Connection, table: str) -> dict:
    """Build a type lookup dictionary from a reference table.
    
    Args:
        conn: Database connection
        table: Name of reference table (e.g., 'transaction_type')
    
    Returns:
        Dictionary mapping ID -> name
    """
    return dict(conn.execute(f'SELECT id, name FROM {table}').fetchall())


# =============================================================================
# WRITING OAIF FILES
# =============================================================================

def create_oaif(filepath: str, company_name: str, base_currency: str = 'USD',
                source_system: str = 'Unknown') -> sqlite3.Connection:
    """Create a new OAIF file with the standard schema.
    
    Args:
        filepath: Path for the new .oaif file
        company_name: Name of the company
        base_currency: ISO 4217 currency code (default: USD)
        source_system: Name of source system
    
    Returns:
        sqlite3.Connection object
    """
    conn = sqlite3.connect(filepath)
    
    # Set OAIF identification
    conn.execute(f'PRAGMA application_id = {OAIF_APPLICATION_ID}')
    conn.execute('PRAGMA user_version = 1')
    conn.execute('PRAGMA foreign_keys = ON')
    conn.execute("PRAGMA encoding = 'UTF-8'")
    
    # Load and execute schema
    schema_path = Path(__file__).parent.parent.parent / 'schema' / 'oaif_schema.sql'
    if schema_path.exists():
        with open(schema_path) as f:
            # Skip PRAGMA statements (already set) and execute rest
            schema = f.read()
            # Remove PRAGMA lines to avoid conflicts
            lines = [l for l in schema.split('\n') if not l.strip().startswith('PRAGMA')]
            conn.executescript('\n'.join(lines))
    else:
        raise FileNotFoundError(f"Schema not found: {schema_path}")
    
    # Add required metadata
    now = datetime.utcnow().isoformat() + 'Z'
    conn.execute('''
        INSERT INTO oaif_metadata (key, value) VALUES
        ('oaif_version', ?),
        ('oaif_min_reader', ?),
        ('created_at', ?),
        ('created_by', ?),
        ('source_system', ?),
        ('company_name', ?),
        ('base_currency', ?)
    ''', (OAIF_VERSION, OAIF_VERSION, now, 'oaif-python-example', 
          source_system, company_name, base_currency))
    
    conn.commit()
    return conn


# =============================================================================
# EXAMPLE QUERIES
# =============================================================================

def print_chart_of_accounts(conn: sqlite3.Connection):
    """Print the chart of accounts."""
    print("\n=== Chart of Accounts ===")
    for row in conn.execute('''
        SELECT a.code, a.full_name, at.name as type, a.balance
        FROM account a
        JOIN account_type at ON a.account_type_id = at.id
        WHERE a.is_active = 1
        ORDER BY a.code
    '''):
        balance = f"${row['balance']:,.2f}" if row['balance'] else ""
        print(f"  {row['code'] or '':<6} {row['full_name']:<40} {row['type']:<20} {balance}")


def print_customers(conn: sqlite3.Connection):
    """Print customer list with balances."""
    print("\n=== Customers ===")
    for row in conn.execute('''
        SELECT name, email, balance, is_active
        FROM customer
        ORDER BY name
    '''):
        status = "Active" if row['is_active'] else "Inactive"
        balance = f"${row['balance']:,.2f}" if row['balance'] else "$0.00"
        print(f"  {row['name']:<30} {row['email'] or '':<30} {balance:>12} ({status})")


def print_trial_balance(conn: sqlite3.Connection):
    """Print trial balance."""
    print("\n=== Trial Balance ===")
    
    total_debits = 0
    total_credits = 0
    
    for row in conn.execute('SELECT * FROM v_trial_balance WHERE balance != 0'):
        debits = row['debits'] or 0
        credits = row['credits'] or 0
        total_debits += debits
        total_credits += credits
        print(f"  {row['account_name']:<40} Dr: ${debits:>12,.2f}  Cr: ${credits:>12,.2f}")
    
    print(f"  {'─' * 70}")
    print(f"  {'TOTALS':<40} Dr: ${total_debits:>12,.2f}  Cr: ${total_credits:>12,.2f}")
    
    diff = total_debits - total_credits
    if abs(diff) > 0.01:
        print(f"  ⚠️  OUT OF BALANCE BY: ${diff:,.2f}")
    else:
        print(f"  ✓ Books are in balance")


def get_recent_transactions(conn: sqlite3.Connection, limit: int = 10) -> list:
    """Get recent transactions."""
    return conn.execute('''
        SELECT 
            th.txn_date,
            tt.name as txn_type,
            th.doc_number,
            COALESCE(c.name, v.name, e.name) as party,
            th.total_amount,
            th.memo
        FROM txn_header th
        JOIN transaction_type tt ON th.txn_type_id = tt.id
        LEFT JOIN customer c ON th.customer_id = c.id
        LEFT JOIN vendor v ON th.vendor_id = v.id
        LEFT JOIN employee e ON th.employee_id = e.id
        WHERE th.is_voided = 0
        ORDER BY th.txn_date DESC, th.id DESC
        LIMIT ?
    ''', (limit,)).fetchall()


# =============================================================================
# DATA INSERTION HELPERS
# =============================================================================

def add_customer(conn: sqlite3.Connection, name: str, email: str = None,
                 **kwargs) -> int:
    """Add a customer and return the new ID."""
    columns = ['name', 'email'] + list(kwargs.keys())
    values = [name, email] + list(kwargs.values())
    placeholders = ', '.join(['?'] * len(values))
    
    cursor = conn.execute(f'''
        INSERT INTO customer ({', '.join(columns)})
        VALUES ({placeholders})
    ''', values)
    
    return cursor.lastrowid


def add_account(conn: sqlite3.Connection, name: str, account_type: str,
                code: str = None, **kwargs) -> int:
    """Add an account and return the new ID."""
    # Look up account type ID
    type_id = conn.execute(
        'SELECT id FROM account_type WHERE name = ?', (account_type,)
    ).fetchone()
    
    if not type_id:
        raise ValueError(f"Unknown account type: {account_type}")
    
    columns = ['name', 'account_type_id', 'code'] + list(kwargs.keys())
    values = [name, type_id[0], code] + list(kwargs.values())
    placeholders = ', '.join(['?'] * len(values))
    
    cursor = conn.execute(f'''
        INSERT INTO account ({', '.join(columns)})
        VALUES ({placeholders})
    ''', values)
    
    return cursor.lastrowid


def add_journal_entry(conn: sqlite3.Connection, date: str, memo: str,
                      lines: list) -> int:
    """Add a journal entry with multiple lines.
    
    Args:
        conn: Database connection
        date: Transaction date (YYYY-MM-DD)
        memo: Transaction memo
        lines: List of dicts with keys: account_id, amount, description
               (amount positive = debit, negative = credit)
    
    Returns:
        Transaction header ID
    
    Raises:
        ValueError: If lines don't balance to zero
    """
    # Verify balance
    total = sum(line['amount'] for line in lines)
    if abs(total) > 0.005:
        raise ValueError(f"Journal entry doesn't balance: {total}")
    
    # Get JOURNAL type ID
    type_id = conn.execute(
        "SELECT id FROM transaction_type WHERE name = 'JOURNAL'"
    ).fetchone()[0]
    
    # Insert header
    cursor = conn.execute('''
        INSERT INTO txn_header (txn_type_id, txn_date, memo, is_posted)
        VALUES (?, ?, ?, 1)
    ''', (type_id, date, memo))
    
    header_id = cursor.lastrowid
    
    # Insert lines
    for i, line in enumerate(lines, 1):
        conn.execute('''
            INSERT INTO txn_line (txn_header_id, line_number, account_id, 
                                  amount, description)
            VALUES (?, ?, ?, ?, ?)
        ''', (header_id, i, line['account_id'], line['amount'], 
              line.get('description', '')))
    
    return header_id


# =============================================================================
# MAIN EXAMPLE
# =============================================================================

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python oaif_examples.py <file.oaif>")
        print("\nExamples:")
        print("  python oaif_examples.py company.oaif        # Read existing file")
        print("  python oaif_examples.py --create new.oaif   # Create new file")
        sys.exit(1)
    
    if sys.argv[1] == '--create':
        if len(sys.argv) < 3:
            print("Error: Specify output filename")
            sys.exit(1)
        
        filepath = sys.argv[2]
        print(f"Creating new OAIF file: {filepath}")
        
        conn = create_oaif(filepath, "Example Company Inc.", "USD", "oaif-example")
        
        # Add some sample data
        checking_id = add_account(conn, "Checking Account", "BANK", "1000")
        revenue_id = add_account(conn, "Service Revenue", "INCOME", "4000")
        
        customer_id = add_customer(conn, "Acme Corp", "billing@acme.com",
                                   phone="555-1234")
        
        # Add a sample journal entry
        add_journal_entry(conn, "2026-01-12", "Sample transaction", [
            {'account_id': checking_id, 'amount': 1000.00, 
             'description': 'Payment received'},
            {'account_id': revenue_id, 'amount': -1000.00,
             'description': 'Service revenue'},
        ])
        
        conn.commit()
        print(f"Created {filepath} successfully!")
        
    else:
        filepath = sys.argv[1]
        
        if not is_valid_oaif(filepath):
            print(f"Error: {filepath} is not a valid OAIF file")
            sys.exit(1)
        
        conn = open_oaif(filepath)
        metadata = get_metadata(conn)
        
        print(f"\n{'=' * 60}")
        print(f"OAIF File: {filepath}")
        print(f"{'=' * 60}")
        print(f"Company:     {metadata.get('company_name', 'Unknown')}")
        print(f"Source:      {metadata.get('source_system', 'Unknown')}")
        print(f"Created:     {metadata.get('created_at', 'Unknown')}")
        print(f"Currency:    {metadata.get('base_currency', 'USD')}")
        print(f"OAIF Version: {metadata.get('oaif_version', 'Unknown')}")
        
        print_chart_of_accounts(conn)
        print_customers(conn)
        print_trial_balance(conn)
        
        print("\n=== Recent Transactions ===")
        for txn in get_recent_transactions(conn, 10):
            print(f"  {txn['txn_date']} {txn['txn_type']:<15} "
                  f"{txn['doc_number'] or '':<10} {txn['party'] or '':<20} "
                  f"${txn['total_amount'] or 0:>10,.2f}")
        
        conn.close()
