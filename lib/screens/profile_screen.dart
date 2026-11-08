import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salary_managenmnet_system/screens/Home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Production Preferences Toggles
  bool _pushNotifications = true;
  bool _twoFactorAuth = true;
  bool _biometricLock = false;
  bool _salaryAlerts = true;
  bool _attendanceAlerts = true;

  // Change Password Dialog Controllers
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Confirm Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of the SalaryPro Admin Workspace?',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: Text('Log Out', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 24,
          ),
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
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF43129D), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('Change Password', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your current administrator password to set a new password.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _currentPassController,
                obscureText: _obscureCurrent,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: GoogleFonts.poppins(fontSize: 13),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setModalState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF6F8FC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _newPassController,
                obscureText: _obscureNew,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: GoogleFonts.poppins(fontSize: 13),
                  prefixIcon: const Icon(Icons.key_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setModalState(() => _obscureNew = !_obscureNew),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF6F8FC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _confirmPassController,
                obscureText: _obscureNew,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: GoogleFonts.poppins(fontSize: 13),
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF6F8FC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43129D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (_newPassController.text.isEmpty || _confirmPassController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all fields', style: GoogleFonts.poppins()),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    if (_newPassController.text != _confirmPassController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('New passwords do not match', style: GoogleFonts.poppins()),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password updated successfully', style: GoogleFonts.poppins()),
                        backgroundColor: const Color(0xFF00C853),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text('Update Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(content, style: GoogleFonts.poppins(fontSize: 13, height: 1.5)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43129D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
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
        title: Text(
          'Settings & Profile',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF43129D),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Production Admin Header Card
            _buildProfileHeroCard(),
            const SizedBox(height: 22),

            // Organization & Workspace
            _buildSectionHeader('Organization & Workspace'),
            _buildCard([
              _buildValueTile(
                icon: Icons.precision_manufacturing_rounded,
                title: 'Factory / Company',
                value: 'Shree Balaji Industries',
                subtitle: 'Manufacturing & Engineering Works',
              ),
              _buildDivider(),
              _buildValueTile(
                icon: Icons.badge_outlined,
                title: 'Factory Unit ID',
                value: 'FACT-UNIT-402',
                showCopy: true,
              ),
              _buildDivider(),
              _buildValueTile(
                icon: Icons.currency_rupee_rounded,
                title: 'Default Currency',
                value: 'INR (₹)',
                subtitle: 'Indian Rupee',
              ),
              _buildDivider(),
              _buildValueTile(
                icon: Icons.calendar_today_rounded,
                title: 'Pay Cycle',
                value: 'Monthly',
                subtitle: 'Last working day',
              ),
              _buildDivider(),
              _buildValueTile(
                icon: Icons.verified_user_rounded,
                title: 'Workspace Plan',
                value: 'Enterprise Tier',
                badgeText: 'PRO',
                badgeColor: const Color(0xFFFFB300),
              ),
            ]),
            const SizedBox(height: 22),

            // Security & Authentication
            _buildSectionHeader('Security & Access Control'),
            _buildCard([
              _buildActionTile(
                icon: Icons.lock_reset_rounded,
                title: 'Change Password',
                subtitle: 'Last changed 14 days ago',
                onTap: _showChangePasswordDialog,
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.security_rounded,
                title: 'Two-Factor Authentication',
                subtitle: 'SMS & Authenticator Verification',
                value: _twoFactorAuth,
                onChanged: (val) {
                  setState(() => _twoFactorAuth = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('2FA ${val ? 'Enabled' : 'Disabled'}', style: GoogleFonts.poppins()),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric / PIN Unlock',
                subtitle: 'Require biometric scan on open',
                value: _biometricLock,
                onChanged: (val) {
                  setState(() => _biometricLock = val);
                },
              ),
              _buildDivider(),
              _buildValueTile(
                icon: Icons.shield_outlined,
                title: 'Cloud Encryption',
                value: 'AES-256 Bit',
                badgeText: 'ENCRYPTED',
                badgeColor: const Color(0xFF00C853),
              ),
            ]),
            const SizedBox(height: 22),

            // Notifications & Alerts
            _buildSectionHeader('Notifications & Automation'),
            _buildCard([
              _buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Instant alerts on approval & status',
                value: _pushNotifications,
                onChanged: (val) => setState(() => _pushNotifications = val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.send_and_archive_rounded,
                title: 'Salary Disbursal Alerts',
                subtitle: 'Notify staff via email upon payout',
                value: _salaryAlerts,
                onChanged: (val) => setState(() => _salaryAlerts = val),
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.how_to_reg_rounded,
                title: 'Daily Attendance Digest',
                subtitle: 'Morning summary of staff presence',
                value: _attendanceAlerts,
                onChanged: (val) => setState(() => _attendanceAlerts = val),
              ),
            ]),
            const SizedBox(height: 22),

            // Support & Legal
            _buildSectionHeader('Legal & Application'),
            _buildCard([
              _buildActionTile(
                icon: Icons.headset_mic_rounded,
                title: 'Help & Priority Support',
                subtitle: 'support@salarypro.com',
                onTap: () => _showInfoDialog(
                  'Support & Helpdesk',
                  'Enterprise 24/7 dedicated support is available:\n\n• Email: support@salarypro.com\n• Toll-Free: 1800-200-SALARY\n• SLA Response: Under 1 hour',
                ),
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.policy_rounded,
                title: 'Privacy Policy',
                subtitle: 'GDPR & ISO-27001 compliant',
                onTap: () => _showInfoDialog(
                  'Privacy Policy',
                  'SalaryPro complies with global data security standards. All employee records, bank details, and salary histories are encrypted at rest and in transit using AES-256 protocols. Your data is never shared with third parties.',
                ),
              ),
              _buildDivider(),
              _buildActionTile(
                icon: Icons.description_rounded,
                title: 'Terms of Service',
                subtitle: 'Commercial Enterprise Agreement',
                onTap: () => _showInfoDialog(
                  'Terms of Service',
                  'By using SalaryPro Workspace, your organization agrees to automated payroll calculations and attendance tracking under standard enterprise service level agreements.',
                ),
              ),
              _buildDivider(),
              _buildValueTile(
                icon: Icons.verified_rounded,
                title: 'Application Version',
                value: 'v1.0.0 (Build 100)',
                subtitle: 'Production Stable Channel',
              ),
            ]),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                  elevation: 1,
                  side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: Text(
                  'Log Out of Workspace',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProfileHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        'AD',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF00C853),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Administrator',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Verified',
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'hbiswal199@gmail.com',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plant & Factory Admin • Full Access',
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SalaryPro Cloud Sync',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  'Connected (Active)',
                  style: GoogleFonts.poppins(color: const Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0B104D),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.8, indent: 56, endIndent: 16, color: Color(0xFFF0F0F0));
  }

  Widget _buildValueTile({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    String? badgeText,
    Color? badgeColor,
    bool showCopy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF43129D), size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
                  ),
              ],
            ),
          ),
          if (badgeText != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? const Color(0xFF43129D)).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor ?? const Color(0xFF43129D),
                ),
              ),
            ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF43129D)),
          ),
          if (showCopy) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF43129D)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title copied to clipboard', style: GoogleFonts.poppins()),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF43129D), size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF43129D), size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: const Color(0xFF43129D),
            activeTrackColor: const Color(0xFF9145D3).withOpacity(0.5),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
