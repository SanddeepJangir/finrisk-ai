# FinRisk AI — Entity Relationship Diagram

## Core Relationships

```text
organizations
      │
      ├────────────── users
      │                  │
      │                  └──── user_roles ──── roles
      │
      ├────────────── customers
      │                  │
      │                  └──── accounts
      │                           │
      │                           └──── transactions
      │                                      │
      │                    ┌─────────────────┼────────────────┐
      │                    │                 │                │
      │                 merchant           device       fraud_predictions
      │
      ├────────────── risk_scores
      │
      ├────────────── customer_features
      │
      ├────────────── documents
      │                  │
      │                  └──── document_chunks
      │
      ├────────────── alerts
      │
      ├────────────── model_versions
      │
      └────────────── audit_logs
