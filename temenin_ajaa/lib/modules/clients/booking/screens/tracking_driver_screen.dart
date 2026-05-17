// lib/modules/booking/screens/tracking_driver_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrackingDriverScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingData;
  final String? paymentMethod;
  
  const TrackingDriverScreen({super.key, this.bookingData, this.paymentMethod});

  @override
  State<TrackingDriverScreen> createState() => _TrackingDriverScreenState();
}

class _TrackingDriverScreenState extends State<TrackingDriverScreen> {
  // Timer untuk update waktu estimasi
  int _remainingSeconds = 240; // 4 menit = 240 detik
  String _estimatedTime = "Arriving in 4 mins";
  String _countdownTimer = "00:04:00";
  
  @override
  void initState() {
    super.initState();
    // Mulai timer countdown
    _startTimer();
  }
  
  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          
          // Update estimated time text
          if (_remainingSeconds > 60) {
            int minutes = _remainingSeconds ~/ 60;
            _estimatedTime = "Arriving in $minutes mins";
          } else if (_remainingSeconds > 0) {
            _estimatedTime = "Arriving in $_remainingSeconds seconds";
          } else {
            _estimatedTime = "Arrived!";
          }
          
          // Update countdown timer format
          int hours = _remainingSeconds ~/ 3600;
          int minutes = (_remainingSeconds % 3600) ~/ 60;
          int seconds = _remainingSeconds % 60;
          _countdownTimer = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
          
          _startTimer();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dari parameter atau gunakan default
    final driverName = widget.bookingData?['driverName'] ?? "Bambang Wijaya";
    final driverImage = widget.bookingData?['driverImage'] ?? 'https://i.pravatar.cc/300?img=12';
    final driverRating = widget.bookingData?['driverRating'] ?? "4.9";
    final driverTrips = widget.bookingData?['driverTrips'] ?? "124";
    final vehicle = widget.bookingData?['vehicle'] ?? "Toyota Alphard";
    final plateNumber = widget.bookingData?['plateNumber'] ?? "B 1234 TAA";
    final pickupLocation = widget.bookingData?['pickup'] ?? "Senayan City Mall, Lobby Selatan";
    final destinationLocation = widget.bookingData?['destination'] ?? "Bandara Internasional Soekarno-Hatta (T3)";
    final totalPayment = widget.bookingData?['totalPayment'] ?? 255000;
    final remainingPayment = widget.bookingData?['remainingPayment'] ?? 178500;
    final paymentMethod = widget.paymentMethod ?? "BCA Virtual Account";
    
    // Format payment method display
    String getPaymentMethodDisplay(String method) {
      switch (method) {
        case "visa": return "Visa •••• 1234";
        case "gopay": return "GoPay";
        case "bca": return "BCA Virtual Account";
        case "mandiri": return "Mandiri Virtual Account";
        case "ovo": return "OVO";
        case "dana": return "Dana";
        default: return method;
      }
    }
    
    // Format currency
    String formatCurrency(int amount) {
      return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      body: Stack(
        children: [
          // Background: Map Placeholder
          _buildMapBackground(),

          // Overlay Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildArrivingCard(
                          driverName: driverName,
                          driverImage: driverImage,
                          driverRating: driverRating,
                          vehicle: vehicle,
                          plateNumber: plateNumber,
                          estimatedTime: _estimatedTime,
                          countdownTimer: _countdownTimer,
                        ),
                        const SizedBox(height: 15),
                        _buildBookingStatusCard(),
                        const SizedBox(height: 15),
                        _buildLocationCard(pickupLocation, destinationLocation),
                        const SizedBox(height: 15),
                        _buildPaymentSummaryCard(
                          totalPayment: totalPayment,
                          remainingPayment: remainingPayment,
                          paymentMethod: getPaymentMethodDisplay(paymentMethod),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://i.stack.imgur.com/HILX3.png'),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Kembali ke halaman utama (HomeLoggedInScreen)
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Text(
            "Temenin Ajaa",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF9DCC),
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=11'),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivingCard({
    required String driverName,
    required String driverImage,
    required String driverRating,
    required String vehicle,
    required String plateNumber,
    required String estimatedTime,
    required String countdownTimer,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "ON THE WAY",
                  style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.access_time_rounded, color: Color(0xFFFF9DCC), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            estimatedTime,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDurationBadge(countdownTimer),
          const SizedBox(height: 20),
          _buildDriverInfo(
            driverName: driverName,
            driverImage: driverImage,
            driverRating: driverRating,
            vehicle: vehicle,
            plateNumber: plateNumber,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: "Chat Driver",
                  color: const Color(0xFFFF9DCC),
                  textColor: const Color(0xFF4A1031),
                  onPressed: () {
                    // TODO: Buka chat dengan driver
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur chat akan segera hadir")),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.emergency_share_outlined,
                  label: "Emergency",
                  color: const Color(0xFF2C2226),
                  textColor: const Color(0xFFFF9DCC),
                  isOutline: true,
                  onPressed: () {
                    // TODO: Emergency contact
                    _showEmergencyDialog();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDurationBadge(String timer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9DCC).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFFFF9DCC), size: 14),
          const SizedBox(width: 8),
          Text(
            timer,
            style: GoogleFonts.shareTechMono(color: const Color(0xFFFF9DCC), fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo({
    required String driverName,
    required String driverImage,
    required String driverRating,
    required String vehicle,
    required String plateNumber,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(driverImage),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(driverName, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFF9DCC), size: 14),
                        const SizedBox(width: 4),
                        Text(driverRating, style: TextStyle(color: const Color(0xFFFF9DCC).withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Text("$vehicle • $plateNumber", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    bool isOutline = false,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: isOutline ? Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.3)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BOOKING STATUS", style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 20),
          _buildTimelineItem("DP Paid", "10:15 AM", true, true),
          _buildTimelineItem("Accepted", "10:18 AM", true, true),
          _buildTimelineItem("On The Way", "Driver is moving to your location", false, true, isActive: true),
          _buildTimelineItem("Started", "", false, false, isFuture: true),
          _buildTimelineItem("Completed", "", false, false, isFuture: true, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isDone, bool hasLine, {bool isActive = false, bool isFuture = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? const Color(0xFFFF9DCC) : (isActive ? Colors.transparent : Colors.transparent),
                border: isActive ? Border.all(color: const Color(0xFFFF9DCC), width: 2) : (isFuture ? Border.all(color: Colors.white10, width: 2) : null),
              ),
              child: isDone 
                ? const Icon(Icons.check, size: 14, color: Color(0xFF4A1031)) 
                : (isActive ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF9DCC), shape: BoxShape.circle))) : null),
            ),
            if (!isLast) Container(width: 2, height: 40, color: isDone ? const Color(0xFFFF9DCC) : Colors.white10),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(color: isFuture ? Colors.white24 : (isDone || isActive ? const Color(0xFFFF9DCC) : Colors.white), fontWeight: FontWeight.bold, fontSize: 15)),
              if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(String pickup, String destination) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _locationRow(const Color(0xFFFF9DCC), "PENJEMPUTAN", pickup),
          const SizedBox(height: 20),
          _locationRow(Colors.white38, "TUJUAN", destination),
        ],
      ),
    );
  }

  Widget _locationRow(Color color, String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10, 
              height: 10, 
              decoration: BoxDecoration(
                color: color, 
                shape: label == "TUJUAN" ? BoxShape.rectangle : BoxShape.circle
              ),
            ),
            if (label == "PENJEMPUTAN") 
              Container(width: 1, height: 30, color: Colors.white10),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3), 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1
                ),
              ),
              Text(
                address, 
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPaymentSummaryCard({
    required int totalPayment,
    required int remainingPayment,
    required String paymentMethod,
  }) {
    String formatCurrency(int amount) {
      return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFFF9DCC)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Fare", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    Text(formatCurrency(totalPayment), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text("Sisa Bayar", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                    Text(formatCurrency(remainingPayment), style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Payment", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    Text(paymentMethod, textAlign: TextAlign.right, style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16151A),
        title: Text(
          "Emergency Contact",
          style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Hubungi tim keamanan kami di:\n\n📞 +62 812 3456 7890\n📧 emergency@temeninajaa.com",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC)),
            ),
          ),
        ],
      ),
    );
  }
}