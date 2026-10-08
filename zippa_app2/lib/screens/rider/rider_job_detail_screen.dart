import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/models/job.dart';
import 'package:zippa_app/providers/job_provider.dart';
import 'package:zippa_app/providers/rider_provider.dart';
import 'package:zippa_app/screens/rider/active_job_screen.dart';
import 'package:zippa_app/screens/shared/negotiations_screen.dart';
import 'package:zippa_app/widget/common/custom_button.dart';

class RiderJobDetailScreen extends StatefulWidget {
  final DeliveryJob job;
  const RiderJobDetailScreen({super.key, required this.job});

  @override
  State<RiderJobDetailScreen> createState() => _RiderJobDetailScreenState();
}

class _RiderJobDetailScreenState extends State<RiderJobDetailScreen> {
  bool _accepting = false;

  Future<void> _acceptJob() async {
    setState(() => _accepting = true);
    final jobs = context.read<JobProvider>();
    final ok = await jobs.updateJobStatus(widget.job.id, 'accepted');
    if (!mounted) return;
    setState(() => _accepting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job accepted! Head to pickup location.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ActiveJobScreen(jobId: widget.job.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jobs.error ?? 'Failed to accept job'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final rider = context.watch<RiderProvider>();
    final notApproved = rider.profile?.isApproved != true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer offer banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer\'s Offered Price',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.estimatedFare != null
                        ? 'GHS ${job.estimatedFare}'
                        : 'Not specified',
                    style: const TextStyle(
                      color: Color(0xFFE94560),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You can accept this price or negotiate a better deal',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Admin approval warning ───────────────────────────────
            if (notApproved) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Pending Approval',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your rider account has not been approved by an '
                            'admin yet. You cannot accept jobs until an admin '
                            'verifies your profile.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Package info
            _InfoCard(
              title: 'Package Info',
              children: [
                _InfoRow(label: 'Type', value: job.packageType.toUpperCase()),
                if (job.packageDescription.isNotEmpty)
                  _InfoRow(label: 'Description', value: job.packageDescription),
              ],
            ),
            const SizedBox(height: 12),

            // Locations
            _InfoCard(
              title: 'Delivery Route',
              children: [
                _InfoRow(
                  label: 'Pickup',
                  value: job.pickupAddress,
                  icon: Icons.circle,
                  iconColor: const Color(0xFFE94560),
                ),
                const Divider(),
                _InfoRow(
                  label: 'Dropoff',
                  value: job.dropoffAddress,
                  icon: Icons.location_on,
                  iconColor: const Color(0xFF1A1A2E),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer info
            _InfoCard(
              title: 'Customer',
              children: [
                _InfoRow(
                  label: 'Name',
                  value: job.customerName,
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF1A1A2E),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Negotiate button (always available)
            CustomButton(
              label: '🤝 Negotiate Price',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NegotiationsScreen(jobId: job.id, userRole: 'rider'),
                ),
              ),
              color: Colors.orange.shade700,
            ),
            const SizedBox(height: 12),

            // Accept button OR disabled state
            if (notApproved)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Accept unavailable — pending approval',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              CustomButton(
                label: 'Accept Job — GHS ${job.estimatedFare ?? ""}',
                onPressed: _acceptJob,
                isLoading: _accepting,
                color: const Color(0xFF1A1A2E),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
  final IconData? icon;
  final Color? iconColor;
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? Colors.grey),
            const SizedBox(width: 6),
          ],
          SizedBox(
            width: 80,
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
