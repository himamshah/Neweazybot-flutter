import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/bots_list_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const EasyBotApp());
}

class EasyBotApp extends StatelessWidget {
  const EasyBotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyBot',
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    setState(() {
      _isLoading = false;
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.blueDim,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppTheme.blue, width: 2),
                ),
                child: const Icon(
                  Icons.trending_up,
                  size: 30,
                  color: AppTheme.blue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'EasyBot',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                color: AppTheme.blue,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const BotsListScreen() : const LoginScreen();
  }
}
