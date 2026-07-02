import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class EditDriverProfileScreen extends StatefulWidget {
  const EditDriverProfileScreen({super.key});

  @override
  State<EditDriverProfileScreen> createState() => _EditDriverProfileScreenState();
}

class _EditDriverProfileScreenState extends State<EditDriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _vehicleNameController;
  late TextEditingController _plateNumberController;
  late TextEditingController _priceController;
  late TextEditingController _experienceController;
  late TextEditingController _bioController;
  
  String _selectedGender = 'Laki-laki';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final auth = Provider.of<AuthProvider>(context);
      final user = auth.user;
      final driver = auth.driverProfileData;

      _fullNameController = TextEditingController(text: user?.fullName ?? '');
      _phoneController = TextEditingController(text: user?.phone ?? '');
      _vehicleNameController = TextEditingController(text: driver?['vehicle_name'] ?? '');
      _plateNumberController = TextEditingController(text: driver?['plate_number'] ?? '');
      _priceController = TextEditingController(text: (driver?['price_per_hour'] ?? 50000).toString());
      _experienceController = TextEditingController(text: (driver?['experience_years'] ?? 0).toString());
      _bioController = TextEditingController(text: driver?['vehicle_stnk'] ?? '');
      _selectedGender = user?.gender ?? 'Laki-laki';
      
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _vehicleNameController.dispose();
    _plateNumberController.dispose();
    _priceController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.updateProfile(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      gender: _selectedGender,
      vehicleName: _vehicleNameController.text,
      plateNumber: _plateNumberController.text,
      pricePerHour: double.tryParse(_priceController.text) ?? 50000.0,
      experienceYears: int.tryParse(_experienceController.text) ?? 0,
      bio: _bioController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Gagal memperbarui profil'),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      appBar: AppBar(
        title: Text(
          "Edit Profil",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 30),

                  _buildSectionHeader("INFORMASI KENDARAAN"),

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
                  const SizedBox(height: 30),

                  _buildSectionHeader("PENGATURAN LAYANAN"),

                  _buildFieldLabel("TARIF PER JAM (RP)"),
                  _buildTextField(
                    controller: _priceController,
                    hint: "50000",
                    icon: Icons.monetization_on_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Tarif harus diisi';
                      final price = double.tryParse(v);
                      if (price == null || price < 25000) return 'Tarif minimal Rp 25.000';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel("PENGALAMAN (TAHUN)"),
                  _buildTextField(
                    controller: _experienceController,
                    hint: "3",
                    icon: Icons.work_history_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.trim().isEmpty ? 'Pengalaman harus diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildFieldLabel("BIOGRAFI / DESKRIPSI DIRI"),
                  _buildTextField(
                    controller: _bioController,
                    hint: "Tulis biografi menarik tentang diri Anda agar klien tertarik menyewa jasa pendampingan Anda...",
                    icon: Icons.description_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 40),

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
                      ),
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A1031)),
                                ),
                              )
                            : Text(
                                "SIMPAN PERUBAHAN",
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
    int maxLines = 1,
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
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFFFF9DCC), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}
