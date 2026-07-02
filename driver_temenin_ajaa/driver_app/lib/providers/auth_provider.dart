import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  bool _isAvailable = false;
  Map<String, dynamic>? _driverProfileData;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  bool get isAvailable => _isAvailable;
  Map<String, dynamic>? get driverProfileData => _driverProfileData;

  // Check initial login status
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      final savedUser = await _authService.getUser();
      
      if (token != null && savedUser != null) {
        _user = savedUser;
        _isAuthenticated = true;
        // Fetch fresh profile details from DB
        await refreshProfile();
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        _user = result['user'];
        _isAuthenticated = true;
        await refreshProfile();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register Driver
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String gender,
    required String vehicleType,
    required String vehicleName,
    required String plateNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        gender: gender,
        vehicleType: vehicleType,
        vehicleName: vehicleName,
        plateNumber: plateNumber,
      );

      if (result['success'] == true) {
        _user = result['user'];
        _isAuthenticated = true;
        await refreshProfile();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh Profile
  Future<void> refreshProfile() async {
    final result = await _authService.getProfile();
    if (result['success'] == true) {
      _user = result['user'];
      _driverProfileData = result['driverData'];
      _isAvailable = _driverProfileData?['is_available'] ?? false;
      notifyListeners();
    }
  }

  // Update Driver Profile
  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String vehicleName,
    required String plateNumber,
    required double pricePerHour,
    required int experienceYears,
    required String bio,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
        gender: gender,
        vehicleName: vehicleName,
        plateNumber: plateNumber,
        pricePerHour: pricePerHour,
        experienceYears: experienceYears,
        bio: bio,
      );

      if (result['success'] == true) {
        _user = result['user'];
        _driverProfileData = result['driverData'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle Driver Online Status
  Future<bool> toggleAvailability() async {
    final target = !_isAvailable;
    
    // Simulate updating coordinate tracking (Senayan City Mall GPS coordinates)
    final double simLat = -6.2278; 
    final double simLng = 106.7972;

    final result = await _authService.updateStatus(target, lat: simLat, lng: simLng);
    if (result['success'] == true) {
      _isAvailable = target;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Simulate Adding Earnings (Local Simulation Mode)
  void simulateAddEarnings(double amount) {
    if (_user != null) {
      _user = _user!.copyWith(balance: (_user!.balance) + amount);
      if (_driverProfileData != null) {
        final newProfile = Map<String, dynamic>.from(_driverProfileData!);
        newProfile['total_rides'] = (newProfile['total_rides'] ?? 0) + 1;
        _driverProfileData = newProfile;
      }
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    // Set status to offline before logout
    if (_isAvailable) {
      await _authService.updateStatus(false);
    }
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _isAvailable = false;
    _driverProfileData = null;
    notifyListeners();
  }
}
