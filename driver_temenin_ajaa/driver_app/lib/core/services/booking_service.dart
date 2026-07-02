import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/booking_model.dart';
import '../constants/api_constants.dart';
import 'auth_service.dart';

class BookingService {
  final AuthService _authService = AuthService();

  // Fetch driver bookings
  Future<Map<String, dynamic>> getDriverBookings({String status = 'all'}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return {'success': false, 'message': 'Authentication required'};

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}?status=$status');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> bookingsJson = data['data'] ?? [];
        final List<BookingModel> bookings = bookingsJson
            .map((json) => BookingModel.fromJson(json))
            .toList();
            
        return {
          'success': true,
          'bookings': bookings,
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to retrieve bookings',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update booking status
  Future<Map<String, dynamic>> updateBookingStatus(String bookingId, String status) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return {'success': false, 'message': 'Authentication required'};

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/drivers/bookings/$bookingId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Status updated successfully',
          'booking': BookingModel.fromJson(data['data']),
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update booking status',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Fetch driver earnings
  Future<Map<String, dynamic>> getDriverEarnings(String period) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return {'success': false, 'message': 'Authentication required'};

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.earnings}?period=$period'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'totalEarnings': (data['data']['total_earnings'] ?? 0.0).toDouble(),
          'totalRides': data['data']['total_rides'] ?? 0,
          'bookings': data['data']['bookings'] ?? [],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to load earnings',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
