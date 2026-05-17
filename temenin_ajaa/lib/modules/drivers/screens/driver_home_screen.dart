// screens/driver/home/driver_home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/driver_provider.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    await driverProvider.fetchDriverProfile();
    await driverProvider.fetchDriverBookings();
    await driverProvider.fetchDriverEarnings();
    
    if (driverProvider.driverProfile != null) {
      setState(() {
        _isAvailable = driverProvider.driverProfile!['is_available'] ?? false;
      });
    }
  }

  Future<void> _toggleAvailability() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    await driverProvider.updateDriverStatus(!_isAvailable);
    setState(() {
      _isAvailable = !_isAvailable;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAvailable ? 'Anda sekarang ONLINE' : 'Anda sekarang OFFLINE'),
        backgroundColor: _isAvailable ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    final profile = driverProvider.driverProfile;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Driver Dashboard',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.circle, color: _isAvailable ? Colors.green : Colors.red, size: 12),
                const SizedBox(width: 4),
                Text(
                  _isAvailable ? 'ONLINE' : 'OFFLINE',
                  style: GoogleFonts.poppins(
                    color: _isAvailable ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(profile, driverProvider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1A1820),
        selectedItemColor: const Color(0xFFFF9DCC),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleAvailability,
        backgroundColor: _isAvailable ? Colors.red : Colors.green,
        icon: Icon(_isAvailable ? Icons.power_settings_new : Icons.power),
        label: Text(_isAvailable ? 'Offline' : 'Online'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody(Map<String, dynamic>? profile, DriverProvider provider) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard(profile, provider);
      case 1:
        return _buildBookings(provider);
      case 2:
        return _buildEarnings(provider);
      case 3:
        return _buildProfile(profile, provider);
      default:
        return _buildDashboard(profile, provider);
    }
  }

  Widget _buildDashboard(Map<String, dynamic>? profile, DriverProvider provider) {
    final earnings = provider.earnings;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF9DCC), Colors.purple.shade300],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${profile?['users']?['full_name'] ?? 'Driver'}!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6F004B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selamat datang di dashboard driver',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6F004B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          /// Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Booking',
                  '${provider.bookings.length}',
                  Icons.book_online,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pendapatan',
                  'Rp ${(earnings?['total_earnings'] ?? 0).toString()}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Rating',
                  '${profile?['rating'] ?? 5.0} ★',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Rides',
                  '${profile?['total_rides'] ?? 0}',
                  Icons.directions_car,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          /// Recent Bookings
          Text(
            'Booking Terbaru',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (provider.bookings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Belum ada booking',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.bookings.length > 3 ? 3 : provider.bookings.length,
              itemBuilder: (context, index) {
                final booking = provider.bookings[index];
                return _buildBookingCard(booking);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor;
    switch (booking['status']) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        break;
      case 'ongoing':
        statusColor = Colors.green;
        break;
      case 'completed':
        statusColor = Colors.purple;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking #${booking['id'].toString().substring(0, 8)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['status'].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                booking['users']['full_name'],
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.attach_money, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Rp ${booking['total_price']}',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (booking['status'] == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateBookingStatus(booking['id'], 'confirmed'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Terima', style: TextStyle(color: Colors.green)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateBookingStatus(booking['id'], 'cancelled'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Tolak', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBookings(DriverProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(provider.bookings[index]);
      },
    );
  }

  Widget _buildEarnings(DriverProvider provider) {
    final earnings = provider.earnings;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total Pendapatan',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
          ),
          Text(
            'Rp ${earnings?['total_earnings'] ?? 0}',
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total Rides: ${earnings?['total_rides'] ?? 0}',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(Map<String, dynamic>? profile, DriverProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFFF9DCC).withOpacity(0.2),
            child: Text(
              profile?['users']?['full_name']?[0]?.toUpperCase() ?? 'D',
              style: GoogleFonts.poppins(fontSize: 40, color: const Color(0xFFFF9DCC)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile?['users']?['full_name'] ?? 'Driver Name',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            profile?['users']?['email'] ?? 'email@example.com',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          
          _buildProfileInfo('Tipe Kendaraan', profile?['vehicle_type'] ?? '-'),
          _buildProfileInfo('Nama Kendaraan', profile?['vehicle_name'] ?? '-'),
          _buildProfileInfo('Nomor Plat', profile?['plate_number'] ?? '-'),
          _buildProfileInfo('Harga per Jam', 'Rp ${profile?['price_per_hour'] ?? 0}'),
          _buildProfileInfo('Pengalaman', '${profile?['experience_years'] ?? 0} tahun'),
          _buildProfileInfo('Rating', '${profile?['rating'] ?? 5.0} ★'),
          _buildProfileInfo('Total Rides', '${profile?['total_rides'] ?? 0}'),
          
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _showEditProfileDialog(profile, provider),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF9DCC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _updateBookingStatus(String bookingId, String status) async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    await driverProvider.updateBookingStatus(bookingId, status);
    await driverProvider.fetchDriverBookings();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking ${status == 'confirmed' ? 'diterima' : 'ditolak'}')),
    );
  }

  void _showEditProfileDialog(Map<String, dynamic>? profile, DriverProvider provider) {
    // Implement edit profile dialog
  }
}