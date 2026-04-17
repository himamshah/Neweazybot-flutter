import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/unified_api_service.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'api_keys_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  ProfileData? _profileData;
  String? _error;
  
  // Password change state
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChangingPassword = false;
  int _passwordStrength = 0;
  String _passwordStrengthLabel = 'Min 8 characters, include numbers & symbols';
  Color _passwordStrengthColor = AppTheme.text3;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await UnifiedApiService.getProfile();
      if (mounted) {
        setState(() {
          _profileData = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_isLoading)
                      _buildLoadingState()
                    else if (_error != null)
                      _buildErrorState()
                    else if (_profileData != null)
                      _buildProfileContent(),
                  ],
                ),
              ),
            ),
            _buildTabBar(),
          ],
        ),
      ),
    );
  }

  
  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back,
              size: 16,
              color: AppTheme.blue,
            ),
            label: const Text(
              'Back',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _handleLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.redDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Sign out',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(
          color: AppTheme.blue,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading profile',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.text3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final profile = _profileData!;
    return Column(
      children: [
        _buildAvatarSection(profile),
        const SizedBox(height: 14),
        _buildStatsRow(profile.stats),
        const SizedBox(height: 14),
        _buildProfileSection(profile.profileInfo),
        const SizedBox(height: 12),
        _buildApiKeysSection(),
        const SizedBox(height: 12),
        _buildPasswordSection(),
        const SizedBox(height: 12),
        _buildDangerZone(),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildAvatarSection(ProfileData profile) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 20, 20),
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
              ),
            ),
          ),
          // Avatar ring
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1a3a5c),
                  const Color(0xFF0e2040),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppTheme.blue.withOpacity(0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.blue.withOpacity(0.15),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.avatar,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.blue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            profile.email,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.text3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Member since ${profile.memberSince}',
                style: const TextStyle(
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

  Widget _buildStatsRow(ProfileStats stats) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _buildStatCell('${stats.totalBots}', 'Total bots'),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          _buildStatCell('${stats.runningBots}', 'Running'),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
          ),
          _buildStatCell(
            '+${stats.allTimePnl.toStringAsFixed(2)}',
            'All-time PnL',
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell(String value, String label, {bool isPositive = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isPositive ? AppTheme.green : AppTheme.text,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.text3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(ProfileInfo profileInfo) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Profile info', Icons.person_outline),
          _buildFieldRow('Full name', profileInfo.fullName),
          _buildFieldRow('Email', profileInfo.email),
          _buildFieldRow('Role', profileInfo.role, roleColor: true),
          _buildFieldRow('User ID', '#${profileInfo.userId}', isMono: true, isMuted: true),
          _buildFieldRow('Last login', profileInfo.lastLogin, isMuted: true),
        ],
      ),
    );
  }

  Widget _buildApiKeysSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildSectionHeader('API Keys', Icons.vpn_key_outlined),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage API keys',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Add and manage exchange API keys',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.text3,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ApiKeysScreen()),
                    );
                  },
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.blue,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Change password', Icons.lock_outline),
          _buildPasswordForm(),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      children: [
        _buildPasswordField(
          'CURRENT PASSWORD',
          _currentPasswordController,
          _obscureCurrentPassword,
          (value) => setState(() => _obscureCurrentPassword = value),
        ),
        _buildPasswordField(
          'NEW PASSWORD',
          _newPasswordController,
          _obscureNewPassword,
          (value) => setState(() => _obscureNewPassword = value),
          showStrength: true,
        ),
        _buildPasswordField(
          'CONFIRM NEW PASSWORD',
          _confirmPasswordController,
          _obscureConfirmPassword,
          (value) => setState(() => _obscureConfirmPassword = value),
        ),
        _buildPasswordSubmitButton(),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    Function(bool) onToggle, {
    bool showStrength = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
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
          TextField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.text,
              ),
              decoration: InputDecoration(
                hintText: showStrength 
                    ? 'Enter new password' 
                    : 'Enter current password',
                hintStyle: const TextStyle(
                  color: AppTheme.text3,
                ),
                filled: true,
                fillColor: AppTheme.bg3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.border2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.border2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppTheme.blue.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(12, 11, 40, 11),
                suffixIcon: GestureDetector(
                  onTap: () => onToggle(!obscureText),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    child: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 15,
                      color: AppTheme.text3,
                    ),
                  ),
                ),
              ),
              onChanged: showStrength ? (value) => _updatePasswordStrength(value) : null,
            ),
          if (showStrength) ...[
            const SizedBox(height: 7),
            _buildPasswordStrengthBar(),
            const SizedBox(height: 4),
            Text(
              _passwordStrengthLabel,
              style: TextStyle(
                fontSize: 10,
                color: _passwordStrengthColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthBar() {
    return Row(
      children: [
        _buildStrengthSegment(0),
        const SizedBox(width: 3),
        _buildStrengthSegment(1),
        const SizedBox(width: 3),
        _buildStrengthSegment(2),
        const SizedBox(width: 3),
        _buildStrengthSegment(3),
      ],
    );
  }

  Widget _buildStrengthSegment(int index) {
    final bool isFilled = index < _passwordStrength;
    Color color = AppTheme.bg4;
    
    if (isFilled) {
      if (_passwordStrength <= 1) {
        color = AppTheme.red;
      } else if (_passwordStrength <= 2) {
        color = AppTheme.amber;
      } else {
        color = AppTheme.green;
      }
    }
    
    return Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPasswordSubmitButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: ElevatedButton(
        onPressed: _isChangingPassword ? null : _handleChangePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: _isChangingPassword
              ? const SizedBox(
                  width: 16,
                  height: 16,
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
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildSectionHeader('Danger zone', Icons.warning, isDanger: true),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete account',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.red,
                        fontWeight: FontWeight.w500,
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
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.red,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {bool isDanger = false}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: isDanger ? AppTheme.red : AppTheme.blue,
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDanger ? AppTheme.red : AppTheme.blue,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value, {bool isMono = false, bool isMuted = false, bool roleColor = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.text2,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: roleColor ? AppTheme.amber : (isMuted ? AppTheme.text3 : AppTheme.text),
              fontWeight: FontWeight.w500,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          _buildTabItem(Icons.grid_view, 'Dashboard', false),
          _buildTabItem(Icons.show_chart, 'Bots', false),
          _buildTabItem(Icons.receipt_long, 'Trades', false),
          _buildTabItem(Icons.person, 'Account', true),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActive) {
            Navigator.pop(context);
          }
        },
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
            if (isActive) ...[
              const SizedBox(height: 1),
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
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.clearToken();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  void _updatePasswordStrength(String password) {
    int score = 0;
    
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[0-9]')) && password.contains(RegExp(r'[a-zA-Z]'))) score++;
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) score++;
    
    setState(() {
      _passwordStrength = score;
      
      final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
      _passwordStrengthLabel = password.isEmpty 
          ? 'Min 8 characters, include numbers & symbols' 
          : labels[score] ?? 'Strong';
      
      if (score >= 3) {
        _passwordStrengthColor = AppTheme.green;
      } else if (score >= 2) {
        _passwordStrengthColor = AppTheme.amber;
      } else {
        _passwordStrengthColor = AppTheme.text3;
      }
    });
  }

  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (currentPassword.isEmpty) {
      _showError('Please enter your current password');
      return;
    }

    if (newPassword.isEmpty) {
      _showError('Please enter a new password');
      return;
    }

    if (newPassword.length < 8) {
      _showError('New password must be at least 8 characters long');
      return;
    }

    if (newPassword == currentPassword) {
      _showError('New password must be different from current password');
      return;
    }

    if (confirmPassword.isEmpty) {
      _showError('Please confirm your new password');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('New passwords do not match');
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final response = await UnifiedApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response['success'] == true) {
        _showSuccess(response['message'] ?? 'Password changed successfully');
        // Clear form
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() {
          _passwordStrength = 0;
          _passwordStrengthLabel = 'Min 8 characters, include numbers & symbols';
          _passwordStrengthColor = AppTheme.text3;
        });
      } else {
        _showError(response['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      _showError('Error changing password: $e');
    } finally {
      setState(() {
        _isChangingPassword = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.green,
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
