import 'package:flutter/material.dart';

class EmployeePayout {
  final int? id;
  final String name;
  final String role;
  final String amount;
  final String date;
  final String status;
  final String avatar;
  final Color avatarColor;
  final String? department;

  const EmployeePayout({
    this.id,
    required this.name,
    required this.role,
    required this.amount,
    required this.date,
    required this.status,
    required this.avatar,
    required this.avatarColor,
    this.department,
  });

  factory EmployeePayout.fromJson(Map<String, dynamic> json) {
    final hexColor = (json['avatar_color'] ?? '#6555FF').toString().replaceAll('#', '');
    final colorInt = int.tryParse('0xFF$hexColor') ?? 0xFF6555FF;

    return EmployeePayout(
      id: json['id'],
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      amount: json['amount'] ?? '₹0',
      date: json['date'] ?? 'Pending',
      status: json['status'] ?? 'Pending',
      avatar: json['avatar'] ?? 'EM',
      avatarColor: Color(colorInt),
      department: json['department'],
    );
  }
}
