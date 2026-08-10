
---

# FILE 3 — `database/schema.sql`

This is the **actual database**.

Use this as your initial schema.

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS vector;


-- =========================================================
-- ORGANIZATIONS
-- =========================================================

CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(150) NOT NULL,

    slug VARCHAR(100) NOT NULL UNIQUE,

    email VARCHAR(255),

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE', 'SUSPENDED', 'INACTIVE')),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- ROLES
-- =========================================================

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(50) NOT NULL UNIQUE,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- =========================================================
-- USERS
-- =========================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    email VARCHAR(255) NOT NULL,

    password_hash TEXT NOT NULL,

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    last_login_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_users_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_users_org_email
        UNIQUE (organization_id, email)
);


CREATE INDEX idx_users_organization_id
ON users(organization_id);


-- =========================================================
-- USER ROLES
-- =========================================================

CREATE TABLE user_roles (
    user_id UUID NOT NULL,

    role_id UUID NOT NULL,

    PRIMARY KEY (user_id, role_id),

    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE
);


-- =========================================================
-- CUSTOMERS
-- =========================================================

CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    external_customer_id VARCHAR(100),

    first_name VARCHAR(100),

    last_name VARCHAR(100),

    email VARCHAR(255),

    phone VARCHAR(30),

    date_of_birth DATE,

    customer_type VARCHAR(30) DEFAULT 'INDIVIDUAL'
        CHECK (
            customer_type IN (
                'INDIVIDUAL',
                'BUSINESS'
            )
        ),

    annual_income NUMERIC(18,2),

    credit_score INTEGER
        CHECK (
            credit_score IS NULL
            OR credit_score BETWEEN 300 AND 900
        ),

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE'
        CHECK (
            status IN (
                'ACTIVE',
                'INACTIVE',
                'BLOCKED'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_customers_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT
);


CREATE INDEX idx_customers_organization_id
ON customers(organization_id);

CREATE INDEX idx_customers_external_id
ON customers(organization_id, external_customer_id);

CREATE INDEX idx_customers_email
ON customers(organization_id, email);


-- =========================================================
-- ACCOUNTS
-- =========================================================

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    customer_id UUID NOT NULL,

    account_number VARCHAR(100) NOT NULL,

    account_type VARCHAR(30) NOT NULL
        CHECK (
            account_type IN (
                'SAVINGS',
                'CURRENT',
                'CREDIT',
                'LOAN'
            )
        ),

    currency CHAR(3) NOT NULL DEFAULT 'INR',

    balance NUMERIC(18,2) NOT NULL DEFAULT 0,

    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE'
        CHECK (
            status IN (
                'ACTIVE',
                'FROZEN',
                'CLOSED'
            )
        ),

    opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_accounts_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_account_number
        UNIQUE (organization_id, account_number)
);


CREATE INDEX idx_accounts_customer_id
ON accounts(customer_id);

CREATE INDEX idx_accounts_organization_id
ON accounts(organization_id);


-- =========================================================
-- MERCHANTS
-- =========================================================

CREATE TABLE merchants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    merchant_code VARCHAR(100),

    merchant_name VARCHAR(200) NOT NULL,

    category VARCHAR(100),

    country VARCHAR(100),

    city VARCHAR(100),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_merchants_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT
);


CREATE INDEX idx_merchants_organization_id
ON merchants(organization_id);


-- =========================================================
-- DEVICES
-- =========================================================

CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    device_fingerprint VARCHAR(255) NOT NULL,

    device_type VARCHAR(50),

    operating_system VARCHAR(100),

    first_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    last_seen_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_devices_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_device_fingerprint
        UNIQUE (organization_id, device_fingerprint)
);


-- =========================================================
-- TRANSACTIONS
-- =========================================================

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    external_transaction_id VARCHAR(100) NOT NULL,

    customer_id UUID NOT NULL,

    account_id UUID NOT NULL,

    merchant_id UUID,

    device_id UUID,

    amount NUMERIC(18,2) NOT NULL,

    currency CHAR(3) NOT NULL DEFAULT 'INR',

    transaction_type VARCHAR(40) NOT NULL,

    status VARCHAR(30) NOT NULL DEFAULT 'COMPLETED'
        CHECK (
            status IN (
                'PENDING',
                'COMPLETED',
                'FAILED',
                'REVERSED',
                'BLOCKED'
            )
        ),

    country VARCHAR(100),

    city VARCHAR(100),

    ip_address INET,

    transaction_time TIMESTAMPTZ NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_transactions_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_transactions_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id)
        REFERENCES accounts(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_transactions_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES merchants(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_transactions_device
        FOREIGN KEY (device_id)
        REFERENCES devices(id)
        ON DELETE SET NULL,

    CONSTRAINT uq_external_transaction
        UNIQUE (
            organization_id,
            external_transaction_id
        )
);


CREATE INDEX idx_transactions_organization_id
ON transactions(organization_id);

CREATE INDEX idx_transactions_customer_id
ON transactions(customer_id);

CREATE INDEX idx_transactions_account_id
ON transactions(account_id);

CREATE INDEX idx_transactions_time
ON transactions(transaction_time);

CREATE INDEX idx_transactions_customer_time
ON transactions(customer_id, transaction_time);

CREATE INDEX idx_transactions_status
ON transactions(organization_id, status);


-- =========================================================
-- MODEL VERSIONS
-- =========================================================

CREATE TABLE model_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    model_name VARCHAR(100) NOT NULL,

    version VARCHAR(50) NOT NULL,

    model_type VARCHAR(50),

    framework VARCHAR(50),

    metrics JSONB,

    parameters JSONB,

    artifact_path TEXT,

    status VARCHAR(30) NOT NULL DEFAULT 'TRAINED'
        CHECK (
            status IN (
                'TRAINED',
                'STAGING',
                'PRODUCTION',
                'ARCHIVED'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_model_version
        UNIQUE (model_name, version)
);


-- =========================================================
-- FRAUD PREDICTIONS
-- =========================================================

CREATE TABLE fraud_predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    transaction_id UUID NOT NULL,

    model_version_id UUID NOT NULL,

    fraud_probability NUMERIC(6,5) NOT NULL
        CHECK (
            fraud_probability BETWEEN 0 AND 1
        ),

    risk_score NUMERIC(5,2) NOT NULL
        CHECK (
            risk_score BETWEEN 0 AND 100
        ),

    prediction VARCHAR(30) NOT NULL
        CHECK (
            prediction IN (
                'NORMAL',
                'SUSPICIOUS',
                'FRAUD'
            )
        ),

    explanation JSONB,

    predicted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_fraud_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_fraud_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES transactions(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_fraud_model
        FOREIGN KEY (model_version_id)
        REFERENCES model_versions(id)
        ON DELETE RESTRICT
);


CREATE INDEX idx_fraud_transaction_id
ON fraud_predictions(transaction_id);

CREATE INDEX idx_fraud_organization_prediction
ON fraud_predictions(organization_id, prediction);

CREATE INDEX idx_fraud_risk_score
ON fraud_predictions(organization_id, risk_score);


-- =========================================================
-- RISK SCORES
-- =========================================================

CREATE TABLE risk_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    customer_id UUID NOT NULL,

    model_version_id UUID NOT NULL,

    probability_of_default NUMERIC(6,5)
        CHECK (
            probability_of_default IS NULL
            OR probability_of_default BETWEEN 0 AND 1
        ),

    risk_score NUMERIC(5,2) NOT NULL
        CHECK (
            risk_score BETWEEN 0 AND 100
        ),

    risk_category VARCHAR(20) NOT NULL
        CHECK (
            risk_category IN (
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    explanation JSONB,

    predicted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_risk_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_risk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_risk_model
        FOREIGN KEY (model_version_id)
        REFERENCES model_versions(id)
        ON DELETE RESTRICT
);


CREATE INDEX idx_risk_customer
ON risk_scores(customer_id);

CREATE INDEX idx_risk_category
ON risk_scores(organization_id, risk_category);

CREATE INDEX idx_risk_score
ON risk_scores(organization_id, risk_score);


-- =========================================================
-- CUSTOMER FEATURES
-- =========================================================

CREATE TABLE customer_features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    customer_id UUID NOT NULL,

    feature_date DATE NOT NULL,

    transaction_count INTEGER DEFAULT 0,

    total_transaction_amount NUMERIC(18,2) DEFAULT 0,

    average_transaction_amount NUMERIC(18,2) DEFAULT 0,

    max_transaction_amount NUMERIC(18,2) DEFAULT 0,

    failed_transaction_count INTEGER DEFAULT 0,

    unique_devices INTEGER DEFAULT 0,

    unique_locations INTEGER DEFAULT 0,

    late_payment_count INTEGER DEFAULT 0,

    debt_to_income_ratio NUMERIC(8,4),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_features_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_features_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_customer_feature_date
        UNIQUE (customer_id, feature_date)
);


CREATE INDEX idx_customer_features_customer
ON customer_features(customer_id, feature_date);


-- =========================================================
-- ALERTS
-- =========================================================

CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    customer_id UUID,

    transaction_id UUID,

    alert_type VARCHAR(50) NOT NULL,

    severity VARCHAR(20) NOT NULL
        CHECK (
            severity IN (
                'LOW',
                'MEDIUM',
                'HIGH',
                'CRITICAL'
            )
        ),

    title VARCHAR(255) NOT NULL,

    description TEXT,

    status VARCHAR(30) NOT NULL DEFAULT 'OPEN'
        CHECK (
            status IN (
                'OPEN',
                'ACKNOWLEDGED',
                'RESOLVED',
                'DISMISSED'
            )
        ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    resolved_at TIMESTAMPTZ,

    CONSTRAINT fk_alert_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_alert_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_alert_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES transactions(id)
        ON DELETE SET NULL
);


CREATE INDEX idx_alerts_organization_status
ON alerts(organization_id, status);

CREATE INDEX idx_alerts_severity
ON alerts(organization_id, severity);


-- =========================================================
-- DOCUMENTS
-- =========================================================

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL,

    uploaded_by UUID NOT NULL,

    file_name VARCHAR(255) NOT NULL,

    file_type VARCHAR(100) NOT NULL,

    file_size BIGINT,

    storage_path TEXT NOT NULL,

    document_type VARCHAR(50),

    processing_status VARCHAR(30) NOT NULL DEFAULT 'UPLOADED'
        CHECK (
            processing_status IN (
                'UPLOADED',
                'PROCESSING',
                'COMPLETED',
                'FAILED'
            )
        ),

    processing_error TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    processed_at TIMESTAMPTZ,

    CONSTRAINT fk_documents_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_documents_user
        FOREIGN KEY (uploaded_by)
        REFERENCES users(id)
        ON DELETE RESTRICT
);


CREATE INDEX idx_documents_organization
ON documents(organization_id);

CREATE INDEX idx_documents_status
ON documents(organization_id, processing_status);


-- =========================================================
-- DOCUMENT CHUNKS
-- =========================================================

CREATE TABLE document_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    document_id UUID NOT NULL,

    chunk_index INTEGER NOT NULL,

    page_number INTEGER,

    content TEXT NOT NULL,

    embedding VECTOR(1536),

    metadata JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_chunks_document
        FOREIGN KEY (document_id)
        REFERENCES documents(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_document_chunk
        UNIQUE (document_id, chunk_index)
);


CREATE INDEX idx_document_chunks_document
ON document_chunks(document_id);


-- =========================================================
-- AUDIT LOGS
-- =========================================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID,

    user_id UUID,

    action VARCHAR(100) NOT NULL,

    entity_type VARCHAR(100),

    entity_id UUID,

    ip_address INET,

    metadata JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_audit_organization
        FOREIGN KEY (organization_id)
        REFERENCES organizations(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
);


CREATE INDEX idx_audit_organization
ON audit_logs(organization_id, created_at);

CREATE INDEX idx_audit_user
ON audit_logs(user_id, created_at);

CREATE INDEX idx_audit_entity
ON audit_logs(entity_type, entity_id);
