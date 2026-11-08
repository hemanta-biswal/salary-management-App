import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from database import init_db, get_db
from config import IS_POSTGRES, DATABASE_URL
from models import (
    LoginRequest,
    RegisterRequest,
    AuthResponse,
    EmployeeCreate,
    EmployeeResponse,
    DashboardStats,
    PayoutItem,
    AttendanceMarkRequest,
    AttendanceItem,
)
from typing import List
from datetime import datetime
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        init_db()
    except Exception as e:
        print(f"[WARN] Startup database check: {e}")
    yield

app = FastAPI(
    title="SalaryPro API (MySQL)",
    description="Python FastAPI backend connected to MySQL database",
    version="1.0.0",
    lifespan=lifespan,
)

# Enable CORS for Flutter mobile/web clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    db_host = "Not Set"
    if DATABASE_URL:
        try:
            # Extract host without credentials
            db_host = DATABASE_URL.split("@")[-1].split("/")[0]
        except Exception:
            db_host = "Configured"
    return {
        "status": "online",
        "database": "Supabase (PostgreSQL)" if IS_POSTGRES else "MySQL (Local)",
        "db_host": db_host,
        "app": "SalaryPro Backend API",
        "docs_url": "/docs",
        "timestamp": datetime.now().isoformat(),
    }

# ----------------- AUTHENTICATION -----------------

@app.post("/api/auth/login", response_model=AuthResponse)
def login(req: LoginRequest):
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT id, name, email, role FROM users WHERE email = %s AND password = %s",
            (req.email.strip().lower(), req.password),
        )
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        return AuthResponse(
            success=True,
            message="Login successful",
            user={"id": user["id"], "name": user["name"], "email": user["email"], "role": user["role"]},
            token=f"fake-jwt-token-user-{user['id']}",
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@app.post("/api/auth/register", response_model=AuthResponse)
def register(req: RegisterRequest):
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT id FROM users WHERE email = %s", (req.email.strip().lower(),))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered",
            )

        if IS_POSTGRES:
            cursor.execute(
                "INSERT INTO users (name, email, password, role) VALUES (%s, %s, %s, %s) RETURNING id",
                (req.name.strip(), req.email.strip().lower(), req.password, "admin"),
            )
            row = cursor.fetchone()
            user_id = row["id"] if isinstance(row, dict) else row[0]
        else:
            cursor.execute(
                "INSERT INTO users (name, email, password, role) VALUES (%s, %s, %s, %s)",
                (req.name.strip(), req.email.strip().lower(), req.password, "admin"),
            )
            user_id = cursor.lastrowid
        conn.commit()
        cursor.close()
        conn.close()

        return AuthResponse(
            success=True,
            message="Account created successfully",
            user={"id": user_id, "name": req.name, "email": req.email, "role": "admin"},
            token=f"fake-jwt-token-user-{user_id}",
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

# ----------------- DASHBOARD STATS -----------------

@app.get("/api/dashboard/stats", response_model=DashboardStats)
def get_dashboard_stats(month: str = "November 2026"):
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)

        # Total employees
        cursor.execute("SELECT COUNT(*) AS total FROM employees")
        total_row = cursor.fetchone()
        total_employees = total_row["total"] if total_row else 0

        # Total payroll calculation
        cursor.execute("""
        SELECT 
            COALESCE(SUM(amount), 0) AS total_payroll,
            COALESCE(SUM(CASE WHEN status = 'Paid' THEN amount ELSE 0 END), 0) AS total_disbursed,
            COALESCE(SUM(CASE WHEN status = 'Pending' THEN amount ELSE 0 END), 0) AS total_pending
        FROM payouts
        WHERE month = %s
        """, (month,))
        totals = cursor.fetchone() or {"total_payroll": 0, "total_disbursed": 0, "total_pending": 0}

        # Recent payouts list with employee details
        cursor.execute("""
        SELECT 
            p.id,
            p.employee_id,
            e.name,
            e.role,
            e.department,
            p.amount,
            p.payout_date,
            p.status,
            e.avatar,
            e.avatar_color
        FROM payouts p
        JOIN employees e ON p.employee_id = e.id
        WHERE p.month = %s
        ORDER BY p.id DESC
        """, (month,))
        payout_rows = cursor.fetchall()
        cursor.close()
        conn.close()

        payouts = [
            PayoutItem(
                id=row["id"],
                employee_id=row["employee_id"],
                name=row["name"],
                role=row["role"],
                department=row.get("department") or "General",
                amount=f"₹{int(row['amount']):,}",
                raw_amount=float(row["amount"]),
                date=row["payout_date"] or "Pending",
                status=row["status"],
                avatar=row["avatar"] or "EM",
                avatar_color=row["avatar_color"] or "#6555FF",
            )
            for row in payout_rows
        ]

        return DashboardStats(
            total_payroll=f"₹{int(totals['total_payroll']):,}",
            total_disbursed=f"₹{int(totals['total_disbursed']):,}",
            total_pending=f"₹{int(totals['total_pending']):,}",
            total_employees=total_employees,
            attendance_rate="96.2%",
            month=month,
            payouts=payouts,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

# ----------------- EMPLOYEES -----------------

@app.get("/api/employees", response_model=List[EmployeeResponse])
def get_employees():
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT id, name, email, phone, role, base_salary, department, avatar, avatar_color, joined_date FROM employees ORDER BY id DESC")
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        return [
            EmployeeResponse(
                id=r["id"],
                name=r["name"],
                email=r["email"],
                phone=r["phone"],
                role=r["role"],
                base_salary=float(r["base_salary"]),
                department=r["department"],
                avatar=r["avatar"],
                avatar_color=r["avatar_color"],
                joined_date=r.get("joined_date"),
            )
            for r in rows
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@app.post("/api/employees", response_model=EmployeeResponse)
def add_employee(emp: EmployeeCreate):
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)

        avatar = emp.avatar
        if not avatar:
            parts = emp.name.split()
            avatar = "".join([p[0].upper() for p in parts[:2]])

        if IS_POSTGRES:
            cursor.execute("""
            INSERT INTO employees (name, email, phone, role, base_salary, department, avatar, avatar_color, joined_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
            """, (emp.name, emp.email, emp.phone, emp.role, emp.base_salary, emp.department, avatar, emp.avatar_color, emp.joined_date))
            row = cursor.fetchone()
            emp_id = row["id"] if isinstance(row, dict) else row[0]
        else:
            cursor.execute("""
            INSERT INTO employees (name, email, phone, role, base_salary, department, avatar, avatar_color, joined_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (emp.name, emp.email, emp.phone, emp.role, emp.base_salary, emp.department, avatar, emp.avatar_color, emp.joined_date))
            emp_id = cursor.lastrowid

        # Create initial pending payout for current month
        cursor.execute("""
        INSERT INTO payouts (employee_id, month, amount, payout_date, status)
        VALUES (%s, %s, %s, %s, %s)
        """, (emp_id, "November 2026", emp.base_salary, "Pending", "Pending"))

        conn.commit()
        cursor.close()
        conn.close()

        return EmployeeResponse(
            id=emp_id,
            name=emp.name,
            email=emp.email,
            phone=emp.phone,
            role=emp.role,
            base_salary=emp.base_salary,
            department=emp.department,
            avatar=avatar,
            avatar_color=emp.avatar_color,
            joined_date=emp.joined_date,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@app.delete("/api/employees/{emp_id}")
def delete_employee(emp_id: int):
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("DELETE FROM employees WHERE id = %s", (emp_id,))
        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="Employee not found")
        conn.commit()
        cursor.close()
        conn.close()
        return {"success": True, "message": "Employee deleted"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

# ----------------- PAYROLL MANAGEMENT -----------------

@app.get("/api/payroll/payouts", response_model=List[PayoutItem])
def get_payouts(month: str = "November 2026"):
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
        SELECT 
            p.id,
            p.employee_id,
            e.name,
            e.role,
            e.department,
            p.amount,
            p.payout_date,
            p.status,
            e.avatar,
            e.avatar_color
        FROM payouts p
        JOIN employees e ON p.employee_id = e.id
        WHERE p.month = %s
        ORDER BY p.id DESC
        """, (month,))
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        return [
            PayoutItem(
                id=r["id"],
                employee_id=r["employee_id"],
                name=r["name"],
                role=r["role"],
                department=r.get("department") or "General",
                amount=f"₹{int(r['amount']):,}",
                raw_amount=float(r["amount"]),
                date=r["payout_date"] or "Pending",
                status=r["status"],
                avatar=r["avatar"] or "EM",
                avatar_color=r["avatar_color"] or "#6555FF",
            )
            for r in rows
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@app.post("/api/payroll/disburse/{payout_id}")
def disburse_salary(payout_id: int):
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)

        today_str = datetime.now().strftime("%d %b, %Y")
        cursor.execute("""
        UPDATE payouts
        SET status = 'Paid', payout_date = %s
        WHERE id = %s
        """, (today_str, payout_id))

        if cursor.rowcount == 0:
            cursor.close()
            conn.close()
            raise HTTPException(status_code=404, detail="Payout record not found")

        conn.commit()
        cursor.close()
        conn.close()

        return {"success": True, "message": "Salary disbursed successfully", "date": today_str}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

# ----------------- ATTENDANCE MANAGEMENT -----------------

@app.get("/api/attendance", response_model=List[AttendanceItem])
def get_attendance(date: str):
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
        SELECT 
            e.id as employee_id,
            e.name,
            e.role,
            e.avatar,
            e.avatar_color,
            COALESCE(a.status, 'Present') as status,
            %s as date
        FROM employees e
        LEFT JOIN attendance a ON e.id = a.employee_id AND a.date = %s
        ORDER BY e.id ASC
        """, (date, date))
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        return [
            AttendanceItem(
                employee_id=r["employee_id"],
                name=r["name"],
                role=r["role"],
                avatar=r["avatar"] or "EM",
                avatar_color=r["avatar_color"] or "#6555FF",
                status=r["status"],
                date=r["date"],
            )
            for r in rows
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")

@app.post("/api/attendance")
def mark_attendance(req: AttendanceMarkRequest):
    try:
        conn = get_db()
        cursor = conn.cursor(dictionary=True)
        if IS_POSTGRES:
            cursor.execute("""
            INSERT INTO attendance (employee_id, date, status, notes)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (employee_id, date) DO UPDATE 
            SET status = EXCLUDED.status, notes = EXCLUDED.notes
            """, (req.employee_id, req.date, req.status, req.notes or ""))
        else:
            cursor.execute("""
            INSERT INTO attendance (employee_id, date, status, notes)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE status = VALUES(status), notes = VALUES(notes)
            """, (req.employee_id, req.date, req.status, req.notes or ""))
        conn.commit()
        cursor.close()
        conn.close()
        return {"success": True, "message": "Attendance marked successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {e}")
