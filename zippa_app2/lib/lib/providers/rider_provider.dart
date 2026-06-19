import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:zippa_app/core/api_client.dart';
import 'package:zippa_app/core/constants.dart';
import 'package:zippa_app/models/rider.dart';

class RiderProvider extends ChangeNotifier {
  RiderProfile? _profile;
  bool          _isLoading = false;
  String?       _error;

  RiderProfile? get profile   => _profile;
  bool          get isLoading => _isLoading;
  String?       get error     => _error;

  void _setLoading(bool val) { _isLoading = val; notifyListeners(); }
  void _setError(String? val) { _error = val; notifyListeners(); }

  // Fetch rider profile
  Future<void> fetchProfile() async {
    _setLoading(true);
    try {
      final res = await ApiClient.dio.get(AppConstants.riderProfile);
      _profile = RiderProfile.fromJson(res.data);
      notifyListeners();
    } on DioException catch (e) {
      _setError(_parseError(e));
    } finally {
      _setLoading(false);
    }
  }

  // Toggle availability
  Future<void> toggleAvailability(bool isAvailable) async {
    _setLoading(true);
    try {
      await ApiClient.dio.patch(AppConstants.riderAvailability, data: {
        'is_available': isAvailable,
      });
      if (_profile != null) {
        _profile = RiderProfile(
          id              : _profile!.id,
          fullName        : _profile!.fullName,
          email           : _profile!.email,
          phone           : _profile!.phone,
          vehicleType     : _profile!.vehicleType,
          vehiclePlate    : _profile!.vehiclePlate,
          licenseNumber   : _profile!.licenseNumber,
          isAvailable     : isAvailable,
          isApproved      : _profile!.isApproved,
          currentLat      : _profile!.currentLat,
          currentLng      : _profile!.currentLng,
          rating          : _profile!.rating,
          totalDeliveries : _profile!.totalDeliveries,
        );
        notifyListeners();
      }
    } on DioException catch (e) {
      _setError(_parseError(e));
    } finally {
      _setLoading(false);
    }
  }

  // Update location
  Future<void> updateLocation(double lat, double lng) async {
    try {
      await ApiClient.dio.patch(AppConstants.riderLocation, data: {
        'current_lat': lat,
        'current_lng': lng,
      });
    } catch (_) {}
  }

  String _parseError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data.containsKey('detail')) return data['detail'];
    }
    return 'Something went wrong. Please try again.';
  }
}