
---

# FILE 2 — `docs/architecture.md`

This file explains **how the components communicate**.

```markdown
# FinRisk AI — Architecture

## 1. Architecture Type

FinRisk AI uses a modular monolithic architecture.

The application consists of:

- Frontend application
- FastAPI backend
- PostgreSQL database
- Redis
- Celery workers
- ML modules
- Document processing pipeline
- AI/RAG pipeline

---

## 2. Component Architecture

```text
                         FINRISK AI
                             │
              ┌──────────────┴──────────────┐
              │                             │
          Frontend                       Backend
                                             │
       ┌─────────────────────────────────────┼───────────────────────┐
       │              │             │        │       │       │       │
       ▼              ▼             ▼        ▼       ▼       ▼       ▼
     Auth        Customers     Transactions Fraud   Risk   Docs    AI
       │              │             │        │       │       │       │
       └──────────────┴─────────────┴────────┴───────┴───────┴───────┘
                                             │
                                      Service Layer
                                             │
                                      Repository Layer
                                             │
                                        PostgreSQL
