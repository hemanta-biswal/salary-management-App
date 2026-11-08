import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salary_managenmnet_system/services/api_service.dart';

class PayrollScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const PayrollScreen({super.key, this.onBack});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final String _selectedMonth = 'November 2026';
  List<dynamic> _payouts = [];
  bool _isLoading = true;
  String _filter = 'All'; // All, Paid, Pending

  @override
  void initState() {
    super.initState();
    _fetchPayouts();
  }

  Future<void> _fetchPayouts() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getPayouts(month: _selectedMonth);
    setState(() {
      _payouts = data;
      _isLoading = false;
    });
  }

  Future<void> _disburseSalary(int payoutId, String empName, String amount) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Disburse Salary', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Confirm payment of $amount to $empName for $_selectedMonth?',
            style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirm & Pay', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.disburseSalary(payoutId);
      if (success) {
        _fetchPayouts();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Salary disbursed successfully to $empName!', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF00C853),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPayslipModal(Map<String, dynamic> payout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Salary Payslip', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0B104D))),
                    Text(_selectedMonth, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: payout['status'] == 'Paid' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payout['status'],
                    style: GoogleFonts.poppins(
                      color: payout['status'] == 'Paid' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildPayslipRow('Employee Name', payout['name']),
            _buildPayslipRow('Designation', payout['role']),
            _buildPayslipRow('Department', payout['department'] ?? 'General'),
            _buildPayslipRow('Payment Date', payout['date'] ?? 'Pending'),
            const Divider(height: 32),
            _buildPayslipRow('Basic Salary', payout['amount']),
            _buildPayslipRow('HRA & Allowances', '₹0'),
            _buildPayslipRow('Tax Deductions', '₹0'),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net Payout', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0B104D))),
                Text(payout['amount'], style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF43129D))),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43129D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.check_rounded, color: Colors.white),
                label: Text('Close', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayslipRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0B104D))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _payouts.where((p) {
      if (_filter == 'All') return true;
      return p['status'] == _filter;
    }).toList();

    double totalDisbursed = 0;
    double totalPending = 0;
    for (var p in _payouts) {
      double amt = (p['raw_amount'] is num) ? p['raw_amount'].toDouble() : 0.0;
      if (p['status'] == 'Paid') {
        totalDisbursed += amt;
      } else {
        totalPending += amt;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('Payroll Management',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF43129D),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchPayouts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Payroll Summary Banner
          Container(
            color: const Color(0xFF43129D),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Disbursed', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(
                          "₹${totalDisbursed.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00C853),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 36, width: 1, color: Colors.black12),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pending Payout', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(
                          "₹${totalPending.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF9100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status Filter Tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: ['All', 'Pending', 'Paid'].map((tab) {
                final isSelected = _filter == tab;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF43129D) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xFF43129D) : Colors.black12),
                        ),
                        child: Center(
                          child: Text(
                            tab,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Payouts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF43129D)))
                : filtered.isEmpty
                    ? Center(child: Text('No payouts match this filter', style: GoogleFonts.poppins(color: Colors.black45)))
                    : RefreshIndicator(
                        onRefresh: _fetchPayouts,
                        color: const Color(0xFF43129D),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final p = filtered[index];
                            final isPaid = p['status'] == 'Paid';
                            final hexColor = (p['avatar_color'] ?? '#6555FF').toString().replaceAll('#', '');
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
                                  GestureDetector(
                                    onTap: () => _showPayslipModal(p),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Color(colorInt).withOpacity(0.15),
                                      child: Text(
                                        p['avatar'] ?? 'EM',
                                        style: GoogleFonts.poppins(
                                          color: Color(colorInt),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _showPayslipModal(p),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p['name'] ?? '',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0B104D),
                                            ),
                                          ),
                                          Text(
                                            p['role'] ?? '',
                                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            p['amount'] ?? '',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF43129D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isPaid)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Paid ✓',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  else
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00C853),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _disburseSalary(p['id'], p['name'], p['amount']),
                                      child: Text(
                                        'Pay Now',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

