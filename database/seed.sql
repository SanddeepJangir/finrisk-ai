-- =========================================================
-- ROLES
-- =========================================================

INSERT INTO roles (name, description)
VALUES
(
    'ADMIN',
    'Full system access'
),
(
    'RISK_ANALYST',
    'Access to fraud and risk analysis'
),
(
    'FINANCIAL_ANALYST',
    'Access to financial analysis'
),
(
    'VIEWER',
    'Read-only access'
);


-- =========================================================
-- ORGANIZATION
-- =========================================================

INSERT INTO organizations (
    name,
    slug,
    email
)
VALUES (
    'Demo Financial Corp',
    'demo-financial',
    'admin@demo-financial.local'
);


-- =========================================================
-- MODEL VERSIONS
-- =========================================================

INSERT INTO model_versions (
    model_name,
    version,
    model_type,
    framework,
    metrics,
    parameters,
    status
)
VALUES
(
    'fraud_detection',
    '1.0.0',
    'classification',
    'scikit-learn',
    '{"precision": 0.91, "recall": 0.87, "f1": 0.89}',
    '{"algorithm": "IsolationForest"}',
    'PRODUCTION'
),
(
    'customer_risk',
    '1.0.0',
    'classification',
    'XGBoost',
    '{"roc_auc": 0.88, "f1": 0.81}',
    '{"algorithm": "XGBClassifier"}',
    'PRODUCTION'
);
