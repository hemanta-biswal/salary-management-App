import os

# If DATABASE_URL is set (e.g. from Render or Supabase), we use PostgreSQL
DATABASE_URL = os.getenv("DATABASE_URL", "").strip()

# Render/Supabase sometimes provide postgres:// which psycopg2 prefers as postgresql://
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

IS_POSTGRES = bool(DATABASE_URL and ("postgres" in DATABASE_URL or "supabase" in DATABASE_URL))

# Local MySQL Database Configuration (Fallback when running locally without Supabase)
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", "NewPassword123"),
    "port": int(os.getenv("DB_PORT", 3306)),
    "database": os.getenv("DB_NAME", "salary_system_db"),
}
