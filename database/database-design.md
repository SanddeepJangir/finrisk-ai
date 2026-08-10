# FinRisk AI — Database Design

## 1. Database Technology

FinRisk AI uses PostgreSQL as the primary relational database.

PostgreSQL is responsible for storing:

- User information
- Organizations
- Customers
- Accounts
- Transactions
- Fraud predictions
- Risk predictions
- Alerts
- Financial documents
- Document metadata
- Model versions
- Audit logs

PostgreSQL with pgvector will also be used for document embeddings.

---

# 2. Database Design Principles

The database follows these principles:

1. Use normalized relational tables for transactional data.
2. Use UUIDs for public entity identifiers.
3. Use foreign keys to maintain referential integrity.
4. Use indexes on frequently queried columns.
5. Store timestamps using TIMESTAMPTZ.
6. Store monetary values using NUMERIC instead of FLOAT.
7. Store passwords only as secure password hashes.
8. Maintain organization-level data isolation.
9. Store uploaded files in object storage and only store metadata in PostgreSQL.
10. Store model predictions separately from model definitions.
11. Maintain audit records for security-sensitive operations.

---

# 3. Entity List

The initial database contains the following entities:

## Organization and Access

- organizations
- roles
- users
- user_roles

## Customer and Financial Data

- customers
- accounts
- merchants
- devices
- transactions

## AI/ML

- fraud_predictions
- risk_scores
- customer_features
- model_versions

## Alerts

- alerts

## Documents

- documents
- document_chunks

## Security and Auditing

- audit_logs

---

# 4. Organization Model

An organization represents a company or financial institution using FinRisk AI.

Every organization-owned entity contains an organization_id.

This provides tenant isolation.

Example:

Organization A must never be able to access transactions belonging to Organization B.

---

# 5. User Model

A user belongs to an organization.

Users can have different roles:

- ADMIN
- RISK_ANALYST
- FINANCIAL_ANALYST
- VIEWER

Authentication information is stored in the users table.

Passwords are stored only as password hashes.

---

# 6. Customer Model

A customer represents an individual or business whose financial behavior is analyzed.

A customer belongs to an organization.

A customer can have multiple accounts.

A customer can have multiple transactions.

A customer can have multiple risk predictions over time.

---

# 7. Account Model

An account represents a financial account belonging to a customer.

Examples:

- Savings
- Current
- Credit
- Loan

A customer can own multiple accounts.

---

# 8. Transaction Model

Transactions represent financial activities.

Each transaction contains:

- Customer
- Account
- Merchant
- Device
- Amount
- Currency
- Transaction type
- Location
- Timestamp
- Status

Transactions are the primary input for fraud and behavioral analysis.

---

# 9. Fraud Prediction Model

A fraud prediction belongs to a transaction.

It stores:

- Model version
- Fraud probability
- Risk score
- Prediction
- Explanation
- Prediction timestamp

A transaction can have multiple predictions because models may change over time.

---

# 10. Risk Score Model

Risk scores represent customer-level financial risk.

A customer can have multiple risk predictions over time.

Each prediction stores:

- Model version
- Probability
- Risk category
- Score
- Explanation

---

# 11. Model Version Model

Every production ML model must have a version.

Example:

fraud_detection_v1.0

The model version allows predictions to be traced back to the exact model that generated them.

---

# 12. Document Model

Documents represent uploaded financial files.

The database stores metadata such as:

- File name
- File type
- Object storage path
- Processing status
- Upload user
- Organization
- File size

The actual file is stored in object storage.

---

# 13. Document Chunk Model

Documents are divided into chunks for RAG.

Each chunk stores:

- Document ID
- Chunk text
- Chunk index
- Page number
- Embedding

Embeddings are stored using pgvector.

---

# 14. Alert Model

Alerts represent suspicious or important financial events.

Examples:

- High-risk transaction
- Fraud detected
- Customer risk increased
- Abnormal transaction behavior

Alerts belong to an organization and may reference a transaction or customer.

---

# 15. Audit Log Model

Audit logs record security-sensitive and important application activities.

Examples:

- LOGIN
- LOGOUT
- FILE_UPLOAD
- TRANSACTION_VIEW
- RISK_PREDICTION
- FRAUD_PREDICTION
- USER_CREATED
- ROLE_CHANGED

---

# 16. Important Constraints

The database should enforce:

- Unique organization email/domain where applicable
- Unique user email within organization
- Unique account number
- Unique transaction ID within organization
- Valid transaction status
- Positive monetary values where applicable
- Valid risk categories
- Valid prediction probabilities between 0 and 1

---

# 17. Monetary Data

Financial amounts use:

NUMERIC(18,2)

instead of FLOAT.

Reason:

Floating-point values can introduce precision problems in financial calculations.

---

# 18. Timestamp Strategy

All database timestamps use:

TIMESTAMPTZ

The database stores timezone-aware timestamps.

Application-level display can convert timestamps to the user's timezone.

---

# 19. Deletion Strategy

Financial transaction records should generally not be physically deleted.

Important records should be retained for auditability.

Where appropriate, soft deletion can be implemented using:

deleted_at
