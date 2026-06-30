import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/providers/auth_provider.dart';
import 'package:zippa_app/providers/job_provider.dart';
import 'package:zippa_app/providers/rider_provider.dart';
import 'package:zippa_app/screens/auth/login_screen.dart';
import 'package:zippa_app/screens/rider/active_job_screen.dart';
import 'package:zippa_app/models/job.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RiderProvider>().fetchProfile();
      context.read<JobProvider>().fetchJobs();
    });
  }

  Future<void> _refresh() async {
    await context.read<JobProvider>().fetchJobs();
  }

  Future<void> _acceptJob(String jobId) async {
    final jobs = context.read<JobProvider>();
    final ok   = await jobs.updateJobStatus(jobId, 'accepted');
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content        : Text('Job accepted! Head to pickup location.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => ActiveJobScreen(jobId: jobId)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content        : Text(jobs.error ?? 'Failed to accept job'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final rider  = context.watch<RiderProvider>();
    final jobs   = context.watch<JobProvider>();
    final pendingJobs = jobs.jobs.where((j) => j.status == 'pending').toList();

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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child    : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child  : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting + availability toggle card
              Container(
                width      : double.infinity,
                padding    : const EdgeInsets.all(20),
                decoration : BoxDecoration(
                  gradient   : const LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${auth.user?.fullName.split(' ').first ?? ''}! 🏍️',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${rider.profile?.rating ?? "0.00"} • '
                        '${rider.profile?.totalDeliveries ?? 0} deliveries',
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Container(
                      padding   : const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color       : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(
                              rider.profile?.isAvailable == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: rider.profile?.isAvailable == true
                                  ? Colors.green
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              rider.profile?.isAvailable == true
                                  ? 'You are Online'
                                  : 'You are Offline',
                              style: const TextStyle(
                                  color     : Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ]),
                          Switch(
                            value          : rider.profile?.isAvailable ?? false,
                            activeColor    : const Color(0xFFE94560),
                            onChanged      : (val) =>
                                rider.toggleAvailability(val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats row
              Row(children: [
                _StatCard(
                  label: 'Available Jobs',
                  value: pendingJobs.length.toString(),
                  icon : Icons.work_outline,
                  color: const Color(0xFFE94560),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Total Deliveries',
                  value: (rider.profile?.totalDeliveries ?? 0).toString(),
                  icon : Icons.local_shipping_outlined,
                  color: const Color(0xFF1A1A2E),
                ),
              ]),
              const SizedBox(height: 24),

              // Available jobs
              const Text('Available Jobs',
                  style: TextStyle(
                      fontSize  : 16,
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFF1A1A2E))),
              const SizedBox(height: 12),

              if (rider.profile?.isAvailable != true)
                Container(
                  width     : double.infinity,
                  padding   : const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color       : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border      : Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Turn on availability to start receiving jobs',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ]),
                )
              else if (jobs.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (pendingJobs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child  : Column(children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No jobs available right now',
                          style: TextStyle(color: Colors.grey)),
                    ]),
                  ),
                )
              else
                ...pendingJobs.map((job) => _AvailableJobCard(
                      job     : job,
                      onAccept: () => _acceptJob(job.id),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Available Job Card ──────────────────────────────────────────────────────
class _AvailableJobCard extends StatelessWidget {
  final DeliveryJob   job;
  final VoidCallback  onAccept;
  const _AvailableJobCard({required this.job, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin    : const EdgeInsets.only(bottom: 12),
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
            children         : [
              Container(
                padding   : const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color       : const Color(0xFFE94560).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(job.packageType.toUpperCase(),
                    style: const TextStyle(
                        color     : Color(0xFFE94560),
                        fontSize  : 10,
                        fontWeight: FontWeight.bold)),
              ),
              if (job.estimatedFare != null)
                Text('GHS ${job.estimatedFare}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize  : 16,
                        color     : Color(0xFF1A1A2E))),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.circle, size: 10, color: Color(0xFFE94560)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(job.pickupAddress,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on, size: 10, color: Color(0xFF1A1A2E)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(job.dropoffAddress,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width : double.infinity,
            height: 44,
            child : ElevatedButton(
              onPressed: onAccept,
              style    : ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Accept Job',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color  color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding   : const EdgeInsets.all(14),
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
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize  : 22,
                    fontWeight: FontWeight.bold,
                    color     : color)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}