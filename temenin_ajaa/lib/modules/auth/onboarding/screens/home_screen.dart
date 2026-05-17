// Path: modules/auth/onboarding/screens/main_home_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:temenin_ajaa/modules/auth/screens/login_screen.dart';
import 'package:temenin_ajaa/providers/auth_provider.dart';
import 'bottom_nav_bar.dart';  // Import bottom nav bar
import 'profile_screen.dart';   // Import profile screen

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeTabContent(),      // Tab 0: Beranda
    const ExploreTabContent(),   // Tab 1: Jelajahi  
    const BookingTabContent(),   // Tab 2: Booking
    const FavoritesTabContent(), // Tab 3: Favorit
    const ProfileScreen(),       // Tab 4: Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// ==================== TAB BERANDA (Isi dari HomeScreen Anda) ====================
class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return Stack(
      children: [
        // Background Glows
        Positioned(
          top: -50,
          left: -30,
          child: _glow(const Color(0xFFFF4DA6).withOpacity(0.12), 300),
        ),
        Positioned(
          bottom: 100,
          right: -50,
          child: _glow(Colors.purple.withOpacity(0.1), 350),
        ),
        
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Temenin Ajaa",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF9DCC),
                      ),
                    ),
                    _buildSmallProfile(context, isLoggedIn),
                  ],
                ),
                const SizedBox(height: 30),

                // Hero Title
                Text(
                  "Halo, mau ditemenin hari ini?",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 12),
                Text(
                  "Temukan partner terbaik untuk aktivitasmu.",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),

                // Search Bar
                _searchBar(),
                const SizedBox(height: 30),

                // Promo Banner
                _mainBanner(size),
                const SizedBox(height: 20),

                // Feature Grid
                Row(
                  children: [
                    Expanded(
                      child: _featureCard(
                        icon: Icons.handshake_rounded,
                        title: 'Hangout\nPartner',
                        subtitle: 'Teman Ngobrol',
                        color: const Color(0xFFFF9DCC),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _featureCard(
                        icon: Icons.explore_rounded,
                        title: 'City Tour',
                        subtitle: 'Eksplorasi Kota',
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Driver Recommended",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Lihat Semua",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF9DCC),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Driver List
                _driverCard(
                  image: 'https://i.pravatar.cc/300?img=11',
                  name: 'Arya Perkasa',
                  vehicle: 'Kawasaki Ninja 250 • Black',
                  rating: '4.8',
                  tags: ['AR', 'DK'],
                ),
                const SizedBox(height: 15),
                _driverCard(
                  image: 'https://i.pravatar.cc/300?img=47',
                  name: 'Dian Sastro',
                  vehicle: 'Honda CBR 250RR • Red',
                  rating: '4.9',
                  tags: ['PR', 'AR'],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallProfile(BuildContext context, bool isLoggedIn) {
    return GestureDetector(
      onTap: () {
        if (!isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withOpacity(0.1),
          backgroundImage: isLoggedIn 
              ? const NetworkImage('https://i.pravatar.cc/300?img=12')
              : null,
          child: !isLoggedIn 
              ? const Icon(Icons.login, color: Color(0xFFFF9DCC), size: 20)
              : null,
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
          const SizedBox(width: 12),
          Text(
            "Cari driver atau layanan",
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _mainBanner(Size size) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF251120), Color(0xFF131217)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: 0,
            child: Image.network(
              'https://images.unsplash.com/photo-1558981806-ec527fa84c39?q=80&w=400&auto=format&fit=crop',
              height: 160,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  width: 200,
                  color: Colors.grey.withOpacity(0.3),
                  child: const Icon(Icons.image_not_supported, color: Colors.white),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Antar Jemput",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Motor Sport Premium",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: color.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _driverCard({required String image, required String name, required String vehicle, required String rating, required List<String> tags}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image, 
                  width: 70, 
                  height: 70, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.withOpacity(0.3),
                      child: const Icon(Icons.person, color: Colors.white),
                    );
                  },
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF16151A), width: 2),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: tags.map((t) => Container(
                    margin: const EdgeInsets.only(right: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFF9DCC).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(t, style: const TextStyle(color: Color(0xFFFF9DCC), fontSize: 10, fontWeight: FontWeight.bold)),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                Text(vehicle, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.4), fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

Widget _glow(Color color, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox()),
  );
}

// ==================== TAB JELAJAHI ====================
class ExploreTabContent extends StatelessWidget {
  const ExploreTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B0910), Color(0xFF1A1A2E)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore, size: 80, color: Color(0xFFFF9DCC)),
            const SizedBox(height: 16),
            Text(
              'Jelajahi Layanan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Temukan berbagai layanan eksklusif',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TAB BOOKING ====================
class BookingTabContent extends StatelessWidget {
  const BookingTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B0910), Color(0xFF1A1A2E)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_online, size: 80, color: Color(0xFFFF9DCC)),
            const SizedBox(height: 16),
            Text(
              'Booking Saya',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lihat dan kelola booking Anda',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TAB FAVORIT ====================
class FavoritesTabContent extends StatelessWidget {
  const FavoritesTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B0910), Color(0xFF1A1A2E)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 80, color: Color(0xFFFF9DCC)),
            const SizedBox(height: 16),
            Text(
              'Favorit',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Layanan favorit Anda akan muncul di sini',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}