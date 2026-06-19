import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/providers/auth_provider.dart';
import 'package:zippa_app/providers/job_provider.dart';
import 'package:zippa_app/screens/auth/login_screen.dart';
import 'package:zippa_app/screens/customer/create_job_screen.dart';
import 'package:zippa_app/screens/customer/job_detail_screen.dart';
import 'package:zippa_app/models/job.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobs = context.watch<JobProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Zippa'),
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
      body: IndexedStack(
        index   : _currentIndex,
        children: [
          _HomeTab(auth: auth, jobs: jobs),
          _JobsTab(jobs: jobs),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex     : _currentIndex,
        onTap            : (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFE94560),
        items            : const [
          BottomNavigationBarItem(
            icon : Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon : Icon(Icons.list_alt_outlined),
            label: 'My Jobs',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed       : () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CreateJobScreen())),
        backgroundColor : const Color(0xFFE94560),
        icon            : const Icon(Icons.add, color: Colors.white),
        label           : const Text('New Delivery',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ── Home Tab ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final AuthProvider auth;
  final JobProvider  jobs;

  const _HomeTab({required this.auth, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child  : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting card
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
                  'Hello, ${auth.user?.fullName.split(' ').first ?? ''}! 👋',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text('Where would you like to send a package today?',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed  : () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const CreateJobScreen())),
                  icon       : const Icon(Icons.add, size: 18),
                  label      : const Text('Create Delivery'),
                  style      : ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    foregroundColor: Colors.white,
                    shape          : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding        : const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    minimumSize    : Size.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats row
          Row(children: [
            _StatCard(
              label: 'Total Jobs',
              value: jobs.jobs.length.toString(),
              icon : Icons.work_outline,
              color: const Color(0xFF1A1A2E),
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Active',
              value: jobs.jobs
                  .where((j) =>
              j.status == 'accepted' || j.status == 'picked_up')
                  .length
                  .toString(),
              icon : Icons.local_shipping_outlined,
              color: const Color(0xFFE94560),
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'Delivered',
              value: jobs.jobs
                  .where((j) => j.status == 'delivered')
                  .length
                  .toString(),
              icon : Icons.check_circle_outline,
              color: Colors.green,
            ),
          ]),
          const SizedBox(height: 24),

          // Recent jobs
          const Text('Recent Deliveries',
              style: TextStyle(
                  fontSize  : 16,
                  fontWeight: FontWeight.bold,
                  color     : Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          if (jobs.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (jobs.jobs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child  : Column(children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No deliveries yet',
                      style: TextStyle(color: Colors.grey)),
                ]),
              ),
            )
          else
            ...jobs.jobs.take(3).map((job) => _JobCard(job: job)),
        ],
      ),
    );
  }
}

// ── Jobs Tab ──────────────────────────────────────────────────────────────────
class _JobsTab extends StatelessWidget {
  final JobProvider jobs;
  const _JobsTab({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return jobs.isLoading
        ? const Center(child: CircularProgressIndicator())
        : jobs.jobs.isEmpty
        ? const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No jobs yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    )
        : RefreshIndicator(
      onRefresh: () => context.read<JobProvider>().fetchJobs(),
      child    : ListView.builder(
        padding    : const EdgeInsets.all(16),
        itemCount  : jobs.jobs.length,
        itemBuilder: (_, i) => _JobCard(job: jobs.jobs[i]),
      ),
    );
  }
}

// ── Job Card ──────────────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final DeliveryJob job;
  const _JobCard({required this.job});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending'   : return Colors.orange;
      case 'accepted'  : return Colors.blue;
      case 'picked_up' : return Colors.purple;
      case 'delivered' : return Colors.green;
      case 'cancelled' : return Colors.red;
      default          : return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => JobDetailScreen(jobId: job.id))),
      child: Container(
        margin    : const EdgeInsets.only(bottom: 12),
        padding   : const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color       : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow   : [
            BoxShadow(
                color  : Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children         : [
                Text(job.packageType.toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color     : Color(0xFF1A1A2E),
                        fontSize  : 13)),
                Container(
                  padding   : const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color       : _statusColor(job.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                        color    : _statusColor(job.status),
                        fontSize : 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.circle, size: 10, color: Color(0xFFE94560)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(job.pickupAddress,
                    style    : const TextStyle(fontSize: 13),
                    maxLines : 1,
                    overflow : TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on, size: 10, color: Color(0xFF1A1A2E)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(job.dropoffAddress,
                    style   : const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            if (job.estimatedFare != null) ...[
              const SizedBox(height: 10),
              Text('GHS ${job.estimatedFare}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFFE94560))),
            ],
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