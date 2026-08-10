# FinRisk AI — Deployment Architecture

## Development

```text
Developer Machine
       │
       ▼
Docker Compose
       │
 ┌─────┼──────────────┐
 ▼     ▼              ▼
API  PostgreSQL      Redis
 │
 ▼
Celery Worker
