class DeliveryJob {
  final String  id;
  final String  customerName;
  final String? riderName;
  final String  packageType;
  final String  packageDescription;
  final String  pickupAddress;
  final String  pickupLat;
  final String  pickupLng;
  final String  dropoffAddress;
  final String  dropoffLat;
  final String  dropoffLng;
  final String? estimatedFare;
  final String? finalFare;
  final String  status;
  final String  createdAt;
  final String? acceptedAt;
  final String? pickedUpAt;
  final String? deliveredAt;

  DeliveryJob({
    required this.id,
    required this.customerName,
    this.riderName,
    required this.packageType,
    required this.packageDescription,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    this.estimatedFare,
    this.finalFare,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  factory DeliveryJob.fromJson(Map<String, dynamic> json) => DeliveryJob(
    id                 : json['id'],
    customerName       : json['customer_name'],
    riderName          : json['rider_name'],
    packageType        : json['package_type'],
    packageDescription : json['package_description'] ?? '',
    pickupAddress      : json['pickup_address'],
    pickupLat          : json['pickup_lat'].toString(),
    pickupLng          : json['pickup_lng'].toString(),
    dropoffAddress     : json['dropoff_address'],
    dropoffLat         : json['dropoff_lat'].toString(),
    dropoffLng         : json['dropoff_lng'].toString(),
    estimatedFare      : json['estimated_fare']?.toString(),
    finalFare          : json['final_fare']?.toString(),
    status             : json['status'],
    createdAt          : json['created_at'],
    acceptedAt         : json['accepted_at'],
    pickedUpAt         : json['picked_up_at'],
    deliveredAt        : json['delivered_at'],
  );
}