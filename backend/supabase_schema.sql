-- ============================================================
-- SalaryPro Factory Management System - Supabase Schema
-- Paste this script into Supabase SQL Editor and click "RUN"
-- ============================================================

-- 1. Users Table (Admin authentication)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Employees Table (Factory staff & workers)
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
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Payouts Table (Salary disbursement history)
CREATE TABLE IF NOT EXISTS payouts (
    id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    month VARCHAR(50) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    payout_date VARCHAR(50),
    status VARCHAR(30) DEFAULT 'Pending'
);

-- 4. Attendance Table (Daily presence tracker)
CREATE TABLE IF NOT EXISTS attendance (
    id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    date VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Present',
    notes VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_emp_date UNIQUE (employee_id, date)
);

-- 5. Seed Admin Accounts
INSERT INTO users (name, email, password, role)
VALUES 
    ('Admin', 'hbiswal199@gmail.com', 'NewPassword123', 'admin'),
    ('Admin', 'admin@salarypro.com', 'admin123', 'admin')
ON CONFLICT (email) DO NOTHING;

-- 6. Seed Factory Staff Records
INSERT INTO employees (name, email, phone, role, base_salary, department, avatar, avatar_color)
VALUES 
    ('Ramesh Verma', 'ramesh.v@factory.com', '+91 98765 43210', 'Production Supervisor', 32000, 'Production / Assembly', 'RV', '#6555FF'),
    ('Suresh Kumar', 'suresh.k@factory.com', '+91 98765 43211', 'Senior CNC Operator', 26000, 'Machine Operations', 'SK', '#00B0FF'),
    ('Priya Sharma', 'priya.s@factory.com', '+91 98765 43212', 'QC Inspector', 24000, 'Quality Control', 'PS', '#FF9100'),
    ('Manoj Patel', 'manoj.p@factory.com', '+91 98765 43213', 'Maintenance Electrician', 22000, 'Maintenance & Electrical', 'MP', '#00E676'),
    ('Hemanta Biswal', 'hbiswal199@gmail.com', '+91 98765 43214', 'Plant Manager', 45000, 'Plant Administration', 'HB', '#43129D'),
    ('Anil Rawat', 'anil.r@factory.com', '+91 98765 43215', 'Welder & Fabricator', 19500, 'Production / Assembly', 'AR', '#7C4DFF'),
    ('Dinesh Yadav', 'dinesh.y@factory.com', '+91 98765 43216', 'Stores & Dispatch Incharge', 21000, 'Stores & Inventory', 'DY', '#FF5722')
ON CONFLICT (email) DO NOTHING;

-- 7. Seed Initial Payout Records for Current Month
INSERT INTO payouts (employee_id, month, amount, payout_date, status)
SELECT id, 'November 2026', base_salary, 
       CASE WHEN name IN ('Ramesh Verma', 'Suresh Kumar') THEN '02 Nov, 2026' ELSE 'Pending' END,
       CASE WHEN name IN ('Ramesh Verma', 'Suresh Kumar') THEN 'Paid' ELSE 'Pending' END
FROM employees
WHERE NOT EXISTS (SELECT 1 FROM payouts WHERE payouts.employee_id = employees.id);

-- 8. Seed Default Today Attendance
INSERT INTO attendance (employee_id, date, status)
SELECT id, '2026-11-02', 'Present'
FROM employees
ON CONFLICT (employee_id, date) DO NOTHING;
