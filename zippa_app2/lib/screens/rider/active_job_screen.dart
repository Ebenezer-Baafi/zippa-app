import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/providers/job_provider.dart';
import 'package:zippa_app/screens/rider/rider_home_screen.dart';
import 'package:zippa_app/widgets/common/custom_button.dart';

class ActiveJobScreen extends StatefulWidget {
  final String jobId;
  const ActiveJobScreen({super.key, required this.jobId});

  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobDetail(widget.jobId);
    });
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _updating = true);
    final jobs = context.read<JobProvider>();
    final ok   = await jobs.updateJobStatus(widget.jobId, newStatus);
    if (!mounted) return;
    setState(() => _updating = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content        : Text(_statusMessage(newStatus)),
          backgroundColor: Colors.green,
        ),
      );
      if (newStatus == 'delivered') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RiderHomeScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content        : Text(jobs.error ?? 'Failed to update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'picked_up' : return 'Package marked as picked up!';
      case 'delivered' : return 'Delivery completed! Great job!';
      default           : return 'Status updated!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobProvider>();
    final job  = jobs.activeJob;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar          : AppBar(title: const Text('Active Delivery')),
      body            : jobs.isLoading && job == null
          ? const Center(child: CircularProgressIndicator())
          : job == null
              ? const Center(child: Text('Job not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress tracker
                      _ProgressTracker(status: job.status),
                      const SizedBox(height: 24),

                      // Package info
                      Container(
                        width     : double.infinity,
                        padding   : const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color       : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow   : [
                            BoxShadow(
                              color    : Colors.black.withOpacity(0.05),
                              blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(job.packageType.toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color     : Color(0xFF1A1A2E))),
                                if (job.estimatedFare != null)
                                  Text('GHS ${job.estimatedFare}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize  : 18,
                                          color     : Color(0xFFE94560))),
                              ],
                            ),
                            if (job.packageDescription.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(job.packageDescription,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ],
                            const Divider(height: 24),
                            Row(children: [
                              const Icon(Icons.circle,
                                  size: 10, color: Color(0xFFE94560)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Pickup',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 11)),
                                    Text(job.pickupAddress,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              const Icon(Icons.location_on,
                                  size: 10, color: Color(0xFF1A1A2E)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Dropoff',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 11)),
                                    Text(job.dropoffAddress,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ]),
                            const Divider(height: 24),
                            Row(children: [
                              const Icon(Icons.person_outline,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text('Customer: ${job.customerName}',
                                  style: const TextStyle(fontSize: 13)),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action button based on status
                      if (job.status == 'accepted')
                        CustomButton(
                          label    : 'Mark as Picked Up',
                          onPressed: () => _updateStatus('picked_up'),
                          isLoading: _updating,
                        )
                      else if (job.status == 'picked_up')
                        CustomButton(
                          label    : 'Mark as Delivered',
                          onPressed: () => _updateStatus('delivered'),
                          isLoading: _updating,
                          color    : Colors.green,
                        )
                      else if (job.status == 'delivered')
                        Container(
                          width     : double.infinity,
                          padding   : const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color       : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border      : Border.all(
                                color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text('Delivery Completed',
                                  style: TextStyle(
                                      color     : Colors.green.shade700,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

// ── Progress Tracker ──────────────────────────────────────────────────────────
class _ProgressTracker extends StatelessWidget {
  final String status;
  const _ProgressTracker({required this.status});

  int get _currentStep {
    switch (status) {
      case 'accepted'  : return 0;
      case 'picked_up' : return 1;
      case 'delivered' : return 2;
      default          : return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Accepted', 'Picked Up', 'Delivered'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isEven) {
          final stepIndex = i ~/ 2;
          final isActive  = stepIndex <= _currentStep;
          return Column(children: [
            Container(
              width     : 32, height: 32,
              decoration: BoxDecoration(
                color : isActive
                    ? const Color(0xFFE94560) : Colors.grey.shade300,
                shape : BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.check : Icons.circle,
                color: Colors.white, size: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(steps[stepIndex],
                style: TextStyle(
                  fontSize  : 10,
                  fontWeight: FontWeight.w600,
                  color     : isActive
                      ? const Color(0xFF1A1A2E) : Colors.grey,
                )),
          ]);
        } else {
          final lineActive = (i - 1) ~/ 2 < _currentStep;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 18),
              color : lineActive
                  ? const Color(0xFFE94560) : Colors.grey.shade300,
            ),
          );
        }
      }),
    );
  }
}