class AppConstants {
  static const String baseUrl = 'https://zippa-backend-z90m.onrender.com';

  // Auth endpoints
  static const String register = '/api/v1/auth/register/';
  static const String login = '/api/v1/auth/login/';
  static const String logout = '/api/v1/auth/logout/';
  static const String me = '/api/v1/auth/me/';
  static const String changePassword = '/api/v1/auth/change-password/';

  // Rider endpoints
  static const String riderProfile = '/api/v1/riders/profile/';
  static const String riderAvailability = '/api/v1/riders/availability/';
  static const String riderLocation = '/api/v1/riders/location/';
  static const String nearbyRiders = '/api/v1/riders/nearby/';

  // Job endpoints
  static const String jobs = '/api/v1/jobs/';
  static const String jobList = '/api/v1/jobs/list/';

  // Negotiations
  static const String negotiations = '/api/v1/negotiations/';

  // Ratings
  static const String ratings = '/api/v1/ratings/';

  // Notifications
  static const String notifications = '/api/v1/notifications/';

  // Core
  static const String fareEstimate = '/api/v1/cores/fare-estimate/';
}

class AppColors {
  static const int primaryInt = 0xFF1A1A2E;
  static const int accentInt = 0xFFE94560;
  static const int backgroundInt = 0xFFF5F5F5;
  static const int greyInt = 0xFF666666;
  static const int greenInt = 0xFF27AE60;
}
