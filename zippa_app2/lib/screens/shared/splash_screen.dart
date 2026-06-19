import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/core/storage.dart';
import 'package:zippa_app/providers/auth_provider.dart';
import 'package:zippa_app/screens/auth/login_screen.dart';
import 'package:zippa_app/screens/customer/home_screen.dart';
import 'package:zippa_app/screens/rider/rider_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final token = await AppStorage.getAccessToken();
    final role  = await AppStorage.getRole();

    if (token == null) {
      _go(const LoginScreen());
      return;
    }

    // fetch user profile
    await context.read<AuthProvider>().fetchMe();
    if (!mounted) return;

    if (role == 'rider') {
      _go(const RiderHomeScreen());
    } else {
      _go(const CustomerHomeScreen());
    }
  }

  void _go(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delivery_dining, size: 80, color: Color(0xFFE94560)),
            SizedBox(height: 16),
            Text(
              'ZIPPA',
              style: TextStyle(
                fontSize   : 36,
                fontWeight : FontWeight.bold,
                color      : Colors.white,
                letterSpacing: 6,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Deliver anything, anywhere.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Color(0xFFE94560)),
          ],
        ),
      ),
    );
  }
}