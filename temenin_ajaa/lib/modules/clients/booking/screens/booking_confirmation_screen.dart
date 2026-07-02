// lib/modules/booking/screens/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_method_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic>? bookingData;
  
  const BookingConfirmationScreen({super.key, this.bookingData});

  @override
  Widget build(BuildContext context) {
    final driverName = bookingData?['driverName'] ?? "Dian Sastro";
    final driverImage = bookingData?['driverImage'] ?? 'https://i.pravatar.cc/300?img=14';
    final driverRating = bookingData?['driverRating'] ?? "4.9";
    final driverTrips = bookingData?['driverTrips'] ?? "450";
    final pickupLocation = bookingData?['pickup'] ?? "Senayan City Mall, Lobby Selatan";
    final destinationLocation = bookingData?['destination'] ?? "Bandara Internasional Soekarno-Hatta (T3)";
    final date = bookingData?['date'] ?? "Selasa, 24 Okt";
    final time = bookingData?['time'] ?? "14:30 WIB";
    final serviceType = bookingData?['serviceType'] ?? "antar_jemput";
    final driverClass = bookingData?['driverClass'] ?? "Gold";
    final vehicle = bookingData?['vehicle'] ?? "Vespa Primavera";
    final plateNumber = bookingData?['plateNumber'] ?? "B 1234 DS";

    // Pricing
    final serviceFee = bookingData?['serviceFee'] ?? 120000;
    final insuranceFee = bookingData?['insuranceFee'] ?? 10000;
    final totalPayment = bookingData?['totalPayment'] ?? 130000;
    final dp = bookingData?['dp'] ?? 65000;
    final remainingPayment = bookingData?['remainingPayment'] ?? 65000;
    final estimatedTime = bookingData?['estimatedTime'] ?? "45";

    // Multi-Layanan
    final hasAdditional = bookingData?['hasAdditionalService'] ?? false;
    final additionalType = bookingData?['additionalServiceType'] ?? '';
    final additionalFee = bookingData?['additionalServiceFee'] ?? 0;

    // Addons
    final useCar = bookingData?['useCar'] ?? false;
    final rentHelmet = bookingData?['rentHelmet'] ?? false;
    final differentArea = bookingData?['differentArea'] ?? false;
    final pulangPergi = bookingData?['pulangPergi'] ?? false;
    final weekendFee = bookingData?['weekendFee'] ?? 0;


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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF190C28), // Sleek deep purple glow
              Color(0xFF0B090E), // Ultra clean dark black
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildDriverCard(driverName, driverImage, driverRating, driverTrips, driverClass, vehicle, plateNumber),
                const SizedBox(height: 15),
                _buildMapRouteSection(estimatedTime),
                const SizedBox(height: 15),
                _buildLocationCard(pickupLocation, destinationLocation, serviceType, bookingData?['description']),
                const SizedBox(height: 15),
                
                // If Multi-Layanan Antar Jemput, show its location card
                if (bookingData?['hasAntarJemput'] == true) ...[
                  _buildAdditionalServiceCard('antar_jemput', bookingData?['serviceAntarJemputFee'] ?? 0, bookingData),
                  const SizedBox(height: 15),
                ],
                // If Multi-Layanan Hangout, show its hangout card
                if (bookingData?['hasHangout'] == true) ...[
                  _buildAdditionalServiceCard('hangout', bookingData?['serviceHangoutFee'] ?? 0, bookingData),
                  const SizedBox(height: 15),
                ],
                
                _buildServiceDetailCard(
                  date, 
                  time, 
                  serviceFee, 
                  insuranceFee, 
                  bookingData?['hasAntarJemput'] == true,
                  bookingData?['serviceAntarJemputFee'] ?? 0,
                  bookingData?['hasHangout'] == true,
                  bookingData?['serviceHangoutFee'] ?? 0,
                  useCar, 
                  rentHelmet, 
                  differentArea, 
                  pulangPergi, 
                  weekendFee,
                ),
                const SizedBox(height: 15),
                _buildPaymentSummaryCard(totalPayment, dp, remainingPayment),
                const SizedBox(height: 30),
                _buildActionButtons(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverCard(String name, String image, String rating, String trips, String driverClass, String vehicle, String plateNumber) {
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
                child: Image.network(image, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 70, height: 70, color: Colors.grey[800], child: const Icon(Icons.person))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFFF9DCC), borderRadius: BorderRadius.circular(4)),
                child: Text(driverClass, style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
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
                    Text("$rating ($trips Order)", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge(vehicle),
                    const SizedBox(width: 8),
                    _buildBadge(plateNumber),
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
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://i.stack.imgur.com/HILX3.png'),
          fit: BoxFit.cover,
          opacity: 0.3,
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

  Widget _buildLocationCard(String pickup, String destination, String type, String? description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF16151A), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                type == 'antar_jemput' 
                    ? Icons.car_rental_rounded 
                    : type == 'hangout' 
                        ? Icons.people_alt_rounded 
                        : Icons.explore_rounded,
                color: const Color(0xFFFF9DCC),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                type == 'antar_jemput' 
                    ? "Rute Antar Jemput" 
                    : type == 'hangout' 
                        ? "Lokasi Hangout" 
                        : "Freedom Request Detail",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (type == 'freedom_request' && description != null && description.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
              child: Text(
                "Request: \"$description\"",
                style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 15),
          ],
          _locationRow(const Color(0xFFFF9DCC), "LOKASI AWAL", pickup),
          const SizedBox(height: 20),
          _locationRow(Colors.white38, "LOKASI TUJUAN", destination),
        ],
      ),
    );
  }

  Widget _buildAdditionalServiceCard(String type, int fee, Map<String, dynamic>? data) {
    final pickup = data?['additionalPickup'] ?? '';
    final dest = data?['additionalDestination'] ?? '';
    final activity = data?['additionalActivity'] ?? '';
    final duration = data?['additionalDuration'] ?? '3';
    
    // Antar Jemput additional details
    final pickupDate = data?['additionalPickupDate'] ?? '';
    final pickupTime = data?['additionalPickupTime'] ?? '';
    final ajNotes = data?['additionalAntarJemputNotes'] ?? '';

    // Hangout additional details
    final hangoutLoc = data?['additionalHangoutLocation'] ?? '';
    final hangoutDate = data?['additionalHangoutDate'] ?? '';
    final hangoutTime = data?['additionalHangoutTime'] ?? '';
    final hgNotes = data?['additionalHangoutNotes'] ?? '';

    String fmt(int amount) {
      return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle_outline_rounded, color: Color(0xFFFF9DCC), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    type == 'hangout' ? "Layanan Tambahan: Hangout" : "Layanan Tambahan: Antar Jemput",
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Text(
                fmt(fee),
                style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (type == 'hangout') ...[
            Text("Aktivitas: $activity ($duration Jam)", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _locationRow(const Color(0xFFFF9DCC), "LOKASI HANGOUT", hangoutLoc.isNotEmpty ? hangoutLoc : "Sesuai rute utama"),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 14),
                const SizedBox(width: 6),
                Text("$hangoutDate, pukul $hangoutTime", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            if (hgNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text("Catatan: \"$hgNotes\"", style: TextStyle(color: Colors.white.withOpacity(0.4), fontStyle: FontStyle.italic, fontSize: 11)),
            ],
          ] else if (type == 'antar_jemput') ...[
            _locationRow(const Color(0xFFFF9DCC), "JEMPUT", pickup),
            const SizedBox(height: 15),
            _locationRow(Colors.white38, "ANTAR", dest),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 14),
                const SizedBox(width: 6),
                Text("$pickupDate, pukul $pickupTime", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            if (ajNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text("Catatan: \"$ajNotes\"", style: TextStyle(color: Colors.white.withOpacity(0.4), fontStyle: FontStyle.italic, fontSize: 11)),
            ],
          ],
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
              width: 8, 
              height: 8, 
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              Text(
                address, 
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildServiceDetailCard(
    String date,
    String time,
    int serviceFee,
    int insuranceFee,
    bool hasAntarJemput,
    int antarJemputFee,
    bool hasHangout,
    int hangoutFee,
    bool useCar,
    bool rentHelmet,
    bool differentArea,
    bool pulangPergi,
    int weekendFee,
  ) {
    String fmt(int amount) {
      return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

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
          _priceItem("Layanan Utama", fmt(serviceFee)),
          if (hasAntarJemput) 
            _priceItem("Layanan Tambahan (Antar Jemput)", fmt(antarJemputFee)),
          if (hasHangout) 
            _priceItem("Layanan Tambahan (Hangout Partner)", fmt(hangoutFee)),
          if (pulangPergi) _priceItem("Opsi Pulang Pergi (PP)", "Termasuk rute ganda"),
          if (useCar) _priceItem("Add-on: Mobil", fmt(50000)),
          if (rentHelmet) _priceItem("Add-on: Helm Ekstra", fmt(10000)),
          if (differentArea) _priceItem("Add-on: Beda Area", fmt(20000)),
          if (weekendFee > 0) _priceItem("Weekend Fee (+25%)", fmt(weekendFee)),
          _priceItem("Asuransi Premium", fmt(insuranceFee)),
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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
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
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(int totalPayment, int dp, int remainingPayment) {
    String formatCurrency(int amount) {
      return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.15)),
      ),
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
          _priceItem("DP Wajib (50% x Total)", formatCurrency(dp)),
          _priceItem("Sisa Pelunasan di Tujuan", formatCurrency(remainingPayment)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF9DCC),
                Color(0xFFFF6B9D),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9DCC).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentMethodScreen(bookingData: bookingData),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
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
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF9DCC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
            child: const Text(
              "Ubah Jadwal / Pesanan",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ),
      ],
    );
  }
}