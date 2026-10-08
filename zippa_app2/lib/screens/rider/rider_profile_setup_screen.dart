import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/core/api_client.dart';
import 'package:zippa_app/core/constants.dart';
import 'package:zippa_app/providers/rider_provider.dart';
import 'package:zippa_app/screens/rider/rider_home_screen.dart';
import 'package:zippa_app/widget/common/custom_button.dart';
import 'package:zippa_app/widget/common/custom_text_field.dart';
import 'package:zippa_app/core/storage.dart';
import 'package:zippa_app/screens/auth/login_screen.dart';

class RiderProfileSetupScreen extends StatefulWidget {
  const RiderProfileSetupScreen({super.key});

  @override
  State<RiderProfileSetupScreen> createState() =>
      _RiderProfileSetupScreenState();
}

class _RiderProfileSetupScreenState extends State<RiderProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehiclePlate = TextEditingController();
  final _licenseNumber = TextEditingController();
  String _vehicleType = 'motorcycle';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {'type': 'bicycle', 'icon': Icons.directions_bike},
    {'type': 'motorcycle', 'icon': Icons.motorcycle},
    {'type': 'car', 'icon': Icons.directions_car},
    {'type': 'van', 'icon': Icons.airport_shuttle},
  ];

  @override
  void dispose() {
    _vehiclePlate.dispose();
    _licenseNumber.dispose();
    super.dispose();
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ApiClient.dio.post(
        AppConstants.riderProfile,
        data: {
          'vehicle_type': _vehicleType,
          'vehicle_plate': _vehiclePlate.text.trim(),
          'license_number': _licenseNumber.text.trim(),
        },
      );
      if (!mounted) return;
      await context.read<RiderProvider>().fetchProfile();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RiderHomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              await AppStorage.clear();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Color(0xFFE94560)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Icon(
                  Icons.motorcycle,
                  size: 48,
                  color: Color(0xFFE94560),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Set Up Your Rider Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete your profile to start accepting delivery jobs.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Vehicle type selector
                const Text(
                  'Vehicle Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _vehicleTypes.map((v) {
                    final selected = v['type'] == _vehicleType;
                    return GestureDetector(
                      onTap: () => setState(() => _vehicleType = v['type']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1A1A2E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF1A1A2E)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              v['icon'],
                              color: selected ? Colors.white : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              v['type'][0].toUpperCase() +
                                  v['type'].substring(1),
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Vehicle Plate Number',
                  controller: _vehiclePlate,
                  prefixIcon: Icons.credit_card,
                  validator: (v) =>
                      v!.isEmpty ? 'Vehicle plate is required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Driver\'s License Number',
                  controller: _licenseNumber,
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) =>
                      v!.isEmpty ? 'License number is required' : null,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Complete Setup',
                  onPressed: _createProfile,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
