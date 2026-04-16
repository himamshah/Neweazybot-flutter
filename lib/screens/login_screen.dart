import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import 'bots_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08090B),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 390,
            decoration: BoxDecoration(
              color: const Color(0xFF08090B),
              borderRadius: BorderRadius.circular(44),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 80,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHero(),
                _buildLoginForm(),
                _buildDivider(),
                _buildSignInRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 44, 28, 36),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          // Grid lines background (only in hero section)
          Positioned.fill(
            child: ClipRect(
              child: CustomPaint(
                painter: _GridLinesPainter(),
              ),
            ),
          ),
          // Chart line at bottom with opacity 0.15 (only in hero section)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: ClipRect(
              child: CustomPaint(
                painter: ChartLinePainter(),
              ),
            ),
          ),
          // Hero content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1a3a5c), Color(0xFF0e2040)],
                  ),
                  border: Border.all(
                    color: AppTheme.blue.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.blue.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: const Size(28, 28),
                  painter: LogoPainter(),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'TradeBot',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Automated crypto trading',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.text3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
      child: Column(
        children: [
          _buildInputField(
            label: 'EMAIL ADDRESS',
            controller: _emailController,
            placeholder: 'you@example.com',
            isPassword: false,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 6),
          _buildInputField(
            label: 'PASSWORD',
            controller: _passwordController,
            placeholder: 'Enter your password',
            isPassword: true,
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // TODO: Implement forgot password
              },
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required bool isPassword,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.text2,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bg3,
            border: Border.all(color: AppTheme.border2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                color: AppTheme.text3,
              ),
              prefixIcon: icon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        icon,
                        size: 16,
                        color: AppTheme.text3,
                      ),
                    )
                  : null,
              suffixIcon: isPassword
                  ? Padding(
                      padding: const EdgeInsets.all(13),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          size: 16,
                          color: AppTheme.text3,
                        ),
                      ),
                    )
                  : null,
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
                'Sign in',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppTheme.border,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'New here?',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.text3,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppTheme.border,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInRow() {
    return const Center(
      child: Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.text3,
          ),
          children: [
            TextSpan(
              text: 'Contact your admin',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('LOGIN DEBUG: Starting login process');
      print('LOGIN DEBUG: Email: ${_emailController.text.trim()}');
      print('LOGIN DEBUG: Password length: ${_passwordController.text.length}');
      
      final response = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('LOGIN DEBUG: Login successful');
      print('LOGIN DEBUG: User: ${response.user.name}');
      print('LOGIN DEBUG: Token length: ${response.token.length}');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BotsListScreen(),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('LOGIN ERROR: Login failed');
      print('LOGIN ERROR: Error: $e');
      print('LOGIN ERROR: Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppTheme.red,
            duration: const Duration(seconds: 5),
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

// Custom painters for the chart line and logo
class ChartLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.blue
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final points = [
      Offset(0, size.height * 0.83),
      Offset(size.width * 0.103, size.height * 0.63),
      Offset(size.width * 0.205, size.height * 0.70),
      Offset(size.width * 0.308, size.height * 0.42),
      Offset(size.width * 0.410, size.height * 0.50),
      Offset(size.width * 0.513, size.height * 0.30),
      Offset(size.width * 0.615, size.height * 0.18),
      Offset(size.width * 0.718, size.height * 0.22),
      Offset(size.width * 0.821, size.height * 0.10),
      Offset(size.width * 0.923, size.height * 0.15),
      Offset(size.width, 0),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width * 0.93, size.height * 0.36);

    // Draw the logo lines
    final logoPoints = [
      Offset(size.width * 0.07, size.height * 0.79),
      Offset(size.width * 0.29, size.height * 0.50),
      Offset(size.width * 0.46, size.height * 0.61),
      Offset(size.width * 0.71, size.height * 0.29),
      Offset(size.width, size.height * 0.36),
    ];

    // Draw lines
    for (int i = 0; i < logoPoints.length - 1; i++) {
      canvas.drawLine(logoPoints[i], logoPoints[i + 1], paint);
    }

    // Draw circle at the end
    final circlePaint = Paint()
      ..color = AppTheme.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size.width * 0.09, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for blue grid lines background
class _GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gridSize = 32.0;
    const lineColor = Color(0xFF4D9EFF);
    const lineOpacity = 0.04;
    
    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      final opacity = _calculateGridOpacity(y, size.height);
      final paint = Paint()
        ..color = lineColor.withOpacity(lineOpacity * opacity)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      final opacity = _calculateGridOpacity(size.height * 0.5, size.height);
      final paint = Paint()
        ..color = lineColor.withOpacity(lineOpacity * opacity)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  double _calculateGridOpacity(double y, double totalHeight) {
    // Create gradient effect: transparent 0% -> visible 30% -> visible 70% -> transparent 100%
    final topThreshold = totalHeight * 0.3;
    final bottomThreshold = totalHeight * 0.7;
    
    if (y < topThreshold) {
      return y / topThreshold; // Fade in
    } else if (y > bottomThreshold) {
      return (totalHeight - y) / (totalHeight - bottomThreshold); // Fade out
    } else {
      return 1.0; // Fully visible
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
