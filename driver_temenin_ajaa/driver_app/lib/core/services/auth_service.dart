import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../constants/api_constants.dart';

class AuthService {
  static const String _tokenKey = 'driver_token';
  static const String _userKey = 'driver_user_data';

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['token'];
        final userData = UserModel.fromJson(data['data']['user']);

        await _saveAuthSession(token, userData);

        return {
          'success': true,
          'user': userData,
          'token': token,
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Email or password incorrect',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Please check server status on port 3001',
      };
    }
  }

  // Register Driver
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String gender,
    required String vehicleType,
    required String vehicleName,
    required String plateNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/drivers/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'gender': gender,
          'vehicle_type': vehicleType,
          'vehicle_name': vehicleName,
          'plate_number': plateNumber,
        }),
      ).timeout(const Duration(seconds: 20));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final token = data['data']['token'];
        final userData = UserModel.fromJson(data['data']['user']);

        await _saveAuthSession(token, userData);

        return {
          'success': true,
          'user': userData,
          'token': token,
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ' + e.toString(),
      };
    }
  }

  // Fetch Driver Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token found'};

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final userData = UserModel.fromJson(data['data']['users']);
        // Save the updated profile locally
        await updateLocalUser(userData);

        return {
          'success': true,
          'user': userData,
          'driverData': data['data'],
        };
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to load profile'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update Status
  Future<Map<String, dynamic>> updateStatus(bool isAvailable, {double? lat, double? lng}) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token found'};

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.status}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'is_available': isAvailable,
          'latitude': lat,
          'longitude': lng,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to update status'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Persistence methods
  Future<void> _saveAuthSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> updateLocalUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null) {
      return UserModel.fromJson(jsonDecode(jsonStr));
    }
    return null;
  }

  // Update Driver Profile
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String vehicleName,
    required String plateNumber,
    required double pricePerHour,
    required int experienceYears,
    required String bio,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token found'};

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/drivers/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'full_name': fullName,
          'phone': phone,
          'gender': gender,
          'vehicle_name': vehicleName,
          'plate_number': plateNumber,
          'price_per_hour': pricePerHour,
          'experience_years': experienceYears,
          'vehicle_stnk': bio,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final updatedUser = UserModel.fromJson(data['data']['users']);
        await updateLocalUser(updatedUser);
        return {
          'success': true,
          'user': updatedUser,
          'driverData': data['data'],
        };
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to update profile'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
