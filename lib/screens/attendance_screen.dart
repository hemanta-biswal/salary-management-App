import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salary_managenmnet_system/services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _currentDate = DateTime.now();
  List<dynamic> _attendanceList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  String get _dateFormatted =>
      "${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}";

  Future<void> _fetchAttendance() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getAttendance(_dateFormatted);
    setState(() {
      _attendanceList = data;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(int empId, String status) async {
    // Optimistic UI update
    setState(() {
      final index = _attendanceList.indexWhere((item) => item['employee_id'] == empId);
      if (index != -1) {
        _attendanceList[index]['status'] = status;
      }
    });

    final success = await ApiService.markAttendance(
      employeeId: empId,
      date: _dateFormatted,
      status: status,
    );

    if (!success) {
      _fetchAttendance(); // Revert on failure
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF43129D),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0B104D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _currentDate = picked);
      _fetchAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = _attendanceList.where((i) => i['status'] == 'Present').length;
    int absentCount = _attendanceList.where((i) => i['status'] == 'Absent').length;
    int leaveCount = _attendanceList.where((i) => i['status'] == 'Leave' || i['status'] == 'Half-day').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text('Daily Attendance',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF43129D),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Strip
          Container(
            color: const Color(0xFF43129D),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF43129D)),
                    onPressed: () {
                      setState(() => _currentDate = _currentDate.subtract(const Duration(days: 1)));
                      _fetchAttendance();
                    },
                  ),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Color(0xFF43129D), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${_currentDate.day} ${_getMonthName(_currentDate.month)}, ${_currentDate.year}",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF0B104D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF43129D)),
                    onPressed: () {
                      setState(() => _currentDate = _currentDate.add(const Duration(days: 1)));
                      _fetchAttendance();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Attendance Counts Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildCountChip('Present', presentCount, const Color(0xFF00C853), const Color(0xFFE8F5E9)),
                const SizedBox(width: 10),
                _buildCountChip('Absent', absentCount, const Color(0xFFD50000), const Color(0xFFFFEBEE)),
                const SizedBox(width: 10),
                _buildCountChip('Leave', leaveCount, const Color(0xFFFF6D00), const Color(0xFFFFF3E0)),
              ],
            ),
          ),

          // Employee Attendance List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF43129D)))
                : _attendanceList.isEmpty
                    ? Center(child: Text('No employees found', style: GoogleFonts.poppins(color: Colors.black45)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _attendanceList.length,
                        itemBuilder: (context, index) {
                          final item = _attendanceList[index];
                          final empId = item['employee_id'];
                          final currentStatus = item['status'] ?? 'Unmarked';
                          final hexColor = (item['avatar_color'] ?? '#6555FF').toString().replaceAll('#', '');
                          final colorInt = int.tryParse('0xFF$hexColor') ?? 0xFF6555FF;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Color(colorInt).withOpacity(0.15),
                                  child: Text(
                                    item['avatar'] ?? 'EM',
                                    style: GoogleFonts.poppins(
                                      color: Color(colorInt),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0B104D),
                                        ),
                                      ),
                                      Text(
                                        item['role'] ?? '',
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildStatusButton(
                                      label: 'P',
                                      isSelected: currentStatus == 'Present',
                                      color: const Color(0xFF00C853),
                                      onTap: () => _updateStatus(empId, 'Present'),
                                    ),
                                    const SizedBox(width: 6),
                                    _buildStatusButton(
                                      label: 'A',
                                      isSelected: currentStatus == 'Absent',
                                      color: const Color(0xFFD50000),
                                      onTap: () => _updateStatus(empId, 'Absent'),
                                    ),
                                    const SizedBox(width: 6),
                                    _buildStatusButton(
                                      label: 'L',
                                      isSelected: currentStatus == 'Leave',
                                      color: const Color(0xFFFF6D00),
                                      onTap: () => _updateStatus(empId, 'Leave'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, int count, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.black12, width: 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black45,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

