# FinRisk AI — Security Architecture

## 1. Authentication

JWT-based authentication will be used.

Flow:

```text
Login
 ↓
Verify credentials
 ↓
Generate access token
 ↓
Client
 ↓
Authorization header
 ↓
API
