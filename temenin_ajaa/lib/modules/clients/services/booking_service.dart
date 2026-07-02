// lib/core/services/booking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temenin_ajaa/core/constants/api_constants.dart';
import '../../../data/models/booking_model.dart';

const String BASE_URL = ApiConstants.baseUrl;

class BookingService {
  Future<Map<String, dynamic>> getBookingHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📖 GET BOOKING HISTORY');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 User ID: $userId');
      print('🔑 Token: ${token?.substring(0, 20)}...');
      print('🌐 URL: $BASE_URL/api/profile/bookings');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }
      
      final response = await http.get(
        Uri.parse('$BASE_URL/api/profile/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> bookingsJson = data['data'] ?? [];
        List<BookingModel> bookings = bookingsJson
            .map((json) => BookingModel.fromJson(json))
            .toList();
        
        print('✅ Loaded ${bookings.length} bookings');
        
        return {
          'success': true,
          'bookings': bookings,
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load bookings',
        };
      }
    } catch (e) {
      print('❌ Get booking history error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}