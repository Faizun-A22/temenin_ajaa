// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:temenin_ajaa/core/services/auth_service.dart';
import '../data/models/user_model.dart';
import 'dart:io';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _isAuthenticated;  

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validasi email sebelum register
      if (!email.contains('@') || !email.contains('.')) {
        _errorMessage = 'Format email tidak valid';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      if (result['success'] == true) {
        _user = result['user'];
        _isAuthenticated = true;
        
        // Simpan user ke SharedPreferences
        await _authService.updateLocalUser(_user!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Registrasi gagal';
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

  // Login method
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success'] == true) {
        _user = result['user'];
        _isAuthenticated = true;
        
        // Simpan user ke SharedPreferences
        await _authService.updateLocalUser(_user!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login gagal';
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

  // Refresh user data from server
  Future<bool> refreshUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.getUserProfile();
      
      print('🔄 Refresh user result: ${result['success']}');
      
      if (result['success'] == true) {
        _user = result['user'];
        _isAuthenticated = true;
        
        // PANGGIL method updateLocalUser yang sudah dibuat
        await _authService.updateLocalUser(_user!);
        
        print('✅ User refreshed: ${_user?.fullName}');
        print('✅ Avatar URL: ${_user?.avatarUrl}');
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to refresh user data';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Refresh error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update profile (without avatar)
  Future<bool> updateProfile(String fullName, String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
      );

      if (result['success'] == true) {
        // Update local user langsung
        if (_user != null) {
          _user = _user!.copyWith(
            fullName: fullName,
            phone: phone,
          );
          // SIMPAN ke SharedPreferences
          await _authService.updateLocalUser(_user!);
        }
        
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

  // Update complete profile with avatar
  Future<bool> updateCompleteProfile({
    required String fullName,
    required String phone,
    required File avatarImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.updateCompleteProfile(
        fullName: fullName,
        phone: phone,
        avatarImage: avatarImage,
      );

      if (result['success'] == true) {
        // Update local user langsung
        if (_user != null) {
          _user = _user!.copyWith(
            fullName: fullName,
            phone: phone,
            avatarUrl: result['avatarUrl'],
          );
          // SIMPAN ke SharedPreferences
          await _authService.updateLocalUser(_user!);
        }
        
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

  // Upload avatar only
  Future<bool> uploadAvatar(File avatarImage) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.uploadAvatar(avatarImage);

      if (result['success'] == true) {
        // Update local user with new avatar URL
        if (_user != null) {
          _user = _user!.copyWith(
            avatarUrl: result['avatarUrl'],
          );
          // SIMPAN ke SharedPreferences
          await _authService.updateLocalUser(_user!);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to upload avatar';
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

  // Delete avatar
  Future<bool> deleteAvatar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.deleteAvatar();

      if (result['success'] == true) {
        // Update local user
        if (_user != null) {
          _user = _user!.copyWith(
            avatarUrl: null,
          );
          // SIMPAN ke SharedPreferences
          await _authService.updateLocalUser(_user!);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to delete avatar';
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

  // Logout method
  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Cek status auth
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authService.getUser();
        if (user != null) {
          _user = user;
          _isAuthenticated = true;
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // ============ METHOD TAMBAHAN UNTUK PERBAIKAN ============
  
  // Update user points (misal setelah transaksi)
  Future<bool> updateUserPoints(int newPoints) async {
    if (_user != null) {
      _user = _user!.copyWith(points: newPoints);
      await _authService.updateLocalUser(_user!);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Update user balance (misal setelah top up)
  Future<bool> updateUserBalance(int newBalance) async {
    if (_user != null) {
      _user = _user!.copyWith(balance: newBalance);
      await _authService.updateLocalUser(_user!);
      notifyListeners();
      return true;
    }
    return false;
  }

  // Get member tier based on points
  String getMemberTier() {
    final points = _user?.points ?? 0;
    if (points >= 2000) {
      return "Diamond Member";
    } else if (points >= 1000) {
      return "Platinum Member";
    } else if (points >= 500) {
      return "Gold Member";
    } else if (points >= 100) {
      return "Silver Member";
    } else {
      return "Regular Member";
    }
  }

  // Get member tier color
  Color getMemberTierColor() {
    final points = _user?.points ?? 0;
    if (points >= 2000) {
      return const Color(0xFFFDE1EF);
    } else if (points >= 1000) {
      return const Color(0xFFE0E0E0);
    } else if (points >= 500) {
      return const Color(0xFFFFD700);
    } else if (points >= 100) {
      return const Color(0xFFC0C0C0);
    } else {
      return const Color(0xFFCD7F32);
    }
  }

  // Get greeting name
  String getGreetingName() {
    final fullName = _user?.fullName ?? 'User';
    return fullName.split(' ').first;
  }

  // Get formatted points with thousand separator
  String getFormattedPoints() {
    final points = _user?.points ?? 0;
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }

  // Get formatted balance with thousand separator
  String getFormattedBalance() {
    final balance = _user?.balance ?? 0;
    return 'Rp ${balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // Update specific user field
  Future<bool> updateUserField({
    String? fullName,
    String? phone,
    String? avatarUrl,
    int? points,
    int? balance,
  }) async {
    if (_user != null) {
      _user = _user!.copyWith(
        fullName: fullName ?? _user!.fullName,
        phone: phone ?? _user!.phone,
        avatarUrl: avatarUrl ?? _user!.avatarUrl,
        points: points ?? _user!.points,
        balance: balance ?? _user!.balance,
      );
      await _authService.updateLocalUser(_user!);
      notifyListeners();
      return true;
    }
    return false;
  }
}