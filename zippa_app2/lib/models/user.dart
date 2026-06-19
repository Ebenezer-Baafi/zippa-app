class User {
  final String  id;
  final String  fullName;
  final String  email;
  final String  phone;
  final String  role;
  final String? profilePhoto;
  final bool    isVerified;
  final String  createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.profilePhoto,
    required this.isVerified,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id           : json['id'],
    fullName     : json['full_name'],
    email        : json['email'],
    phone        : json['phone'],
    role         : json['role'],
    profilePhoto : json['profile_photo'],
    isVerified   : json['is_verified'] ?? false,
    createdAt    : json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'id'            : id,
    'full_name'     : fullName,
    'email'         : email,
    'phone'         : phone,
    'role'          : role,
    'profile_photo' : profilePhoto,
    'is_verified'   : isVerified,
    'created_at'    : createdAt,
  };
}