// lib/modules/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/auth_provider.dart';
import '../../clients/screens/home_loggedin_screen.dart';
import 'register_screen.dart'; // Import RegisterScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _loginError;
  

  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      // PERBAIKAN: Menggunakan positional arguments, bukan named parameters
      final success = await authProvider.login(
        _emailController.text.trim(), // email (positional)
        _passwordController.text,      // password (positional)
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Cek role user dari response
        final userRole = authProvider.userRole;
        
        if (mounted) {
          // Simpan role ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userRole', userRole);
          
          // Navigasi berdasarkan role
          if (userRole == 'driver') {
            // Akun driver tidak diizinkan masuk ke aplikasi client
            await authProvider.logout();
            setState(() {
              _loginError = 'Akun driver tidak dapat login di aplikasi ini. Aplikasi ini khusus untuk pelanggan.';
            });
          } else {
            // User biasa
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeLoggedInScreen()),
            );
          }
        }
      } else {
        setState(() {
          _loginError = authProvider.errorMessage ?? 'Login gagal. Periksa email dan password Anda.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loginError = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      body: Stack(
        children: [
          /// Background Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF9DCC).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  /// Logo / Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9DCC).withOpacity(0.2),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/app_logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Temenin Ajaa',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF9DCC),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login ke akun Anda',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  /// Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Email Field
                        Text(
                          'Email',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade300,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Masukkan email Anda',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF9DCC)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email harus diisi';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Email tidak valid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        /// Password Field
                        Text(
                          'Password',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade300,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Masukkan password',
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF9DCC)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password harus diisi';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                        ),
                        
                        /// Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Implement forgot password
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fitur lupa password akan segera tersedia'),
                                ),
                              );
                            },
                            child: Text(
                              'Lupa Password?',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFF9DCC),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        /// Error Message
                        if (_loginError != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _loginError!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 24),
                        
                        /// Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9DCC),
                              foregroundColor: const Color(0xFF6F004B),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F004B)),
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        /// Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun? ',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Daftar Sekarang',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFF9DCC),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}