// lib/modules/booking/screens/antar_jemput_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:temenin_ajaa/providers/driver_provider.dart';
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
  
  // Multi-Layanan State
  bool _addAdditionalService = false;
  String _additionalServiceType = 'hangout'; // or 'freedom'
  String _addHangoutActivity = 'Ngopi';
  final _addHangoutDurationController = TextEditingController(text: '3');
  final _addFreedomDescriptionController = TextEditingController();
  final _addFreedomLocationController = TextEditingController();

  // Add-ons State
  bool _pulangPergi = false;
  bool _useCar = false;
  bool _rentHelmet = false;
  bool _differentArea = false;
  bool _isWeekendApplied = false;

  dynamic _selectedDriverId = '';
  String _selectedDriverName = '';
  String _selectedDriverImage = '';
  double _selectedDriverRating = 0.0;
  int _selectedDriverPrice = 0; // price per km
  String _selectedDriverVehicle = '';
  int _selectedDriverTrips = 0;
  String _selectedDriverClass = 'Gold';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false).fetchDrivers();
    });

    if (widget.selectedPartner != null) {
      _selectedDriverId = widget.selectedPartner!['id'] ?? '';
      _selectedDriverName = widget.selectedPartner!['name'] ?? '';
      _selectedDriverImage = widget.selectedPartner!['image'] ?? '';
      _selectedDriverRating = widget.selectedPartner!['rating'] is String 
          ? double.parse(widget.selectedPartner!['rating']) 
          : (widget.selectedPartner!['rating']?.toDouble() ?? 0.0);
      _selectedDriverVehicle = widget.selectedPartner!['vehicle'] ?? '';
      _selectedDriverPrice = widget.selectedPartner!['price'] is int 
          ? widget.selectedPartner!['price'] 
          : 5000;
      _selectedDriverTrips = widget.selectedPartner!['kpi'] is int 
          ? (widget.selectedPartner!['kpi'] as int) * 2 
          : 120;
      _selectedDriverClass = widget.selectedPartner!['type'] ?? 'Gold';
    }
  }

  void _checkWeekend(DateTime date) {
    setState(() {
      _isWeekendApplied = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    });
  }

  Map<String, dynamic> _calculatePrice() {
    const double distance = 15.0; // Simulated trip distance of 15 km
    
    // Service 1: Antar Jemput. Pulang Pergi doubles the distance/trip fee
    double baseService1Price = (distance * _selectedDriverPrice);
    if (_pulangPergi) {
      baseService1Price *= 2.0;
    }
    int service1Fee = baseService1Price.toInt();

    // Service 2: If Multi-Layanan is checked
    int service2Fee = 0;
    if (_addAdditionalService) {
      if (_additionalServiceType == 'hangout') {
        int duration = int.tryParse(_addHangoutDurationController.text) ?? 3;
        // Package prices according to PRD
        if (duration <= 3) {
          switch (_selectedDriverClass) {
            case 'Bronze': service2Fee = 75000; break;
            case 'Silver': service2Fee = 90000; break;
            case 'Gold': service2Fee = 110000; break;
            case 'Platinum': service2Fee = 125000; break;
            case 'Diamond': service2Fee = 150000; break;
            case 'VVIP': service2Fee = 225000; break;
          }
        } else if (duration <= 6) {
          switch (_selectedDriverClass) {
            case 'Bronze': service2Fee = 145000; break;
            case 'Silver': service2Fee = 175000; break;
            case 'Gold': service2Fee = 210000; break;
            case 'Platinum': service2Fee = 240000; break;
            case 'Diamond': service2Fee = 285000; break;
            case 'VVIP': service2Fee = 435000; break;
          }
        } else {
          switch (_selectedDriverClass) {
            case 'Bronze': service2Fee = 215000; break;
            case 'Silver': service2Fee = 260000; break;
            case 'Gold': service2Fee = 310000; break;
            case 'Platinum': service2Fee = 355000; break;
            case 'Diamond': service2Fee = 420000; break;
            case 'VVIP': service2Fee = 645000; break;
          }
        }
      } else if (_additionalServiceType == 'freedom') {
        // Base flat rate for Freedom Request based on class
        int baseFreedom = 70000;
        switch (_selectedDriverClass) {
          case 'Bronze': baseFreedom = 40000; break;
          case 'Silver': baseFreedom = 50000; break;
          case 'Gold': baseFreedom = 70000; break;
          case 'Platinum': baseFreedom = 90000; break;
          case 'Diamond': baseFreedom = 120000; break;
          case 'VVIP': baseFreedom = 200000; break;
        }
        // Assumed 10km route for Freedom Request
        int kmRate = 8000;
        switch (_selectedDriverClass) {
          case 'Bronze': kmRate = 5000; break;
          case 'Silver': kmRate = 6000; break;
          case 'Gold': kmRate = 8000; break;
          case 'Platinum': kmRate = 10000; break;
          case 'Diamond': kmRate = 12000; break;
          case 'VVIP': kmRate = 15000; break;
        }
        service2Fee = baseFreedom + (10 * kmRate);
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

    if (_selectedDriverId == '' && drivers.isNotEmpty) {
      final defaultDriver = drivers[0];
      _selectedDriverId = defaultDriver['id'];
      _selectedDriverName = defaultDriver['name'];
      _selectedDriverImage = defaultDriver['image'];
      _selectedDriverRating = double.tryParse(defaultDriver['rating']?.toString() ?? '0.0') ?? 4.5;
      _selectedDriverPrice = defaultDriver['price'] ~/ 10;
      if (_selectedDriverPrice < 3000) _selectedDriverPrice = 5000;
      _selectedDriverVehicle = defaultDriver['vehicle'];
      _selectedDriverTrips = defaultDriver['kpi'] * 2;
      _selectedDriverClass = defaultDriver['type'];
    }

    final prices = _calculatePrice();

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
                  const SizedBox(height: 25),
                  
                  _buildSectionTitle("Pilih Driver Anda"),
                  const SizedBox(height: 10),
                  _buildDriverSelector(drivers),
                  const SizedBox(height: 25),
                  
                  // Multi-Layanan Section
                  _buildMultiServiceSection(),
                  const SizedBox(height: 25),
                  
                  _buildSectionTitle("Add-ons & Biaya Tambahan"),
                  const SizedBox(height: 10),
                  _buildAddonsCard(),
                  const SizedBox(height: 25),
                  
                  _buildSectionTitle("Catatan Tambahan"),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _notesController,
                    hint: "Contoh: Bawa jas hujan, pakai helm pink, dll.",
                    icon: Icons.note_add_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  
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
            const Icon(Icons.calendar_today_rounded, color: Color(0xFFFF9DCC), size: 20),
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
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: Color(0xFFFF9DCC), size: 20),
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

  Widget _buildDriverSelector(List<Map<String, dynamic>> drivers) {
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
        children: drivers.map((driver) {
          final double rateKm = (driver['price'] ?? 50000.0) / 10;
          final int finalRateKm = rateKm < 3000 ? 5000 : rateKm.toInt();

          return RadioListTile<dynamic>(
            value: driver['id'],
            groupValue: _selectedDriverId,
            onChanged: (value) {
              setState(() {
                _selectedDriverId = value!;
                final selectedDriver = drivers.firstWhere((d) => d['id'] == _selectedDriverId);
                _selectedDriverName = selectedDriver['name'];
                _selectedDriverImage = selectedDriver['image'];
                _selectedDriverRating = double.tryParse(selectedDriver['rating']?.toString() ?? '0.0') ?? 4.5;
                _selectedDriverPrice = finalRateKm;
                _selectedDriverVehicle = selectedDriver['vehicle'];
                _selectedDriverTrips = selectedDriver['kpi'] * 2;
                _selectedDriverClass = selectedDriver['type'];
              });
            },
            activeColor: const Color(0xFFFF9DCC),
            title: Row(
              children: [
                Text(
                  driver['name'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9DCC).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    driver['type'],
                    style: const TextStyle(color: Color(0xFFFF9DCC), fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              "${driver['vehicle']} • ⭐ ${driver['rating']} • ${driver['gender']}",
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
                  "Rp $finalRateKm",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF9DCC),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "/km",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.3),
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

  Widget _buildMultiServiceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.1)),
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
                        "Pesan hangout/freedom dengan driver yang sama",
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
                  activeColor: const Color(0xFFFF9DCC),
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
                    label: const Center(child: Text("Hangout Partner")),
                    selected: _additionalServiceType == 'hangout',
                    onSelected: (selected) {
                      if (selected) setState(() => _additionalServiceType = 'hangout');
                    },
                    selectedColor: const Color(0xFFFF9DCC),
                    labelStyle: TextStyle(
                      color: _additionalServiceType == 'hangout' ? const Color(0xFF4A1031) : Colors.white,
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
                    selectedColor: const Color(0xFFFF9DCC),
                    labelStyle: TextStyle(
                      color: _additionalServiceType == 'freedom' ? const Color(0xFF4A1031) : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (_additionalServiceType == 'hangout') ...[
              DropdownButtonFormField<String>(
                value: _addHangoutActivity,
                dropdownColor: const Color(0xFF1C1B21),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.people_alt_rounded, color: Color(0xFFFF9DCC)),
                  labelText: "Pilih Aktivitas Hangout",
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: ['Ngopi', 'Makan', 'Jalan-jalan', 'Shopping', 'Nonton']
                    .map((act) => DropdownMenuItem(value: act, child: Text(act)))
                    .toList(),
                onChanged: (val) => setState(() => _addHangoutActivity = val!),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _addHangoutDurationController,
                hint: "Durasi Hangout (Jam: 3, 6, atau 9)",
                icon: Icons.timer_rounded,
                keyboardType: TextInputType.number,
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
            value: _pulangPergi,
            onChanged: (val) => setState(() => _pulangPergi = val!),
            activeColor: const Color(0xFFFF9DCC),
            checkColor: const Color(0xFF4A1031),
            title: const Text("Perjalanan Pulang Pergi (PP)", style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text("Rute tempuh ganda otomatis (+100% biaya jemput)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ),
          const Divider(color: Colors.white10, height: 10),
          CheckboxListTile(
            value: _useCar,
            onChanged: (val) => setState(() => _useCar = val!),
            activeColor: const Color(0xFFFF9DCC),
            checkColor: const Color(0xFF4A1031),
            title: const Text("Gunakan Mobil", style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text("Mobil eksklusif ber-AC (+Rp 50.000)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ),
          const Divider(color: Colors.white10, height: 10),
          CheckboxListTile(
            value: _rentHelmet,
            onChanged: (val) => setState(() => _rentHelmet = val!),
            activeColor: const Color(0xFFFF9DCC),
            checkColor: const Color(0xFF4A1031),
            title: const Text("Sewa Helm Ekstra", style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text("Helm ekstra bersih dan steril (+Rp 10.000)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
          ),
          const Divider(color: Colors.white10, height: 10),
          CheckboxListTile(
            value: _differentArea,
            onChanged: (val) => setState(() => _differentArea = val!),
            activeColor: const Color(0xFFFF9DCC),
            checkColor: const Color(0xFF4A1031),
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
        border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.15)),
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
                  decoration: BoxDecoration(color: const Color(0xFFFF9DCC).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: const Text("Weekend +25%", style: TextStyle(color: Color(0xFFFF9DCC), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          _priceRow("Antar Jemput (15 km)", fmt(prices['service1Fee'])),
          if (_addAdditionalService)
            _priceRow(
              _additionalServiceType == 'hangout' ? "Multi-Layanan (Hangout)" : "Multi-Layanan (Freedom Request)",
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
              Text("DP Wajib (50%)", style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 14)),
              Text(fmt(prices['dp']), style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 18)),
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
            Color(0xFFFF6B9D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9DCC).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (_selectedDriverId == '' || _selectedDriverId == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pilih driver terlebih dahulu")),
              );
              return;
            }
            if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pilih tanggal dan waktu terlebih dahulu")),
              );
              return;
            }
            
            const distance = 15;
            
            final bookingData = {
              'serviceType': 'antar_jemput',
              'driverId': _selectedDriverId,
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
              
              // Pricing Details
              'serviceFee': prices['service1Fee'],
              'insuranceFee': 10000,
              'totalPayment': prices['totalEstimasi'] + 10000,
              'dp': prices['dp'] + 5000, // DP includes 50% insurance
              'remainingPayment': prices['remaining'] + 5000,
              'estimatedTime': (distance * 3).toString(),
              
              // Multi service details
              'hasAdditionalService': _addAdditionalService,
              'additionalServiceType': _additionalServiceType,
              'additionalServiceFee': prices['service2Fee'],
              'additionalActivity': _addHangoutActivity,
              'additionalDuration': _addHangoutDurationController.text,
              'additionalDescription': _addFreedomDescriptionController.text,
              'additionalLocation': _addFreedomLocationController.text,
              
              // Addons
              'pulangPergi': _pulangPergi,
              'useCar': _useCar,
              'rentHelmet': _rentHelmet,
              'differentArea': _differentArea,
              'weekendFee': prices['weekendFee'],
              'notes': _notesController.text,
              'driverClass': _selectedDriverClass,
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
            color: const Color(0xFF4A1031),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}