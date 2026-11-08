import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Live Cloud Backend on Render
  static String get baseUrl => 'https://salary-management-app-1.onrender.com';

  // 1. Authentication
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Invalid credentials'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to backend server: $e'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to backend server: $e'};
    }
  }

  // 2. Dashboard Stats
  static Future<Map<String, dynamic>> getDashboardStats({String month = "November 2026"}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/dashboard/stats?month=$month'));
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Failed to load stats'};
    } catch (e) {
      return {'success': false, 'message': '$e'};
    }
  }

  // 3. Employee Directory
  static Future<List<dynamic>> getEmployees() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/employees'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addEmployee(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/employees'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteEmployee(int empId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/employees/$empId'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Payroll Payouts
  static Future<List<dynamic>> getPayouts({String month = "November 2026"}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/payroll/payouts?month=$month'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> disburseSalary(int payoutId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/payroll/disburse/$payoutId'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 5. Attendance Management
  static Future<List<dynamic>> getAttendance(String date) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/attendance?date=$date'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> markAttendance({
    required int employeeId,
    required String date,
    required String status,
    String notes = "",
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employee_id': employeeId,
          'date': date,
          'status': status,
          'notes': notes,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
