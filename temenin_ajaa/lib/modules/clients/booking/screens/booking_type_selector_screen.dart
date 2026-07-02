// lib/modules/booking/screens/booking_type_selector_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'antar_jemput_booking_screen.dart';
import 'hangout_booking_screen.dart';
import 'freedom_request_booking_screen.dart';

class BookingTypeSelectorScreen extends StatefulWidget {
  const BookingTypeSelectorScreen({super.key});

  @override
  State<BookingTypeSelectorScreen> createState() => _BookingTypeSelectorScreenState();
}

class _BookingTypeSelectorScreenState extends State<BookingTypeSelectorScreen> {
  int? _selectedIndex;

  final List<BookingType> _bookingTypes = [
    BookingType(
      id: 0,
      title: "Antar Jemput",
      subtitle: "Perjalanan dari titik A ke B dengan driver profesional",
      icon: Icons.car_rental_rounded,
      gradientColors: [const Color(0xFFFF9DCC), const Color(0xFFFF5EA2)],
      lightColor: const Color(0xFFFF9DCC),
      darkColor: const Color(0xFF4A1031),
    ),
    BookingType(
      id: 1,
      title: "Hangout Partner",
      subtitle: "Temani harimu, dari ngopi, jalan-jalan, sampai acara khusus",
      icon: Icons.people_alt_rounded,
      gradientColors: [const Color(0xFFFF9DCC), const Color(0xFF9D6BFF)],
      lightColor: const Color(0xFF9D6BFF),
      darkColor: const Color(0xFF2D1B4E),
    ),
    BookingType(
      id: 2,
      title: "Freedom Request",
      subtitle: "Minta tolong apa saja (antre tiket, belanja, dll) secara bebas",
      icon: Icons.explore_rounded,
      gradientColors: [const Color(0xFFFF9DCC), const Color(0xFFFF8552)],
      lightColor: const Color(0xFFFF8552),
      darkColor: const Color(0xFF4A1B10),
    ),
  ];

void _handleBooking() {
  if (_selectedIndex == null) return;

  final selectedType = _bookingTypes[_selectedIndex!];

  if (selectedType.title == "Antar Jemput") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AntarJemputBookingScreen(),
      ),
    );
  } else if (selectedType.title == "Hangout Partner") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HangoutBookingScreen(),
      ),
    );
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FreedomRequestBookingScreen(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildTitleSection(),
                      const SizedBox(height: 30),

                      // Booking Type Cards
                      ...List.generate(_bookingTypes.length, (index) {
                        final type = _bookingTypes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildBookingCard(
                            type: type,
                            isSelected: _selectedIndex == index,
                            onTap: () => setState(() => _selectedIndex = index),
                          ),
                        );
                      }),

                      const SizedBox(height: 40),

                      // Primary Action Button
                      _buildContinueButton(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Temenin Ajaa",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF9DCC),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pilih Layanan",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tentukan tipe perjalanan yang kamu butuhkan",
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard({
    required BookingType type,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: type.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color(0xFF16151A),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.lightColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : type.lightColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                type.icon,
                color: isSelected ? Colors.white : type.lightColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 18),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.title,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type.subtitle,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Selection Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isSelected = _selectedIndex != null;
    final selectedType = isSelected ? _bookingTypes[_selectedIndex!] : null;
    
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isSelected ? _handleBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? (selectedType!.title == "Antar Jemput"
                  ? const Color(0xFFFF9DCC)
                  : const Color(0xFF9D6BFF))
              : const Color(0xFF2A2A35),
          foregroundColor: isSelected
              ? (selectedType!.title == "Antar Jemput"
                  ? const Color(0xFF4A1031)
                  : const Color(0xFF2D1B4E))
              : Colors.white54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          isSelected ? "Lanjut ke Booking" : "Pilih layanan terlebih dahulu",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class BookingType {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color lightColor;
  final Color darkColor;

  BookingType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.lightColor,
    required this.darkColor,
  });
}