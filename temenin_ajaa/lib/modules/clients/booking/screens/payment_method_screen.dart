// lib/modules/booking/screens/payment_method_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../providers/auth_provider.dart';
import 'tracking_driver_screen.dart'; // Import untuk navigasi ke tracking

class PaymentMethodScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingData;
  
  const PaymentMethodScreen({super.key, this.bookingData});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedMethod = "visa";
  
  // Data pembayaran dari booking sebelumnya
  late int totalPayment;
  late int dpAmount;
  
  @override
  void initState() {
    super.initState();
    // Ambil data dari parameter atau gunakan default
    totalPayment = widget.bookingData?['totalPayment'] ?? 250000;
    dpAmount = widget.bookingData?['dp'] ?? 125000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C11),
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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTotalPaymentCard(),
                      const SizedBox(height: 30),
                    
                    _buildSectionTitle("Saved Methods"),
                    const SizedBox(height: 15),
                    _buildPaymentTile(
                      id: "visa",
                      icon: Icons.credit_card_rounded,
                      title: "Visa ending in 1234",
                      subtitle: "Expires 12/26",
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentTile(
                      id: "gopay",
                      icon: Icons.account_balance_wallet_rounded,
                      title: "GoPay",
                      subtitle: "Rp 1.250.000",
                      isPriceSubtitle: true,
                    ),
                    
                    const SizedBox(height: 30),
                    _buildSectionTitle("Other Methods"),
                    const SizedBox(height: 15),
                    
                    _buildSubCategory("VIRTUAL ACCOUNTS"),
                    _buildPaymentTile(
                      id: "bca", 
                      title: "BCA Virtual Account", 
                      isSimple: true, 
                      logoText: "BCA"
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentTile(
                      id: "mandiri", 
                      title: "Mandiri Virtual Account", 
                      isSimple: true, 
                      logoText: "MDR"
                    ),
                    
                    const SizedBox(height: 20),
                    _buildSubCategory("E-WALLETS"),
                    _buildPaymentTile(
                      id: "ovo", 
                      icon: Icons.account_balance_wallet_outlined, 
                      title: "OVO", 
                      isSimple: true
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentTile(
                      id: "dana", 
                      icon: Icons.account_balance_rounded, 
                      title: "Dana", 
                      isSimple: true
                    ),
                    
                    const SizedBox(height: 20),
                    _buildSubCategory("CREDIT / DEBIT CARDS"),
                    _buildPaymentTile(
                      id: "new_card", 
                      icon: Icons.add_card_rounded, 
                      title: "Credit or Debit Card", 
                      isSimple: true
                    ),
                    
                    const SizedBox(height: 25),
                    _buildPromoCodeField(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
     ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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

  Widget _buildTotalPaymentCard() {
    // Format currency
    String formatCurrency(int amount) {
      return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOTAL PEMBAYARAN", 
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.5), 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1
                ),
              ),
              const SizedBox(height: 5),
              Text(
                formatCurrency(totalPayment), 
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFF9DCC), 
                  fontSize: 32, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "DP yang dibayarkan: ${formatCurrency(dpAmount)}",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFFF9DCC)),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title, 
      style: GoogleFonts.poppins(
        color: Colors.white, 
        fontSize: 18, 
        fontWeight: FontWeight.bold
      ),
    );
  }

  Widget _buildSubCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title, 
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.4), 
          fontSize: 10, 
          fontWeight: FontWeight.w800, 
          letterSpacing: 1
        ),
      ),
    );
  }

  Widget _buildPaymentTile({
    required String id,
    IconData? icon,
    required String title,
    String? subtitle,
    bool isPriceSubtitle = false,
    bool isSimple = false,
    String? logoText,
  }) {
    bool isSelected = selectedMethod == id;

    return GestureDetector(
      onTap: () => setState(() => selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16151A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9DCC).withOpacity(0.5) : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: logoText != null
                  ? Center(
                      child: Text(
                        logoText, 
                        style: const TextStyle(
                          color: Color(0xFF3282B8), 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12
                        ),
                      ),
                    )
                  : Icon(
                      icon, 
                      color: isSelected ? const Color(0xFFFF9DCC) : Colors.white38, 
                      size: 22
                    ),
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
                      fontWeight: FontWeight.w500, 
                      fontSize: 14
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle, 
                      style: GoogleFonts.poppins(
                        color: isPriceSubtitle ? const Color(0xFFFF9DCC) : Colors.white.withOpacity(0.3), 
                        fontSize: 11
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF9DCC) : Colors.white12, 
                  width: 2
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10, 
                        height: 10, 
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF9DCC), 
                          shape: BoxShape.circle
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard_rounded, color: Color(0xFFFF9DCC), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Have a promo code?",
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
            ),
          ),
          Text(
            "APPLY", 
            style: GoogleFonts.poppins(
              color: const Color(0xFFFF9DCC), 
              fontWeight: FontWeight.bold, 
              fontSize: 12
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    String formatCurrency(int amount) {
      return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    }

    return Container(
      color: const Color(0xFF0B090E), // Match the bottom of the gradient background
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9DCC).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                // Show loading progress dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                    ),
                  ),
                );

                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final userId = authProvider.user?.id;
                
                final random = Random();
                final otpPin = (random.nextInt(9000) + 1000).toString();
                final bookingDetails = Map<String, dynamic>.from(widget.bookingData ?? {});
                bookingDetails['otp'] = otpPin;

                String bookingId = 'mock-booking-id';
                try {
                  final response = await Supabase.instance.client.from('bookings').insert({
                    'user_id': userId ?? '33333333-3333-3333-3333-111111111111', 
                    'driver_id': bookingDetails['driverId'],
                    'status': 'pending',
                    'pickup_location': bookingDetails['pickup'],
                    'dropoff_location': bookingDetails['destination'],
                    'total_price': bookingDetails['totalPayment'],
                    'additional_details': bookingDetails,
                  }).select('id').single();
                  
                  bookingId = response['id'] as String;
                  debugPrint('✅ Booking created in database: $bookingId');
                } catch (e) {
                  debugPrint('⚠️ DB insert failed, using mock booking ID. Error: $e');
                }

                // Close loading dialog
                if (context.mounted) {
                  Navigator.pop(context);
                }

                // ✅ Navigasi ke halaman tracking driver
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackingDriverScreen(
                        bookingData: bookingDetails,
                        paymentMethod: selectedMethod,
                        bookingId: bookingId,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                "Bayar DP ${formatCurrency(dpAmount)}",
                style: const TextStyle(
                  color: Color(0xFF4A1031),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, color: Colors.white.withOpacity(0.4), size: 14),
              const SizedBox(width: 6),
              Text(
                "Secure SSL Encrypted Payment",
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
            ],
          )
        ],
      ),
    );
  }
}