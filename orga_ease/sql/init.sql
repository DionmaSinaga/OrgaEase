-- OrgaEase: skema awal database orgaease_app_db
-- Cara pakai: jalankan file ini di extension PostgreSQL VS Code Anda
-- (klik kanan database orgaease_app_db -> New Query -> paste & Run),
-- atau via terminal: psql -U postgres -d orgaease_app_db -f sql/init.sql

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
