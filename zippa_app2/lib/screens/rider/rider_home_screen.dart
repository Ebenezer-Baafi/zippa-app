import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/providers/auth_provider.dart';
import 'package:zippa_app/providers/job_provider.dart';
import 'package:zippa_app/providers/rider_provider.dart';
import 'package:zippa_app/screens/auth/login_screen.dart';
import 'package:zippa_app/models/job.dart';
import 'package:zippa_app/core/api_client.dart';
import 'package:zippa_app/core/constants.dart';
import 'package:zippa_app/screens/shared/notifications_screen.dart';
import 'package:zippa_app/screens/rider/rider_job_detail_screen.dart';
import 'package:zippa_app/screens/rider/rider_profile_setup_screen.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final riderProvider = context.read<RiderProvider>();
      await riderProvider.fetchProfile();

      if (!mounted) return;

      // Defensive guard: if no profile, redirect to setup
      if (riderProvider.profile == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RiderProfileSetupScreen()),
        );
        return;
      }

      if (!mounted) return;
      context.read<JobProvider>().fetchJobs();
    });
  }

  Future<void> _refresh() async {
    await context.read<JobProvider>().fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rider = context.watch<RiderProvider>();
    final jobs = context.watch<JobProvider>();
    final pendingJobs = jobs.jobs.where((j) => j.status == 'pending').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Zippa Rider' : 'My Deliveries'),
        actions: [
          const _NotificationBell(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            auth: auth,
            rider: rider,
            jobs: jobs,
            pendingJobs: pendingJobs,
            onRefresh: _refresh,
          ),
          const _MyDeliveriesTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFE94560),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'My Deliveries',
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _fetchUnread();
  }

  Future<void> _fetchUnread() async {
    try {
      final res = await ApiClient.dio.get(
        '${AppConstants.notifications}unread/',
      );
      if (!mounted) return;
      setState(() => _unread = res.data['unread_count'] ?? 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
            _fetchUnread();
          },
        ),
        if (_unread > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFE94560),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$_unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Available Job Card ──────────────────────────────────────────────────────
class _AvailableJobCard extends StatelessWidget {
  final DeliveryJob job;
  final VoidCallback onAccept;

  const _AvailableJobCard({required this.job, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RiderJobDetailScreen(job: job)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE94560).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.packageType.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFE94560),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (job.estimatedFare != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'GHS ${job.estimatedFare}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const Text(
                        'offered',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.circle, size: 10, color: Color(0xFFE94560)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.pickupAddress,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 10,
                  color: Color(0xFF1A1A2E),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.dropoffAddress,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Tap to view details',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

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
        padding: const EdgeInsets.all(10),
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
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final AuthProvider auth;
  final RiderProvider rider;
  final JobProvider jobs;
  final List<dynamic> pendingJobs;
  final Future<void> Function() onRefresh;

  const _HomeTab({
    required this.auth,
    required this.rider,
    required this.jobs,
    required this.pendingJobs,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting + availability toggle card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${auth.user?.fullName.split(' ').first ?? ''}! 🏍️',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${rider.profile?.rating ?? "0.00"} • '
                        '${rider.profile?.totalDeliveries ?? 0} deliveries',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
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
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: rider.profile?.isAvailable ?? false,
                          activeColor: const Color(0xFFE94560),
                          onChanged: (val) => rider.toggleAvailability(val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Approval banner
            if (rider.profile?.isApproved != true)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Your account is pending admin approval. '
                        'You cannot accept jobs yet.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // Stats row
            Row(
              children: [
                _StatCard(
                  label: 'Available Jobs',
                  value: pendingJobs.length.toString(),
                  icon: Icons.work_outline,
                  color: const Color(0xFFE94560),
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Total Deliveries',
                  value: (rider.profile?.totalDeliveries ?? 0).toString(),
                  icon: Icons.local_shipping_outlined,
                  color: const Color(0xFF1A1A2E),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Available jobs
            const Text(
              'Available Jobs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            if (rider.profile?.isAvailable != true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Turn on availability to start receiving jobs',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else if (jobs.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (pendingJobs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No jobs available right now',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...pendingJobs.map(
                (job) => _AvailableJobCard(job: job, onAccept: () {}),
              ),
          ],
        ),
      ),
    );
  }
}

// ── My Deliveries Tab ─────────────────────────────────────────────────────────
class _MyDeliveriesTab extends StatefulWidget {
  const _MyDeliveriesTab();

  @override
  State<_MyDeliveriesTab> createState() => _MyDeliveriesTabState();
}

class _MyDeliveriesTabState extends State<_MyDeliveriesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchMyDeliveries();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobProvider>();
    final myJobs = jobs.jobs; // already filtered by backend (scope=my)

    return jobs.isLoading && myJobs.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : myJobs.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('No deliveries yet', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 4),
                Text(
                  'Accepted jobs will appear here',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: () => context.read<JobProvider>().fetchMyDeliveries(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myJobs.length,
              itemBuilder: (_, i) {
                final job = myJobs[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            job.packageType.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                job.status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              job.status.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                color: _statusColor(job.status),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 10,
                            color: Color(0xFFE94560),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              job.pickupAddress,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 10,
                            color: Color(0xFF1A1A2E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              job.dropoffAddress,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (job.finalFare != null ||
                          job.estimatedFare != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GHS ${job.finalFare ?? job.estimatedFare}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE94560),
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Customer: ${job.customerName}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
  }
}
