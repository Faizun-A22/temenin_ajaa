// lib/modules/booking/screens/hangout_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:temenin_ajaa/providers/driver_provider.dart';
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
  final _notesController = TextEditingController();
  
  // Multi-Layanan State
  bool _addAdditionalService = false;
  String _additionalServiceType = 'antar_jemput'; // or 'freedom'
  final _addPickupController = TextEditingController();
  final _addDestinationController = TextEditingController();
  final _addFreedomDescriptionController = TextEditingController();
  final _addFreedomLocationController = TextEditingController();

  // Add-ons State
  bool _useCar = false;
  bool _rentHelmet = false;
  bool _differentArea = false;
  bool _isWeekendApplied = false;

  String _selectedActivity = 'Ngopi';
  int _selectedDurationIndex = 0; // 0 = 3 Jam, 1 = 6 Jam, 2 = 9 Jam
  final List<int> _durations = [3, 6, 9];

  dynamic _selectedPartnerId = '';
  String _selectedPartnerName = '';
  String _selectedPartnerImage = '';
  double _selectedPartnerRating = 0.0;

  String _selectedPartnerVehicle = '';
  int _selectedPartnerTrips = 0;
  String _selectedPartnerClass = 'Gold';
  
  final List<String> _activities = ['Ngopi', 'Makan', 'Jalan-jalan', 'Belanja', 'Olahraga', 'Nonton'];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false).fetchDrivers();
    });

    if (widget.selectedPartner != null) {
      _selectedPartnerName = widget.selectedPartner!['name'] ?? '';
      _selectedPartnerImage = widget.selectedPartner!['image'] ?? '';
      _selectedPartnerRating = widget.selectedPartner!['rating'] is String 
          ? double.parse(widget.selectedPartner!['rating']) 
          : (widget.selectedPartner!['rating']?.toDouble() ?? 0.0);
      _selectedPartnerVehicle = widget.selectedPartner!['vehicle'] ?? '';
      _selectedPartnerId = widget.selectedPartner!['id'] ?? '';
      _selectedPartnerTrips = widget.selectedPartner!['kpi'] is int 
          ? (widget.selectedPartner!['kpi'] as int) * 2 
          : 120;
      _selectedPartnerClass = widget.selectedPartner!['type'] ?? 'Gold';
    }
  }

  void _checkWeekend(DateTime date) {
    setState(() {
      _isWeekendApplied = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    });
  }

  // Get package prices according to PRD Section 7.1
  int _getPackagePrice(String driverClass, int durationIndex) {
    if (durationIndex == 0) { // 3 Jam
      switch (driverClass) {
        case 'Bronze': return 75000;
        case 'Silver': return 90000;
        case 'Gold': return 110000;
        case 'Platinum': return 125000;
        case 'Diamond': return 150000;
        case 'VVIP': return 225000;
        default: return 110000;
      }
    } else if (durationIndex == 1) { // 6 Jam
      switch (driverClass) {
        case 'Bronze': return 145000;
        case 'Silver': return 175000;
        case 'Gold': return 210000;
        case 'Platinum': return 240000;
        case 'Diamond': return 285000;
        case 'VVIP': return 435000;
        default: return 210000;
      }
    } else { // 9 Jam
      switch (driverClass) {
        case 'Bronze': return 215000;
        case 'Silver': return 260000;
        case 'Gold': return 310000;
        case 'Platinum': return 355000;
        case 'Diamond': return 420000;
        case 'VVIP': return 645000;
        default: return 310000;
      }
    }
  }

  Map<String, dynamic> _calculatePrice() {
    // Service 1 Fee: Hangout Package price
    int service1Fee = _getPackagePrice(_selectedPartnerClass, _selectedDurationIndex);

    // Service 2 Fee: If Multi-Layanan is checked
    int service2Fee = 0;
    if (_addAdditionalService) {
      double perKmRate = 8000;
      switch (_selectedPartnerClass) {
        case 'Bronze': perKmRate = 5000; break;
        case 'Silver': perKmRate = 6000; break;
        case 'Gold': perKmRate = 8000; break;
        case 'Platinum': perKmRate = 10000; break;
        case 'Diamond': perKmRate = 12000; break;
        case 'VVIP': perKmRate = 15000; break;
      }

      if (_additionalServiceType == 'antar_jemput') {
        // Flat 15km for added Antar Jemput
        service2Fee = (15 * perKmRate).toInt() + 15000; // includes base rate
      } else if (_additionalServiceType == 'freedom') {
        int baseFreedom = 70000;
        switch (_selectedPartnerClass) {
          case 'Bronze': baseFreedom = 40000; break;
          case 'Silver': baseFreedom = 50000; break;
          case 'Gold': baseFreedom = 70000; break;
          case 'Platinum': baseFreedom = 90000; break;
          case 'Diamond': baseFreedom = 120000; break;
          case 'VVIP': baseFreedom = 200000; break;
        }
        // Flat 10km for added Freedom request
        service2Fee = baseFreedom + (10 * perKmRate).toInt();
      }
    }

    int baseSubtotal = service1Fee + service2Fee;

    // Add-ons
    int carAddon = _useCar ? 50000 : 0;
    int helmetAddon = _rentHelmet ? 10000 : 0;
    int areaAddon = _differentArea ? 20000 : 0;

    int subtotal = baseSubtotal + carAddon + helmetAddon + areaAddon;

    // Weekend Fee = Subtotal * 25%
    int weekendFee = _isWeekendApplied ? (subtotal * 0.25).toInt() : 0;

    // Total Estimasi = Subtotal + Weekend Fee
    int totalEstimasi = subtotal + weekendFee;

    // DP 50%
    int dp = (totalEstimasi * 0.5).toInt();

    // Sisa Bayar
    int remainingPayment = totalEstimasi - dp;

    return {
      'service1Fee': service1Fee,
      'service2Fee': service2Fee,
      'subtotal': subtotal,
      'weekendFee': weekendFee,
      'totalEstimasi': totalEstimasi,
      'dp': dp,
      'remaining': remainingPayment,
    };
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final drivers = driverProvider.drivers;

    if (_selectedPartnerId == '' && drivers.isNotEmpty) {
      final defaultPartner = drivers[0];
      _selectedPartnerId = defaultPartner['id'];
      _selectedPartnerName = defaultPartner['name'];
      _selectedPartnerImage = defaultPartner['image'];
      _selectedPartnerRating = double.tryParse(defaultPartner['rating']?.toString() ?? '0.0') ?? 4.5;
      _selectedPartnerVehicle = defaultPartner['vehicle'];
      _selectedPartnerTrips = defaultPartner['kpi'] * 2;
      _selectedPartnerClass = defaultPartner['type'];
    }

    final prices = _calculatePrice();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      appBar: AppBar(
        title: Text(
          "Hangout Partner",
          style: GoogleFonts.poppins(
            color: const Color(0xFFFF9DCC),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFFF9DCC)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF190C28), // Sleek deep purple glow
              Color(0xFF0B090E), // Ultra clean dark black
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
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
              
              _buildSectionTitle("Pilih Paket Durasi"),
              const SizedBox(height: 10),
              _buildDurationChips(),
              const SizedBox(height: 20),
              
              _buildSectionTitle("Pilih Partner"),
              const SizedBox(height: 10),
              _buildPartnerSelector(drivers),
              const SizedBox(height: 25),

              // Multi-Layanan Section
              _buildMultiServiceSection(),
              const SizedBox(height: 25),

              _buildSectionTitle("Add-ons & Biaya Tambahan"),
              const SizedBox(height: 10),
              _buildAddonsCard(),
              const SizedBox(height: 30),

              // Live Estimasi Harga
              _buildPricingCard(prices),
              const SizedBox(height: 30),
              
              _buildBookingButton(prices),
              const SizedBox(height: 40),
            ],
          ),
        ),
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
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
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
                ),
              ),
              child: Text(
                activity,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationChips() {
    return Row(
      children: List.generate(_durations.length, (index) {
        final d = _durations[index];
        final isSelected = _selectedDurationIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDurationIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: index == 2 ? 0 : 10),
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF9D6BFF) : const Color(0xFF1C1B21),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                "$d Jam",
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
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
          _checkWeekend(date);
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
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: Color(0xFF9D6BFF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dateController.text.isEmpty ? "Pilih tanggal" : _dateController.text,
                style: TextStyle(
                  color: _dateController.text.isEmpty ? Colors.white.withOpacity(0.3) : Colors.white,
                  fontSize: 13,
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
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: Color(0xFF9D6BFF), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _timeController.text.isEmpty ? "Pilih waktu" : _timeController.text,
                style: TextStyle(
                  color: _timeController.text.isEmpty ? Colors.white.withOpacity(0.3) : Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerSelector(List<Map<String, dynamic>> drivers) {
    if (drivers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(
          "Tidak ada mitra aktif yang tersedia",
          style: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: drivers.map((partner) {
          final packagePrice = _getPackagePrice(partner['type'], _selectedDurationIndex);

          return RadioListTile<dynamic>(
            value: partner['id'],
            groupValue: _selectedPartnerId,
            onChanged: (value) {
              setState(() {
                _selectedPartnerId = value!;
                final selectedPartner = drivers.firstWhere((p) => p['id'] == _selectedPartnerId);
                _selectedPartnerName = selectedPartner['name'];
                _selectedPartnerImage = selectedPartner['image'];
                _selectedPartnerRating = double.tryParse(selectedPartner['rating']?.toString() ?? '0.0') ?? 4.5;

                _selectedPartnerVehicle = selectedPartner['vehicle'];
                _selectedPartnerTrips = selectedPartner['kpi'] * 2;
                _selectedPartnerClass = selectedPartner['type'];
              });
            },
            activeColor: const Color(0xFF9D6BFF),
            title: Row(
              children: [
                Text(
                  partner['name'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9D6BFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    partner['type'],
                    style: const TextStyle(color: Color(0xFF9D6BFF), fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              "${partner['vehicle']} • ⭐ ${partner['rating']} • ${partner['gender']}",
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            secondary: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Rp ${packagePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9D6BFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Paket ${_durations[_selectedDurationIndex]} Jam",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMultiServiceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9D6BFF).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _addAdditionalService = !_addAdditionalService),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Multi-Layanan (Tambah Layanan)",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Pesan antar jemput/freedom dengan partner yang sama",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: _addAdditionalService,
                  onChanged: (value) => setState(() => _addAdditionalService = value),
                  activeColor: const Color(0xFF9D6BFF),
                ),
              ],
            ),
          ),
          if (_addAdditionalService) ...[
            const Divider(color: Colors.white10, height: 25),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Antar Jemput")),
                    selected: _additionalServiceType == 'antar_jemput',
                    onSelected: (selected) {
                      if (selected) setState(() => _additionalServiceType = 'antar_jemput');
                    },
                    selectedColor: const Color(0xFF9D6BFF),
                    labelStyle: TextStyle(
                      color: _additionalServiceType == 'antar_jemput' ? const Color(0xFF2D1B4E) : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Freedom Request")),
                    selected: _additionalServiceType == 'freedom',
                    onSelected: (selected) {
                      if (selected) setState(() => _additionalServiceType = 'freedom');
                    },
                    selectedColor: const Color(0xFF9D6BFF),
                    labelStyle: TextStyle(
                      color: _additionalServiceType == 'freedom' ? const Color(0xFF2D1B4E) : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (_additionalServiceType == 'antar_jemput') ...[
              _buildTextField(
                controller: _addPickupController,
                hint: "Lokasi Penjemputan Tambahan",
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addDestinationController,
                hint: "Lokasi Tujuan Antar Tambahan",
                icon: Icons.flag_rounded,
              ),
            ] else ...[
              _buildTextField(
                controller: _addFreedomDescriptionController,
                hint: "Deskripsi request terbuka (misal: tolong antre, dll)",
                icon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addFreedomLocationController,
                hint: "Lokasi detail request pengerjaan",
                icon: Icons.location_on_rounded,
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildAddonsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: _useCar,
            onChanged: (val) => setState(() => _useCar = val!),
            activeColor: const Color(0xFF9D6BFF),
            checkColor: const Color(0xFF2D1B4E),
            title: const Text("Gunakan Mobil", style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text("Mobil eksklusif ber-AC (+Rp 50.000)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ),
          const Divider(color: Colors.white10, height: 10),
          CheckboxListTile(
            value: _rentHelmet,
            onChanged: (val) => setState(() => _rentHelmet = val!),
            activeColor: const Color(0xFF9D6BFF),
            checkColor: const Color(0xFF2D1B4E),
            title: const Text("Sewa Helm Ekstra", style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text("Helm ekstra bersih dan steril (+Rp 10.000)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ),
          const Divider(color: Colors.white10, height: 10),
          CheckboxListTile(
            value: _differentArea,
            onChanged: (val) => setState(() => _differentArea = val!),
            activeColor: const Color(0xFF9DFFB6),
            checkColor: const Color(0xFF2D1B4E),
            title: const Text("Beda Area Layanan", style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text("Biaya tambahan penugasan beda wilayah (+Rp 20.000)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(Map<String, dynamic> prices) {
    String fmt(int val) {
      return "Rp ${val.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9D6BFF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Estimasi Biaya", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              if (_isWeekendApplied)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF9D6BFF).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: const Text("Weekend +25%", style: TextStyle(color: Color(0xFF9D6BFF), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          _priceRow("Hangout Partner Paket ${_durations[_selectedDurationIndex]} Jam", fmt(prices['service1Fee'])),
          if (_addAdditionalService)
            _priceRow(
              _additionalServiceType == 'antar_jemput' ? "Multi-Layanan (Antar Jemput)" : "Multi-Layanan (Freedom Request)",
              fmt(prices['service2Fee']),
            ),
          if (_useCar) _priceRow("Add-on Mobil", fmt(50000)),
          if (_rentHelmet) _priceRow("Sewa Helm Ekstra", fmt(10000)),
          if (_differentArea) _priceRow("Beda Area Layanan", fmt(20000)),
          if (_isWeekendApplied) _priceRow("Weekend Fee (25%)", fmt(prices['weekendFee'])),
          const Divider(color: Colors.white10, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Estimasi", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
              Text(fmt(prices['totalEstimasi']), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("DP Wajib (50%)", style: GoogleFonts.poppins(color: const Color(0xFF9D6BFF), fontWeight: FontWeight.bold, fontSize: 14)),
              Text(fmt(prices['dp']), style: GoogleFonts.poppins(color: const Color(0xFF9D6BFF), fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sisa Pelunasan di Tujuan", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              Text(fmt(prices['remaining']), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBookingButton(Map<String, dynamic> prices) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF9DCC),
            Color(0xFF9D6BFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9DCC).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (_selectedPartnerId == '' || _selectedPartnerId == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pilih partner terlebih dahulu")),
              );
              return;
            }
            if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pilih tanggal dan waktu terlebih dahulu")),
              );
              return;
            }
            
            final bookingData = {
              'serviceType': 'hangout',
              'driverId': _selectedPartnerId,
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
              
              // Pricing Details
              'serviceFee': prices['service1Fee'],
              'insuranceFee': 10000,
              'totalPayment': prices['totalEstimasi'] + 10000,
              'dp': prices['dp'] + 5000, // DP includes 50% insurance
              'remainingPayment': prices['remaining'] + 5000,
              'duration': _durations[_selectedDurationIndex],
              'estimatedTime': '15',
              
              // Multi service details
              'hasAdditionalService': _addAdditionalService,
              'additionalServiceType': _additionalServiceType,
              'additionalServiceFee': prices['service2Fee'],
              'additionalPickup': _addPickupController.text,
              'additionalDestination': _addDestinationController.text,
              'additionalDescription': _addFreedomDescriptionController.text,
              'additionalLocation': _addFreedomLocationController.text,
 
              // Addons
              'useCar': _useCar,
              'rentHelmet': _rentHelmet,
              'differentArea': _differentArea,
              'weekendFee': prices['weekendFee'],
              'notes': _notesController.text,
              'driverClass': _selectedPartnerClass,
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
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          "Booking Sekarang",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D1B4E),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}