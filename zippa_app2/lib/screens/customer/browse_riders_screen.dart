import 'package:flutter/material.dart';
import 'package:zippa_app/core/api_client.dart';
import 'package:zippa_app/core/constants.dart';
import 'package:zippa_app/screens/customer/rider_detail_screen.dart';

class BrowseRidersScreen extends StatefulWidget {
  const BrowseRidersScreen({super.key});

  @override
  State<BrowseRidersScreen> createState() => _BrowseRidersScreenState();
}

class _BrowseRidersScreenState extends State<BrowseRidersScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _riders = [];

  @override
  void initState() {
    super.initState();
    _fetchRiders();
  }

  Future<void> _fetchRiders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.dio.get(AppConstants.nearbyRiders);
      final list = (res.data as List)
          .map((r) => Map<String, dynamic>.from(r))
          .toList();
      if (!mounted) return;
      setState(() {
        _riders = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load riders. Pull to refresh.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Browse Riders')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _fetchRiders,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_riders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No riders available right now',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                'Try posting a delivery job instead',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRiders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _riders.length,
        itemBuilder: (_, i) => _RiderCard(rider: _riders[i]),
      ),
    );
  }
}

// ── Rider Card ────────────────────────────────────────────────────────────────
class _RiderCard extends StatelessWidget {
  final Map<String, dynamic> rider;
  const _RiderCard({required this.rider});

  @override
  Widget build(BuildContext context) {
    final name = (rider['full_name'] ?? 'Unknown').toString();
    final vehicle = (rider['vehicle_type'] ?? 'unknown').toString();
    final plate = (rider['vehicle_plate'] ?? '').toString();
    final rating = (rider['rating'] ?? '0.00').toString();
    final deliveries = rider['total_deliveries'] ?? 0;
    final photo = rider['photo'];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RiderDetailScreen(rider: rider)),
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
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1A1A2E),
              backgroundImage: (photo != null && photo.toString().isNotEmpty)
                  ? NetworkImage(photo.toString())
                  : null,
              child: (photo == null || photo.toString().isEmpty)
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    plate.isNotEmpty
                        ? '${_capitalize(vehicle)} • $plate'
                        : _capitalize(vehicle),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.local_shipping_outlined,
                        color: Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$deliveries ${deliveries == 1 ? "delivery" : "deliveries"}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
