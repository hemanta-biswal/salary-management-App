import os
import sys
from config import DB_CONFIG, DATABASE_URL, IS_POSTGRES

# PostgreSQL (Supabase) Connection Wrapper
class PostgresConnectionWrapper:
    def __init__(self, raw_conn):
        self._conn = raw_conn

    def cursor(self, dictionary=True):
        import psycopg2.extras
        if dictionary:
            return self._conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        return self._conn.cursor()

    def commit(self):
        self._conn.commit()

    def rollback(self):
        self._conn.rollback()

    def close(self):
        self._conn.close()

# ----------------- GET DB CONNECTION -----------------
def get_db():
    if IS_POSTGRES:
        import psycopg2
        try:
            raw_conn = psycopg2.connect(DATABASE_URL)
            return PostgresConnectionWrapper(raw_conn)
        except Exception as e:
            print(f"[ERROR] Failed to connect to Supabase PostgreSQL: {e}")
            raise

    # Fallback to MySQL for local development
    import mysql.connector
    try:
        return mysql.connector.connect(
            host=DB_CONFIG["host"],
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
            port=DB_CONFIG["port"],
            database=DB_CONFIG["database"],
        )
    except mysql.connector.Error as err:
        if err.errno in (1045, 1698) and DB_CONFIG["password"] != "":
            try:
                return mysql.connector.connect(
                    host=DB_CONFIG["host"],
                    user=DB_CONFIG["user"],
                    password="",
                    port=DB_CONFIG["port"],
                    database=DB_CONFIG["database"],
                )
            except Exception:
                pass

        if err.errno == 1049 or "1049" in str(err) or "Unknown database" in str(err):
            print(f"[WARN] Database `{DB_CONFIG['database']}` was not found. Initializing now...")
            init_db()
            return mysql.connector.connect(
                host=DB_CONFIG["host"],
                user=DB_CONFIG["user"],
                password=DB_CONFIG["password"],
                port=DB_CONFIG["port"],
                database=DB_CONFIG["database"],
            )
        raise

# ----------------- LOCAL MYSQL HELPERS -----------------
def get_server_connection():
    import mysql.connector
    try:
        return mysql.connector.connect(
            host=DB_CONFIG["host"],
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
            port=DB_CONFIG["port"],
        )
    except mysql.connector.Error as err:
        if err.errno in (1045, 1698) and DB_CONFIG["password"] != "":
            try:
                return mysql.connector.connect(
                    host=DB_CONFIG["host"],
                    user=DB_CONFIG["user"],
                    password="",
                    port=DB_CONFIG["port"],
                )
            except Exception:
                pass
        raise

def create_database_if_not_exists():
    server_conn = get_server_connection()
    cursor = server_conn.cursor()
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{DB_CONFIG['database']}`")
    server_conn.commit()
    cursor.close()
    server_conn.close()
    print(f"[OK] MySQL Database `{DB_CONFIG['database']}` verified/created.")

# ----------------- INITIALIZE DATABASE -----------------
def init_db():
    if IS_POSTGRES:
        _init_postgres()
    else:
        _init_mysql()

def _init_postgres():
    import psycopg2
    print("[INFO] Connecting to Supabase (PostgreSQL)...")
    try:
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor()

        # Users Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(150) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            role VARCHAR(50) DEFAULT 'admin',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """)

        # Employees Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS employees (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(150) UNIQUE,
            phone VARCHAR(30),
            role VARCHAR(100) NOT NULL,
            base_salary NUMERIC(12, 2) NOT NULL,
            department VARCHAR(100),
            avatar VARCHAR(10),
            avatar_color VARCHAR(20),
            joined_date VARCHAR(20) DEFAULT '2026-01-15',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """)

        # Payouts Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS payouts (
            id SERIAL PRIMARY KEY,
            employee_id INT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
            month VARCHAR(50) NOT NULL,
            amount NUMERIC(12, 2) NOT NULL,
            payout_date VARCHAR(50),
            status VARCHAR(30) DEFAULT 'Pending'
        );
        """)

        # Attendance Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS attendance (
            id SERIAL PRIMARY KEY,
            employee_id INT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
            date VARCHAR(30) NOT NULL,
            status VARCHAR(30) NOT NULL DEFAULT 'Present',
            notes VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT unique_emp_date UNIQUE (employee_id, date)
        );
        """)
        conn.commit()

        # Seed Admin Accounts
        admin_emails = [
            ("Admin", "hbiswal199@gmail.com", "NewPassword123", "admin"),
            ("Admin", "admin@salarypro.com", "admin123", "admin"),
        ]
        for user in admin_emails:
            cursor.execute("SELECT id FROM users WHERE email = %s;", (user[1],))
            if not cursor.fetchone():
                cursor.execute("""
                INSERT INTO users (name, email, password, role)
                VALUES (%s, %s, %s, %s);
                """, user)
                conn.commit()

        # Seed Factory Employees if empty
        cursor.execute("SELECT COUNT(*) FROM employees;")
        count = cursor.fetchone()[0]
        if count == 0:
            sample_employees = [
                ("Ramesh Verma", "ramesh.v@factory.com", "+91 98765 43210", "Production Supervisor", 32000, "Production / Assembly", "RV", "#6555FF"),
                ("Suresh Kumar", "suresh.k@factory.com", "+91 98765 43211", "Senior CNC Operator", 26000, "Machine Operations", "SK", "#00B0FF"),
                ("Priya Sharma", "priya.s@factory.com", "+91 98765 43212", "QC Inspector", 24000, "Quality Control", "PS", "#FF9100"),
                ("Manoj Patel", "manoj.p@factory.com", "+91 98765 43213", "Maintenance Electrician", 22000, "Maintenance & Electrical", "MP", "#00E676"),
                ("Hemanta Biswal", "hbiswal199@gmail.com", "+91 98765 43214", "Plant Manager", 45000, "Plant Administration", "HB", "#43129D"),
                ("Anil Rawat", "anil.r@factory.com", "+91 98765 43215", "Welder & Fabricator", 19500, "Production / Assembly", "AR", "#7C4DFF"),
                ("Dinesh Yadav", "dinesh.y@factory.com", "+91 98765 43216", "Stores & Dispatch Incharge", 21000, "Stores & Inventory", "DY", "#FF5722"),
            ]

            for emp in sample_employees:
                cursor.execute("""
                INSERT INTO employees (name, email, phone, role, base_salary, department, avatar, avatar_color)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id;
                """, emp)
                emp_id = cursor.fetchone()[0]

                status = "Paid" if emp[0] in ["Ramesh Verma", "Suresh Kumar"] else "Pending"
                date = "02 Nov, 2026" if status == "Paid" else "Pending"
                cursor.execute("""
                INSERT INTO payouts (employee_id, month, amount, payout_date, status)
                VALUES (%s, %s, %s, %s, %s);
                """, (emp_id, "November 2026", emp[4], date, status))

                cursor.execute("""
                INSERT INTO attendance (employee_id, date, status)
                VALUES (%s, %s, %s)
                ON CONFLICT (employee_id, date) DO NOTHING;
                """, (emp_id, "2026-11-02", "Present"))

            conn.commit()

        cursor.close()
        conn.close()
        print("[OK] Supabase PostgreSQL Database initialized successfully!")
    except Exception as e:
        print(f"[ERROR] Supabase PostgreSQL initialization error: {e}")
        raise

def _init_mysql():
    import mysql.connector
    print(f"Connecting to MySQL server at {DB_CONFIG['host']}:{DB_CONFIG['port']}...")
    try:
        # 1. Ensure database exists
        create_database_if_not_exists()

        # 2. Connect to the database
        conn = None
        try:
            conn = mysql.connector.connect(
                host=DB_CONFIG["host"],
                user=DB_CONFIG["user"],
                password=DB_CONFIG["password"],
                port=DB_CONFIG["port"],
                database=DB_CONFIG["database"],
            )
        except mysql.connector.Error as err:
            if err.errno in (1045, 1698) and DB_CONFIG["password"] != "":
                conn = mysql.connector.connect(
                    host=DB_CONFIG["host"],
                    user=DB_CONFIG["user"],
                    password="",
                    port=DB_CONFIG["port"],
                    database=DB_CONFIG["database"],
                )
            else:
                raise

        cursor = conn.cursor(dictionary=True)

        # Users Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(150) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            role VARCHAR(50) DEFAULT 'admin',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """)

        # Employees Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS employees (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(150) UNIQUE,
            phone VARCHAR(30),
            role VARCHAR(100) NOT NULL,
            base_salary DECIMAL(12, 2) NOT NULL,
            department VARCHAR(100),
            avatar VARCHAR(10),
            avatar_color VARCHAR(20),
            joined_date VARCHAR(20) DEFAULT '2026-01-15',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """)

        # Auto-migrate missing columns if table was created in earlier version
        cursor.execute("SHOW COLUMNS FROM employees LIKE 'phone'")
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE employees ADD COLUMN phone VARCHAR(30) AFTER email")
            conn.commit()

        cursor.execute("SHOW COLUMNS FROM employees LIKE 'joined_date'")
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE employees ADD COLUMN joined_date VARCHAR(20) DEFAULT '2026-01-15'")
            conn.commit()

        # Payouts Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS payouts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            employee_id INT NOT NULL,
            month VARCHAR(50) NOT NULL,
            amount DECIMAL(12, 2) NOT NULL,
            payout_date VARCHAR(50),
            status VARCHAR(30) DEFAULT 'Pending',
            FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
        )
        """)

        # Attendance Table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS attendance (
            id INT AUTO_INCREMENT PRIMARY KEY,
            employee_id INT NOT NULL,
            date VARCHAR(30) NOT NULL,
            status VARCHAR(30) NOT NULL DEFAULT 'Present',
            notes VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
            UNIQUE KEY unique_emp_date (employee_id, date)
        )
        """)

        # Seed Accounts
        admin_emails = [
            ("Admin", "hbiswal199@gmail.com", "NewPassword123", "admin"),
            ("Admin", "admin@salarypro.com", "admin123", "admin"),
        ]

        for user in admin_emails:
            cursor.execute("SELECT id FROM users WHERE email = %s", (user[1],))
            if not cursor.fetchone():
                cursor.execute("""
                INSERT INTO users (name, email, password, role)
                VALUES (%s, %s, %s, %s)
                """, user)
                conn.commit()

        # Seed Sample Factory Employees if empty
        cursor.execute("SELECT COUNT(*) as count FROM employees")
        count_row = cursor.fetchone()
        if count_row and count_row["count"] == 0:
            sample_employees = [
                ("Ramesh Verma", "ramesh.v@factory.com", "+91 98765 43210", "Production Supervisor", 32000, "Production / Assembly", "RV", "#6555FF"),
                ("Suresh Kumar", "suresh.k@factory.com", "+91 98765 43211", "Senior CNC Operator", 26000, "Machine Operations", "SK", "#00B0FF"),
                ("Priya Sharma", "priya.s@factory.com", "+91 98765 43212", "QC Inspector", 24000, "Quality Control", "PS", "#FF9100"),
                ("Manoj Patel", "manoj.p@factory.com", "+91 98765 43213", "Maintenance Electrician", 22000, "Maintenance & Electrical", "MP", "#00E676"),
                ("Hemanta Biswal", "hbiswal199@gmail.com", "+91 98765 43214", "Plant Manager", 45000, "Plant Administration", "HB", "#43129D"),
                ("Anil Rawat", "anil.r@factory.com", "+91 98765 43215", "Welder & Fabricator", 19500, "Production / Assembly", "AR", "#7C4DFF"),
                ("Dinesh Yadav", "dinesh.y@factory.com", "+91 98765 43216", "Stores & Dispatch Incharge", 21000, "Stores & Inventory", "DY", "#FF5722"),
            ]

            for emp in sample_employees:
                cursor.execute("""
                INSERT INTO employees (name, email, phone, role, base_salary, department, avatar, avatar_color)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, emp)
                emp_id = cursor.lastrowid

                status = "Paid" if emp[0] in ["Ramesh Verma", "Suresh Kumar"] else "Pending"
                date = "02 Nov, 2026" if status == "Paid" else "Pending"
                cursor.execute("""
                INSERT INTO payouts (employee_id, month, amount, payout_date, status)
                VALUES (%s, %s, %s, %s, %s)
                """, (emp_id, "November 2026", emp[4], date, status))

                # Default attendance for today
                cursor.execute("""
                INSERT IGNORE INTO attendance (employee_id, date, status)
                VALUES (%s, %s, %s)
                """, (emp_id, "2026-11-02", "Present"))

            conn.commit()

        cursor.close()
        conn.close()
        print("[OK] MySQL Database and tables initialized successfully!")

    except Exception as err:
        print(f"[ERROR] MySQL Error: {err}")
        raise

if __name__ == "__main__":
    init_db()
