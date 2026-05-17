// lib/modules/booking/screens/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_method_screen.dart'; // Import untuk navigasi ke payment

class BookingConfirmationScreen extends StatelessWidget {
  // Data booking yang diterima dari halaman sebelumnya
  final Map<String, dynamic>? bookingData;
  
  const BookingConfirmationScreen({super.key, this.bookingData});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari parameter atau gunakan default
    final driverName = bookingData?['driverName'] ?? "Bambang Wijaya";
    final driverImage = bookingData?['driverImage'] ?? 'https://i.pravatar.cc/300?img=12';
    final driverRating = bookingData?['driverRating'] ?? "4.9";
    final driverTrips = bookingData?['driverTrips'] ?? "124";
    final pickupLocation = bookingData?['pickup'] ?? "Senayan City Mall, Lobby Selatan";
    final destinationLocation = bookingData?['destination'] ?? "Bandara Internasional Soekarno-Hatta (T3)";
    final date = bookingData?['date'] ?? "Selasa, 24 Okt";
    final time = bookingData?['time'] ?? "14:30 WIB";
    final serviceFee = bookingData?['serviceFee'] ?? 250000;
    final insuranceFee = bookingData?['insuranceFee'] ?? 5000;
    final totalPayment = bookingData?['totalPayment'] ?? 255000;
    final dp = bookingData?['dp'] ?? 76500;
    final remainingPayment = bookingData?['remainingPayment'] ?? 178500;
    final estimatedTime = bookingData?['estimatedTime'] ?? "45";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Konfirmasi Booking",
          style: GoogleFonts.poppins(
            color: const Color(0xFFFF9DCC),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: const Icon(Icons.receipt_long_outlined, color: Color(0xFFFF9DCC), size: 20),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildDriverCard(driverName, driverImage, driverRating, driverTrips),
            const SizedBox(height: 15),
            _buildMapRouteSection(estimatedTime),
            const SizedBox(height: 15),
            _buildLocationCard(pickupLocation, destinationLocation),
            const SizedBox(height: 15),
            _buildServiceDetailCard(date, time, serviceFee),
            const SizedBox(height: 15),
            _buildPaymentSummaryCard(totalPayment, dp, remainingPayment),
            const SizedBox(height: 30),
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(String name, String image, String rating, String trips) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B21),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(image, width: 70, height: 70, fit: BoxFit.cover),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFF9DCC), borderRadius: BorderRadius.circular(4)),
                child: const Text("ELITE", style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFF9DCC), size: 14),
                    const SizedBox(width: 4),
                    Text("$rating ($trips Perjalanan)", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge("SUV Black"),
                    const SizedBox(width: 8),
                    _buildBadge("Vaksin Lengkap"),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
    );
  }

  Widget _buildMapRouteSection(String estimatedTime) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://i.stack.imgur.com/HILX3.png'),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 15,
            left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFF9DCC).withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFFFF9DCC), size: 14),
                  const SizedBox(width: 6),
                  Text("Est. $estimatedTime Menit", style: const TextStyle(color: Color(0xFFFF9DCC), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLocationCard(String pickup, String destination) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF16151A), borderRadius: BorderRadius.circular(20)),
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

  Widget _buildServiceDetailCard(String date, String time, int serviceFee) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF16151A), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Detail Layanan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildInfoBox("TANGGAL", date)),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoBox("WAKTU", time)),
            ],
          ),
          const SizedBox(height: 20),
          _priceItem("Layanan Temenin Antar", "Rp ${serviceFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}"),
          _priceItem("Biaya Tol & Parkir", "Termasuk"),
          _priceItem("Asuransi Premium", "Rp 5.000"),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _priceItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5))),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(int totalPayment, int dp, int remainingPayment) {
    // Format currency
    String formatCurrency(int amount) {
      return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF16151A), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Pembayaran", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(formatCurrency(totalPayment), style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const Divider(color: Colors.white10, height: 25),
          _priceItem("DP (30%)", formatCurrency(dp)),
          _priceItem("Sisa Bayar di Tujuan", formatCurrency(remainingPayment)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // ✅ Navigasi ke halaman payment method
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentMethodScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9DCC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
            child: const Text(
              "Konfirmasi & Bayar DP",
              style: TextStyle(color: Color(0xFF4A1031), fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              // ✅ Kembali ke halaman sebelumnya
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF9DCC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
            child: const Text(
              "Ubah Jadwal",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ),
      ],
    );
  }
}