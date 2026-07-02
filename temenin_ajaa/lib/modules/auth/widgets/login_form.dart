// Path: widgets\login_form.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:temenin_ajaa/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua field')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
    
    // Navigate to home
    if (mounted) {
      context.go(AppRoutes.clientHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: MediaQuery.viewInsetsOf(context).bottom > 0 
              ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
              : ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 24),
                _buildPasswordField(),
                const SizedBox(height: 8),
                _buildForgotPassword(),
                const SizedBox(height: 32),
                _buildLoginButton(),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildGoogleButton(),
                const SizedBox(height: 16),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HP / EMAIL',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: AppTheme.textLight),
          decoration: InputDecoration(
            hintText: 'Masukkan nomor atau email',
            hintStyle: TextStyle(
              color: AppTheme.textMuted.withOpacity(0.4),
            ),
            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20),
            filled: true,
            fillColor: AppTheme.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PASSWORD',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(color: AppTheme.textLight),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: AppTheme.textMuted.withOpacity(0.4),
            ),
            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textMuted,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: AppTheme.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Lupa Password?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xB3FFB0D0),
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPink,
          foregroundColor: AppTheme.deepRed,
          elevation: 0,
          shadowColor: AppTheme.primaryPink.withOpacity(0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepRed),
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: Colors.white.withOpacity(0.05)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Atau',
            style: TextStyle(
              color: AppTheme.textMuted.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: Colors.white.withOpacity(0.05)),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Image.network(
        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
        width: 20,
        height: 20,
      ),
      label: const Text(
        'Login dengan Google',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryPink,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppTheme.primaryPink.withOpacity(0.3), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(double.infinity, 56),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun?',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        TextButton(
          onPressed: () {
            // Navigate to register screen
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Daftar Akun',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryPink,
            ),
          ),
        ),
      ],
    );
  }
}