class ApiConstants {
  // Use http://localhost:3001 for Android Emulator / Physical Device (via adb reverse), iOS / Web / desktop
  static const String baseUrl = 'http://203.194.112.254/api/driver'; 
  
  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String getMe = '/api/auth/me';
  
  // Driver Endpoints
  static const String profile = '/api/drivers/profile';
  static const String status = '/api/drivers/status';
  static const String bookings = '/api/drivers/bookings';
  static const String earnings = '/api/drivers/earnings';
}
