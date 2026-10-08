import 'package:flutter/material.dart';
import 'package:zippa_app/core/api_client.dart';
import 'package:zippa_app/core/constants.dart';
import 'package:zippa_app/widget/common/custom_button.dart';
import 'package:dio/dio.dart';

class NegotiationsScreen extends StatefulWidget {
  final String jobId;
  final String userRole;

  const NegotiationsScreen({
    super.key,
    required this.jobId,
    required this.userRole,
  });

  @override
  State<NegotiationsScreen> createState() => _NegotiationsScreenState();
}

class _NegotiationsScreenState extends State<NegotiationsScreen> {
  List<dynamic> _negotiations = [];
  bool _isLoading = true;
  bool _submitting = false;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNegotiations();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchNegotiations() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient.dio.get(
        '${AppConstants.negotiations}${widget.jobId}/list/',
      );
      setState(() => _negotiations = res.data);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _sendOffer() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiClient.dio.post(
        '${AppConstants.negotiations}${widget.jobId}/',
        data: {
          'amount': double.parse(_amountController.text),
          'note': _noteController.text.trim(),
        },
      );
      _amountController.clear();
      _noteController.clear();
      await _fetchNegotiations();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.response?.statusCode} - ${e.response?.data}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _submitting = false);
  }

  Future<void> _respond(
    String negotiationId,
    String status, {
    double? counterAmount,
    String? note,
  }) async {
    setState(() => _submitting = true);
    try {
      await ApiClient.dio.patch(
        '${AppConstants.negotiations}respond/$negotiationId/',
        data: {
          'status': status,
          if (counterAmount != null) 'amount': counterAmount,
          if (note != null) 'note': note,
        },
      );
      await _fetchNegotiations();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer ${status}!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to respond'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _submitting = false);
  }

  void _showCounterDialog(String negotiationId) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Counter Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your Amount (GHS)',
                prefixText: 'GHS ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (amountCtrl.text.isNotEmpty) {
                _respond(
                  negotiationId,
                  'countered',
                  counterAmount: double.parse(amountCtrl.text),
                  note: noteCtrl.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
            ),
            child: const Text('Send Counter'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'countered':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    // find pending negotiation where current user is receiver
    final pendingForMe = _negotiations
        .where((n) => n['status'] == 'pending')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Fare Negotiation')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Negotiations history
                Expanded(
                  child: _negotiations.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.handshake_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No negotiations yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Send an offer to start negotiating',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchNegotiations,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _negotiations.length,
                            itemBuilder: (_, i) {
                              final n = _negotiations[i];
                              final status = n['status'] ?? 'pending';
                              final isPending = status == 'pending';
                              final isReceiver =
                                  isPending &&
                                  pendingForMe.isNotEmpty &&
                                  pendingForMe.last['id'] == n['id'];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isPending
                                      ? Border.all(color: Colors.blue.shade200)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          n['sender_name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1A2E),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              status,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              color: _statusColor(status),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'GHS ${n['amount']}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE94560),
                                      ),
                                    ),
                                    if (n['note'] != null &&
                                        n['note'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        n['note'],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],

                                    // Response buttons for pending offers
                                    if (isReceiver) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _submitting
                                                  ? null
                                                  : () => _respond(
                                                      n['id'],
                                                      'rejected',
                                                    ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(
                                                  color: Colors.red,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text('Reject'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: _submitting
                                                  ? null
                                                  : () => _showCounterDialog(
                                                      n['id'],
                                                    ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.orange,
                                                side: const BorderSide(
                                                  color: Colors.orange,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text('Counter'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _submitting
                                                  ? null
                                                  : () => _respond(
                                                      n['id'],
                                                      'accepted',
                                                    ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Accept',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
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
                        ),
                ),

                // Send offer panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Send an Offer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Amount (GHS)',
                                prefixText: 'GHS ',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                hintText: 'Note (optional)',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        label: 'Send Offer',
                        onPressed: _sendOffer,
                        isLoading: _submitting,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
