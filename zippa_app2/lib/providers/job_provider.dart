import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zippa_app/core/api_client.dart';
import 'package:zippa_app/core/constants.dart';
import 'package:zippa_app/models/job.dart';

class JobProvider extends ChangeNotifier {
  List<DeliveryJob> _jobs      = [];
  DeliveryJob?      _activeJob;
  bool              _isLoading = false;
  String?           _error;
  Map<String, dynamic>? _fareEstimate;

  List<DeliveryJob>     get jobs         => _jobs;
  DeliveryJob?          get activeJob    => _activeJob;
  bool                  get isLoading    => _isLoading;
  String?               get error        => _error;
  Map<String, dynamic>? get fareEstimate => _fareEstimate;
  Dio                   get dio          => ApiClient.dio;

  void _setLoading(bool val) { _isLoading = val; notifyListeners(); }
  void _setError(String? val) { _error = val; notifyListeners(); }

  // Fetch jobs
  Future<void> fetchJobs() async {
    _setLoading(true);
    try {
      final res = await ApiClient.dio.get(AppConstants.jobList);
      _jobs = (res.data as List).map((j) => DeliveryJob.fromJson(j)).toList();
      notifyListeners();
    } on DioException catch (e) {
      _setError(_parseError(e));
    } finally {
      _setLoading(false);
    }
  }

  // Create job
  Future<bool> createJob(Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await ApiClient.dio.post(AppConstants.jobs, data: data);
      _jobs.insert(0, DeliveryJob.fromJson(res.data));
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _setError(_parseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get job detail
  Future<void> fetchJobDetail(String jobId) async {
    _setLoading(true);
    try {
      final res = await ApiClient.dio.get('${AppConstants.jobs}$jobId/');
      _activeJob = DeliveryJob.fromJson(res.data);
      notifyListeners();
    } on DioException catch (e) {
      _setError(_parseError(e));
    } finally {
      _setLoading(false);
    }
  }

  // Update job status (rider)
  Future<bool> updateJobStatus(String jobId, String status) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await ApiClient.dio.patch(
        '${AppConstants.jobs}$jobId/status/',
        data: {'status': status},
      );
      _activeJob = DeliveryJob.fromJson(res.data);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _setError(_parseError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fare estimate
  Future<void> estimateFare({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await ApiClient.dio.post(AppConstants.fareEstimate, data: {
        'pickup_lat'  : pickupLat,
        'pickup_lng'  : pickupLng,
        'dropoff_lat' : dropoffLat,
        'dropoff_lng' : dropoffLng,
      });
      _fareEstimate = res.data;
      notifyListeners();
    } on DioException catch (e) {
      _setError(_parseError(e));
    } finally {
      _setLoading(false);
    }
  }

  String _parseError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data.containsKey('detail')) return data['detail'];
    }
    return 'Something went wrong. Please try again.';
  }
}