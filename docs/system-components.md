# FinRisk AI — System Components

## 1. Frontend

Responsibilities:

- Login
- Dashboard
- Data upload
- Transaction search
- Risk visualization
- Fraud alerts
- AI analyst

---

## 2. API Server

Technology:

FastAPI

Responsibilities:

- REST APIs
- Authentication
- Authorization
- Validation
- Business orchestration

---

## 3. PostgreSQL

Responsibilities:

- Persistent application data
- Transaction data
- Customer data
- Risk results
- Fraud results
- Audit logs

---

## 4. Redis

Responsibilities:

- Celery broker
- Cache
- Rate limiting
- Temporary state

---

## 5. Celery Workers

Responsibilities:

- CSV processing
- PDF processing
- OCR
- Embedding generation
- Batch ML inference

---

## 6. ML Engine

Responsibilities:

- Fraud detection
- Anomaly detection
- Customer risk prediction
- Feature engineering
- Model inference
- Explainability

---

## 7. Document Intelligence

Pipeline:

```text
Upload
 ↓
File validation
 ↓
Text extraction
 ↓
OCR if required
 ↓
Structure extraction
 ↓
Chunking
 ↓
Embedding
 ↓
pgvector
