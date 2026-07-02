// lib/modules/driver/screens/partner_list_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:temenin_ajaa/core/theme/app_theme.dart';
import 'package:temenin_ajaa/providers/driver_provider.dart';
import 'partner_profile_screen.dart';

class PartnerListScreen extends StatefulWidget {
  const PartnerListScreen({super.key});

  @override
  State<PartnerListScreen> createState() => _PartnerListScreenState();
}

class _PartnerListScreenState extends State<PartnerListScreen> {
  String _activeFilter = 'All';
  String _activeGenderFilter = 'Semua';

  final List<String> _filters = ['All', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'VVIP'];
  final List<String> _genderFilters = ['Semua', 'Perempuan', 'Laki-laki'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().fetchDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = context.watch<DriverProvider>();
    final List<Map<String, dynamic>> drivers = driverProvider.drivers;

    // Filter list by class AND gender
    final filteredList = drivers.where((partner) {
      final matchesFilter = _activeFilter == 'All' || partner['type'] == _activeFilter;
      final matchesGender = _activeGenderFilter == 'Semua' || partner['gender'] == _activeGenderFilter;
      return matchesFilter && matchesGender;
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.darkBgGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFFF9DCC)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Temenin Ajaa",
            style: GoogleFonts.poppins(
              color: const Color(0xFFFF9DCC),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage: const NetworkImage('https://i.pravatar.cc/300?img=32'),
              ),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Available Partners",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Temukan partner terbaik sesuai kelas dan kebutuhan Anda.",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Filter Chips (Membership Class)
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final filterName = _filters[index];
                        final isActive = _activeFilter == filterName;
                        return GestureDetector(
                          onTap: () => setState(() => _activeFilter = filterName),
                          child: _buildFilterChip(filterName, isActive: isActive),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Gender Preference Toggle
                  Text(
                    "Pilihan Gender Mitra:",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 36,
                    child: Row(
                      children: _genderFilters.map((gender) {
                        final isActive = _activeGenderFilter == gender;
                        return GestureDetector(
                          onTap: () => setState(() => _activeGenderFilter = gender),
                          child: _buildGenderChip(gender, isActive: isActive),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            
            Expanded(
              child: driverProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                      ),
                    )
                  : driverProvider.errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                const SizedBox(height: 10),
                                Text(
                                  driverProvider.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: () => driverProvider.fetchDrivers(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF9DCC),
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text("Coba Lagi"),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, color: Colors.white.withOpacity(0.2), size: 48),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Mitra tidak ditemukan",
                                    style: GoogleFonts.poppins(color: Colors.white30, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final partner = filteredList[index];
                                return _partnerCard(
                                  context: context,
                                  id: partner['id'],
                                  name: partner['name'],
                                  vehicle: partner['vehicle'],
                                  rating: partner['rating'],
                                  status: partner['status'],
                                  type: partner['type'],
                                  image: partner['image'],
                                  tag: partner['tag'],
                                  isAvailable: partner['isAvailable'],
                                  price: partner['price'],
                                  kpi: partner['kpi'],
                                  gender: partner['gender'] ?? 'Laki-laki',
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF9DCC) : const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isActive ? Colors.black : Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildGenderChip(String label, {bool isActive = false}) {
    IconData icon = Icons.people_outline;
    if (label == 'Perempuan') icon = Icons.female_rounded;
    if (label == 'Laki-laki') icon = Icons.male_rounded;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isActive ? AppTheme.primaryGradient : null,
        color: isActive ? null : const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.transparent : Colors.white.withOpacity(0.05)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFF9DCC).withOpacity(0.15),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isActive ? Colors.black : Colors.white.withOpacity(0.4), 
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.black : Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _partnerCard({
    required BuildContext context,
    required String id,
    required String name,
    required String vehicle,
    required String rating,
    required String status,
    required String type,
    required String image,
    required String tag,
    required bool isAvailable,
    required int price,
    required int kpi,
    required String gender,
  }) {
    Color classColor = const Color(0xFFFF9DCC);
    if (type == 'VVIP') classColor = const Color(0xFFE5D5FF);
    if (type == 'Diamond') classColor = const Color(0xFFC4E0E5);
    if (type == 'Platinum') classColor = const Color(0xFFB3C5FF);
    if (type == 'Gold') classColor = const Color(0xFFFFDF91);
    if (type == 'Silver') classColor = const Color(0xFFE8E8E8);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.06), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  image, 
                  height: 200, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.withOpacity(0.3),
                      child: const Icon(Icons.person, color: Colors.white, size: 50),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.2), Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: classColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F9D58).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user_rounded, color: Colors.white, size: 10),
                      SizedBox(width: 4),
                      Text("VERIFIED", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF9DCC), size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name, 
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              gender == 'Perempuan' ? Icons.female_rounded : Icons.male_rounded,
                              color: gender == 'Perempuan' ? const Color(0xFFFF9DCC) : Colors.blueAccent,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.directions_bike_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(width: 6),
                            Text(vehicle, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAvailable ? const Color(0xFFFF9DCC).withOpacity(0.1) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isAvailable ? const Color(0xFFFF9DCC).withOpacity(0.3) : Colors.white12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isAvailable ? const Color(0xFFFF9DCC) : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "KPI: $kpi%",
                            style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: isAvailable ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PartnerProfileScreen(
                              partnerData: {
                                'id': id,
                                'name': name,
                                'vehicle': vehicle,
                                'rating': rating,
                                'status': status,
                                'type': type,
                                'image': image,
                                'tag': type,
                                'isAvailable': isAvailable,
                                'price': price,
                              },
                            ),
                          ),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable ? const Color(0xFFFF9DCC) : Colors.transparent,
                        foregroundColor: isAvailable ? Colors.black : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isAvailable ? BorderSide.none : const BorderSide(color: Color(0xFFFF9DCC), width: 1),
                        ),
                      ),
                      child: const Text("Lihat Profil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}