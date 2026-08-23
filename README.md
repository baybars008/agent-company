# agent-company

AgentSpace desktop app için backend — PostgreSQL + PostgREST.

## Mimari

```
AgentSpace (desktop) → HTTPS → PostgREST → PostgreSQL
```

Supabase yerine kendi sunucunda çalışır. Lokal yük yok.

## Coolify Deploy

### 1. PostgreSQL Servisi

Coolify → New Service → PostgreSQL 16  
Database: `agentcompany`

### 2. Schema Kur

```bash
ssh coolify-new-root
docker exec -i <postgres-container> psql -U agentcompany agentcompany < schema.sql
```

### 3. PostgREST Servisi

Coolify → New Service → Docker Image  
Image: `postgrest/postgrest:v12.2.3`  
Port: `3000`  
Env: `postgrest.env.example` dosyasındaki değerleri doldur

### 4. Domain Bağla

Coolify → PostgREST service → Domain: `api.revoria-limited.xyz`

### 5. AgentSpace Bağla

```bash
AGENTSPACE_APP_SUPABASE_URL=https://api.revoria-limited.xyz ./agentspace
```

## Tablolar

| Tablo | Açıklama |
|-------|---------|
| `companies` | Organizasyonlar |
| `company_members` | Üyelikler |
| `teams` | Takımlar |
| `agents` | Ajan kayıtları |
