import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/booking_service.dart';
import '../data/models/booking_model.dart';
import '../data/models/user_model.dart';
import 'auth_provider.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  
  List<BookingModel> _bookings = [];
  BookingModel? _activeBooking;
  BookingModel? _incomingBooking;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Earnings state
  double _totalEarnings = 0.0;
  int _totalRides = 0;
  List<dynamic> _earningsBookings = [];
  
  // Realtime subscription
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get activeBooking => _activeBooking;
  BookingModel? get incomingBooking => _incomingBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  double get totalEarnings => _totalEarnings;
  int get totalRides => _totalRides;
  List<dynamic> get earningsBookings => _earningsBookings;

  // Clear current incoming request
  void clearIncomingRequest() {
    _incomingBooking = null;
    notifyListeners();
  }

  // Set active booking manually (e.g. on click from list)
  void setActiveBooking(BookingModel? booking) {
    _activeBooking = booking;
    notifyListeners();
  }

  // Subscribe to real-time bookings from Supabase
  void subscribeToBookings(String driverId) {
    _realtimeSubscription?.cancel();
    
    debugPrint('📡 Subscribing to Supabase Realtime for Driver bookings (Driver ID: $driverId)');
    
    try {
      _realtimeSubscription = Supabase.instance.client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('driver_id', driverId)
          .listen((List<Map<String, dynamic>> data) {
            debugPrint('⚡ Supabase Realtime received data: ${data.length} records');
            
            // Check if there is a pending booking assigned to this driver
            final pendingRequest = data.where((json) => json['status'] == 'pending');
            if (pendingRequest.isNotEmpty) {
              // Fetch full client details for the incoming request
              _fetchFullIncomingBooking(pendingRequest.first['id']);
            } else {
              _incomingBooking = null;
              notifyListeners();
            }

            // Sync active booking details if any booking is currently running (status: ongoing, arrived, or accepted)
            final activeList = data.where((json) => 
                json['status'] == 'accepted' || 
                json['status'] == 'on_the_way' || 
                json['status'] == 'arrived' || 
                json['status'] == 'started' || 
                json['status'] == 'ongoing');
            
            if (activeList.isNotEmpty) {
              _fetchFullActiveBooking(activeList.first['id']);
            } else {
              _activeBooking = null;
              notifyListeners();
            }
          });
    } catch (e) {
      debugPrint('❌ Supabase subscription error: $e');
    }
  }

  // Helper: Fetch full booking model with client details
  Future<void> _fetchFullIncomingBooking(String bookingId) async {
    try {
      final res = await Supabase.instance.client
          .from('bookings')
          .select('*, users:user_id(*)')
          .eq('id', bookingId)
          .maybeSingle();
      
      if (res != null) {
        _incomingBooking = BookingModel.fromJson(res);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching incoming booking details: $e');
    }
  }

  Future<void> _fetchFullActiveBooking(String bookingId) async {
    try {
      final res = await Supabase.instance.client
          .from('bookings')
          .select('*, users:user_id(*)')
          .eq('id', bookingId)
          .maybeSingle();
      
      if (res != null) {
        _activeBooking = BookingModel.fromJson(res);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching active booking details: $e');
    }
  }

  // Cancel subscription
  void unsubscribeFromBookings() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
  }

  // Load Bookings History (via API)
  Future<void> loadBookingsHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _bookingService.getDriverBookings(status: 'all');
    if (result['success'] == true) {
      _bookings = result['bookings'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Simulate Incoming Booking Request (Local Simulation Mode)
  void simulateIncomingBooking({String serviceType = 'antar_jemput', bool useCar = false}) {
    if (serviceType == 'antar_jemput') {
      _incomingBooking = BookingModel(
        id: 'dummy-booking-id',
        userId: 'dummy-user-id',
        driverId: 'dummy-driver-id',
        status: 'pending',
        pickupLocation: 'Senayan City Mall, Lobby Selatan',
        dropoffLocation: 'Bandara Internasional Soekarno-Hatta (T3)',
        duration: 45,
        totalPrice: useCar ? 180000 : 130000,
        createdAt: DateTime.now(),
        client: UserModel(
          id: 'dummy-user-id',
          email: 'client@example.com',
          fullName: 'Aura Kasih',
          phone: '+62 812-9876-5432',
          role: 'client',
          balance: 100000,
          points: 50,
          avatarUrl: 'https://i.pravatar.cc/300?img=47',
          isVerified: true,
        ),
        additionalDetails: {
          'serviceType': 'antar_jemput',
          'useCar': useCar,
          'rentHelmet': !useCar,
          'pulangPergi': false,
          'notes': useCar ? 'Tolong jemput di lobi selatan ya Kak, bawa mobil yang bersih.' : 'Tolong bawa helm cadangan yang wangi ya Kak.',
          'chat_messages': [
            {
              'sender': 'user',
              'text': 'Halo Kak, posisinya di mana?',
              'time': '12:00',
            }
          ]
        }
      );
    } else if (serviceType == 'hangout') {
      _incomingBooking = BookingModel(
        id: 'dummy-booking-id',
        userId: 'dummy-user-id',
        driverId: 'dummy-driver-id',
        status: 'pending',
        pickupLocation: 'Grand Indonesia, West Mall',
        dropoffLocation: 'Grand Indonesia, West Mall',
        duration: 180, // 3 hours
        totalPrice: 160000,
        createdAt: DateTime.now(),
        client: UserModel(
          id: 'dummy-user-id',
          email: 'client@example.com',
          fullName: 'Nicholas Saputra',
          phone: '+62 811-2345-6789',
          role: 'client',
          balance: 500000,
          points: 200,
          avatarUrl: 'https://i.pravatar.cc/300?img=12',
          isVerified: true,
        ),
        additionalDetails: {
          'serviceType': 'hangout',
          'activity': 'Nonton Bioskop & Makan Malam',
          'duration': '3',
          'notes': 'Mau nonton film KKN di Desa Penari jam 19.00 ya kak.',
          'chat_messages': [
            {
              'sender': 'user',
              'text': 'Halo Kak, sudah sampai di Grand Indonesia?',
              'time': '18:45',
            }
          ]
        }
      );
    } else if (serviceType == 'freedom_request') {
      _incomingBooking = BookingModel(
        id: 'dummy-booking-id',
        userId: 'dummy-user-id',
        driverId: 'dummy-driver-id',
        status: 'pending',
        pickupLocation: 'Kost Elite Kuningan, Jaksel',
        dropoffLocation: 'Supermarket Ranch Market Kemang',
        duration: 240, // 4 hours
        totalPrice: 220000,
        createdAt: DateTime.now(),
        client: UserModel(
          id: 'dummy-user-id',
          email: 'client@example.com',
          fullName: 'Pevita Pearce',
          phone: '+62 813-5555-8888',
          role: 'client',
          balance: 800000,
          points: 350,
          avatarUrl: 'https://i.pravatar.cc/300?img=5',
          isVerified: true,
        ),
        additionalDetails: {
          'serviceType': 'freedom_request',
          'description': 'Temani belanja bulanan di supermarket, bantu bawakan kantong belanjaan ke kost, sekalian mengobrol santai.',
          'duration': '4',
          'notes': 'Tolong bawa mobil ya kak agar muat banyak belanjaan.',
          'chat_messages': [
            {
              'sender': 'user',
              'text': 'Halo kak, siap jalan sekarang?',
              'time': '10:00',
            }
          ]
        }
      );
    }
    notifyListeners();
  }

  // Accept booking
  Future<bool> acceptBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    if (bookingId == 'dummy-booking-id') {
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoading = false;
      
      if (_incomingBooking != null) {
        _activeBooking = BookingModel(
          id: _incomingBooking!.id,
          userId: _incomingBooking!.userId,
          driverId: _incomingBooking!.driverId,
          status: 'on_the_way',
          pickupLocation: _incomingBooking!.pickupLocation,
          dropoffLocation: _incomingBooking!.dropoffLocation,
          duration: _incomingBooking!.duration,
          totalPrice: _incomingBooking!.totalPrice,
          createdAt: _incomingBooking!.createdAt,
          client: _incomingBooking!.client,
          additionalDetails: _incomingBooking!.additionalDetails,
        );
        _incomingBooking = null;
      }
      notifyListeners();
      return true;
    }

    // Set state to 'accepted' or 'on_the_way'
    final result = await _bookingService.updateBookingStatus(bookingId, 'on_the_way');
    _isLoading = false;
    
    if (result['success'] == true) {
      _incomingBooking = null;
      _activeBooking = result['booking'];
      notifyListeners();
      return true;
    }
    
    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }

  // Reject booking (cancels it or returns to queue)
  Future<bool> rejectBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    if (bookingId == 'dummy-booking-id') {
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoading = false;
      _incomingBooking = null;
      notifyListeners();
      return true;
    }

    final result = await _bookingService.updateBookingStatus(bookingId, 'cancelled');
    _isLoading = false;

    if (result['success'] == true) {
      _incomingBooking = null;
      notifyListeners();
      return true;
    }

    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }

  // Update Booking Progress Status
  Future<bool> updateBookingProgress(String status, {AuthProvider? authProvider}) async {
    if (_activeBooking == null) return false;
    
    _isLoading = true;
    notifyListeners();

    if (_activeBooking!.id == 'dummy-booking-id') {
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoading = false;
      
      if (status == 'completed') {
        _totalEarnings += _activeBooking!.totalPrice;
        _totalRides += 1;
        _earningsBookings.insert(0, {
          'total_price': _activeBooking!.totalPrice,
          'created_at': DateTime.now().toIso8601String(),
          'pickup_location': _activeBooking!.pickupLocation,
          'dropoff_location': _activeBooking!.dropoffLocation,
        });
        
        if (authProvider != null) {
          authProvider.simulateAddEarnings(_activeBooking!.totalPrice);
        }
        _activeBooking = null; // Clear active since it is completed
      } else {
        _activeBooking = BookingModel(
          id: _activeBooking!.id,
          userId: _activeBooking!.userId,
          driverId: _activeBooking!.driverId,
          status: status,
          pickupLocation: _activeBooking!.pickupLocation,
          dropoffLocation: _activeBooking!.dropoffLocation,
          duration: _activeBooking!.duration,
          totalPrice: _activeBooking!.totalPrice,
          createdAt: _activeBooking!.createdAt,
          client: _activeBooking!.client,
          additionalDetails: _activeBooking!.additionalDetails,
        );
      }
      notifyListeners();
      return true;
    }

    final result = await _bookingService.updateBookingStatus(_activeBooking!.id, status);
    _isLoading = false;

    if (result['success'] == true) {
      _activeBooking = result['booking'];
      if (status == 'completed') {
        _activeBooking = null; // Clear active since it is completed
      }
      notifyListeners();
      return true;
    }

    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }

  // Load Earnings
  Future<void> loadEarnings(String period) async {
    _isLoading = true;
    notifyListeners();

    final result = await _bookingService.getDriverEarnings(period);
    if (result['success'] == true) {
      _totalEarnings = result['totalEarnings'];
      _totalRides = result['totalRides'];
      _earningsBookings = result['bookings'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromBookings();
    super.dispose();
  }
}
