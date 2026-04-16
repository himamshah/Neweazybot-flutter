import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'bots_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  int _passwordStrength = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 390,
            decoration: BoxDecoration(
              color: AppTheme.bg,
              borderRadius: BorderRadius.circular(44),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                _buildStatusBar(),
                _buildAvatarSection(),
                _buildStatsRow(),
                _buildProfileSection(),
                _buildPasswordSection(),
                _buildDangerZone(),
                _buildTabBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
            ),
          ),
          Row(
            children: [
              // Signal bars
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.text.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                width: 3,
                height: 9,
                decoration: BoxDecoration(
                  color: AppTheme.text.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                width: 3,
                height: 11,
                decoration: BoxDecoration(
                  color: AppTheme.text.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.text,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              // WiFi bars
              Container(
                width: 22,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.text.withOpacity(0.35),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(3.5),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppTheme.text,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          // Radial glow behind avatar
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.5,
                colors: [
                  AppTheme.blue.withOpacity(0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1a3a5c), Color(0xFF0e2040)],
                  ),
                  border: Border.all(
                    color: AppTheme.blue.withOpacity(0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.blue.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Sagar Mehta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'sagar@tradebot.app',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.text3,
                ),
              ),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Member since Jan 2025',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.text3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '4',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text,
                    fontFamily: 'monospace',
                  ),
                ),
                const Text(
                  'Total bots',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.text3,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '3',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text,
                    fontFamily: 'monospace',
                  ),
                ),
                const Text(
                  'Running',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.text3,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '+$850',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.green,
                    fontFamily: 'monospace',
                  ),
                ),
                const Text(
                  'All-time PnL',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.text3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 0),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Profile info', Icons.person_outline),
          _buildFieldRow('Full name', 'Sagar Mehta'),
          _buildFieldRow('Email', 'sagar@tradebot.app'),
          _buildFieldRow('Role', 'Admin', color: AppTheme.amber),
          _buildFieldRow('User ID', '#USR-0042', isMono: true),
          _buildFieldRow('Last login', 'Today, 9:41 AM', isMuted: true),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 0),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Change password', Icons.lock_outline),
          _buildPasswordField(
            'CURRENT PASSWORD',
            _currentPasswordController,
            _obscureCurrentPassword,
            (value) {},
          ),
          const SizedBox(height: 4),
          _buildPasswordField(
            'NEW PASSWORD',
            _newPasswordController,
            _obscureNewPassword,
            _checkPasswordStrength,
          ),
          const SizedBox(height: 4),
          _buildPasswordField(
            'CONFIRM NEW PASSWORD',
            _confirmPasswordController,
            _obscureConfirmPassword,
            (value) {},
          ),
          const SizedBox(height: 12),
          _buildPasswordSubmit(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: AppTheme.blue,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.blue,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value, {Color? color, bool isMono = false, bool isMuted = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.text2,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: color ?? AppTheme.text,
                fontWeight: FontWeight.w500,
                fontFamily: isMono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, Function(String)? onChanged) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.text3,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.bg3,
              border: Border.all(color: AppTheme.border2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: label == 'NEW PASSWORD' ? 'Enter new password' : 'Enter current password',
                hintStyle: const TextStyle(
                  color: AppTheme.text3,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.text,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSubmit() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 14, 0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePasswordUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          elevation: 0,
          shadowColor: MaterialStatePropertyAll(AppTheme.blue.withOpacity(0.25)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Update password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 0),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Danger zone', Icons.warning, color: AppTheme.red),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete account',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.red,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'This action cannot be undone',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.text3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 7,
                height: 12,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 22, 8),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(Icons.dashboard_outlined, 'Dashboard', false),
          ),
          Expanded(
            child: _buildTabItem(Icons.list_alt, 'Bots', false),
          ),
          Expanded(
            child: _buildTabItem(Icons.show_chart, 'Trades', true),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? AppTheme.blue : AppTheme.text3,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppTheme.blue : AppTheme.text3,
            ),
          ),
          if (isActive)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppTheme.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ],
    );
  }

  void _checkPasswordStrength(String value) {
    int score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++;
    if (RegExp(r'[0-9]').hasMatch(value) && RegExp(r'[a-zA-Z]').hasMatch(value)) score++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) score++;

    setState(() {
      _passwordStrength = score;
    });
  }

  Future<void> _handlePasswordUpdate() async {
    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all password fields'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual password update logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully'),
            backgroundColor: AppTheme.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password update failed: ${e.toString()}'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
