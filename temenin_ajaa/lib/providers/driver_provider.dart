// lib/providers/driver_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart'; // Import API constants

class DriverProvider with ChangeNotifier {
  String? _token;
  String? _errorMessage;
  Map<String, dynamic>? _driverProfile;
  List<dynamic> _bookings = [];
  Map<String, dynamic>? _earnings;

  String? get token => _token;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get driverProfile => _driverProfile;
  List<dynamic> get bookings => _bookings;
  Map<String, dynamic>? get earnings => _earnings;

  Future<bool> registerDriver({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String vehicleType,
    required String vehicleName,
    required String plateNumber,
    required int pricePerHour,
    required int experienceYears,
    required String idCardNumber,
    required String driverLicenseNumber,
    required String vehicleStnk,
    required File ktpImage,
    required File simImage,
    required File stnkImage,
    File? vehiclePhoto,
  }) async {
    try {
      // Upload images first
      final ktpUrl = await _uploadImage(ktpImage, 'ktp');
      final simUrl = await _uploadImage(simImage, 'sim');
      final stnkUrl = await _uploadImage(stnkImage, 'stnk');
      String? vehiclePhotoUrl;
      if (vehiclePhoto != null) {
        vehiclePhotoUrl = await _uploadImage(vehiclePhoto, 'vehicle');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/api/drivers/register'),
      );

      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['full_name'] = fullName;
      request.fields['phone'] = phone;
      request.fields['vehicle_type'] = vehicleType;
      request.fields['vehicle_name'] = vehicleName;
      request.fields['plate_number'] = plateNumber;
      request.fields['price_per_hour'] = pricePerHour.toString();
      request.fields['experience_years'] = experienceYears.toString();
      request.fields['id_card_number'] = idCardNumber;
      request.fields['driver_license_number'] = driverLicenseNumber;
      request.fields['vehicle_stnk'] = vehicleStnk;
      request.fields['ktp_url'] = ktpUrl;
      request.fields['sim_url'] = simUrl;
      request.fields['stnk_url'] = stnkUrl;
      if (vehiclePhotoUrl != null) {
        request.fields['vehicle_photo_url'] = vehiclePhotoUrl;
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);

      if (response.statusCode == 201 && result['success'] == true) {
        _token = result['data']['token'];
        _driverProfile = result['data']['driver'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userRole', 'driver');
        await prefs.setString('userId', result['data']['user']['id'].toString());
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String> _uploadImage(File image, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/api/upload/driver-document'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['document_type'] = type;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);
      
      if (response.statusCode == 200 && result['success'] == true) {
        return result['data']['url'];
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return '';
    }
  }

  Future<void> fetchDriverProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/drivers/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          _driverProfile = result['data'];
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDriverStatus(bool isAvailable, {double? latitude, double? longitude}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return;
      
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/drivers/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'is_available': isAvailable,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          _driverProfile = result['data'];
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchDriverBookings({String status = 'all'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/drivers/bookings?status=$status'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          _bookings = result['data'];
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return;
      
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/drivers/bookings/$bookingId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );
      
      if (response.statusCode == 200) {
        await fetchDriverBookings();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchDriverEarnings({String period = 'monthly'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/drivers/earnings?period=$period'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          _earnings = result['data'];
          notifyListeners();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearData() {
    _token = null;
    _errorMessage = null;
    _driverProfile = null;
    _bookings = [];
    _earnings = null;
    notifyListeners();
  }
}