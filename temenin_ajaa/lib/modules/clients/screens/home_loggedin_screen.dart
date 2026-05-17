import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:temenin_ajaa/modules/clients/driver/screens/partner_list_screen.dart';
import 'package:temenin_ajaa/modules/clients/driver/screens/partner_profile_screen.dart';
import 'package:temenin_ajaa/modules/clients/chat/screens/chat_list_screen.dart';
import 'package:temenin_ajaa/modules/clients/booking/screens/booking_type_selector_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/profile_tab.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class HomeLoggedInScreen extends StatefulWidget {
  const HomeLoggedInScreen({super.key});

  @override
  State<HomeLoggedInScreen> createState() => _HomeLoggedInScreenState();
}

class _HomeLoggedInScreenState extends State<HomeLoggedInScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const NewHomeContent(),
    const PartnerListScreen(),
    const BookingTypeSelectorScreen(),
    const ChatListScreen(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
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

class NewHomeContent extends StatefulWidget {
  const NewHomeContent({super.key});

  @override
  State<NewHomeContent> createState() => _NewHomeContentState();
}

class _NewHomeContentState extends State<NewHomeContent> {
  void _navigateToPartnerProfile(BuildContext context, String name, String img, String rate, bool isElite) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerProfileScreen(
          partnerData: {
            'name': name,
            'image': img,
            'rating': rate,
            'tag': isElite ? 'ELITE' : 'REGULAR',
          },
        ),
      ),
    );
  }

  // Helper method untuk mendapatkan progress menuju level selanjutnya
  double _getMembershipProgress() {
    final points = Provider.of<AuthProvider>(context).user?.points ?? 0;
    if (points >= 2000) return 1.0;
    if (points >= 1000) return (points - 1000) / 1000;
    if (points >= 500) return (points - 500) / 500;
    if (points >= 100) return (points - 100) / 400;
    return points / 100;
  }

  // Helper method untuk mendapatkan points yang dibutuhkan ke level berikutnya
  int _getPointsToNextLevel() {
    final points = Provider.of<AuthProvider>(context).user?.points ?? 0;
    if (points < 100) return 100 - points;
    if (points < 500) return 500 - points;
    if (points < 1000) return 1000 - points;
    if (points < 2000) return 2000 - points;
    return 0;
  }

  // Helper method untuk mendapatkan nama level berikutnya
  String _getNextLevelName() {
    final points = Provider.of<AuthProvider>(context).user?.points ?? 0;
    if (points < 100) return "Silver Member";
    if (points < 500) return "Gold Member";
    if (points < 1000) return "Platinum Member";
    if (points < 2000) return "Diamond Member";
    return "Ultimate Member";
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    // Get dynamic values from user data
    final greetingName = authProvider.getGreetingName();
    final memberTier = authProvider.getMemberTier();
    final memberColor = authProvider.getMemberTierColor();
    final formattedPoints = authProvider.getFormattedPoints();
    final points = user?.points ?? 0;
    
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await authProvider.refreshUser();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // Header - Dynamic with user data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : const NetworkImage('https://i.pravatar.cc/300?img=32') as ImageProvider,
                        child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white, size: 20)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Temenin Ajaa",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            user?.fullName ?? 'User',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16151A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Greeting - Dynamic with user name
              Text(
                "Halo, $greetingName! 👋", 
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)
              ),
              const SizedBox(height: 8),
              
              // Member Tier - Dynamic based on points
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [memberColor, memberColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      memberTier.contains("Diamond") 
                          ? Icons.diamond_outlined 
                          : memberTier.contains("Platinum") 
                              ? Icons.star_outlined
                              : memberTier.contains("Gold")
                                  ? Icons.emoji_events_outlined
                                  : Icons.verified_outlined,
                      size: 14, 
                      color: const Color(0xFF4A1031)
                    ),
                    const SizedBox(width: 5),
                    Text(
                      memberTier, 
                      style: GoogleFonts.poppins(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF4A1031)
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Point Balance Card - Dynamic with real points
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8E2B5F), Color(0xFFC25A8E), Color(0xFFE98CB7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8E2B5F).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "POINT BALANCE", 
                          style: GoogleFonts.poppins(
                            color: Colors.white70, 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedPoints, 
                              style: GoogleFonts.poppins(
                                color: Colors.white, 
                                fontSize: 32, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "pts", 
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18),
                            ),
                          ],
                        ),
                        if (points > 0)
                          Text(
                            "≈ ${(points / 100).toStringAsFixed(0)} Poin lagi ke ${_getNextLevelName()}",
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to top up screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur Top Up akan segera hadir')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8E2B5F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text("Top Up", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Active Booking Section
              Text(
                "Active Booking", 
                style: GoogleFonts.poppins(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16151A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1558981403-c5f91cbba527?w=100&h=100&fit=crop',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[800],
                            child: const Icon(Icons.person, color: Colors.white54),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Partner: Kevin Sanjaya", 
                            style: GoogleFonts.poppins(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9DCC).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.near_me_rounded, color: Color(0xFFFF9DCC), size: 12),
                                SizedBox(width: 4),
                                Text(
                                  "On the Way",
                                  style: TextStyle(color: Color(0xFFFF9DCC), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Arriving in 8 mins", 
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Grid Menu
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.8,
                children: [
                  _buildMenuCard(Icons.card_giftcard_rounded, "Reward Center"),
                  _buildMenuCard(Icons.confirmation_num_rounded, "Voucher"),
                  _buildMenuCard(Icons.person_add_alt_1_rounded, "Referral"),
                  _buildMenuCard(Icons.history_rounded, "History"),
                ],
              ),
              const SizedBox(height: 30),

              // Special For You Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Special For You", 
                    style: GoogleFonts.poppins(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      "View All",
                      style: TextStyle(color: Color(0xFFFF9DCC), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToPartnerProfile(context, 'Raka Wijaya', 'https://i.pravatar.cc/300?img=11', '4.9', false),
                      child: _buildPartnerCard(
                        'https://i.pravatar.cc/300?img=11',
                        'Raka Wijaya',
                        '4.9',
                        false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToPartnerProfile(context, 'Dimas Satria', 'https://i.pravatar.cc/300?img=12', '5.0', true),
                      child: _buildPartnerCard(
                        'https://i.pravatar.cc/300?img=12',
                        'Dimas Satria',
                        '5.0',
                        true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Section: Explore by Category
              Text(
                "Explore by Interest",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip("All", isSelected: true),
                    _buildCategoryChip("Fine Dining"),
                    _buildCategoryChip("Movie Buddy"),
                    _buildCategoryChip("Sports"),
                    _buildCategoryChip("Study Friend"),
                    _buildCategoryChip("Travel"),
                    _buildCategoryChip("Shopping"),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Section: Exclusive Offers (Horizontal Banner)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800&q=80'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9DCC), Color(0xFFFFB8D9)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        memberTier.contains("Diamond") ? "🔥 DIAMOND EXCLUSIVE" : "🔥 WEEKEND PROMO",
                        style: GoogleFonts.poppins(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A1031),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      memberTier.contains("Diamond") 
                          ? "Dapatkan Cashback 20%\nUntuk Diamond Member"
                          : "Dapatkan Cashback 10%\nUntuk Semua Member",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9DCC).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Claim Now →",
                          style: TextStyle(
                            color: Color(0xFFFF9DCC),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Section: Loyalty Progress - Dynamic based on points
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1A1920), const Color(0xFF16151A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Membership Progress", 
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E2B5F).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            memberTier, 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _getMembershipProgress(),
                        minHeight: 8,
                        backgroundColor: const Color(0xFF2D2C33),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8E2B5F)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      points >= 2000 
                          ? "🎉 Selamat! Anda sudah mencapai level tertinggi!"
                          : "Kumpulkan ${_getPointsToNextLevel()} poin lagi untuk jadi ${_getNextLevelName()}",
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Section: Recent Reviews
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "What Users Say", 
                    style: GoogleFonts.poppins(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz, color: Colors.white54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildReviewCard(
                "Jessica S.",
                "Kevin ramah banget dan on-time. Sangat membantu pas acara formal!",
                "4.9",
              ),
              const SizedBox(height: 12),
              _buildReviewCard(
                "Budi Aris",
                "Dimas asik diajak diskusi soal bisnis. Definisi partner elit.",
                "5.0",
              ),
              const SizedBox(height: 120), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1920), const Color(0xFF16151A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF9DCC).withOpacity(0.15), const Color(0xFFFF9DCC).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF9DCC), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(String img, String name, String rate, bool isElite) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  img,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 130,
                      color: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.white54),
                    );
                  },
                ),
              ),
              if (isElite)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2B5F), Color(0xFFC25A8E)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "ELITE",
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        rate,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Available",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF8E2B5F), Color(0xFFC25A8E)],
              )
            : null,
        color: isSelected ? null : const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isSelected ? Colors.transparent : Colors.white12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF8E2B5F).withOpacity(0.3),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.white60,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildReviewCard(String name, String comment, String rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1920), const Color(0xFF16151A).withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E2B5F), Color(0xFFFF9DCC)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, size: 12, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              const Icon(Icons.star, color: Colors.amber, size: 12),
              const SizedBox(width: 4),
              Text(rating, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}