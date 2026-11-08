from pydantic import BaseModel
from typing import Optional, List

# Auth Schemas
class LoginRequest(BaseModel):
    email: str
    password: str

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str

class AuthResponse(BaseModel):
    success: bool
    message: str
    user: Optional[dict] = None
    token: Optional[str] = None

# Employee Schemas
class EmployeeCreate(BaseModel):
    name: str
    email: str
    phone: Optional[str] = ""
    role: str
    base_salary: float
    department: Optional[str] = "Production / Assembly"
    avatar: Optional[str] = None
    avatar_color: Optional[str] = "#6555FF"
    joined_date: Optional[str] = "2026-11-01"

class EmployeeResponse(BaseModel):
    id: int
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    role: str
    base_salary: float
    department: Optional[str] = None
    avatar: Optional[str] = None
    avatar_color: Optional[str] = None
    joined_date: Optional[str] = None

# Payout Schemas
class PayoutItem(BaseModel):
    id: int
    employee_id: int
    name: str
    role: str
    amount: str
    raw_amount: Optional[float] = 0.0
    date: str
    status: str
    avatar: str
    avatar_color: str
    department: Optional[str] = "General"

# Dashboard Stats Schema
class DashboardStats(BaseModel):
    total_payroll: str
    total_disbursed: str
    total_pending: str
    total_employees: int
    attendance_rate: str
    month: str
    payouts: List[PayoutItem]

# Attendance Schemas
class AttendanceMarkRequest(BaseModel):
    employee_id: int
    date: str
    status: str  # Present, Absent, Half-day, Leave
    notes: Optional[str] = ""

class AttendanceItem(BaseModel):
    employee_id: int
    name: str
    role: str
    avatar: str
    avatar_color: str
    status: str  # Present, Absent, Half-day, Leave, or Unmarked
    date: str
