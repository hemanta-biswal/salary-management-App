import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salary_managenmnet_system/screens/add_employee_screen.dart';
import 'package:salary_managenmnet_system/services/api_service.dart';

class StaffScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const StaffScreen({super.key, this.onBack});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List<dynamic> _employees = [];
  List<dynamic> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDept = 'All';

  final List<String> _departments = [
    'All',
    'Production / Assembly',
    'Machine Operations',
    'Quality Control',
    'Maintenance & Electrical',
    'Stores & Inventory',
    'Plant Administration',
  ];

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getEmployees();
    setState(() {
      _employees = data;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    _filteredEmployees = _employees.where((emp) {
      final nameMatches = (emp['name'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final roleMatches = (emp['role'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final deptMatches = _selectedDept == 'All' || (emp['department'] ?? '') == _selectedDept;
      return (nameMatches || roleMatches) && deptMatches;
    }).toList();
  }

  Future<void> _deleteEmployee(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Employee', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove $name? This will also remove their payroll records.',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteEmployee(id);
      if (success) {
        _fetchEmployees();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Employee removed', style: GoogleFonts.poppins()),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Staff Directory',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF43129D),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchEmployees,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: const Color(0xFF43129D),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _applyFilters();
                  });
                },
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search factory staff by name or role...',
                  hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                  icon: const Icon(Icons.search, color: Color(0xFF43129D)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Department Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _departments.map((dept) {
                final isSelected = _selectedDept == dept;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(dept,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        )),
                    selected: isSelected,
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF43129D),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? const Color(0xFF43129D) : Colors.black12),
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedDept = dept;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Staff List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF43129D)))
                : _filteredEmployees.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 64, color: Colors.black26),
                            const SizedBox(height: 12),
                            Text('No employees found', style: GoogleFonts.poppins(color: Colors.black45)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchEmployees,
                        color: const Color(0xFF43129D),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final emp = _filteredEmployees[index];
                            final hexColor = (emp['avatar_color'] ?? '#6555FF').toString().replaceAll('#', '');
                            final colorInt = int.tryParse('0xFF$hexColor') ?? 0xFF6555FF;
                            final salary = (emp['base_salary'] is num) ? emp['base_salary'].toInt() : 50000;

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
                                    radius: 24,
                                    backgroundColor: Color(colorInt).withOpacity(0.15),
                                    child: Text(
                                      emp['avatar'] ?? 'EM',
                                      style: GoogleFonts.poppins(
                                        color: Color(colorInt),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emp['name'] ?? '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0B104D),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          emp['role'] ?? '',
                                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEDE7F6),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                emp['department'] ?? 'General',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF43129D),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "₹${salary.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}/mo",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF00C853),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                    onPressed: () => _deleteEmployee(emp['id'], emp['name']),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          );
          if (res == true) _fetchEmployees();
        },
        backgroundColor: const Color(0xFF43129D),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: Text('Add Staff', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

