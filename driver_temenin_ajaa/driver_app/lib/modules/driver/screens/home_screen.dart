import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../data/models/booking_model.dart';
import 'active_booking_screen.dart';
import 'chat_list_screen.dart';
import 'earnings_screen.dart';
import 'profile_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    // Fetch initial profile and subscribe if online
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final booking = Provider.of<BookingProvider>(context, listen: false);
      
      auth.refreshProfile().then((_) {
        final driverId = auth.driverProfileData?['id'] as String?;
        if (auth.isAvailable && driverId != null) {
          booking.subscribeToBookings(driverId);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final booking = context.watch<BookingProvider>();

    // Listen for incoming booking requests and show alert card
    if (booking.incomingBooking != null && !_isDialogOpen) {
      _isDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showIncomingRequestDialog(booking.incomingBooking!).then((_) {
          _isDialogOpen = false;
          if (mounted) {
            Provider.of<BookingProvider>(context, listen: false).clearIncomingRequest();
          }
        });
      });
    }

    // List of screens to display in bottom navigation
    final List<Widget> screens = [
      _buildDashboard(auth, booking),
      const DriverChatListScreen(),
      const DriverEarningsScreen(),
      const DriverProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF160D27),
              Color(0xFF0B0910),
            ],
          ),
        ),
        child: SafeArea(child: screens[_currentIndex]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF16151A),
        selectedItemColor: const Color(0xFFFF9DCC),
        unselectedItemColor: Colors.white30,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: "Earnings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(AuthProvider auth, BookingProvider booking) {
    final name = auth.user?.fullName ?? 'Driver';
    final vehicle = auth.driverProfileData?['vehicle_name'] ?? 'Vespa Primavera';
    final plate = auth.driverProfileData?['plate_number'] ?? 'B 1234 DS';
    final rating = auth.driverProfileData?['rating'] ?? 5.0;
    
    String formatCurrency(double amount) {
      return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Header Profile Info
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(auth.user?.avatarUrl ?? 'https://i.pravatar.cc/300?img=33'),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, $name! 👋",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "$vehicle • $plate",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9DCC).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rate_rounded, color: Color(0xFFFF9DCC), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(color: Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 13),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 25),
          
          // Online Status Banner Card
          _buildOnlineStatusCard(auth, booking),
          const SizedBox(height: 25),

          // Stats Rows
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: "SALDO ANDA",
                  value: formatCurrency(auth.user?.balance ?? 0.0),
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFFFF9DCC),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildMetricCard(
                  title: "RIDES SELESAI",
                  value: "${auth.driverProfileData?['total_rides'] ?? 0} Order",
                  icon: Icons.done_all_rounded,
                  color: const Color(0xFF9D6BFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Active Ride Card
          if (booking.activeBooking != null) ...[
            Text(
              "ORDER PENDAMPINGAN AKTIF",
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            _buildActiveBookingCard(booking.activeBooking!),
            const SizedBox(height: 30),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_bike_rounded,
                      size: 64,
                      color: auth.isAvailable ? const Color(0xFFFF9DCC).withOpacity(0.3) : Colors.white12,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      auth.isAvailable 
                        ? "Menunggu order masuk..." 
                        : "Aktifkan status online untuk mulai menerima order",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
                    ),
                    if (auth.isAvailable) ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showSimulationPicker(context, booking);
                        },
                        icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF4A1031)),
                        label: Text(
                          "SIMULASI ORDER MASUK",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9DCC),
                          foregroundColor: const Color(0xFF4A1031),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: const Color(0xFFFF9DCC).withOpacity(0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOnlineStatusCard(AuthProvider auth, BookingProvider booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(24),
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
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: auth.isAvailable ? const Color(0xFF00FF7F) : Colors.red,
                  boxShadow: auth.isAvailable
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00FF7F).withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.isAvailable ? "Status: ONLINE" : "Status: OFFLINE",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    auth.isAvailable ? "Siap menerima order!" : "Aktifkan untuk mulai bekerja",
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: auth.isAvailable,
            onChanged: (val) async {
              final success = await auth.toggleAvailability();
              if (success) {
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
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white30,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBookingCard(BookingModel bookingData) {
    final clientName = bookingData.client?.fullName ?? 'Client';
    final service = bookingData.additionalDetails?['serviceType'] ?? 'antar_jemput';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DriverActiveBookingScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1B21),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(bookingData.client?.avatarUrl ?? 'https://i.pravatar.cc/300?img=12'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clientName, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(
                        service == 'antar_jemput'
                            ? 'Layanan Antar Jemput'
                            : (service == 'hangout' ? 'Layanan Hangout' : 'Freedom Request Pendamping'),
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9DCC).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bookingData.status.toUpperCase(),
                    style: const TextStyle(color: Color(0xFFFF9DCC), fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const Divider(color: Colors.white10, height: 25),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFFFF9DCC), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bookingData.pickupLocation,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bookingData.dropoffLocation,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rp ${(bookingData.totalPrice).toStringAsFixed(0)}",
                  style: const TextStyle(color: Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    Text("LIHAT DETAIL", style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 11)),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFFF9DCC), size: 16),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showIncomingRequestDialog(BookingModel request) {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF16151A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ORDER REQUEST MASUK!",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF9DCC),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("PENDING", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(request.client?.avatarUrl ?? 'https://i.pravatar.cc/300?img=12'),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.client?.fullName ?? 'Client',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          request.client?.phone ?? '+62 xxx-xxxx-xxxx',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 30),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Color(0xFFFF9DCC), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(request.pickupLocation, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.flag_rounded, color: Colors.white30, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(request.dropoffLocation, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Pembayaran (Est):", style: GoogleFonts.poppins(color: Colors.white30, fontSize: 13)),
                  Text(
                    "Rp ${(request.totalPrice).toStringAsFixed(0)}",
                    style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        bookingProvider.rejectBooking(request.id);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text("TOLAK", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF9DCC), Color(0xFFFF6B9D)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await bookingProvider.acceptBooking(request.id);
                          if (success && mounted) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DriverActiveBookingScreen()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "TERIMA",
                          style: GoogleFonts.poppins(color: const Color(0xFF4A1031), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _showSimulationPicker(BuildContext context, BookingProvider booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16151A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PILIH SIMULASI ORDER PENDAMPING",
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFF9DCC),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Simulasikan orderan masuk berdasarkan kebutuhan klien",
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 20),
              
              _simulationItem(
                context,
                icon: Icons.directions_bike_rounded,
                title: "Antar Jemput (Motor)",
                desc: "Klien: Aura Kasih • Rp 130.000",
                onTap: () {
                  booking.simulateIncomingBooking(serviceType: 'antar_jemput', useCar: false);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _simulationItem(
                context,
                icon: Icons.directions_car_rounded,
                title: "Antar Jemput (Mobil)",
                desc: "Klien: Aura Kasih • Rp 180.000",
                onTap: () {
                  booking.simulateIncomingBooking(serviceType: 'antar_jemput', useCar: true);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _simulationItem(
                context,
                icon: Icons.local_play_rounded,
                title: "Layanan Hangout (Nonton & Makan)",
                desc: "Klien: Nicholas Saputra • Rp 160.000 (3 Jam)",
                onTap: () {
                  booking.simulateIncomingBooking(serviceType: 'hangout');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _simulationItem(
                context,
                icon: Icons.volunteer_activism_rounded,
                title: "Freedom Request (Custom)",
                desc: "Klien: Pevita Pearce • Rp 220.000 (4 Jam)",
                onTap: () {
                  booking.simulateIncomingBooking(serviceType: 'freedom_request');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _simulationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1E24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9DCC).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFFF9DCC), size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}
