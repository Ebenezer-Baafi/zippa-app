class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://zippa-backend-z90m.onrender.com';

  // Auth endpoints
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String me = '/auth/me/';
  static const String changePassword = '/auth/me/change-password/';

  // Rider endpoints
  static const String riderProfile = '/riders/profile/';
  static const String riderAvailability = '/riders/availability/';
  static const String riderLocation = '/riders/location/';
  static const String nearbyRiders = '/riders/nearby/';

  // Job endpoints
  static const String jobs = '/jobs/';
  static const String jobList = '/jobs/list/';

  // Negotiations
  static const String negotiations = '/negotiations/';

  // Ratings
  static const String ratings = '/ratings/';

  // Notifications
  static const String notifications = '/notifications/';

  // Core
  static const String fareEstimate = '/cores/fare-estimate/';
}

class AppColors {
  static const int primaryInt = 0xFF1A1A2E;
  static const int accentInt = 0xFFE94560;
  static const int backgroundInt = 0xFFF5F5F5;
  static const int greyInt = 0xFF666666;
  static const int greenInt = 0xFF27AE60;
}
