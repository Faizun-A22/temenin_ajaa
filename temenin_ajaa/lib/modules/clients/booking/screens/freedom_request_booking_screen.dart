// lib/modules/clients/booking/screens/freedom_request_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:temenin_ajaa/providers/driver_provider.dart';
import 'freedom_request_negotiation_screen.dart';

class FreedomRequestBookingScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedPartner;
  
  const FreedomRequestBookingScreen({super.key, this.selectedPartner});

  @override
  State<FreedomRequestBookingScreen> createState() => _FreedomRequestBookingScreenState();
}

class _FreedomRequestBookingScreenState extends State<FreedomRequestBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  // Multi-Layanan State
  bool _addAdditionalService = false;
  bool _addAntarJemput = false;
  bool _addHangout = false;

  // Additional Antar Jemput
  final _addPickupController = TextEditingController();
  final _addDestinationController = TextEditingController();
  final _addPickupDateController = TextEditingController();
  final _addPickupTimeController = TextEditingController();
  final _addAntarJemputNotesController = TextEditingController();

  // Additional Hangout
  String _addHangoutActivity = 'Ngopi';
  final _addHangoutLocationController = TextEditingController();
  final _addHangoutDurationController = TextEditingController(text: '3');
  final _addHangoutDateController = TextEditingController();
  final _addHangoutTimeController = TextEditingController();
  final _addHangoutNotesController = TextEditingController();
  int _selectedAddHangoutDurationIndex = 0;

  // Custom Offer Price State
  final _userOfferPriceController = TextEditingController();

  // Add-ons State (Inside Antar Jemput only)
  bool _useCar = false;
  bool _rentHelmet = false;
  bool _differentArea = false;
  bool _isWeekendApplied = false;

  String _selectedClass = 'Gold';
  dynamic _selectedDriverId = '';
  String _selectedDriverName = '';
  String _selectedDriverImage = '';
  double _selectedDriverRating = 0.0;
  int _selectedDriverBasePrice = 70000; // default Gold
  String _selectedDriverVehicle = '';
  int _selectedDriverTrips = 0;

  final List<String> _classes = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'VVIP'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverProvider>(context, listen: false).fetchDrivers();
    });

    if (widget.selectedPartner != null) {
      _selectedDriverName = widget.selectedPartner!['name'] ?? '';
      _selectedDriverImage = widget.selectedPartner!['image'] ?? '';
      _selectedDriverRating = widget.selectedPartner!['rating'] is String 
          ? double.parse(widget.selectedPartner!['rating']) 
          : (widget.selectedPartner!['rating']?.toDouble() ?? 0.0);
      _selectedDriverVehicle = widget.selectedPartner!['vehicle'] ?? '';
      _selectedDriverId = widget.selectedPartner!['id'] ?? '';
      _selectedDriverBasePrice = widget.selectedPartner!['price'] is int 
          ? widget.selectedPartner!['price'] 
          : 70000;
      _selectedDriverTrips = widget.selectedPartner!['kpi'] is int 
          ? (widget.selectedPartner!['kpi'] as int) * 2 
          : 120;
      
      final incomingClass = widget.selectedPartner!['type'] ?? 'Gold';
      if (_classes.contains(incomingClass)) {
        _selectedClass = incomingClass;
      }
    }
  }

  void _updateRecommendedUserOfferPrice() {
    double distance = 10.0;
    double perKmRate = 0;
    switch (_selectedClass) {
      case 'Bronze': perKmRate = 5000; break;
      case 'Silver': perKmRate = 6000; break;
      case 'Gold': perKmRate = 8000; break;
      case 'Platinum': perKmRate = 10000; break;
      case 'Diamond': perKmRate = 12000; break;
      case 'VVIP': perKmRate = 15000; break;
    }
    int service1Fee = _selectedDriverBasePrice + (distance * perKmRate).toInt();
    _userOfferPriceController.text = service1Fee.toString();
  }

  void _checkWeekend(DateTime date) {
    setState(() {
      _isWeekendApplied = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    });
  }

  // Calculate pricing breakdown
  Map<String, dynamic> _calculatePrice() {
    // 1. Service 1 Fee: Base Rate (Flat Rate Freedom Request) + Distance Fee (assumed 10 km)
    double distance = 10.0;
    double perKmRate = 0;
    switch (_selectedClass) {
      case 'Bronze': perKmRate = 5000; break;
      case 'Silver': perKmRate = 6000; break;
      case 'Gold': perKmRate = 8000; break;
      case 'Platinum': perKmRate = 10000; break;
      case 'Diamond': perKmRate = 12000; break;
      case 'VVIP': perKmRate = 15000; break;
    }
    int service1Fee = _selectedDriverBasePrice + (distance * perKmRate).toInt();
    
    // 2. Service 2 Fee: Antar Jemput (if toggled)
    int service2Fee = 0; // Antar Jemput fee
    int service3Fee = 0; // Hangout Partner fee
    
    if (_addAdditionalService) {
      if (_addAntarJemput) {
        // Flat simulate distance of 8 km
        service2Fee = (8 * perKmRate).toInt() + 15000; // distance fee + base rate
      }
      
      if (_addHangout) {
        int duration = [3, 6, 9][_selectedAddHangoutDurationIndex];
        // Package prices according to PRD
        if (duration <= 3) {
          switch (_selectedClass) {
            case 'Bronze': service3Fee = 75000; break;
            case 'Silver': service3Fee = 90000; break;
            case 'Gold': service3Fee = 110000; break;
            case 'Platinum': service3Fee = 125000; break;
            case 'Diamond': service3Fee = 150000; break;
            case 'VVIP': service3Fee = 225000; break;
          }
        } else if (duration <= 6) {
          switch (_selectedClass) {
            case 'Bronze': service3Fee = 145000; break;
            case 'Silver': service3Fee = 175000; break;
            case 'Gold': service3Fee = 210000; break;
            case 'Platinum': service3Fee = 240000; break;
            case 'Diamond': service3Fee = 285000; break;
            case 'VVIP': service3Fee = 435000; break;
          }
        } else {
          switch (_selectedClass) {
            case 'Bronze': service3Fee = 215000; break;
            case 'Silver': service3Fee = 260000; break;
            case 'Gold': service3Fee = 310000; break;
            case 'Platinum': service3Fee = 355000; break;
            case 'Diamond': service3Fee = 420000; break;
            case 'VVIP': service3Fee = 645000; break;
          }
        }
      }
    }

    int baseSubtotal = service1Fee + service2Fee + service3Fee;
    
    // Add-ons (only if Antar Jemput is active under Multi-Layanan)
    int carAddon = (_addAdditionalService && _addAntarJemput && _useCar) ? 50000 : 0;
    int helmetAddon = (_addAdditionalService && _addAntarJemput && _rentHelmet) ? 10000 : 0;
    int areaAddon = (_addAdditionalService && _addAntarJemput && _differentArea) ? 20000 : 0;
    
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
      'service2Fee': service2Fee + service3Fee, // combined additional services
      'serviceAntarJemputFee': service2Fee,
      'serviceHangoutFee': service3Fee,
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

    // Group the drivers by class dynamically
    final Map<String, List<Map<String, dynamic>>> driversByClass = {
      'Bronze': [],
      'Silver': [],
      'Gold': [],
      'Platinum': [],
      'Diamond': [],
      'VVIP': [],
    };
    for (var d in drivers) {
      final type = d['type'] ?? 'Gold';
      if (driversByClass.containsKey(type)) {
        driversByClass[type]!.add(d);
      }
    }

    final currentClassDrivers = driversByClass[_selectedClass] ?? [];
    if (_selectedDriverId == '' && currentClassDrivers.isNotEmpty) {
      final defaultDriver = currentClassDrivers[0];
      _selectedDriverId = defaultDriver['id'];
      _selectedDriverName = defaultDriver['name'];
      _selectedDriverImage = defaultDriver['image'];
      _selectedDriverRating = double.tryParse(defaultDriver['rating']?.toString() ?? '0.0') ?? 4.5;
      _selectedDriverBasePrice = defaultDriver['price'];
      _selectedDriverVehicle = defaultDriver['vehicle'];
      _selectedDriverTrips = defaultDriver['kpi'] * 2;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateRecommendedUserOfferPrice();
      });
    }

    final prices = _calculatePrice();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      appBar: AppBar(
        title: Text(
          "Freedom Request",
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
                  _buildSectionTitle("Deskripsi Request (Terbuka)"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _descriptionController,
                hint: "Tuliskan apa saja yang perlu dibantu (misal: antre tiket, membelikan titipan makanan, tolong bawakan barang, dll.)",
                icon: Icons.edit_note_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Lokasi Request"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _pickupController,
                hint: "Masukkan titik pengerjaan / lokasi toko / pengambilan",
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Lokasi Tujuan (Opsional)"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _destinationController,
                hint: "Masukkan lokasi pengantaran / tujuan akhir",
                icon: Icons.flag_rounded,
                requiredField: false,
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

              _buildSectionTitle("Klasifikasi Driver"),
              const SizedBox(height: 10),
              _buildClassChips(),
              const SizedBox(height: 20),

              _buildSectionTitle("Pilih Driver (${_selectedClass})"),
              const SizedBox(height: 10),
              _buildDriverSelector(driversByClass),
              const SizedBox(height: 25),

              // Multi-Layanan Section
              _buildMultiServiceSection(),
              const SizedBox(height: 25),

              _buildSectionTitle("Tawaran Harga Anda (Layanan Utama)"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _userOfferPriceController,
                hint: "Masukkan penawaran harga Anda (misal: 150000)",
                icon: Icons.payments_rounded,
                keyboardType: TextInputType.number,
              ),
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
    bool requiredField = true,
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
        validator: requiredField
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Field ini harus diisi';
                }
                return null;
              }
            : null,
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

  Widget _buildClassChips() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final c = _classes[index];
          final isSelected = _selectedClass == c;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedClass = c;
                _selectedDriverId = '';
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF9DCC) : const Color(0xFF1C1B21),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Text(
                c,
                style: GoogleFonts.poppins(
                  color: isSelected ? const Color(0xFF4A1031) : Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDriverSelector(Map<String, List<Map<String, dynamic>>> driversByClass) {
    final list = driversByClass[_selectedClass] ?? [];
    
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(
          "Tidak ada mitra kelas $_selectedClass yang aktif",
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
        children: list.map((driver) {
          return RadioListTile<dynamic>(
            value: driver['id'],
            groupValue: _selectedDriverId,
            onChanged: (value) {
              setState(() {
                _selectedDriverId = value!;
                final match = list.firstWhere((d) => d['id'] == _selectedDriverId);
                _selectedDriverName = match['name'];
                _selectedDriverImage = match['image'];
                _selectedDriverRating = double.tryParse(match['rating']?.toString() ?? '0.0') ?? 4.5;
                _selectedDriverBasePrice = match['price'];
                _selectedDriverVehicle = match['vehicle'];
                _selectedDriverTrips = match['kpi'] * 2;
                _updateRecommendedUserOfferPrice();
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
                  "Rp ${driver['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF9DCC),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Base Request",
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
        border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              _addAdditionalService = !_addAdditionalService;
              if (!_addAdditionalService) {
                _addAntarJemput = false;
                _addHangout = false;
                _useCar = false;
                _rentHelmet = false;
                _differentArea = false;
              }
            }),
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
                        "Pesan layanan lain dengan driver yang sama sekaligus",
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
                  onChanged: (value) => setState(() {
                    _addAdditionalService = value;
                    if (!value) {
                      _addAntarJemput = false;
                      _addHangout = false;
                      _useCar = false;
                      _rentHelmet = false;
                      _differentArea = false;
                    }
                  }),
                  activeColor: const Color(0xFFFF9DCC),
                ),
              ],
            ),
          ),
          if (_addAdditionalService) ...[
            const Divider(color: Colors.white10, height: 25),
            
            // Checkbox 1: Antar Jemput
            CheckboxListTile(
              value: _addAntarJemput,
              onChanged: (val) => setState(() {
                _addAntarJemput = val!;
                if (!val) {
                  _useCar = false;
                  _rentHelmet = false;
                  _differentArea = false;
                }
              }),
              activeColor: const Color(0xFFFF9DCC),
              checkColor: const Color(0xFF4A1031),
              contentPadding: EdgeInsets.zero,
              title: const Text("Layanan Antar Jemput", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("Tambahkan rute perjalanan antar-jemput", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ),
            if (_addAntarJemput) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1B21),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomDateField(
                            controller: _addPickupDateController,
                            label: "Pilih tanggal",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCustomTimeField(
                            controller: _addPickupTimeController,
                            label: "Pilih waktu",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _addAntarJemputNotesController,
                      hint: "Catatan khusus (misal: jemput di lobi timur)",
                      icon: Icons.note_add_rounded,
                    ),
                    const Divider(color: Colors.white10, height: 25),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Add-ons & Biaya Tambahan (Antar Jemput)",
                        style: TextStyle(color: Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 5),
                    CheckboxListTile(
                      value: _useCar,
                      onChanged: (val) => setState(() => _useCar = val!),
                      activeColor: const Color(0xFFFF9DCC),
                      checkColor: const Color(0xFF4A1031),
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Gunakan Mobil", style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: Text("Sesuai standar operasional premium (+Rp 50.000)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                    ),
                    CheckboxListTile(
                      value: _rentHelmet,
                      onChanged: (val) => setState(() => _rentHelmet = val!),
                      activeColor: const Color(0xFFFF9DCC),
                      checkColor: const Color(0xFF4A1031),
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Sewa Helm Ekstra", style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: Text("Helm ekstra bersih dan steril (+Rp 10.000)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                    ),
                    CheckboxListTile(
                      value: _differentArea,
                      onChanged: (val) => setState(() => _differentArea = val!),
                      activeColor: const Color(0xFFFF9DCC),
                      checkColor: const Color(0xFF4A1031),
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Beda Area Layanan", style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: Text("Biaya tambahan penugasan beda wilayah (+Rp 20.000)", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                    ),
                  ],
                ),
              ),
            ],
            
            const Divider(color: Colors.white10, height: 25),
            
            // Checkbox 2: Hangout Partner
            CheckboxListTile(
              value: _addHangout,
              onChanged: (val) => setState(() => _addHangout = val!),
              activeColor: const Color(0xFFFF9DCC),
              checkColor: const Color(0xFF4A1031),
              contentPadding: EdgeInsets.zero,
              title: const Text("Layanan Hangout Partner", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("Tambahkan aktivitas hangout bersama", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            ),
            if (_addHangout) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1B21),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pilih Aktivitas (horizontal chips)
                    Text(
                      "Pilih Aktivitas Hangout",
                      style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ['Ngopi', 'Makan', 'Jalan-jalan', 'Shopping', 'Nonton'].map((activity) {
                          final isSelected = _addHangoutActivity == activity;
                          return GestureDetector(
                            onTap: () => setState(() => _addHangoutActivity = activity),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFF9DCC) : const Color(0xFF131218),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
                                ),
                              ),
                              child: Text(
                                activity,
                                style: GoogleFonts.poppins(
                                  color: isSelected ? const Color(0xFF4A1031) : Colors.white.withOpacity(0.5),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _addHangoutLocationController,
                      hint: "Lokasi Hangout",
                      icon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 15),
                    // Pilih Paket Durasi (horizontal chips)
                    Text(
                      "Pilih Paket Durasi",
                      style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(3, (index) {
                        final d = [3, 6, 9][index];
                        final isSelected = _selectedAddHangoutDurationIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedAddHangoutDurationIndex = index),
                            child: Container(
                              margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFF9DCC) : const Color(0xFF131218),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Text(
                                "$d Jam",
                                style: GoogleFonts.poppins(
                                  color: isSelected ? const Color(0xFF4A1031) : Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCustomDateField(
                            controller: _addHangoutDateController,
                            label: "Pilih tanggal",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCustomTimeField(
                            controller: _addHangoutTimeController,
                            label: "Pilih waktu",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _addHangoutNotesController,
                      hint: "Catatan (misal: tolong temani belanja pakaian)",
                      icon: Icons.note_add_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ]
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
          _priceRow("Freedom Request Flat Base", fmt(_selectedDriverBasePrice)),
          _priceRow("Estimasi Rute Jarak Jauh (10 km)", fmt(prices['service1Fee'] - _selectedDriverBasePrice)),
          if (_addAdditionalService && _addAntarJemput)
            _priceRow("Multi-Layanan (Antar Jemput)", fmt(prices['serviceAntarJemputFee'])),
          if (_addAdditionalService && _addHangout)
            _priceRow("Multi-Layanan (Hangout Partner)", fmt(prices['serviceHangoutFee'])),
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

  Widget _buildCustomDateField({required TextEditingController controller, required String label}) {
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
            controller.text = "$dayName, ${date.day} ${months[date.month - 1]} ${date.year}";
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
            const Icon(Icons.calendar_today_rounded, color: Color(0xFFFF9DCC), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.text.isEmpty ? label : controller.text,
                style: TextStyle(
                  color: controller.text.isEmpty ? Colors.white.withOpacity(0.3) : Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTimeField({required TextEditingController controller, required String label}) {
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
            controller.text = "$hour:$minute WIB";
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
            const Icon(Icons.access_time_rounded, color: Color(0xFFFF9DCC), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.text.isEmpty ? label : controller.text,
                style: TextStyle(
                  color: controller.text.isEmpty ? Colors.white.withOpacity(0.3) : Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
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
            Color(0xFFFF8552),
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
            if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pilih tanggal dan waktu terlebih dahulu")),
              );
              return;
            }

            // Parse custom user initial offer, fallback to recommended service1Fee if empty/invalid
            final int userOffer = int.tryParse(_userOfferPriceController.text) ?? prices['service1Fee'];

            final bookingData = {
              'serviceType': 'freedom_request',
              'driverId': _selectedDriverId,
              'driverName': _selectedDriverName,
              'driverImage': _selectedDriverImage,
              'driverRating': _selectedDriverRating.toString(),
              'driverTrips': _selectedDriverTrips.toString(),
              'vehicle': _selectedDriverVehicle,
              'plateNumber': 'B 9999 ${_selectedDriverName.substring(0, 2).toUpperCase()}',
              'pickup': _pickupController.text,
              'destination': _destinationController.text.isEmpty ? 'Tujuan Sesuai Request' : _destinationController.text,
              'date': _dateController.text,
              'time': _timeController.text,
              'description': _descriptionController.text,
              
              // Pricing Details
              'serviceFee': prices['service1Fee'],
              'userInitialPrice': userOffer,
              'insuranceFee': 10000,
              'totalPayment': prices['totalEstimasi'] + 10000, // include insurance
              'dp': (prices['dp'] + 5000), // DP includes 50% insurance
              'remainingPayment': (prices['remaining'] + 5000),
              
              // Multi service details
              'hasAdditionalService': _addAdditionalService,
              'hasAntarJemput': _addAntarJemput,
              'hasHangout': _addHangout,
              'additionalServiceFee': prices['service2Fee'],
              'serviceAntarJemputFee': prices['serviceAntarJemputFee'],
              'serviceHangoutFee': prices['serviceHangoutFee'],
              
              // Antar Jemput details
              'additionalPickup': _addPickupController.text,
              'additionalDestination': _addDestinationController.text,
              'additionalPickupDate': _addPickupDateController.text.isNotEmpty ? _addPickupDateController.text : _dateController.text,
              'additionalPickupTime': _addPickupTimeController.text.isNotEmpty ? _addPickupTimeController.text : _timeController.text,
              'additionalAntarJemputNotes': _addAntarJemputNotesController.text,
              
              // Hangout details
              'additionalActivity': _addHangoutActivity,
              'additionalHangoutLocation': _addHangoutLocationController.text,
              'additionalDuration': ([3, 6, 9][_selectedAddHangoutDurationIndex]).toString(),
              'additionalHangoutDate': _addHangoutDateController.text.isNotEmpty ? _addHangoutDateController.text : _dateController.text,
              'additionalHangoutTime': _addHangoutTimeController.text.isNotEmpty ? _addHangoutTimeController.text : _timeController.text,
              'additionalHangoutNotes': _addHangoutNotesController.text,
              
              // Addons
              'useCar': _useCar,
              'rentHelmet': _rentHelmet,
              'differentArea': _differentArea,
              'weekendFee': prices['weekendFee'],
              'notes': _notesController.text,
              'estimatedTime': '35',
              'driverClass': _selectedClass,
            };

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FreedomRequestNegotiationScreen(bookingData: bookingData),
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
