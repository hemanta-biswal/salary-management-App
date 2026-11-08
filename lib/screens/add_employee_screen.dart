import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salary_managenmnet_system/services/api_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();
  final _salaryController = TextEditingController();

  String _selectedDepartment = 'Production / Assembly';
  final List<String> _departments = [
    'Production / Assembly',
    'Machine Operations',
    'Quality Control',
    'Maintenance & Electrical',
    'Stores & Inventory',
    'Plant Administration',
  ];

  // Quick factory role presets
  final List<Map<String, String>> _factoryRolePresets = [
    {'role': 'Production Supervisor', 'dept': 'Production / Assembly', 'salary': '32000'},
    {'role': 'CNC Machine Operator', 'dept': 'Machine Operations', 'salary': '26000'},
    {'role': 'QC Inspector', 'dept': 'Quality Control', 'salary': '24000'},
    {'role': 'Maintenance Electrician', 'dept': 'Maintenance & Electrical', 'salary': '22000'},
    {'role': 'Lathe Machine Operator', 'dept': 'Machine Operations', 'salary': '21000'},
    {'role': 'Welder & Fabricator', 'dept': 'Production / Assembly', 'salary': '20000'},
    {'role': 'Stores & Dispatch', 'dept': 'Stores & Inventory', 'salary': '21000'},
    {'role': 'Assembly Line Worker', 'dept': 'Production / Assembly', 'salary': '18000'},
    {'role': 'Plant Manager', 'dept': 'Plant Administration', 'salary': '45000'},
  ];

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final salary = double.tryParse(_salaryController.text.trim()) ?? 50000.0;
    final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    final success = await ApiService.addEmployee({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': _roleController.text.trim(),
      'base_salary': salary,
      'department': _selectedDepartment,
      'joined_date': dateStr,
    });

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employee added successfully to MySQL!', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save employee. Check server connection.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: Text(
          'Add New Employee',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF43129D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Personal Details'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'e.g. Alex Johnson',
                icon: Icons.person_outline_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter employee name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Work Email',
                hint: 'alex@company.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || !val.contains('@') ? 'Please enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+91 98765 43210',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Job & Compensation'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _roleController,
                label: 'Job Title / Role',
                hint: 'e.g. CNC Operator / Production Supervisor',
                icon: Icons.precision_manufacturing_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter job title' : null,
              ),
              const SizedBox(height: 10),
              // Factory Role Quick Select Chips
              Text(
                'Quick Select Factory Role:',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF43129D)),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _factoryRolePresets.map((preset) {
                    final isSelected = _roleController.text == preset['role'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(preset['role']!),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF43129D),
                        ),
                        backgroundColor: isSelected ? const Color(0xFF43129D) : const Color(0xFFEDE7F6),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onPressed: () {
                          setState(() {
                            _roleController.text = preset['role']!;
                            _selectedDepartment = preset['dept']!;
                            if (_salaryController.text.isEmpty) {
                              _salaryController.text = preset['salary']!;
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _buildDepartmentDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _salaryController,
                label: 'Monthly Base Salary (₹)',
                hint: 'e.g. 26000',
                icon: Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter monthly salary';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitEmployee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43129D),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          'Save Employee',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0B104D),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF6555FF), size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF43129D), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Department', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDepartment,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF43129D)),
              items: _departments.map((dept) {
                return DropdownMenuItem(
                  value: dept,
                  child: Text(dept, style: GoogleFonts.poppins(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDepartment = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Joining Date', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF6555FF)),
                    const SizedBox(width: 12),
                    Text(
                      "${_selectedDate.day} ${_getMonthName(_selectedDate.month)}, ${_selectedDate.year}",
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
                const Icon(Icons.edit_calendar_rounded, size: 18, color: Colors.black45),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

