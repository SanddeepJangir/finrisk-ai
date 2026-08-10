# FinRisk AI — Technology Decisions

## Backend

### FastAPI

Chosen because:

- High performance
- Async support
- Automatic OpenAPI documentation
- Pydantic validation
- Excellent Python ML integration

---

## Database

### PostgreSQL

Chosen because:

- Strong relational capabilities
- ACID transactions
- Complex analytical queries
- Excellent indexing
- JSON support
- pgvector integration

---

## Vector Database

### pgvector

Chosen initially instead of a separate vector database because:

- Reduces infrastructure complexity
- Keeps structured and vector data together
- PostgreSQL already handles application data
- Suitable for the project's initial scale

A dedicated vector database can be introduced later if scale requires it.

---

## Cache / Queue

### Redis

Used for:

- Caching
- Background task queue
- Rate limiting
- Temporary state

---

## Background Processing

### Celery

Used for:

- Large file processing
- Document processing
- Embeddings
- Batch ML jobs

---

## ML

### Scikit-learn

Used for:

- Baseline models
- Preprocessing
- Classical ML
- Anomaly detection

### XGBoost / LightGBM

Used for:

- Fraud prediction
- Risk prediction

---

## Deep Learning

### PyTorch

Used only when deep learning provides measurable benefit.

Potential use:

- Autoencoder-based anomaly detection
- Document models
- Advanced behavioral modeling

---

## Frontend

The initial implementation will use a modern web frontend with reusable components and charting support.

The frontend communicates with the backend exclusively through APIs.

---

## Containerization

### Docker

Used to ensure consistent development and deployment environments.

---

## Cloud

AWS is the initial deployment target.

The architecture should remain cloud-portable.

---

## Architecture Decision

The project intentionally avoids microservices during the initial development phase.

A modular monolith reduces:

- Deployment complexity
- Debugging complexity
- Infrastructure cost
- Development overhead

Services can be extracted later when required.
