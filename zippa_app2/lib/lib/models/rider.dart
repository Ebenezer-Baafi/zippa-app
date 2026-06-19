class RiderProfile {
  final String  id;
  final String  fullName;
  final String  email;
  final String  phone;
  final String  vehicleType;
  final String  vehiclePlate;
  final String  licenseNumber;
  final bool    isAvailable;
  final bool    isApproved;
  final String? currentLat;
  final String? currentLng;
  final String  rating;
  final int     totalDeliveries;

  RiderProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.licenseNumber,
    required this.isAvailable,
    required this.isApproved,
    this.currentLat,
    this.currentLng,
    required this.rating,
    required this.totalDeliveries,
  });

  factory RiderProfile.fromJson(Map<String, dynamic> json) => RiderProfile(
    id              : json['id'],
    fullName        : json['full_name'],
    email           : json['email'],
    phone           : json['phone'],
    vehicleType     : json['vehicle_type'],
    vehiclePlate    : json['vehicle_plate'],
    licenseNumber   : json['license_number'],
    isAvailable     : json['is_available'] ?? false,
    isApproved      : json['is_approved']  ?? false,
    currentLat      : json['current_lat']?.toString(),
    currentLng      : json['current_lng']?.toString(),
    rating          : json['rating']?.toString() ?? '0.00',
    totalDeliveries : json['total_deliveries'] ?? 0,
  );
}