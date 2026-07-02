import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:temenin_ajaa/core/constants/api_constants.dart';

class DriverProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _drivers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDrivers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _errorMessage = 'Tidak terautentikasi';
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('📡 Fetching live drivers from: ${ApiConstants.baseUrl}${ApiConstants.drivers}');
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.drivers}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 Drivers response status: ${response.statusCode}');
      print('📡 Drivers response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> driverList = data['data'] ?? [];
          
          // Map backend driver format to client app format
          _drivers = driverList.map<Map<String, dynamic>>((driver) {
            final user = driver['users'] ?? {};
            final pricePerHour = (driver['price_per_hour'] ?? 50000.0).toDouble();
            
            // Map price to membership type/class dynamically
            String type = 'Gold';
            if (pricePerHour <= 40000) {
              type = 'Bronze';
            } else if (pricePerHour <= 60000) {
              type = 'Silver';
            } else if (pricePerHour <= 80000) {
              type = 'Gold';
            } else if (pricePerHour <= 100000) {
              type = 'Platinum';
            } else if (pricePerHour <= 150000) {
              type = 'Diamond';
            } else {
              type = 'VVIP';
            }

            final plate = driver['plate_number'] ?? 'B 1234 RW';
            final plateParts = plate.split(' ');
            final tag = plateParts.isNotEmpty ? plateParts.last : 'DR';

            return {
              'id': driver['id'],
              'user_id': driver['user_id'],
              'name': user['full_name'] ?? 'Driver',
              'email': user['email'] ?? '',
              'phone': user['phone'] ?? '',
              'vehicle': driver['vehicle_name'] ?? 'Kendaraan',
              'vehicle_type': driver['vehicle_type'] ?? 'Motor',
              'plate_number': plate,
              'rating': (driver['rating'] ?? 5.0).toString(),
              'status': (driver['is_available'] ?? false) ? 'Available' : 'Booked',
              'type': type,
              'image': user['avatar_url'] ?? 'https://i.pravatar.cc/300?img=33',
              'tag': tag,
              'isAvailable': driver['is_available'] ?? false,
              'price': pricePerHour.toInt(),
              'kpi': 90 + ((driver['total_rides'] ?? 0) % 10), // Dynamically calculate a KPI
              'gender': user['gender'] ?? 'Laki-laki',
              'experience_years': driver['experience_years'] ?? 3,
              'vehicle_stnk': driver['vehicle_stnk'] ?? '', // bio
            };
          }).toList();
          
          print('✅ Live drivers mapped: ${_drivers.length}');
        } else {
          _errorMessage = data['message'] ?? 'Gagal memuat data driver';
        }
      } else {
        _errorMessage = 'Gagal memuat data dari server (${response.statusCode})';
      }
    } catch (e) {
      print('❌ Fetch drivers error: $e');
      _errorMessage = 'Koneksi error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
