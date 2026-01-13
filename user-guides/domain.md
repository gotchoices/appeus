# Domain Contract Human User Guide

This folder contains shared specifications about the app’s “domain” — the data and behavior the app depends on, regardless of whether the app is “client/server” or not.  This means all app targets (UI/UX) need to honor the common domain specs.

## What to do in this folder

- Create specification files describing how data is managed, stored, changed etc.
- Without these specs, the agent will need to infer everything from stories alone
- If you’re unsure what the domain should should contain, prompt the agent to analyze target stories (`design/stories/<target>/`) and specs (`design/specs/<target>/`) to help you infer what the data structures might need to contain.  Then review them and and analyze how to make the data model robust so it will handle all your intended use cases.
- When generation is blocked by missing domain details
  - Consider improving target stories
  - Update these specs with missing details
  - Regenerate the affected slice(s).

Common domain contract topics (create what your project needs):
- **Schema**: entities/structures and relationships
- **Operations**: procedures/operations the UI relies on (queries, commands, calculations)
- **Rules / invariants**: validation, semantics, permissions, constraints
- **Interfaces**: external systems, storage backends, sync model, import/export

Typical file names (optional; use what fits your project):
- `schema.md`
- `ops.md` (or `operations.md`, or `api.md` if that’s the language your project uses)
- `rules.md`
- `interfaces.md`

Notes:
- The domain contract is **shared** across targets (mobile/web/desktop) and should remain compatible as new targets are added.
 - Additive changes are preferred where possible.  If you make breaking changes, make sure the agent regenerates.
 - For very complex domains, you may create sub-folders under domain by topic, each containing multiple files.

## Examples

These are examples of the *kind* of information you might write. Use your own domain language and keep it human-readable.

### Schema (what data exists, how it relates, where it lives)

Your `schema.md` can be:
- **SQL-oriented** (DDL schema)
- **NoSQL / local-storage oriented** (document structure / JSON shape)
- **Pure markdown** describing the data groupings the UI needs (lists/records/values), even if you haven’t decided storage yet

Pick whichever is most concrete for your project right now.

#### Example: SQL schema (SQLite/Postgres style)

```sql
-- Accounts and transactions (minimal example)
CREATE TABLE accounts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  currency_code TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL REFERENCES accounts(id),
  category_id TEXT NULL REFERENCES categories(id),
  occurred_at TEXT NOT NULL,
  amount_cents INTEGER NOT NULL,
  merchant_name TEXT NOT NULL,
  notes TEXT NULL
);

CREATE INDEX idx_transactions_account_date
  ON transactions(account_id, occurred_at DESC);
```

#### Example: local storage / NoSQL document shapes (JSON-oriented)

```json
{
  "accounts": [
    { "id": "acc_1", "name": "Checking", "currency": "USD" }
  ],
  "categories": [
    { "id": "cat_food", "name": "Food" }
  ],
  "transactions": [
    {
      "id": "tx_1",
      "accountId": "acc_1",
      "categoryId": "cat_food",
      "occurredAt": "2026-01-01T09:30:00Z",
      "amountCents": -1299,
      "merchantName": "Coffee Shop",
      "notes": "Morning coffee"
    }
  ]
}
```

#### Example: “what the UI needs” (screen-driven schema, storage-agnostic)

```markdown
## Transaction list screen needs

The list is a collection of TransactionSummary records:

TransactionSummary:
- id (string)
- occurredAt (datetime)
- merchantName (string)
- amount (money)
- categoryName (string | null)

## Transaction detail screen needs

TransactionDetail:
- id
- occurredAt
- amount
- merchantName
- notes (string | null)
- account: { id, name }
- category: { id, name } | null

## Relationships (conceptual)

- Transaction belongs to exactly one Account
- Transaction may have one Category
```

### Operations (what the UI needs to do)

In `ops.md` (or `operations.md` / `api.md`), describe operations the UI relies on. Keep it focused on outcomes, not implementation.

```markdown
## Operation: Transactions.list

**Purpose:** Populate the transaction list screen with filters applied.

**Inputs**
- accountId (required)
- dateRange (optional)
- categoryId (optional)
- searchText (optional)

**Outputs**
- ordered list of Transaction summaries
- totalCount (for “showing X of Y”)

**Notes**
- sorting: newest first
- paging: the UI needs “load more”
```

### Rules / invariants (constraints and semantics)

In `rules.md`, capture constraints the UI must honor and what errors should mean to the user.

```markdown
## Rule: Amount must be valid

- amount must be > 0 for income and spend transactions
- the UI should show: “Enter an amount greater than 0”

## Rule: A transaction must belong to an account

- accountId is required
- if an account is deleted, its transactions are either reassigned or archived (decide which)

## Permission rule (if applicable)

- a “viewer” can see transactions but cannot edit or delete
```

### Interfaces (external systems + storage/sync model)

In `interfaces.md`, describe what your app integrates with and the expectations around storage and syncing.

```markdown
## Storage model

- Source of truth: local database on device
- Sync: optional cloud backup when signed in
- Offline: app must work fully offline; sync retries in background

## REST client/server API (example)

If you have a backend, describe the API at the “contract” level: resources, auth expectations, and shapes.

Base URL: `https://api.example.com`

Auth:
- mobile/web use a bearer token after login
- token refresh rules (if any)

Endpoints:

### GET /v1/transactions

Inputs (query):
- accountId (required)
- cursor (optional)

Output:
- list of TransactionSummary
- nextCursor (optional)

Errors:
- 401 if token invalid/expired
- 403 if account not accessible

### POST /v1/transactions

Input:
- TransactionCreate

Output:
- created TransactionDetail

## Internal data interface boundary (example)

Even if you have a backend, it helps to describe the app’s internal “data layer boundary” so screens stay simple.

Screens/pages should call a stable internal interface like:
- `Transactions.list(filters)`
- `Transactions.get(id)`
- `Transactions.create(input)`

Notes:
- screens should not know if data came from mock JSON, local DB, or network
- screens should not accept a `variant` parameter; variant is a mock-only side-channel

## Peer-to-peer / multi-device sync (example)

If devices talk to each other or sync without a central server, capture the model and conflict rules.

Transport:
- local network discovery (same Wi‑Fi) or “invite code”

Data ownership:
- each device owns its own transactions
- shared data: categories can be shared across a group

Sync model:
- append-only event log per device
- reconcile by timestamp + deviceId

Conflicts:
- edits to the same transaction: last-write-wins OR “manual merge” prompt (choose one)

## External interface: Bank import (example)

- user can import a CSV from their bank
- required columns: date, description, amount
- duplicates: detect by (date, amount, merchantName) within 30 days
```

Other interface use cases you might document here:
- OAuth login (Google/Apple) and what user identity means in your domain
- Push notifications (what events trigger them, what data must be present)
- Payments/subscriptions (what “active subscription” means, receipt validation expectations)
- File import/export (what formats, what fields are required)

## Helpful links

- `appeus/docs/DESIGN.md` (domain contract principle + phases)
- `appeus/docs/GENERATION.md` (how domain specs feed staleness and generation)


