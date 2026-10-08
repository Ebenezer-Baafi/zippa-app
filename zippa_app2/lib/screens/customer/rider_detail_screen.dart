import 'package:flutter/material.dart';
import 'package:zippa_app/screens/customer/create_job_screen.dart';

class RiderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> rider;
  const RiderDetailScreen({super.key, required this.rider});

  @override
  Widget build(BuildContext context) {
    final name = (rider['full_name'] ?? 'Unknown').toString();
    final email = (rider['email'] ?? '').toString();
    final phone = (rider['phone'] ?? '').toString();
    final vehicle = (rider['vehicle_type'] ?? 'unknown').toString();
    final plate = (rider['vehicle_plate'] ?? '').toString();
    final license = (rider['license_number'] ?? '').toString();
    final rating = (rider['rating'] ?? '0.00').toString();
    final deliveries = rider['total_deliveries'] ?? 0;
    final photo = rider['photo'];
    final riderId = rider['id']?.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Rider Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                        (photo != null && photo.toString().isNotEmpty)
                        ? NetworkImage(photo.toString())
                        : null,
                    child: (photo == null || photo.toString().isEmpty)
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$rating rating',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.local_shipping_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$deliveries ${deliveries == 1 ? "delivery" : "deliveries"}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Vehicle info ──────────────────────────────────────
            _InfoCard(
              title: 'Vehicle',
              children: [
                _InfoRow(label: 'Type', value: _capitalize(vehicle)),
                if (plate.isNotEmpty) _InfoRow(label: 'Plate', value: plate),
                if (license.isNotEmpty)
                  _InfoRow(label: 'License', value: license),
              ],
            ),
            const SizedBox(height: 12),

            // ── Contact info ──────────────────────────────────────
            _InfoCard(
              title: 'Contact',
              children: [
                if (email.isNotEmpty) _InfoRow(label: 'Email', value: email),
                if (phone.isNotEmpty) _InfoRow(label: 'Phone', value: phone),
              ],
            ),
            const SizedBox(height: 32),

            // ── Send Request button ───────────────────────────────
            ElevatedButton.icon(
              onPressed: riderId == null
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateJobScreen(riderId: riderId, riderName: name),
                      ),
                    ),
              icon: const Icon(Icons.send),
              label: Text(
                'Send Delivery Request to $name',
                textAlign: TextAlign.center,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Small note
            const Center(
              child: Text(
                'The rider will receive your request and can accept or decline.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
