import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/providers/auth_provider.dart';
import 'package:zippa_app/screens/customer/home_screen.dart';
import 'package:zippa_app/screens/rider/rider_home_screen.dart';
import 'package:zippa_app/widget/common/custom_button.dart';
import 'package:zippa_app/widget/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _fullName        = TextEditingController();
  final _email           = TextEditingController();
  final _phone           = TextEditingController();
  final _password        = TextEditingController();
  final _confirmPassword = TextEditingController();
  String _role           = 'customer';
  bool   _obscure        = true;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.register(
      fullName       : _fullName.text.trim(),
      email          : _email.text.trim(),
      phone          : _phone.text.trim(),
      password       : _password.text,
      confirmPassword: _confirmPassword.text,
      role           : _role,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _role == 'rider'
              ? const RiderHomeScreen()
              : const CustomerHomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content        : Text(auth.error ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title           : const Text('Create Account'),
        backgroundColor : Colors.white,
        foregroundColor : const Color(0xFF1A1A2E),
        elevation       : 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child  : Form(
            key  : _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Join Zippa',
                    style: TextStyle(
                        fontSize  : 26,
                        fontWeight: FontWeight.bold,
                        color     : Color(0xFF1A1A2E))),
                const SizedBox(height: 6),
                const Text('Create your account to get started',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 28),

                // Role selector
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _role = 'customer'),
                      child: Container(
                        padding     : const EdgeInsets.symmetric(vertical: 14),
                        decoration  : BoxDecoration(
                          color       : _role == 'customer'
                              ? const Color(0xFFE94560)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('Customer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color     : _role == 'customer'
                                    ? Colors.white
                                    : Colors.grey,
                              )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _role = 'rider'),
                      child: Container(
                        padding     : const EdgeInsets.symmetric(vertical: 14),
                        decoration  : BoxDecoration(
                          color       : _role == 'rider'
                              ? const Color(0xFF1A1A2E)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text('Rider',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color     : _role == 'rider'
                                    ? Colors.white
                                    : Colors.grey,
                              )),
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                CustomTextField(
                  label     : 'Full Name',
                  controller: _fullName,
                  prefixIcon: Icons.person_outline,
                  validator : (v) => v!.isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label       : 'Email',
                  controller  : _email,
                  prefixIcon  : Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator   : (v) => v!.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label       : 'Phone',
                  controller  : _phone,
                  prefixIcon  : Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator   : (v) => v!.isEmpty ? 'Phone is required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label      : 'Password',
                  controller : _password,
                  prefixIcon : Icons.lock_outline,
                  obscureText: _obscure,
                  suffix     : GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 18, color: Colors.grey,
                    ),
                  ),
                  validator: (v) => v!.length < 6
                      ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label      : 'Confirm Password',
                  controller : _confirmPassword,
                  prefixIcon : Icons.lock_outline,
                  obscureText: true,
                  validator  : (v) => v != _password.text
                      ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  label    : 'Create Account',
                  onPressed: _register,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Login',
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