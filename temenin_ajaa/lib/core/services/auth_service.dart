import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:temenin_ajaa/core/constants/api_constants.dart';
import 'package:temenin_ajaa/data/models/user_model.dart';

// const String BASE_URL = 'http://192.168.0.126:3000';
const String BASE_URL = 'http://192.168.1.6:3000';

class Log {
  static void d(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }
  
  static void e(String message) {
    if (kDebugMode) {
      print('[ERROR] $message');
    }
  }
}

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';

 Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    print('═══════════════════════════════════════════════════');
    print('🔐 LOGIN ATTEMPT');
    print('═══════════════════════════════════════════════════');
    print('📧 Email: $email');
    print('🔑 Password length: ${password.length}');
    print('🌐 URL: ${ApiConstants.baseUrl}${ApiConstants.login}');
    
    final requestBody = jsonEncode({
      'email': email.trim(),
      'password': password,
    });
    print('📦 Request body: $requestBody');
    
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
      headers: {
        'Content-Type': ApiConstants.contentType,
      },
      body: requestBody,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        print('⏰ Connection timeout!');
        throw Exception('Connection timeout');
      },
    );

    print('📡 Response status code: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('📊 Parsed response: $data');
      
      if (data['success'] == true) {
        print('✅ Login success!');
        
        // Cek struktur data
        if (data['data'] == null) {
          print('❌ Error: data is null');
          return {
            'success': false,
            'message': 'Response data is null',
          };
        }
        
        print('🔑 Token: ${data['data']['token']}');
        print('👤 User data: ${data['data']['user']}');
        
        final token = data['data']['token'];
        final userData = data['data']['user'];
        
        // Validasi userData
        if (userData == null) {
          print('❌ Error: user data is null');
          return {
            'success': false,
            'message': 'User data is null',
          };
        }
        
        // Konversi ke UserModel
        final user = UserModel.fromJson(userData);
        print('✅ UserModel created:');
        print('   - ID: ${user.id}');
        print('   - Email: ${user.email}');
        print('   - Name: ${user.fullName}');
        print('   - Phone: ${user.phone}');
        print('   - Balance: ${user.balance}');
        print('   - Points: ${user.points}');
        
        await _saveAuthData(token, null, user);
        print('💾 Auth data saved to local storage');
        
        print('═══════════════════════════════════════════════════');
        
        return {
          'success': true,
          'user': user,
          'token': token,
          'message': data['message'] ?? 'Login berhasil',
        };
      } else {
        print('❌ Login failed: ${data['message']}');
        print('═══════════════════════════════════════════════════');
        return {
          'success': false,
          'message': data['message'] ?? 'Email atau password salah',
        };
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
      print('═══════════════════════════════════════════════════');
      
      String errorMessage;
      try {
        final data = jsonDecode(response.body);
        errorMessage = data['message'] ?? 'Login gagal';
      } catch (e) {
        errorMessage = 'Server error: ${response.statusCode}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  } catch (e) {
    print('❌ EXCEPTION: $e');
    print('═══════════════════════════════════════════════════');
    Log.e('Login error: $e');
    return {
      'success': false,
      'message': 'Koneksi error: ${e.toString()}',
    };
  }
}

  // Register dengan named parameters
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    // Validasi input
    if (email.isEmpty || password.isEmpty || fullName.isEmpty || phone.isEmpty) {
      return {
        'success': false,
        'message': 'Semua field harus diisi',
      };
    }

    if (password.length < 6) {
      return {
        'success': false,
        'message': 'Password minimal 6 karakter',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'full_name': fullName.trim(),
          'phone': phone.trim(),
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true) {
          final token = data['data']['token'];
          final refreshToken = data['data']['refresh_token'];
          final user = UserModel.fromJson(data['data']['user']);
          
          await _saveAuthData(token, refreshToken, user);
          
          return {
            'success': true,
            'user': user,
            'token': token,
            'message': data['message'] ?? 'Registrasi berhasil',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Registrasi gagal',
          };
        }
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal (${response.statusCode})',
        };
      }
    } catch (e) {
      Log.e('Register error: $e');
      return {
        'success': false,
        'message': 'Koneksi error: ${e.toString()}',
      };
    }
  }

  
  // Login dengan Google
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.googleLogin}'),
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
        body: jsonEncode({
          'id_token': idToken,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['token'];
        final refreshToken = data['data']['refresh_token'];
        final user = UserModel.fromJson(data['data']['user']);
        
        await _saveAuthData(token, refreshToken, user);
        
        return {
          'success': true,
          'user': user,
          'token': token,
          'message': 'Login dengan Google berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login dengan Google gagal',
        };
      }
    } catch (e) {
      Log.e('Google login error: $e');
      return {
        'success': false,
        'message': 'Koneksi error: ${e.toString()}',
      };
    }
  }

// services/auth_service.dart

Future<Map<String, dynamic>> uploadAvatar(File avatarImage) async {
  try {
    final token = await getToken();
    
    print('📸 Uploading avatar...');
    print('   - File path: ${avatarImage.path}');
    print('   - File exists: ${await avatarImage.exists()}');
    
    // 🔴 PERBAIKI: Tambahkan header yang lebih lengkap
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$BASE_URL/api/profile/avatar'),
    );
    
    // Tambahkan headers
    request.headers['Authorization'] = 'Bearer $token';
    // Jangan set Content-Type, biar multipart yang set
    
    // Tambahkan file dengan nama field 'avatar'
    var fileStream = http.ByteStream(avatarImage.openRead());
    var fileLength = await avatarImage.length();
    
    var multipartFile = http.MultipartFile(
      'avatar',
      fileStream,
      fileLength,
      filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    
    request.files.add(multipartFile);
    
    print('📤 Sending multipart request...');
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = json.decode(responseBody);
    
    print('📸 Upload response status: ${response.statusCode}');
    print('📸 Upload response body: $responseBody');
    
    if (response.statusCode == 200) {
      return {
        'success': true,
        'avatarUrl': data['data']?['avatar_url'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to upload avatar',
      };
    }
  } catch (e) {
    print('❌ Upload error: $e');
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}

// Delete avatar
Future<Map<String, dynamic>> deleteAvatar() async {
  try {
    final token = await getToken();
    
    final response = await http.delete(
      Uri.parse('$BASE_URL/api/profile/avatar'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return {
        'success': true,
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete avatar',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}


  // Refresh token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return {
          'success': false,
          'message': 'Refresh token tidak ditemukan',
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}'),
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final newToken = data['data']['token'];
        final newRefreshToken = data['data']['refresh_token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, newToken);
        if (newRefreshToken != null) {
          await prefs.setString(_refreshTokenKey, newRefreshToken);
        }
        
        return {
          'success': true,
          'token': newToken,
          'message': 'Token berhasil diperbarui',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Refresh token gagal',
        };
      }
    } catch (e) {
      Log.e('Refresh token error: $e');
      return {
        'success': false,
        'message': 'Koneksi error: ${e.toString()}',
      };
    }
  }

  // Get current user from server
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getMe}'),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final user = UserModel.fromJson(data['data']);
        await _saveUser(user);
        return user;
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshResult = await refreshToken();
        if (refreshResult['success'] == true) {
          // Retry get current user with new token
          return await getCurrentUser();
        }
      }
      return null;
    } catch (e) {
      Log.e('Get current user error: $e');
      return null;
    }
  }

  // Save auth data locally
  Future<void> _saveAuthData(String token, String? refreshToken, UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      Log.e('Error saving auth data: $e');
    }
  }

  // Save user only
  Future<void> _saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      Log.e('Error saving user: $e');
    }
  }

  // services/auth_service.dart

// 🔴 TAMBAHKAN: Method public untuk save user
Future<void> saveUser(UserModel user) async {
  await _saveUser(user);
}

// Ubah _saveUser menjadi public atau tambahkan wrapper
// Jika tidak ingin mengubah, tambahkan method ini:
Future<void> updateLocalUser(UserModel user) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    print('💾 User saved to local storage: ${user.fullName}');
  } catch (e) {
    print('❌ Error saving user: $e');
  }
}

  // Get stored token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      Log.e('Error getting token: $e');
      return null;
    }
  }

  // Get stored refresh token
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      Log.e('Error getting refresh token: $e');
      return null;
    }
  }

  // Get stored user
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      Log.e('Error getting user: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    
    // Optional: Check if token is still valid
    final user = await getUser();
    return user != null;
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        // Optional: Call logout endpoint
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logout}'),
          headers: {
            'Content-Type': ApiConstants.contentType,
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      Log.e('Error logging out: $e');
      // Still clear local data even if server call fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userKey);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
  required String fullName,
  required String phone,
}) async {
  try {
    final token = await getToken();
    
    // ✅ Perbaiki URL - ganti YOUR_API_URL dengan BASE_URL
    final response = await http.put(
      Uri.parse('$BASE_URL/api/profile/profile'), // URL yang benar
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'full_name': fullName, // ✅ Ganti fullName jadi full_name (sesuai backend)
        'phone': phone,
      }),
    );

    print('Update profile response: ${response.statusCode}');
    print('Update profile body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'message': data['message'],
        'user': UserModel.fromJson(data['data']), // ✅ data['data'] bukan data['user']
      };
    } else {
      final data = json.decode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update profile',
      };
    }
  } catch (e) {
    print('Update profile error: $e');
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}

// services/auth_service.dart

Future<Map<String, dynamic>> updateCompleteProfile({
  required String fullName,
  required String phone,
  required File avatarImage,
}) async {
  try {
    final token = await getToken();
    
    print('📤 Starting updateCompleteProfile');
    print('   - fullName: $fullName');
    print('   - phone: $phone');
    print('   - avatarPath: ${avatarImage.path}');
    
    // Cara 1: Upload avatar dulu dengan POST
    var avatarRequest = http.MultipartRequest(
      'POST',
      Uri.parse('$BASE_URL/api/profile/avatar'),
    );
    
    avatarRequest.headers['Authorization'] = 'Bearer $token';
    avatarRequest.files.add(
      await http.MultipartFile.fromPath('avatar', avatarImage.path),
    );
    
    print('📸 Uploading avatar...');
    final avatarResponse = await avatarRequest.send();
    final avatarResponseBody = await avatarResponse.stream.bytesToString();
    print('📸 Avatar response status: ${avatarResponse.statusCode}');
    print('📸 Avatar response body: $avatarResponseBody');
    
    final avatarData = json.decode(avatarResponseBody);
    
    if (avatarResponse.statusCode != 200) {
      return {
        'success': false,
        'message': avatarData['message'] ?? 'Failed to upload avatar',
      };
    }
    
    // Cara 2: Update profile dengan PUT (bukan Multipart)
    print('📝 Updating profile...');
    final profileResponse = await http.put(
      Uri.parse('$BASE_URL/api/profile/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'full_name': fullName, // Pastikan pakai full_name, bukan fullName
        'phone': phone,
      }),
    );
    
    print('📝 Profile response status: ${profileResponse.statusCode}');
    final profileResponseBody = profileResponse.body;
    print('📝 Profile response body: $profileResponseBody');
    
    final profileData = json.decode(profileResponseBody);
    
    if (profileResponse.statusCode == 200) {
      return {
        'success': true,
        'message': profileData['message'],
        'avatarUrl': avatarData['data']?['avatar_url'],
        'user': profileData['data'],
      };
    } else {
      return {
        'success': false,
        'message': profileData['message'] ?? 'Failed to update profile',
      };
    }
  } catch (e) {
    print('❌ Update complete profile error: $e');
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}



  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan',
        };
      }

      if (newPassword.length < 6) {
        return {
          'success': false,
          'message': 'Password baru minimal 6 karakter',
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.changePassword}'),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password berhasil diubah',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengubah password',
        };
      }
    } catch (e) {
      Log.e('Change password error: $e');
      return {
        'success': false,
        'message': 'Koneksi error: ${e.toString()}',
      };
    }
  }

  // Forgot password - send reset email
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.forgotPassword}'),
        headers: {
          'Content-Type': ApiConstants.contentType,
        },
        body: jsonEncode({
          'email': email.trim(),
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Email reset password telah dikirim',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengirim email reset password',
        };
      }
    } catch (e) {
      Log.e('Forgot password error: $e');
      return {
        'success': false,
        'message': 'Koneksi error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
  try {
    final token = await getToken();
    
    print('Getting user profile...');
    print('Token: $token');
    print('URL: $BASE_URL/api/profile/profile');
    
    final response = await http.get(
      Uri.parse('$BASE_URL/api/profile/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'user': UserModel.fromJson(data['data']),
        'stats': data['data']['stats'] ?? {
          'totalBookings': 0,
          'ongoingBookings': 0, 
          'completedBookings': 0,
        },
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to load profile',
      };
    }
  } catch (e) {
    print('Get profile error: $e');
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}

  // Clear all local data (force logout)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Log.d('All local data cleared');
    } catch (e) {
      Log.e('Error clearing data: $e');
    }
  }
}