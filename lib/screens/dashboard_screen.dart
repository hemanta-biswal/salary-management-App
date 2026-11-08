import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salary_managenmnet_system/screens/add_employee_screen.dart';
import 'package:salary_managenmnet_system/screens/attendance_screen.dart';
import 'package:salary_managenmnet_system/screens/payroll_screen.dart';
import 'package:salary_managenmnet_system/screens/profile_screen.dart';
import 'package:salary_managenmnet_system/screens/staff_screen.dart';
import 'package:salary_managenmnet_system/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;
  final String _selectedMonth = 'November 2026';
  bool _isLoading = false;

  String _totalPayroll = '₹0';
  String _totalDisbursed = '₹0';
  String _totalPending = '₹0';
  String _totalEmployees = '0';
  String _attendanceRate = '100%';
  List<dynamic> _payouts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getDashboardStats(month: _selectedMonth);
    if (res['success'] == true) {
      final data = res['data'];
      setState(() {
        _totalPayroll = data['total_payroll'] ?? '₹0';
        _totalDisbursed = data['total_disbursed'] ?? '₹0';
        _totalPending = data['total_pending'] ?? '₹0';
        _totalEmployees = (data['total_employees'] ?? 0).toString();
        _attendanceRate = data['attendance_rate'] ?? '100%';
        _payouts = data['payouts'] ?? [];
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedNavIndex != 0) {
          // If on any tab (Payroll, Staff, Profile), back button returns to Admin Dashboard Page (Tab 0)
          setState(() => _selectedNavIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FC),
        body: IndexedStack(
          index: _selectedNavIndex,
          children: [
            _buildDashboardHome(),
            StaffScreen(
              onBack: () => setState(() => _selectedNavIndex = 0),
            ),
            PayrollScreen(
              onBack: () => setState(() => _selectedNavIndex = 0), // <-- Navigates to Admin Dashboard Page!
            ),
            ProfileScreen(
              onBack: () => setState(() => _selectedNavIndex = 0), // <-- Navigates to Admin Dashboard Page!
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // Tab 0: Main Dashboard Home View
  Widget _buildDashboardHome() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF43129D),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              const SizedBox(height: 20),
              _buildHeroPayrollCard(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 28),
              _buildRecentTransactionsHeader(),
              const SizedBox(height: 12),
              _buildRecentTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Greeting & Profile Header
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = 3),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43129D), Color(0xFF9145D3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'AD',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Admin 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B104D),
                    ),
                  ),
                  Text(
                    'SalaryPro Workspace (MySQL)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _loadDashboardData,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B104D)),
                    )
                  : const Icon(Icons.refresh_rounded, color: Color(0xFF0B104D)),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Main Gradient Payroll Summary Card
  Widget _buildHeroPayrollCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 43, 6, 93),
              Color.fromARGB(255, 67, 18, 157),
              Color.fromARGB(255, 145, 69, 211),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF43129D).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Monthly Payroll',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _selectedMonth,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _totalPayroll,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 4, backgroundColor: Color(0xFF00E676)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Disbursed', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                            Text(
                              _totalDisbursed,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(height: 28, width: 1, color: Colors.white24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 4, backgroundColor: Color(0xFFFF9100)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pending', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                            Text(
                              _totalPending,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Quick Action Buttons
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B104D),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Add Staff',
                color: const Color(0xFF6555FF),
                onTap: () async {
                  final added = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
                  );
                  if (added == true) _loadDashboardData();
                },
              ),
              _buildActionButton(
                icon: Icons.fact_check_rounded,
                label: 'Attendance',
                color: const Color(0xFF00B0FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.payments_rounded,
                label: 'Pay Salary',
                color: const Color(0xFF00C853),
                onTap: () => setState(() => _selectedNavIndex = 2), // Switch to Payroll tab
              ),
              _buildActionButton(
                icon: Icons.receipt_long_rounded,
                label: 'Payslips',
                color: const Color(0xFFFF6D00),
                onTap: () => setState(() => _selectedNavIndex = 2), // Switch to Payroll tab
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0B104D),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Statistics Row
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedNavIndex = 1), // Open Staff tab
              child: _buildMetricCard(
                title: 'Total Employees',
                value: _totalEmployees,
                change: 'View All →',
                isPositive: true,
                icon: Icons.badge_outlined,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                );
              },
              child: _buildMetricCard(
                title: 'Attendance',
                value: _attendanceRate,
                change: 'Mark Today →',
                isPositive: true,
                icon: Icons.verified_user_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 18, color: const Color(0xFF6555FF)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B104D),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              change,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF43129D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Recent Transactions Header
  Widget _buildRecentTransactionsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Payouts',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B104D),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedNavIndex = 2), // Switch to Payroll tab
            child: Text(
              'See All',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6555FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Recent Transactions List
  Widget _buildRecentTransactionsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _payouts.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text('No payouts recorded yet.', style: GoogleFonts.poppins(color: Colors.black45)),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _payouts.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 68),
                itemBuilder: (context, index) {
                  final payout = _payouts[index];
                  final isPaid = payout['status'] == 'Paid';
                  final hexColor = (payout['avatar_color'] ?? '#6555FF').toString().replaceAll('#', '');
                  final colorInt = int.tryParse('0xFF$hexColor') ?? 0xFF6555FF;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(colorInt).withOpacity(0.15),
                          child: Text(
                            payout['avatar'] ?? 'EM',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Color(colorInt),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payout['name'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0B104D),
                                ),
                              ),
                              Text(
                                payout['role'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              payout['amount'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0B104D),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                payout['status'] ?? 'Pending',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isPaid ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  // 7. Bottom Navigation Bar
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF43129D),
        unselectedItemColor: Colors.black38,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Staff',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Payroll',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
