import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/booking_provider.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  String _selectedPeriod = 'daily'; // 'daily', 'weekly', 'monthly'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    Provider.of<BookingProvider>(context, listen: false).loadEarnings(_selectedPeriod);
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    String formatCurrency(double amount) {
      return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "Pendapatan Anda",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Monitor performa finansial dan riwayat order selesai",
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Period Chips
          Row(
            children: [
              _buildPeriodChip('daily', 'HARI INI'),
              const SizedBox(width: 8),
              _buildPeriodChip('weekly', 'MINGGU INI'),
              const SizedBox(width: 8),
              _buildPeriodChip('monthly', 'BULAN INI'),
            ],
          ),
          const SizedBox(height: 20),

          // Earnings Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E0A2D), Color(0xFF16151A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TOTAL PENDAPATAN BERSIH",
                  style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                const SizedBox(height: 10),
                Text(
                  formatCurrency(bookingProvider.totalEarnings),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const Divider(color: Colors.white10, height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TOTAL ORDER SELESAI", style: TextStyle(color: Colors.white30, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          "${bookingProvider.totalRides} Perjalanan",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFFFF9DCC), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "Tarif flat include PP",
                            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 25),

          Text(
            "RIWAYAT ORDER SELESAI",
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),

          // Completed Rides History List
          Expanded(
            child: bookingProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                    ),
                  )
                : bookingProvider.earningsBookings.isEmpty
                    ? Center(
                        child: Text(
                          "Belum ada order selesai pada periode ini",
                          style: GoogleFonts.poppins(color: Colors.white30, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: bookingProvider.earningsBookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookingProvider.earningsBookings[index];
                          final price = (booking['total_price'] ?? 0.0).toDouble();
                          final dateStr = booking['created_at'] != null 
                              ? DateTime.parse(booking['created_at']).toLocal().toString().substring(0, 10) 
                              : '-';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16151A),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.check_circle_rounded, color: Color(0xFF00FF7F), size: 20),
                                    ),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Order Pendampingan",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Selesai pada $dateStr",
                                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Text(
                                  formatCurrency(price),
                                  style: const TextStyle(color: Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period, String label) {
    bool isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9DCC) : const Color(0xFF16151A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9DCC) : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? const Color(0xFF4A1031) : Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
