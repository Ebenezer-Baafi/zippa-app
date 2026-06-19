import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/providers/job_provider.dart';
import 'package:zippa_app/widget/common/custom_button.dart';
import 'package:zippa_app/widget/common/custom_text_field.dart';
import 'package:zippa_app/widget/common/address_search_field.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _packageDescription = TextEditingController();

  String  _packageType    = 'document';
  double? _estimatedFare;
  bool    _fetchingFare   = false;

  // Pickup
  String? _pickupAddress;
  double? _pickupLat;
  double? _pickupLng;

  // Dropoff
  String? _dropoffAddress;
  double? _dropoffLat;
  double? _dropoffLng;

  final List<String> _packageTypes = [
    'document', 'small', 'medium', 'large', 'fragile'
  ];

  @override
  void dispose() {
    _packageDescription.dispose();
    super.dispose();
  }

  Future<void> _estimateFare() async {
    if (_pickupLat == null || _dropoffLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content        : Text('Please select both pickup and dropoff addresses'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _fetchingFare = true);
    final jobs = context.read<JobProvider>();
    await jobs.estimateFare(
      pickupLat : _pickupLat!,
      pickupLng : _pickupLng!,
      dropoffLat: _dropoffLat!,
      dropoffLng: _dropoffLng!,
    );
    if (mounted && jobs.fareEstimate != null) {
      setState(() {
        _estimatedFare =
            (jobs.fareEstimate!['estimated_fare'] as num).toDouble();
      });
    }
    setState(() => _fetchingFare = false);
  }

  Future<void> _createJob() async {
    if (!_formKey.currentState!.validate()) return;
    print('pickup: $_pickupAddress, lat: $_pickupLat, lng: $_pickupLng');
    print('dropoff: $_dropoffAddress, lat: $_dropoffLat, lng: $_dropoffLng');
    print('fare: $_estimatedFare');
    if (_pickupLat == null || _dropoffLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content        : Text('Please select pickup and dropoff addresses'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_estimatedFare == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content        : Text('Please estimate fare before creating job'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final jobs = context.read<JobProvider>();
    final ok   = await jobs.createJob({
      'package_type'       : _packageType,
      'package_description': _packageDescription.text,
      'pickup_address'     : _pickupAddress,
      'pickup_lat'         : _pickupLat,
      'pickup_lng'         : _pickupLng,
      'dropoff_address'    : _dropoffAddress,
      'dropoff_lat'        : _dropoffLat,
      'dropoff_lng'        : _dropoffLng,
      'estimated_fare'     : _estimatedFare,
    });
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content        : Text('Delivery job created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content        : Text(jobs.error ?? 'Failed to create job'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('New Delivery')),
      body  : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child  : Form(
          key  : _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package type selector
              const Text('Package Type',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color     : Color(0xFF1A1A2E))),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child : ListView.separated(
                  scrollDirection : Axis.horizontal,
                  itemCount       : _packageTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder     : (_, i) {
                    final type     = _packageTypes[i];
                    final selected = type == _packageType;
                    return GestureDetector(
                      onTap : () => setState(() => _packageType = type),
                      child : Container(
                        padding   : const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color       : selected
                              ? const Color(0xFFE94560) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border      : Border.all(
                            color: selected
                                ? const Color(0xFFE94560)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(type,
                            style: TextStyle(
                              color     : selected
                                  ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Pickup
              _SectionHeader(
                  title: 'Pickup Location',
                  color: const Color(0xFFE94560)),
              const SizedBox(height: 10),
              AddressSearchField(
                label    : 'Search pickup address',
                icon     : Icons.circle,
                iconColor: const Color(0xFFE94560),
                onSelected: (address, lat, lng) {
                  setState(() {
                    _pickupAddress = address;
                    _pickupLat     = lat;
                    _pickupLng     = lng;
                  });
                },
              ),
              if (_pickupAddress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child  : Row(children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_pickupAddress!,
                          style: const TextStyle(
                              color: Colors.green, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ),
              const SizedBox(height: 20),

              // Dropoff
              _SectionHeader(
                  title: 'Dropoff Location',
                  color: const Color(0xFF1A1A2E)),
              const SizedBox(height: 10),
              AddressSearchField(
                label    : 'Search dropoff address',
                icon     : Icons.location_on,
                iconColor: const Color(0xFF1A1A2E),
                onSelected: (address, lat, lng) {
                  setState(() {
                    _dropoffAddress = address;
                    _dropoffLat     = lat;
                    _dropoffLng     = lng;
                  });
                },
              ),
              if (_dropoffAddress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child  : Row(children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_dropoffAddress!,
                          style: const TextStyle(
                              color: Colors.green, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ),
              const SizedBox(height: 20),

              // Package description
              CustomTextField(
                label     : 'Package Description (optional)',
                controller: _packageDescription,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 20),

              // Fare estimate display
              if (_estimatedFare != null)
                Container(
                  width     : double.infinity,
                  padding   : const EdgeInsets.all(16),
                  margin    : const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color       : const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    const Text('Estimated Fare',
                        style: TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('GHS ${_estimatedFare!.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color     : Color(0xFFE94560),
                            fontSize  : 28,
                            fontWeight: FontWeight.bold)),
                    if (jobs.fareEstimate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.route, color: Colors.white54, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${jobs.fareEstimate!['distance_km']} km  •  '
                                '${jobs.fareEstimate!['duration_min']} mins',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ]),
                ),

              // Replace the two buttons at the bottom with this:
              CustomButton(
                label    : 'Estimate Fare',
                onPressed: _fetchingFare ? null : _estimateFare,
                isLoading: _fetchingFare,
                color    : const Color(0xFF1A1A2E),
              ),
              const SizedBox(height: 16), // increase spacing
              CustomButton(
                label    : 'Create Delivery Job',
                onPressed: (jobs.isLoading || _fetchingFare) ? null : _createJob,
                isLoading: jobs.isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color  color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width     : 4, height: 18,
        decoration: BoxDecoration(
            color       : color,
            borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 8),
      Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color     : color,
              fontSize  : 15)),
    ]);
  }
}