// lib/modules/booking/screens/antar_jemput_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_confirmation_screen.dart';

class AntarJemputBookingScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedPartner;
  
  const AntarJemputBookingScreen({super.key, this.selectedPartner});

  @override
  State<AntarJemputBookingScreen> createState() => _AntarJemputBookingScreenState();
}

class _AntarJemputBookingScreenState extends State<AntarJemputBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  
  int _selectedDriverId = 0;
  String _selectedDriverName = '';
  String _selectedDriverImage = '';
  double _selectedDriverRating = 0;
  int _selectedDriverPrice = 0;
  String _selectedDriverVehicle = '';
  int _selectedDriverTrips = 0;
  
  final List<Map<String, dynamic>> _drivers = [
    {
      'id': 1, 
      'name': 'Arya Perkasa', 
      'vehicle': 'Kawasaki Ninja 250', 
      'rating': 4.8, 
      'price': 15000,
      'image': 'https://i.pravatar.cc/300?img=11',
      'trips': 320
    },
    {
      'id': 2, 
      'name': 'Dian Sastro', 
      'vehicle': 'Honda CBR 250RR', 
      'rating': 4.9, 
      'price': 20000,
      'image': 'https://i.pravatar.cc/300?img=12',
      'trips': 450
    },
    {
      'id': 3, 
      'name': 'Putra Ramadhan', 
      'vehicle': 'Yamaha R15 V4', 
      'rating': 5.0, 
      'price': 18000,
      'image': 'https://i.pravatar.cc/300?img=13',
      'trips': 280
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedPartner != null) {
      _selectedDriverName = widget.selectedPartner!['name'] ?? '';
      _selectedDriverImage = widget.selectedPartner!['image'] ?? '';
      _selectedDriverRating = widget.selectedPartner!['rating'] is String 
          ? double.parse(widget.selectedPartner!['rating']) 
          : (widget.selectedPartner!['rating'] ?? 0.0);
      _selectedDriverPrice = widget.selectedPartner!['price'] ?? 0;
      _selectedDriverVehicle = widget.selectedPartner!['vehicle'] ?? '';
      
      final matchingDriver = _drivers.firstWhere(
        (d) => d['name'] == _selectedDriverName,
        orElse: () => {'id': 0},
      );
      _selectedDriverId = matchingDriver['id'];
      _selectedDriverTrips = matchingDriver['trips'] ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      appBar: AppBar(
        title: Text(
          "Antar Jemput",
          style: GoogleFonts.poppins(
            color: const Color(0xFFFF9DCC),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0D0C11),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFFF9DCC)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Lokasi Penjemputan"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _pickupController,
                hint: "Masukkan lokasi penjemputan",
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 20),
              
              _buildSectionTitle("Lokasi Tujuan"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _destinationController,
                hint: "Masukkan lokasi tujuan",
                icon: Icons.flag_rounded,
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Tanggal"),
                        const SizedBox(height: 10),
                        _buildDateField(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Waktu"),
                        const SizedBox(height: 10),
                        _buildTimeField(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildSectionTitle("Pilih Driver"),
              const SizedBox(height: 10),
              _buildDriverSelector(),
              const SizedBox(height: 20),
              
              _buildSectionTitle("Catatan (Opsional)"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _notesController,
                hint: "Tambahkan catatan untuk driver",
                icon: Icons.note_add_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              
              _buildBookingButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(icon, color: const Color(0xFFFF9DCC), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Field ini harus diisi';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFFF9DCC),
                  onPrimary: Colors.black,
                  surface: Color(0xFF1C1B21),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
            final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
            final dayName = days[date.weekday - 1];
            _dateController.text = "$dayName, ${date.day} ${months[date.month - 1]} ${date.year}";
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1B21),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: Color(0xFFFF9DCC), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dateController.text.isEmpty ? "Pilih tanggal" : _dateController.text,
                style: TextStyle(
                  color: _dateController.text.isEmpty ? Colors.white.withValues(alpha: 0.3) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFFF9DCC),
                  onPrimary: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          setState(() {
            final hour = time.hour.toString().padLeft(2, '0');
            final minute = time.minute.toString().padLeft(2, '0');
            _timeController.text = "$hour:$minute WIB";
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1B21),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: Color(0xFFFF9DCC), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _timeController.text.isEmpty ? "Pilih waktu" : _timeController.text,
                style: TextStyle(
                  color: _timeController.text.isEmpty ? Colors.white.withValues(alpha: 0.3) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: _drivers.map((driver) {
          final isSelected = _selectedDriverId == driver['id'];
          return RadioListTile<int>(
            value: driver['id'],
            groupValue: _selectedDriverId,
            onChanged: (value) {
              setState(() {
                _selectedDriverId = value!;
                final selectedDriver = _drivers.firstWhere((d) => d['id'] == _selectedDriverId);
                _selectedDriverName = selectedDriver['name'];
                _selectedDriverImage = selectedDriver['image'];
                _selectedDriverRating = selectedDriver['rating'];
                _selectedDriverPrice = selectedDriver['price'];
                _selectedDriverVehicle = selectedDriver['vehicle'];
                _selectedDriverTrips = selectedDriver['trips'];
              });
            },
            activeColor: const Color(0xFFFF9DCC),
            title: Text(
              driver['name'],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "${driver['vehicle']} • ⭐ ${driver['rating']}",
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            secondary: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Rp ${driver['price']}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF9DCC),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "/km",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (_selectedDriverId == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pilih driver terlebih dahulu")),
              );
              return;
            }
            
            const distance = 15;
            final serviceFee = _selectedDriverPrice * distance;
            const insuranceFee = 5000;
            final totalPayment = serviceFee + insuranceFee;
            final dp = (totalPayment * 0.3).toInt();
            final remainingPayment = totalPayment - dp;
            
            final bookingData = {
              'serviceType': 'antar_jemput',
              'driverName': _selectedDriverName,
              'driverImage': _selectedDriverImage,
              'driverRating': _selectedDriverRating.toString(),
              'driverTrips': _selectedDriverTrips.toString(),
              'vehicle': _selectedDriverVehicle,
              'plateNumber': 'B 1234 ${_selectedDriverName.substring(0, 2).toUpperCase()}',
              'pickup': _pickupController.text,
              'destination': _destinationController.text,
              'date': _dateController.text,
              'time': _timeController.text,
              'serviceFee': serviceFee,
              'insuranceFee': insuranceFee,
              'totalPayment': totalPayment,
              'dp': dp,
              'remainingPayment': remainingPayment,
              'estimatedTime': (distance * 3).toString(),
              'notes': _notesController.text,
            };
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingConfirmationScreen(bookingData: bookingData),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9DCC),
          foregroundColor: const Color(0xFF4A1031),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          "Booking Sekarang",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}