// Path: modules/auth/onboarding/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Data dummy user
  final Map<String, dynamic> _userData = {
    'fullName': 'Sarah Maharani',
    'email': 'sarah.maharani@example.com',
    'phone': '+62 812 3456 7890',
    'joinDate': '2024',
    'isVerified': true,
    'avatarUrl': null, // null untuk menggunakan icon default
    'membershipLevel': 'DIAMOND',
    'membershipProgress': 0.68,
    'pointsBalance': 2450,
    'pointsToNextReward': 500,
    'stats': {
      'totalBookings': 24,
      'ongoingBookings': 2,
      'completedBookings': 22,
    },
    'recentActivities': [
      {'title': 'Spa & Massage', 'date': '15 Mei 2026', 'points': 150, 'status': 'Completed'},
      {'title': 'Fine Dining', 'date': '10 Mei 2026', 'points': 200, 'status': 'Completed'},
      {'title': 'Private Driver', 'date': '5 Mei 2026', 'points': 100, 'status': 'Completed'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            color: const Color(0xFFFF9DCC),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFF9DCC)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFFFF9DCC)),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildProfileHeader(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildUserInfo(),
                  const SizedBox(height: 24),
                  _buildMembershipCard(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildMenuSection(
                    title: "LAYANAN SAYA",
                    children: [
                      _menuTile(Icons.history_rounded, "Riwayat Booking",
                          onTap: () => _navigateToBookingHistory(context)),
                      _menuTile(Icons.account_balance_wallet_outlined, "Metode Pembayaran",
                          onTap: () => _navigateToPaymentMethods(context)),
                      _menuTile(Icons.card_giftcard_outlined, "Rewards & Voucher",
                          badge: "${_userData['pointsBalance']} pts",
                          onTap: () => _navigateToRewards(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMenuSection(
                    title: "PENGATURAN",
                    children: [
                      _menuTile(Icons.notifications_outlined, "Notifikasi",
                          badge: "3",
                          onTap: () => _navigateToNotifications(context)),
                      _menuTile(Icons.help_outline_rounded, "Pusat Bantuan",
                          onTap: () => _navigateToHelpCenter(context)),
                      _menuTile(Icons.security_outlined, "Keamanan Akun",
                          onTap: () => _navigateToSecurity(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMenuSection(
                    title: "LAINNYA",
                    children: [
                      _menuTile(Icons.share_outlined, "Bagikan Aplikasi",
                          onTap: () => _shareApp(context)),
                      _menuTile(Icons.star_outline, "Beri Rating",
                          onTap: () => _rateApp(context)),
                      _menuTile(Icons.info_outline, "Tentang Aplikasi",
                          onTap: () => _navigateToAbout(context)),
                      _menuTile(Icons.logout_rounded, "Keluar",
                          isLogout: true,
                          onTap: () => _showLogoutDialog(context)),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1121),
            Color(0xFF1A0D15),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showAvatarOptions(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9DCC).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF2D1121),
                        backgroundImage: _userData['avatarUrl'] != null
                            ? NetworkImage(_userData['avatarUrl'])
                            : null,
                        child: _userData['avatarUrl'] == null
                            ? Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white.withOpacity(0.6),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9DCC),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1A0D15), width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _userData['fullName'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9DCC), Color(0xFFD47BAA)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _userData['membershipLevel'],
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData['email'],
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
  Icons.star,
  size: 14,
  color: Color(0xFFFFD700),
),
                        const SizedBox(width: 4),
                        Text(
                          "Level 42 · ${_userData['membershipLevel']} Member",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android, size: 16, color: Color(0xFFFF9DCC)),
              const SizedBox(width: 8),
              Text(
                _userData['phone'],
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Color(0xFFFF9DCC)),
              const SizedBox(width: 8),
              Text(
                "Bergabung sejak ${_userData['joinDate']}",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9DCC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
  Icons.verified,
  size: 12,
  color: Color(0xFFFF9DCC),
),
                    const SizedBox(width: 4),
                    Text(
                      _userData['isVerified'] ? "Terverifikasi" : "Belum Verifikasi",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFFF9DCC),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1121),
            Color(0xFF6B2142),
            Color(0xFF3B122A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9DCC).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "MEMBERSHIP",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _userData['membershipLevel'],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    "Member",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _userData['membershipProgress'],
                      strokeWidth: 6,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${(_userData['membershipProgress'] * 100).toInt()}%",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "to next",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPointsInfo("Poin Saya", _userData['pointsBalance'].toString(), "pts"),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildPointsInfo("Hadiah Terdekat", _userData['pointsToNextReward'].toString(), "pts lagi"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: "Top Up",
                  icon: Icons.add_card_outlined,
                  color: const Color(0xFFFF9DCC),
                  onPressed: () => _topUp(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  label: "Upgrade",
                  icon: Icons.trending_up_outlined,
                  color: Colors.white,
                  isOutlined: true,
                  onPressed: () => _upgradeMembership(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsInfo(String label, String value, String unit) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: const Color(0xFF631841),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = _userData['stats'];
    
    return Row(
      children: [
        Expanded(child: _buildStatItem(
          stats['totalBookings'].toString(),
          "Total Booking", 
          Icons.calendar_month
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(
          stats['ongoingBookings'].toString(),
          "Berlangsung", 
          Icons.play_circle, 
          isHighlight: true
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(
          stats['completedBookings'].toString(),
          "Selesai", 
          Icons.check_circle
        )),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? const Color(0xFFFF9DCC).withOpacity(0.2) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isHighlight ? const Color(0xFFFF9DCC) : Colors.white.withOpacity(0.4), size: 20),
          const SizedBox(height: 8),
          Text(
            value, 
            style: GoogleFonts.poppins(
              color: isHighlight ? const Color(0xFFFF9DCC) : Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.4), 
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _menuTile(
    IconData icon, 
    String title, {
    String? badge, 
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          _showComingSoonDialog();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLogout ? Colors.red.withOpacity(0.1) : const Color(0xFFFF9DCC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: isLogout ? Colors.redAccent : const Color(0xFFFF9DCC), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title, 
                  style: GoogleFonts.poppins(
                    color: isLogout ? Colors.redAccent : Colors.white, 
                    fontSize: 14, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9DCC).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge, 
                    style: const TextStyle(
                      color: Color(0xFFFF9DCC),
                      fontSize: 10, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.2), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation Methods with dummy data
  void _navigateToBookingHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Riwayat Booking",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._userData['recentActivities'].map<Widget>((activity) {
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9DCC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.event, color: Color(0xFFFF9DCC)),
                        ),
                        title: Text(
                          activity['title'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          activity['date'],
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                        trailing: Text(
                          "+${activity['points']} pts",
                          style: const TextStyle(
                            color: Color(0xFFFF9DCC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9DCC),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Tutup"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToPaymentMethods(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        title: const Text('Metode Pembayaran', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card, color: Color(0xFFFF9DCC)),
              title: const Text('Visa •••• 4242', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Color(0xFFFF9DCC)),
              title: const Text('Mastercard •••• 5555', style: TextStyle(color: Colors.white)),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Color(0xFFFF9DCC)),
              title: const Text('Tambah Metode Pembayaran', style: TextStyle(color: Color(0xFFFF9DCC))),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _navigateToRewards(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        title: const Text('Rewards & Voucher', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9DCC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Poin Saya', style: TextStyle(color: Colors.white70)),
                  Text(
                    '${_userData['pointsBalance']} pts',
                    style: const TextStyle(
                      color: Color(0xFFFF9DCC),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.local_offer, color: Color(0xFFFF9DCC)),
              title: Text('Diskon 20%', style: TextStyle(color: Colors.white)),
              subtitle: Text('Minimal belanja 500k', style: TextStyle(color: Colors.white54)),
              trailing: Text('500 pts', style: TextStyle(color: Color(0xFFFF9DCC))),
            ),
            const ListTile(
              leading: Icon(Icons.spa, color: Color(0xFFFF9DCC)),
              title: Text('Free Spa Session', style: TextStyle(color: Colors.white)),
              subtitle: Text('1x treatment', style: TextStyle(color: Colors.white54)),
              trailing: Text('1500 pts', style: TextStyle(color: Color(0xFFFF9DCC))),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        title: const Text('Notifikasi', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.notifications_active, color: Color(0xFFFF9DCC)),
              title: Text('Booking Confirmed', style: TextStyle(color: Colors.white)),
              subtitle: Text('Your spa booking has been confirmed', style: TextStyle(color: Colors.white54)),
            ),
            const ListTile(
              leading: Icon(Icons.card_giftcard, color: Color(0xFFFF9DCC)),
              title: Text('New Reward Available', style: TextStyle(color: Colors.white)),
              subtitle: Text('Check out your new vouchers', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _navigateToHelpCenter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        title: const Text('Pusat Bantuan', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.help, color: Color(0xFFFF9DCC)),
              title: Text('FAQ', style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.contact_support, color: Color(0xFFFF9DCC)),
              title: Text('Hubungi CS', style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.description, color: Color(0xFFFF9DCC)),
              title: Text('Panduan Pengguna', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _navigateToSecurity(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        title: const Text('Keamanan Akun', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(Icons.lock, color: Color(0xFFFF9DCC)),
              title: Text('Ubah Password', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.verified_user, color: Color(0xFFFF9DCC)),
              title: Text('Verifikasi 2 Langkah', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.devices, color: Color(0xFFFF9DCC)),
              title: Text('Perangkat Terhubung', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFFFF9DCC)),
                title: const Text('Bahasa', style: TextStyle(color: Colors.white)),
                trailing: const Text('Indonesia', style: TextStyle(color: Colors.white54)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode, color: Color(0xFFFF9DCC)),
                title: const Text('Mode Gelap', style: TextStyle(color: Colors.white)),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: const Color(0xFFFF9DCC),
                ),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.privacy_tip, color: Color(0xFFFF9DCC)),
                title: const Text('Kebijakan Privasi', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Color(0xFFFF9DCC)),
                title: const Text('Syarat & Ketentuan', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1C24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFFFF9DCC)),
                title: const Text("Ambil Foto", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFF9DCC)),
                title: const Text("Pilih dari Galeri", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonDialog();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _topUp(BuildContext context) {
    _showComingSoonDialog();
  }

  void _upgradeMembership(BuildContext context) {
    _showComingSoonDialog();
  }

  void _shareApp(BuildContext context) {
    _showComingSoonDialog();
  }

  void _rateApp(BuildContext context) {
    _showComingSoonDialog();
  }

  void _navigateToAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        title: const Text('Tentang Aplikasi', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flash_on, size: 50, color: Color(0xFFFF9DCC)),
            const SizedBox(height: 16),
            Text(
              'GlowUp',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF9DCC),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            const Text(
              'Premium Lifestyle Experience',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Konfirmasi Keluar",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Apakah kamu yakin ingin keluar?",
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Batal",
                style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: Text(
                "Keluar",
                style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        title: const Text('Fitur Segera Hadir', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Fitur ini sedang dalam pengembangan. Terima kasih atas pengertiannya!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFFF9DCC))),
          ),
        ],
      ),
    );
  }
}