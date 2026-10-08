import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zippa_app/core/api_client.dart';
import 'package:zippa_app/core/constants.dart';
import 'package:zippa_app/widget/common/custom_button.dart';

class RateRiderScreen extends StatefulWidget {
  final String jobId;
  final String riderName;

  const RateRiderScreen({
    super.key,
    required this.jobId,
    required this.riderName,
  });

  @override
  State<RateRiderScreen> createState() => _RateRiderScreenState();
}

class _RateRiderScreenState extends State<RateRiderScreen> {
  double _rating = 5;
  final _comment = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isLoading = true);
    try {
      await ApiClient.dio.post(
        '${AppConstants.ratings}job/${widget.jobId}/',
        data: {'score': _rating.toInt(), 'comment': _comment.text.trim()},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit rating'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Rate Your Rider')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Rider avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              widget.riderName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'How was your delivery experience?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Star rating
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 48,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (_, __) =>
                  const Icon(Icons.star_rounded, color: Colors.amber),
              onRatingUpdate: (r) => setState(() => _rating = r),
            ),
            const SizedBox(height: 12),
            Text(
              _ratingLabel(_rating.toInt()),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE94560),
              ),
            ),
            const SizedBox(height: 32),

            // Comment field
            TextFormField(
              controller: _comment,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Leave a comment (optional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE94560),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              label: 'Submit Rating',
              onPressed: _submitRating,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Very Poor 😞';
      case 2:
        return 'Poor 😐';
      case 3:
        return 'Good 🙂';
      case 4:
        return 'Great 😊';
      case 5:
        return 'Excellent 🌟';
      default:
        return '';
    }
  }
}
