// lib/modules/auth/screens/register_driver_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../providers/auth_provider.dart';
import '../../../providers/driver_provider.dart';
import '../../drivers/screens/driver_home_screen.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Personal Information
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Driver & Vehicle Information
  final _vehicleNameController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _pricePerHourController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _idCardNumberController = TextEditingController();
  final _driverLicenseController = TextEditingController();
  final _vehicleStnkController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isAgreed = false;
  
  String? _selectedVehicleType;
  String? _vehicleTypeError; // Untuk menampung error vehicle type
  File? _ktpImage;
  File? _simImage;
  File? _stnkImage;
  File? _vehiclePhotoImage;
  
  final List<String> _vehicleTypes = [
    'Motor', 
    'Mobil Penumpang', 
    'Mobil Keluarga', 
    'SUV', 
    'Minibus'
  ];
  
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _vehicleNameController.dispose();
    _plateNumberController.dispose();
    _pricePerHourController.dispose();
    _experienceYearsController.dispose();
    _idCardNumberController.dispose();
    _driverLicenseController.dispose();
    _vehicleStnkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, Function(File) onImagePicked) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        onImagePicked(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Fungsi validasi form
  bool _validateForm() {
    // Validasi vehicle type
    if (_selectedVehicleType == null) {
      setState(() {
        _vehicleTypeError = 'Pilih tipe kendaraan';
      });
      return false;
    } else {
      setState(() {
        _vehicleTypeError = null;
      });
    }
    
    // Validasi form fields
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    
    return true;
  }

  Future<void> _handleRegister() async {
    // Validasi form
    if (!_validateForm()) {
      return;
    }

    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap setujui syarat dan ketentuan driver'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validasi file upload
    if (_ktpImage == null || _simImage == null || _stnkImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap upload KTP, SIM, dan STNK terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final driverProvider = Provider.of<DriverProvider>(context, listen: false);

    try {
      final success = await driverProvider.registerDriver(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        vehicleType: _selectedVehicleType!,
        vehicleName: _vehicleNameController.text.trim(),
        plateNumber: _plateNumberController.text.toUpperCase().trim(),
        pricePerHour: int.parse(_pricePerHourController.text),
        experienceYears: int.tryParse(_experienceYearsController.text) ?? 0,
        idCardNumber: _idCardNumberController.text.trim(),
        driverLicenseNumber: _driverLicenseController.text.trim(),
        vehicleStnk: _vehicleStnkController.text.trim(),
        ktpImage: _ktpImage!,
        simImage: _simImage!,
        stnkImage: _stnkImage!,
        vehiclePhoto: _vehiclePhotoImage,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pendaftaran Berhasil!',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Data driver Anda sedang diverifikasi oleh admin.\nKami akan memberitahu via email jika sudah disetujui.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/driver-home');
                    },
                    child: Text(
                      'Ke Halaman Driver',
                      style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC)),
                    ),
                  ),
                ],
              );
            },
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(driverProvider.errorMessage ?? 'Pendaftaran gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFF9DCC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daftar Sebagai Driver',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF9DCC).withOpacity(0.2),
                            Colors.purple.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_transportation, color: Color(0xFFFF9DCC), size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bergabung sebagai Driver',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Dapatkan penghasilan tambahan dengan mengantar pelanggan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// Section Title: Informasi Pribadi
                    _buildSectionTitle('Informasi Pribadi', Icons.person_outline),
                    const SizedBox(height: 16),

                    /// Full Name
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Nama Lengkap *',
                      hint: 'Sesuai dengan KTP',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nama harus diisi';
                        if (value.length < 3) return 'Nama minimal 3 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email *',
                      hint: 'email@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email harus diisi';
                        if (!value.contains('@') || !value.contains('.')) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Phone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Nomor HP *',
                      hint: '08xxxxxxxxxx',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nomor HP harus diisi';
                        if (value.length < 10 || value.length > 13) return 'Nomor HP tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// ID Card Number (KTP)
                    _buildTextField(
                      controller: _idCardNumberController,
                      label: 'Nomor KTP *',
                      hint: '16 digit nomor KTP',
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nomor KTP harus diisi';
                        if (value.length != 16) return 'Nomor KTP harus 16 digit';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Driver License Number (SIM)
                    _buildTextField(
                      controller: _driverLicenseController,
                      label: 'Nomor SIM *',
                      hint: 'Nomor Surat Izin Mengemudi',
                      icon: Icons.drive_eta_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nomor SIM harus diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    /// Section Title: Informasi Kendaraan
                    _buildSectionTitle('Informasi Kendaraan', Icons.directions_car),
                    const SizedBox(height: 16),

                    /// Vehicle Type Dropdown (Fixed version)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipe Kendaraan *',
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
                            border: Border.all(
                              color: _vehicleTypeError != null 
                                ? Colors.red 
                                : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedVehicleType,
                              hint: Text(
                                'Pilih tipe kendaraan',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                              dropdownColor: const Color(0xFF1A1820),
                              style: const TextStyle(color: Colors.white),
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: const Color(0xFFFF9DCC)),
                              items: _vehicleTypes.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedVehicleType = newValue;
                                  if (newValue != null) {
                                    _vehicleTypeError = null;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        if (_vehicleTypeError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Text(
                              _vehicleTypeError!,
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Vehicle Name
                    _buildTextField(
                      controller: _vehicleNameController,
                      label: 'Nama Kendaraan *',
                      hint: 'Contoh: Honda Beat, Toyota Avanza',
                      icon: Icons.directions_car,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nama kendaraan harus diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Plate Number
                    _buildTextField(
                      controller: _plateNumberController,
                      label: 'Nomor Plat *',
                      hint: 'B 1234 ABC',
                      icon: Icons.confirmation_number_outlined,
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nomor plat harus diisi';
                        if (value.length < 5) return 'Nomor plat tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Price Per Hour
                    _buildTextField(
                      controller: _pricePerHourController,
                      label: 'Harga per Jam *',
                      hint: 'Minimal Rp 25.000',
                      icon: Icons.money_outlined,
                      keyboardType: TextInputType.number,
                      prefixText: 'Rp ',
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Harga per jam harus diisi';
                        final price = int.tryParse(value);
                        if (price == null) return 'Harga tidak valid';
                        if (price < 25000) return 'Minimal Rp 25.000';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Vehicle STNK Number
                    _buildTextField(
                      controller: _vehicleStnkController,
                      label: 'Nomor STNK *',
                      hint: 'Nomor Surat Tanda Nomor Kendaraan',
                      icon: Icons.description_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nomor STNK harus diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Experience Years
                    _buildTextField(
                      controller: _experienceYearsController,
                      label: 'Pengalaman (Tahun)',
                      hint: '0',
                      icon: Icons.work_outline,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    /// Section Title: Dokumen
                    _buildSectionTitle('Upload Dokumen', Icons.cloud_upload_outlined),
                    const SizedBox(height: 8),
                    Text(
                      'Dokumen yang diperlukan untuk verifikasi',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Upload KTP
                    _buildUploadCard(
                      title: 'Foto KTP *',
                      subtitle: 'Upload foto KTP yang jelas',
                      icon: Icons.credit_card,
                      file: _ktpImage,
                      onTap: () => _pickImage(ImageSource.gallery, (file) {
                        setState(() => _ktpImage = file);
                      }),
                    ),
                    const SizedBox(height: 12),

                    /// Upload SIM
                    _buildUploadCard(
                      title: 'Foto SIM *',
                      subtitle: 'Upload foto SIM yang masih berlaku',
                      icon: Icons.drive_eta,
                      file: _simImage,
                      onTap: () => _pickImage(ImageSource.gallery, (file) {
                        setState(() => _simImage = file);
                      }),
                    ),
                    const SizedBox(height: 12),

                    /// Upload STNK
                    _buildUploadCard(
                      title: 'Foto STNK *',
                      subtitle: 'Upload foto STNK kendaraan',
                      icon: Icons.description,
                      file: _stnkImage,
                      onTap: () => _pickImage(ImageSource.gallery, (file) {
                        setState(() => _stnkImage = file);
                      }),
                    ),
                    const SizedBox(height: 12),

                    /// Upload Vehicle Photo (Optional)
                    _buildUploadCard(
                      title: 'Foto Kendaraan (Opsional)',
                      subtitle: 'Upload foto kendaraan Anda',
                      icon: Icons.camera_alt,
                      file: _vehiclePhotoImage,
                      onTap: () => _pickImage(ImageSource.gallery, (file) {
                        setState(() => _vehiclePhotoImage = file);
                      }),
                    ),
                    const SizedBox(height: 24),

                    /// Password Fields
                    _buildSectionTitle('Keamanan Akun', Icons.security),
                    const SizedBox(height: 16),

                    /// Password
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password *',
                      hint: 'Minimal 6 karakter',
                      icon: Icons.lock_outline,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade400,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password harus diisi';
                        if (value.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Confirm Password
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Password *',
                      hint: 'Masukkan ulang password',
                      icon: Icons.lock_outline,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade400,
                        ),
                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Konfirmasi password harus diisi';
                        if (value != _passwordController.text) return 'Password tidak cocok';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    /// Terms and Conditions
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _isAgreed,
                            onChanged: (value) => setState(() => _isAgreed = value ?? false),
                            activeColor: const Color(0xFFFF9DCC),
                            checkColor: const Color(0xFF6F004B),
                            side: BorderSide(color: Colors.grey.shade600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Saya menyetujui ',
                                  style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
                                ),
                                TextSpan(
                                  text: 'Syarat & Ketentuan Driver',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFF9DCC),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' dan ',
                                  style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
                                ),
                                TextSpan(
                                  text: 'Kode Etik Driver',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFF9DCC),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    /// Register Button
                    _buildRegisterButton(),
                    const SizedBox(height: 20),

                    /// Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun driver? ',
                          style: GoogleFonts.poppins(color: Colors.grey.shade400),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFFF9DCC),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF9DCC), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    String? prefixText,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            textCapitalization: textCapitalization,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(icon, color: const Color(0xFFFF9DCC), size: 20),
              prefixText: prefixText,
              prefixStyle: TextStyle(color: Colors.grey.shade400),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: file != null ? const Color(0xFFFF9DCC) : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9DCC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFF9DCC), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    file != null ? 'File terpilih' : subtitle,
                    style: GoogleFonts.poppins(
                      color: file != null ? const Color(0xFFFF9DCC) : Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              file != null ? Icons.check_circle : Icons.cloud_upload,
              color: file != null ? Colors.green : const Color(0xFFFF9DCC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9DCC),
          foregroundColor: const Color(0xFF6F004B),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                'Daftar Sebagai Driver',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}