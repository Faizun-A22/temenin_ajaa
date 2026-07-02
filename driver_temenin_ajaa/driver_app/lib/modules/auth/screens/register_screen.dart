import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../driver/screens/home_screen.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vehicleNameController = TextEditingController();
  final _plateNumberController = TextEditingController();
  
  String _selectedVehicleType = 'Motor';
  String _selectedGender = 'Laki-laki';
  bool _obscurePassword = true;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      gender: _selectedGender,
      vehicleType: _selectedVehicleType,
      vehicleName: _vehicleNameController.text,
      plateNumber: _plateNumberController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E0A2D),
              Color(0xFF0B0910),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daftar Akun Driver",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bergabunglah dengan armada Temenin Ajaa dan mulai hasilkan uang",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Section: Informasi Pribadi
                  _buildSectionHeader("INFORMASI PRIBADI"),
                  
                  _buildFieldLabel("NAMA LENGKAP"),
                  _buildTextField(
                    controller: _fullNameController,
                    hint: "Andi Wijaya",
                    icon: Icons.person_rounded,
                    validator: (v) => v!.trim().isEmpty ? 'Nama harus diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel("NOMOR TELEPON"),
                  _buildTextField(
                    controller: _phoneController,
                    hint: "+62 812-xxxx-xxxx",
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.trim().isEmpty ? 'Nomor telepon harus diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel("GENDER"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16151A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        dropdownColor: const Color(0xFF16151A),
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: ['Laki-laki', 'Perempuan']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedGender = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel("ALAMAT EMAIL"),
                  _buildTextField(
                    controller: _emailController,
                    hint: "andi.wijaya@gmail.com",
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (!v!.contains('@')) ? 'Masukkan email valid' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel("PASSWORD"),
                  _buildTextField(
                    controller: _passwordController,
                    hint: "Minimal 6 karakter",
                    icon: Icons.lock_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: Colors.white30,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) => v!.length < 6 ? 'Password minimal 6 karakter' : null,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Section: Detail Kendaraan
                  _buildSectionHeader("INFORMASI KENDARAAN"),
                  
                  _buildFieldLabel("TIPE KENDARAAN"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16151A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: _selectedVehicleType,
                        dropdownColor: const Color(0xFF16151A),
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: ['Motor', 'Mobil']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedVehicleType = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel("MERK / MODEL KENDARAAN"),
                  _buildTextField(
                    controller: _vehicleNameController,
                    hint: "Yamaha NMAX 2024 / Toyota Avanza",
                    icon: Icons.directions_car_rounded,
                    validator: (v) => v!.trim().isEmpty ? 'Detail kendaraan harus diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel("PLAT NOMOR KENDARAAN"),
                  _buildTextField(
                    controller: _plateNumberController,
                    hint: "B 1234 ABC",
                    icon: Icons.credit_card_rounded,
                    validator: (v) => v!.trim().isEmpty ? 'Plat nomor harus diisi' : null,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF9DCC),
                            Color(0xFFFF6B9D),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9DCC).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ]
                      ),
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A1031)),
                                ),
                              )
                            : Text(
                                "DAFTAR SEBAGAI DRIVER",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF4A1031),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white38,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.white10),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFF9DCC),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFFFF9DCC), size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}
