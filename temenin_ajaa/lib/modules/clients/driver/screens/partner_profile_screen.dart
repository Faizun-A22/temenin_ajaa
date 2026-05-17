// lib/modules/driver/screens/partner_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:temenin_ajaa/modules/clients/chat/screens/chat_room_screen.dart';

import 'package:temenin_ajaa/modules/clients/booking/screens/antar_jemput_booking_screen.dart';
import 'package:temenin_ajaa/modules/clients/booking/screens/hangout_booking_screen.dart';

class PartnerProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? partnerData;
  
  const PartnerProfileScreen({super.key, this.partnerData});

  @override
  Widget build(BuildContext context) {
    final partnerName = partnerData?['name'] ?? "Raditya Pratama";
    final partnerRating = partnerData?['rating'] ?? "4.8";
    final partnerVehicle = partnerData?['vehicle'] ?? "Kawasaki Ninja ZX-25R";
    final partnerType = partnerData?['type'] ?? "PR PREMIUM PARTNER";
    final partnerImage = partnerData?['image'] ?? "https://images.unsplash.com/photo-1558981403-c5f91cbba527";
    final partnerStatus = partnerData?['status'] ?? "Available";
    final partnerTag = partnerData?['tag'] ?? "PR";
    final partnerPrice = partnerData?['price'] ?? 15000;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(context, partnerName, partnerType, partnerRating, partnerImage, partnerStatus),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("About $partnerName"),
                  const SizedBox(height: 10),
                  _buildDescription(partnerName),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Vehicle Details"),
                  const SizedBox(height: 15),
                  _buildVehicleCard(partnerVehicle, partnerTag),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Availability"),
                  const SizedBox(height: 15),
                  _buildCalendarCard(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(
        context, 
        partnerName, 
        partnerVehicle, 
        partnerRating, 
        partnerImage, 
        partnerTag,
        partnerPrice,
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, String name, String type, String rating, String image, String status) {
    return Stack(
      children: [
        Container(
          height: 450,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  const Color(0xFF0D0C11),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "Temenin Ajaa",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFF9DCC),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=33'),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9DCC).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF9DCC).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      type,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF9DCC),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFF9DCC), size: 12),
                        const SizedBox(width: 4),
                        Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: Colors.white.withValues(alpha: 0.6), size: 16),
                  const SizedBox(width: 6),
                  Text("1.2k+ Orders", style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
                  const SizedBox(width: 15),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: status == "Available" ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status, 
                    style: TextStyle(
                      color: status == "Available" ? Colors.green : Colors.red, 
                      fontSize: 14, 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatItem("98%", "SUCCESS RATE")),
        const SizedBox(width: 15),
        Expanded(child: _buildStatItem("3 yrs", "EXPERIENCE")),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: const Color(0xFFFF9DCC),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescription(String name) {
    return Text(
      "Professional companion and rider specializing in premium city tours and errand runs. Known for punctuality and high-level safety standards. Fluent in English and passionate about delivering a first-class experience for every trip.",
      style: GoogleFonts.poppins(
        color: Colors.white.withValues(alpha: 0.6),
        fontSize: 14,
        height: 1.6,
      ),
    );
  }

  Widget _buildVehicleCard(String vehicle, String tag) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?q=80&w=1000', 
                  height: 180, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    "B 1234 $tag",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Midnight Shadow Edition • 2023", style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
                  ],
                ),
                const Icon(Icons.motorcycle_rounded, color: Color(0xFFFF9DCC), size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("OCTOBER 2023", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const Row(
                children: [
                  Icon(Icons.chevron_left, color: Colors.white38),
                  SizedBox(width: 15),
                  Icon(Icons.chevron_right, color: Colors.white38),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ["MO", "TU", "WE", "TH", "FR", "SA", "SU"].map((d) => Text(d, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.bold))).toList(),
        ),
        const SizedBox(height: 15),
        _calendarRow(["25", "26", "1", "2", "3", "4", "5"], selectedIndex: 4),
        const SizedBox(height: 10),
        _calendarRow(["6", "7", "8", "9", "10", "", ""], activeIndex: 0, selectedIndex: 4),
      ],
    );
  }

  Widget _calendarRow(List<String> days, {int? activeIndex, int? selectedIndex}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        bool isActive = index == activeIndex;
        bool isSelected = index == selectedIndex;
        return Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF9DCC) : (isSelected ? const Color(0xFFFF9DCC).withValues(alpha: 0.2) : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              days[index],
              style: TextStyle(
                color: isActive ? const Color(0xFF4A1031) : (days[index] == "25" || days[index] == "26" ? Colors.white24 : Colors.white),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showBookingOptionsDialog(
    BuildContext context,
    String name,
    String vehicle,
    String rating,
    String image,
    String tag,
    int price,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1B21),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Pilih Layanan Booking",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pilih tipe perjalanan yang kamu inginkan",
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 25),
            _buildBookingOption(
              context: context,
              title: "Antar Jemput",
              subtitle: "Perjalanan dari titik A ke B dengan driver profesional",
              icon: Icons.car_rental_rounded,
              color: const Color(0xFFFF9DCC),
              iconColor: const Color(0xFFFF9DCC),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AntarJemputBookingScreen(
                      selectedPartner: {
                        'name': name,
                        'vehicle': vehicle,
                        'rating': rating,
                        'image': image,
                        'tag': tag,
                        'price': price,
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            _buildBookingOption(
              context: context,
              title: "Hangout Partner",
              subtitle: "Temani harimu, dari ngopi, jalan-jalan, sampai acara khusus",
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF9D6BFF),
              iconColor: const Color(0xFF9D6BFF),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HangoutBookingScreen(
                      selectedPartner: {
                        'name': name,
                        'vehicle': vehicle,
                        'rating': rating,
                        'image': image,
                        'tag': tag,
                        'price': price,
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16151A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    String name,
    String vehicle,
    String rating,
    String image,
    String tag,
    int price,
  ) {
    return Container(
      color: const Color(0xFF0D0C11),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to ChatRoomScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                      partnerName: name,
                      partnerImage: image,
                      partnerStatus: "Online Now",
                      partnerTag: tag,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                side: const BorderSide(color: Color(0xFFFF9DCC)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Icon(Icons.chat_outlined, color: Color(0xFFFF9DCC)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () {
                _showBookingOptionsDialog(
                  context, 
                  name, 
                  vehicle, 
                  rating, 
                  image, 
                  tag, 
                  price,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9DCC),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Booking Sekarang", style: TextStyle(color: Color(0xFF4A1031), fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}