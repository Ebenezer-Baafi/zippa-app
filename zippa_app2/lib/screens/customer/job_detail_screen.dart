import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/providers/job_provider.dart';
import 'package:zippa_app/widget/common/custom_button.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobDetail(widget.jobId);
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelJob() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Job'),
        content: const Text('Are you sure you want to cancel this delivery?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final jobs = context.read<JobProvider>();
    try {
      await jobs.dio.patch('/jobs/${widget.jobId}/cancel/');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel job'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobProvider>();
    final job = jobs.activeJob;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Job Detail')),
      body: jobs.isLoading
          ? const Center(child: CircularProgressIndicator())
          : job == null
          ? const Center(child: Text('Job not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusColor(job.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _statusColor(job.status).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _statusColor(job.status),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Status: ${job.status.replaceAll('_', ' ').toUpperCase()}',
                          style: TextStyle(
                            color: _statusColor(job.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Package info
                  _InfoCard(
                    title: 'Package Info',
                    children: [
                      _InfoRow(
                        label: 'Type',
                        value: job.packageType.toUpperCase(),
                      ),
                      if (job.packageDescription.isNotEmpty)
                        _InfoRow(
                          label: 'Description',
                          value: job.packageDescription,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Locations
                  _InfoCard(
                    title: 'Locations',
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

                  // Fare
                  _InfoCard(
                    title: 'Fare Details',
                    children: [
                      _InfoRow(
                        label: 'Estimated Fare',
                        value: job.estimatedFare != null
                            ? 'GHS ${job.estimatedFare}'
                            : 'N/A',
                      ),
                      _InfoRow(
                        label: 'Final Fare',
                        value: job.finalFare != null
                            ? 'GHS ${job.finalFare}'
                            : 'Pending',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rider info
                  if (job.riderName != null)
                    _InfoCard(
                      title: 'Rider',
                      children: [
                        _InfoRow(
                          label: 'Assigned Rider',
                          value: job.riderName!,
                          icon: Icons.person_outline,
                          iconColor: const Color(0xFF1A1A2E),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),

                  // Timestamps
                  _InfoCard(
                    title: 'Timeline',
                    children: [
                      _InfoRow(
                        label: 'Created',
                        value: _formatDate(job.createdAt),
                      ),
                      if (job.acceptedAt != null)
                        _InfoRow(
                          label: 'Accepted',
                          value: _formatDate(job.acceptedAt!),
                        ),
                      if (job.pickedUpAt != null)
                        _InfoRow(
                          label: 'Picked Up',
                          value: _formatDate(job.pickedUpAt!),
                        ),
                      if (job.deliveredAt != null)
                        _InfoRow(
                          label: 'Delivered',
                          value: _formatDate(job.deliveredAt!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Cancel button
                  if (job.status == 'pending')
                    CustomButton(
                      label: 'Cancel Job',
                      onPressed: _cancelJob,
                      color: Colors.red,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
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
            width: 90,
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
