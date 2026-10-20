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

-- Organisasi.
-- id = primary key otomatis dari database (SERIAL).
-- name dipakai sebagai kunci route halaman organisasi (unik).
CREATE TABLE IF NOT EXISTS organizations (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  instansi TEXT,
  category TEXT NOT NULL,
  logo_url TEXT,
  address TEXT,
  description TEXT,
  contacts TEXT NOT NULL DEFAULT '{}', -- JSON: {"Instagram":"@akun", ...}
  created_by INT REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_organizations_name ON organizations (name);

-- Keanggotaan user di sebuah organisasi + jabatan/role.
-- Pembuat organisasi otomatis tercatat sebagai 'Kepala Organisasi'.
CREATE TABLE IF NOT EXISTS organization_members (
  org_id INT NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'Anggota',
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (org_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_org_members_user ON organization_members (user_id);
