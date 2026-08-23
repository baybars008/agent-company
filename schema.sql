-- agent-company backend schema
-- PostgreSQL 15+

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS companies (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name        TEXT NOT NULL,
  slug        TEXT UNIQUE NOT NULL,
  settings    JSONB NOT NULL DEFAULT '{}',
  owner_user_id TEXT,
  onboarded   BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS company_members (
  company_id  TEXT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  user_id     TEXT NOT NULL,
  role        TEXT NOT NULL DEFAULT 'owner',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (company_id, user_id)
);

CREATE TABLE IF NOT EXISTS teams (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name        TEXT NOT NULL,
  slug        TEXT,
  wing_slug   TEXT,
  company_id  TEXT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS agents (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name        TEXT NOT NULL,
  role_id     TEXT,
  team_id     TEXT REFERENCES teams(id) ON DELETE SET NULL,
  company_id  TEXT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  status      TEXT NOT NULL DEFAULT 'idle',
  settings    JSONB NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- PostgREST anonymous role (no RLS — API gateway handles auth)
DO $$ BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN;
  END IF;
END $$;

GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON companies, company_members, teams, agents TO anon;

-- seed: default org (overwrite with your own)
INSERT INTO companies (id, name, slug, onboarded)
VALUES ('default-org', 'My Company', 'my-company', true)
ON CONFLICT DO NOTHING;

INSERT INTO company_members (company_id, user_id, role)
VALUES ('default-org', 'local-user-id', 'owner')
ON CONFLICT DO NOTHING;

INSERT INTO teams (id, name, slug, company_id)
VALUES ('default-team', 'Default Team', 'default-team', 'default-org')
ON CONFLICT DO NOTHING;
