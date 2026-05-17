// lib/modules/booking/screens/hangout_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_confirmation_screen.dart';

class HangoutBookingScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedPartner;
  
  const HangoutBookingScreen({super.key, this.selectedPartner});

  @override
  State<HangoutBookingScreen> createState() => _HangoutBookingScreenState();
}

class _HangoutBookingScreenState extends State<HangoutBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedActivity = 'Ngopi';
  int _selectedPartnerId = 0;
  String _selectedPartnerName = '';
  String _selectedPartnerImage = '';
  double _selectedPartnerRating = 0;
  int _selectedPartnerPrice = 0;
  String _selectedPartnerInterest = '';
  String _selectedPartnerVehicle = '';
  int _selectedPartnerTrips = 0;
  
  final List<String> _activities = ['Ngopi', 'Makan', 'Jalan-jalan', 'Belanja', 'Olahraga', 'Nonton'];
  
  final List<Map<String, dynamic>> _partners = [
    {
      'id': 1, 
      'name': 'Arya Perkasa', 
      'interest': 'Ngopi & Ngobrol', 
      'rating': 4.8, 
      'price': 50000,
      'image': 'https://i.pravatar.cc/300?img=11',
      'vehicle': 'Honda PCX 160',
      'plateNumber': 'B 1234 ABC',
      'trips': 320
    },
    {
      'id': 2, 
      'name': 'Dian Sastro', 
      'interest': 'Kuliner & Travel', 
      'rating': 4.9, 
      'price': 60000,
      'image': 'https://i.pravatar.cc/300?img=12',
      'vehicle': 'Yamaha NMAX',
      'plateNumber': 'B 5678 DEF',
      'trips': 450
    },
    {
      'id': 3, 
      'name': 'Putra Ramadhan', 
      'interest': 'Olahraga & Musik', 
      'rating': 5.0, 
      'price': 55000,
      'image': 'https://i.pravatar.cc/300?img=13',
      'vehicle': 'Vespa Primavera',
      'plateNumber': 'B 9012 GHI',
      'trips': 280
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedPartner != null) {
      _selectedPartnerName = widget.selectedPartner!['name'] ?? '';
      _selectedPartnerImage = widget.selectedPartner!['image'] ?? '';
      _selectedPartnerRating = widget.selectedPartner!['rating'] is String 
          ? double.parse(widget.selectedPartner!['rating']) 
          : (widget.selectedPartner!['rating'] ?? 0.0);
      _selectedPartnerPrice = widget.selectedPartner!['price'] ?? 0;
      _selectedPartnerVehicle = widget.selectedPartner!['vehicle'] ?? '';
      
      final matchingPartner = _partners.firstWhere(
        (p) => p['name'] == _selectedPartnerName,
        orElse: () => {'id': 0},
      );
      _selectedPartnerId = matchingPartner['id'];
      _selectedPartnerInterest = matchingPartner['interest'] ?? '';
      _selectedPartnerTrips = matchingPartner['trips'] ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      appBar: AppBar(
        title: Text(
          "Hangout Partner",
          style: GoogleFonts.poppins(
            color: const Color(0xFF9D6BFF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0D0C11),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF9D6BFF)),
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
              _buildSectionTitle("Pilih Aktivitas"),
              const SizedBox(height: 10),
              _buildActivitySelector(),
              const SizedBox(height: 20),
              
              _buildSectionTitle("Lokasi Hangout"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _locationController,
                hint: "Masukkan lokasi hangout",
                icon: Icons.location_on_rounded,
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
              
              _buildSectionTitle("Durasi (Jam)"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _durationController,
                hint: "Berapa jam hangout?",
                icon: Icons.timer_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              
              _buildSectionTitle("Pilih Partner"),
              const SizedBox(height: 10),
              _buildPartnerSelector(),
              const SizedBox(height: 20),
              
              _buildSectionTitle("Catatan (Opsional)"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _notesController,
                hint: "Tambahkan catatan untuk partner",
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
          prefixIcon: Icon(icon, color: const Color(0xFF9D6BFF), size: 20),
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

  Widget _buildActivitySelector() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _activities.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final activity = _activities[index];
          final isSelected = _selectedActivity == activity;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedActivity = activity;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF9D6BFF) : const Color(0xFF1C1B21),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Text(
                activity,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
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
                  primary: Color(0xFF9D6BFF),
                  onPrimary: Colors.white,
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
            const Icon(Icons.calendar_today_rounded, color: Color(0xFF9D6BFF), size: 20),
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
                  primary: Color(0xFF9D6BFF),
                  onPrimary: Colors.white,
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
            const Icon(Icons.access_time_rounded, color: Color(0xFF9D6BFF), size: 20),
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

  Widget _buildPartnerSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: _partners.map((partner) {
          final isSelected = _selectedPartnerId == partner['id'];
          return RadioListTile<int>(
            value: partner['id'],
            groupValue: _selectedPartnerId,
            onChanged: (value) {
              setState(() {
                _selectedPartnerId = value!;
                final selectedPartner = _partners.firstWhere((p) => p['id'] == _selectedPartnerId);
                _selectedPartnerName = selectedPartner['name'];
                _selectedPartnerImage = selectedPartner['image'];
                _selectedPartnerRating = selectedPartner['rating'];
                _selectedPartnerPrice = selectedPartner['price'];
                _selectedPartnerInterest = selectedPartner['interest'];
                _selectedPartnerVehicle = selectedPartner['vehicle'];
                _selectedPartnerTrips = selectedPartner['trips'];
              });
            },
            activeColor: const Color(0xFF9D6BFF),
            title: Text(
              partner['name'],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "${partner['interest']} • ⭐ ${partner['rating']}",
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            secondary: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Rp ${partner['price']}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9D6BFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "/jam",
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
            if (_selectedPartnerId == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pilih partner terlebih dahulu")),
              );
              return;
            }
            
            int duration = int.tryParse(_durationController.text) ?? 0;
            if (duration <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Masukkan durasi hangout yang valid")),
              );
              return;
            }
            
            int pricePerHour = _selectedPartnerPrice;
            int totalPrice = duration * pricePerHour;
            int dp = (totalPrice * 0.3).toInt();
            int remainingPayment = totalPrice - dp;
            
            final bookingData = {
              'serviceType': 'hangout',
              'activity': _selectedActivity,
              'driverName': _selectedPartnerName,
              'driverImage': _selectedPartnerImage,
              'driverRating': _selectedPartnerRating.toString(),
              'driverTrips': _selectedPartnerTrips.toString(),
              'vehicle': _selectedPartnerVehicle,
              'plateNumber': 'B 1234 ${_selectedPartnerName.substring(0, 2).toUpperCase()}',
              'pickup': _locationController.text,
              'destination': _locationController.text,
              'date': _dateController.text,
              'time': _timeController.text,
              'duration': duration,
              'serviceFee': totalPrice,
              'insuranceFee': 10000,
              'totalPayment': totalPrice + 10000,
              'dp': dp,
              'remainingPayment': remainingPayment + 10000,
              'estimatedTime': '15',
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
          backgroundColor: const Color(0xFF9D6BFF),
          foregroundColor: const Color(0xFF2D1B4E),
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