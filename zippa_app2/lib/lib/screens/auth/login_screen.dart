import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/providers/auth_provider.dart';
import 'package:zippa_app/screens/auth/register_screen.dart';
import 'package:zippa_app/screens/customer/home_screen.dart';
import 'package:zippa_app/screens/rider/rider_home_screen.dart';
import 'package:zippa_app/widget/common/custom_button.dart';
import 'package:zippa_app/widget/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _email     = TextEditingController();
  final _password  = TextEditingController();
  bool  _obscure   = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(
      email   : _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    if (ok) {
      final role = auth.user?.role;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => role == 'rider'
              ? const RiderHomeScreen()
              : const CustomerHomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content         : Text(auth.error ?? 'Login failed'),
          backgroundColor : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child  : Form(
            key  : _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const Icon(Icons.delivery_dining,
                    size: 48, color: Color(0xFFE94560)),
                const SizedBox(height: 16),
                const Text('Welcome back!',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 6),
                const Text('Login to your Zippa account',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 36),
                CustomTextField(
                  label       : 'Email',
                  controller  : _email,
                  prefixIcon  : Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator   : (v) =>
                  v!.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label      : 'Password',
                  controller : _password,
                  prefixIcon : Icons.lock_outline,
                  obscureText: _obscure,
                  suffix     : GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(_obscure
                        ? Icons.visibility_off
                        : Icons.visibility,
                        size: 18, color: Colors.grey),
                  ),
                  validator: (v) =>
                  v!.isEmpty ? 'Password is required' : null,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  label    : 'Login',
                  onPressed: _login,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen())),
                      child: const Text('Register',
                          style: TextStyle(
                              color     : Color(0xFFE94560),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}