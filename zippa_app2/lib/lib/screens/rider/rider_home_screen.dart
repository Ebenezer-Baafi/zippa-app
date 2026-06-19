import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/providers/auth_provider.dart';
import 'package:zippa_app/screens/auth/login_screen.dart';

class RiderHomeScreen extends StatelessWidget {
  const RiderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Zippa Rider'),
        actions: [
          IconButton(
            icon     : const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.motorcycle,
                size: 64, color: Color(0xFF1A1A2E)),
            const SizedBox(height: 16),
            Text(
              'Welcome, ${auth.user?.fullName ?? ''}!',
              style: const TextStyle(
                  fontSize  : 22,
                  fontWeight: FontWeight.bold,
                  color     : Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            const Text('Rider Dashboard coming soon...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}