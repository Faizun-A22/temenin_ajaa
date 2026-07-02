import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'edit_profile_screen.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final user = auth.user;
    final driver = auth.driverProfileData;

    final name = user?.fullName ?? 'Driver';
    final email = user?.email ?? 'driver@temeninajaa.com';
    final phone = user?.phone ?? '+62 xxx-xxxx-xxxx';
    final avatar = user?.avatarUrl ?? 'https://i.pravatar.cc/300?img=33';
    
    final vehicle = driver?['vehicle_name'] ?? 'Vespa Primavera';
    final plate = driver?['plate_number'] ?? 'B 1234 DS';
    final rate = (driver?['price_per_hour'] ?? 50000.0).toDouble();
    final exp = driver?['experience_years'] ?? 3;

    String formatCurrency(double amount) {
      return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profil Driver",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Lihat informasi akun dan data kendaraan Anda",
                      style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Color(0xFFFF9DCC)),
                tooltip: "Edit Profil",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditDriverProfileScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Avatar & Name Card
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(avatar),
                  backgroundColor: Colors.white10,
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Mitra Pendamping Temenin Ajaa",
                  style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),

          // Detail Section
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Status Toggle Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16151A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: auth.isAvailable ? const Color(0xFFFF9DCC).withOpacity(0.3) : Colors.white.withOpacity(0.05),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: auth.isAvailable ? const Color(0xFF00FF7F) : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              auth.isAvailable ? "Status: ONLINE" : "Status: OFFLINE",
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Switch(
                          value: auth.isAvailable,
                          onChanged: (val) async {
                            final success = await auth.toggleAvailability();
                            if (success) {
                              final booking = Provider.of<BookingProvider>(context, listen: false);
                              final driverId = auth.driverProfileData?['id'] as String?;
                              if (auth.isAvailable && driverId != null) {
                                booking.subscribeToBookings(driverId);
                              } else {
                                booking.unsubscribeFromBookings();
                              }
                            }
                          },
                          activeColor: const Color(0xFFFF9DCC),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mini Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _miniStatsCard("Rating", "${driver?['rating'] ?? 5.0}", Icons.star_rate_rounded, const Color(0xFFFF9DCC)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _miniStatsCard("Order Selesai", "${driver?['total_rides'] ?? 0}", Icons.directions_bike_rounded, const Color(0xFF9D6BFF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Personal Info Card
                  _buildProfileCard(
                    title: "INFORMASI PRIBADI",
                    items: [
                      _profileItem("Email", email),
                      _profileItem("Telepon", phone),
                      _profileItem("Gender", user?.gender ?? 'Laki-laki'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Info Card
                  _buildProfileCard(
                    title: "DETAIL KENDARAAN",
                    items: [
                      _profileItem("Merk & Model", vehicle),
                      _profileItem("Plat Nomor", plate),
                      _profileItem("Biaya / Jam", formatCurrency(rate)),
                      _profileItem("Pengalaman", "$exp Tahun"),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const DriverLoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: Text(
                        "KELUAR AKUN",
                        style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileCard({required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 15),
          ...items,
        ],
      ),
    );
  }

  Widget _profileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _miniStatsCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
