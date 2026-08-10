# FinRisk AI — Data Flow

## 1. Transaction Upload

```text
CSV File
   ↓
Frontend
   ↓
POST /transactions/upload
   ↓
FastAPI
   ↓
File Validation
   ↓
Create Processing Job
   ↓
Redis
   ↓
Celery Worker
   ↓
CSV Parsing
   ↓
Data Cleaning
   ↓
Feature Engineering
   ↓
PostgreSQL
   ↓
Fraud Detection
   ↓
Risk Score
   ↓
Alerts
