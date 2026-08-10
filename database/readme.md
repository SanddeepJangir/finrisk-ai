# Database

FinRisk AI uses PostgreSQL.

## Files

### schema.sql

Contains:

- Extensions
- Tables
- Constraints
- Foreign keys
- Indexes

### seed.sql

Contains development reference data.

---

## Database Extensions

The project uses:

- pgcrypto
- pgvector

---

## Local Database

The database will be started through Docker Compose.

Example:

```bash
docker compose up -d postgres
