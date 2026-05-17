// lib/modules/driver/screens/partner_list_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'partner_profile_screen.dart';

class PartnerListScreen extends StatelessWidget {
  const PartnerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Color(0xFFFF9DCC)),
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
              backgroundImage: const NetworkImage('https://i.pravatar.cc/100?img=12'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Available Partners",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Find the perfect companion for your journey.",
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 25),
            
            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip("All", isActive: true),
                  _buildFilterChip("AR"),
                  _buildFilterChip("DK"),
                  _buildFilterChip("PR"),
                  _buildFilterChip("Available"),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Partner List - ✅ Kirim context ke _partnerCard
            _partnerCard(
              context: context, // ✅ Kirim context
              id: 1,
              name: "Adrian Wijaya",
              vehicle: "Kawasaki Ninja ZX-25R",
              rating: "4.9",
              status: "Available",
              type: "ELITE",
              image: "https://images.unsplash.com/photo-1558981806-ec527fa84c39?q=80&w=600",
              tag: "AR",
              isAvailable: true,
              price: 25000,
            ),
            _partnerCard(
              context: context, // ✅ Kirim context
              id: 2,
              name: "Diki Pratama",
              vehicle: "Honda CBR250RR",
              rating: "4.7",
              status: "Booked",
              type: "PREMIUM",
              image: "https://images.unsplash.com/photo-1591114002673-8a3064619d00?q=80&w=600",
              tag: "DK",
              isAvailable: false,
              price: 20000,
            ),
            _partnerCard(
              context: context, // ✅ Kirim context
              id: 3,
              name: "Putra Ramadhan",
              vehicle: "Yamaha R15 V4",
              rating: "5.0",
              status: "Available",
              type: "ELITE",
              image: "https://images.unsplash.com/photo-1614165933026-07521c7a6b8b?q=80&w=600",
              tag: "PR",
              isAvailable: true,
              price: 30000,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF9DCC) : const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isActive ? Colors.black : Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _partnerCard({
    required BuildContext context, // ✅ Tambahkan parameter context
    required int id,
    required String name,
    required String vehicle,
    required String rating,
    required String status,
    required String type,
    required String image,
    required String tag,
    required bool isAvailable,
    required int price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Image Header with Overlays
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
              // Gradient Overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.2), Colors.transparent, Colors.black.withOpacity(0.6)],
                    ),
                  ),
                ),
              ),
              // Elite/Premium Badge
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: type == "ELITE" ? const Color(0xFFFFB6D9).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ),
              // Rating Badge
              Positioned(
                bottom: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
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
          
          // Info Section
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
                        Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9DCC).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(tag, style: const TextStyle(color: Color(0xFFFF9DCC), fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: isAvailable ? () {
                        // ✅ Navigasi ke PartnerProfileScreen
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
                                'tag': tag,
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