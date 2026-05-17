// lib/modules/home/widgets/profile_tab.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:temenin_ajaa/data/models/user_model.dart';
import 'package:temenin_ajaa/modules/clients/pages/help_center_page.dart';
import 'package:temenin_ajaa/modules/clients/pages/notifications_page.dart';
import 'package:temenin_ajaa/modules/clients/pages/settings_page.dart';
import '../../../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../pages/edit_profile_page.dart';
import '../pages/booking_history_page.dart';
import '../pages/payment_methods_page.dart';
import '../pages/rewards_page.dart';


class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshUser();
  }

  void _refreshProfile() {
    setState(() {
      _refreshKey++;
    });
    _refreshUserData();
  }

  Future<void> _navigateToEditProfile(BuildContext context, dynamic user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
    
    if (result == true) {
      _refreshProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      key: ValueKey(_refreshKey),
      builder: (context, authProvider, child) {
        print('AuthProvider user: ${authProvider.user}');
        print('Is loading: ${authProvider.isLoading}');
        
        if (authProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF9DCC),
            ),
          );
        }
        
        if (authProvider.user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'User not found',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _refreshUserData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9DCC),
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }
        
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileHeader(context, authProvider.user),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildUserInfo(authProvider.user),
                    const SizedBox(height: 24),
                    _buildMembershipCard(),
                    const SizedBox(height: 20),
                    _buildStatsRow(authProvider.user),
                    const SizedBox(height: 24),
                    _buildMenuSection(
                      title: "AKUN",
                      children: [
                        _menuTile(context, Icons.person_outline_rounded, "Edit Profile",
                            onTap: () => _navigateToEditProfile(context, authProvider.user)),
                        _menuTile(context, Icons.history_rounded, "Booking History",
                            badge: "3 ACTIVE",
                            onTap: () => _navigateToBookingHistory(context)),
                        _menuTile(context, Icons.account_balance_wallet_outlined, "Payment Methods",
    onTap: () => _navigateToPaymentMethods(context)),
                        _menuTile(context, Icons.card_giftcard_outlined, "Rewards & Vouchers",
                            onTap: () => _navigateToRewards(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMenuSection(
                      title: "PENGATURAN & DUKUNGAN",
                      children: [
                        _menuTile(context, Icons.notifications_outlined, "Notifikasi",
                            onTap: () => _navigateToNotifications(context)),
                        _menuTile(context, Icons.help_outline_rounded, "Help Center",
                            onTap: () => _navigateToHelpCenter(context)),
                        _menuTile(context, Icons.settings_outlined, "Settings & Privacy",
                            onTap: () => _navigateToSettings(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMenuSection(
                      title: "LAINNYA",
                      children: [
                        _menuTile(context, Icons.share_outlined, "Bagikan Aplikasi",
                            onTap: () => _shareApp(context)),
                        _menuTile(context, Icons.info_outline, "Tentang Aplikasi",
                            onTap: () => _navigateToAbout(context)),
                        _menuTile(context, Icons.logout_rounded, "Logout",
                            isLogout: true,
                            onTap: () => _showLogoutDialog(context, authProvider)),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
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
                        // 🔴 PERBAIKI: Hanya tampilkan foto jika ada, tanpa dummy
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user.avatarUrl)
                            : null,
                        child: user?.avatarUrl == null
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
                            user?.fullName ?? "User Name",
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
                            color: const Color(0xFFFF9DCC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "ELITE",
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
                      user?.email ?? "user@example.com",
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
                        const Icon(Icons.star, size: 14, color: Color(0xFFFFD700)),
                        const SizedBox(width: 4),
                        Text(
                          "Level 42 · Diamond Member",
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

  Widget _buildUserInfo(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Color(0xFFFF9DCC)),
          const SizedBox(width: 8),
          Text(
            "Bergabung sejak ${_formatJoinDate(user?.createdAt)}",
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
                const Icon(Icons.verified, size: 12, color: Color(0xFFFF9DCC)),
                const SizedBox(width: 4),
                Text(
                  user?.isVerified == true ? "Verified" : "Unverified",
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
                    "Diamond",
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
                    const CircularProgressIndicator(
                      value: 0.68,
                      strokeWidth: 6,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "68%",
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
                _buildPointsInfo("Points Balance", "2,450", "pts"),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildPointsInfo("Next Reward", "500", "pts to go"),
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
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  label: "Upgrade",
                  icon: Icons.trending_up_outlined,
                  color: Colors.white,
                  isOutlined: true,
                  onPressed: () {},
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

  Widget _buildStatsRow(UserModel? user) {
    final stats = user?.stats ?? {};
    
    return Row(
      children: [
        Expanded(child: _buildStatItem(
          (stats['totalBookings'] ?? 0).toString(),
          "Total Bookings", 
          Icons.calendar_month
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(
          (stats['ongoingBookings'] ?? 0).toString(),
          "Ongoing", 
          Icons.play_circle, 
          isHighlight: true
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem(
          (stats['completedBookings'] ?? 0).toString(),
          "Completed", 
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
    BuildContext context, 
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
          print('Navigate to $title');
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

  String _formatJoinDate(DateTime? date) {
    if (date == null) return "2024";
    return "${date.year}";
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
                title: const Text("Take a photo"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera, context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFF9DCC)),
                title: const Text("Choose from gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery, context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text("Remove photo", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAvatar(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        await _uploadAvatar(imageFile, context);
      }
    } catch (e) {
      print('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _uploadAvatar(File imageFile, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF9DCC)),
      ),
    );
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.uploadAvatar(imageFile);
      
      if (context.mounted) {
        Navigator.pop(context);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diupdate')),
          );
          _refreshProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage ?? 'Gagal upload foto')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteAvatar(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        title: const Text('Hapus Foto', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus foto profil?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final success = await authProvider.deleteAvatar();
              
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto profil berhasil dihapus')),
                  );
                  _refreshProfile();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.errorMessage ?? 'Gagal hapus foto')),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // Di profile_tab.dart, update method _navigateToBookingHistory:

void _navigateToBookingHistory(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const BookingHistoryPage(),  // ← BookingHistoryPage, BUKAN BookingService
    ),
  );
}

  void _navigateToPaymentMethods(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const PaymentMethodsPage(),
    ),
  );
}

  void _navigateToRewards(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const RewardsPage(),
    ),
  );
}

  void _navigateToHelpCenter(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const HelpCenterPage(),
    ),
  );
}


  void _navigateToNotifications(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const NotificationsPage(),
    ),
  );
}

  void _navigateToSettings(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    ),
  );
}

  void _shareApp(BuildContext context) {
    print('Share app');
  }

  void _navigateToAbout(BuildContext context) {
    print('Navigate to About');
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1C24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Konfirmasi Logout",
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
              onPressed: () async {
                await authProvider.logout();
                
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}