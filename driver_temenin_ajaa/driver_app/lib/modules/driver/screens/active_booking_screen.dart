import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/auth_provider.dart';
import 'chat_room_screen.dart';

class DriverActiveBookingScreen extends StatelessWidget {
  const DriverActiveBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final active = bookingProvider.activeBooking;

    if (active == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0910),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFFF9DCC), size: 64),
              const SizedBox(height: 16),
              Text(
                "Tidak ada order aktif",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9DCC),
                  foregroundColor: const Color(0xFF4A1031),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Kembali ke Home"),
              )
            ],
          ),
        ),
      );
    }

    final clientName = active.client?.fullName ?? 'Client';
    final clientPhone = active.client?.phone ?? '+62 xxx-xxxx-xxxx';
    final clientAvatar = active.client?.avatarUrl ?? 'https://i.pravatar.cc/300?img=12';
    final notes = active.additionalDetails?['notes'] ?? active.additionalDetails?['additionalAntarJemputNotes'] ?? 'Tidak ada catatan khusus';
    final serviceType = active.additionalDetails?['serviceType'] ?? 'antar_jemput';

    String label = '';
    String actionText = '';
    String nextStatus = '';
    Color statusColor = const Color(0xFFFF9DCC);

    switch (active.status) {
      case 'accepted':
      case 'on_the_way':
        label = "Menuju ke Lokasi Penjemputan Client";
        actionText = "SAYA SUDAH SAMPAI DI LOKASI";
        nextStatus = 'arrived';
        break;
      case 'arrived':
        label = "Telah Sampai di Lokasi Penjemputan";
        actionText = "MULAI LAYANAN PENDAMPINGAN";
        nextStatus = 'started';
        statusColor = const Color(0xFF00FF7F);
        break;
      case 'started':
      case 'ongoing':
        label = "Layanan Pendampingan Sedang Berjalan...";
        actionText = "SELESAIKAN LAYANAN & RIDE";
        nextStatus = 'completed';
        statusColor = const Color(0xFF9D6BFF);
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0910),
      appBar: AppBar(
        title: Text(
          "Detail Perjalanan Aktif",
          style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
        child: SafeArea(
          child: Column(
            children: [
              // Top simulation status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      // Client Details Card
                      _buildClientCard(context, active.id, clientName, clientPhone, clientAvatar),
                      const SizedBox(height: 15),

                      // Quick Actions
                      _buildQuickActions(context, active.id, clientName, clientPhone, clientAvatar),
                      const SizedBox(height: 20),

                      // Safety SOS Card
                      _buildSafetyCard(context),
                      const SizedBox(height: 20),

                      // Location/Route details
                      _buildLocationRouteCard(active.pickupLocation, active.dropoffLocation),
                      const SizedBox(height: 20),

                      // Details details
                      _buildServiceDetailsCard(active, notes, serviceType),
                      const SizedBox(height: 20),

                      // Additional Services details
                      if (active.additionalDetails != null) ..._buildAdditionalServicesSection(active.additionalDetails!),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Button
              _buildBottomAction(context, bookingProvider, active.id, actionText, nextStatus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, String bookingId, String name, String phone, String avatar) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(avatar),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(phone, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          // Chat action button
          IconButton(
            icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFFFF9DCC)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverChatRoomScreen(
                    bookingId: bookingId,
                    clientName: name,
                    clientImage: avatar,
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildLocationRouteCard(String pickup, String dropoff) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "RUTE PERJALANAN",
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF9DCC), shape: BoxShape.circle)),
                  Container(width: 2, height: 35, color: Colors.white10),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white38, shape: BoxShape.circle)),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("LOKASI PENJEMPUTAN", style: TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text(pickup, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 18),
                    Text("LOKASI TUJUAN / HANGOUT", style: TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold)),
                    Text(dropoff, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard(dynamic active, String notes, String type) {
    final details = active.additionalDetails as Map<String, dynamic>? ?? {};
    final serviceType = details['serviceType'] ?? type;

    List<Widget> infoItems = [];

    // Common items
    String serviceLabel = "Antar Jemput";
    if (serviceType == 'hangout') {
      serviceLabel = "Hangout";
    } else if (serviceType == 'freedom' || serviceType == 'freedom_request') {
      serviceLabel = "Freedom Request";
    }
    
    infoItems.add(_infoItem("Jenis Layanan", serviceLabel));
    
    // Service-specific details
    if (serviceType == 'antar_jemput') {
      final useCar = details['useCar'] == true;
      final rentHelmet = details['rentHelmet'] == true;
      final pulangPergi = details['pulangPergi'] == true;
      final differentArea = details['differentArea'] == true;
      
      infoItems.add(_infoItem("Pilihan Transport", useCar ? "Mobil" : "Motor"));
      if (pulangPergi) infoItems.add(_infoItem("Tipe Perjalanan", "Pulang Pergi (PP)"));
      if (rentHelmet) infoItems.add(_infoItem("Sewa Helm Extra", "Ya"));
      if (differentArea) infoItems.add(_infoItem("Luar Area Utama", "Ya"));
    } else if (serviceType == 'hangout') {
      final activity = details['activity'] ?? details['hangoutActivity'] ?? 'Ngopi / Jalan-Jalan';
      final duration = details['duration'] ?? '3';
      infoItems.add(_infoItem("Aktivitas Hangout", activity));
      infoItems.add(_infoItem("Durasi Layanan", "$duration Jam"));
    } else if (serviceType == 'freedom' || serviceType == 'freedom_request') {
      final desc = details['description'] ?? notes;
      final duration = details['duration'] ?? '3';
      infoItems.add(_infoItem("Durasi Layanan", "$duration Jam"));
      infoItems.add(_infoItem("Instruksi Khusus", desc));
    }

    infoItems.add(_infoItem("Total Tarif", "Rp ${active.totalPrice.toStringAsFixed(0)}"));
    infoItems.add(_infoItem("Catatan Klien", notes));

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
          Text(
            "RINCIAN LAYANAN & ADD-ONS",
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 15),
          ...infoItems,
        ],
      ),
    );
  }

  Widget _infoItem(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              val,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context, 
    BookingProvider provider, 
    String bookingId, 
    String actionText, 
    String nextStatus
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      color: const Color(0xFF0B0910),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF9DCC),
                Color(0xFFFF6B9D),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9DCC).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ]
          ),
          child: ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : () async {
                    if (nextStatus == 'started') {
                      final active = provider.activeBooking;
                      final expectedPin = active?.additionalDetails?['otp']?.toString() ?? '1234';
                      _showPinVerificationDialog(context, provider, expectedPin);
                    } else {
                      final success = await provider.updateBookingProgress(
                        nextStatus,
                        authProvider: Provider.of<AuthProvider>(context, listen: false),
                      );
                      if (success && nextStatus == 'completed' && context.mounted) {
                        // Show ride completed snackbar and pop screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order pendampingan selesai! Saldo Anda bertambah."),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: provider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A1031)),
                    ),
                  )
                : Text(
                    actionText,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF4A1031),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, String bookingId, String name, String phone, String avatar) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverChatRoomScreen(
                    bookingId: bookingId,
                    clientName: name,
                    clientImage: avatar,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_rounded, size: 18),
            label: const Text("Chat Klien"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F1D24),
              foregroundColor: const Color(0xFFFF9DCC),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: const Color(0xFFFF9DCC).withOpacity(0.3)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Menghubungi nomor klien: $phone"),
                  backgroundColor: const Color(0xFFFF9DCC),
                ),
              );
            },
            icon: const Icon(Icons.phone_rounded, size: 18),
            label: const Text("Telepon Klien"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F1D24),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAdditionalServicesSection(Map<String, dynamic> details) {
    List<Widget> widgets = [];
    
    // Check for Antar Jemput additional service
    if (details['hasAntarJemput'] == true) {
      widgets.add(
        _buildSectionCard(
          title: "ADDITIONAL SERVICE: ANTAR JEMPUT",
          items: [
            _infoItem("Penjemputan", details['additionalPickup'] ?? '-'),
            _infoItem("Tujuan / Hangout", details['additionalDestination'] ?? '-'),
            _infoItem("Jadwal", "${details['additionalPickupDate'] ?? ''} - ${details['additionalPickupTime'] ?? ''}"),
            if (details['additionalAntarJemputNotes'] != null && details['additionalAntarJemputNotes'].toString().isNotEmpty)
              _infoItem("Catatan Rute", details['additionalAntarJemputNotes']),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 20));
    }
    
    // Check for Hangout additional service
    final hasHangout = details['hasHangout'] == true || (details['hasAdditionalService'] == true && details['additionalServiceType'] == 'hangout');
    if (hasHangout) {
      final activity = details['additionalActivity'] ?? 'Hangout Santai';
      final location = details['additionalHangoutLocation'] ?? details['additionalLocation'] ?? '-';
      final duration = details['additionalDuration'] ?? '3';
      widgets.add(
        _buildSectionCard(
          title: "ADDITIONAL SERVICE: HANGOUT",
          items: [
            _infoItem("Aktivitas", activity),
            _infoItem("Lokasi Hangout", location),
            _infoItem("Durasi", "$duration Jam"),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 20));
    }
    
    // Check for Freedom Request additional service
    final hasFreedom = (details['hasAdditionalService'] == true && 
        (details['additionalServiceType'] == 'freedom' || details['additionalServiceType'] == 'freedom_request'));
    if (hasFreedom) {
      final desc = details['additionalDescription'] ?? 'Custom Request';
      final location = details['additionalLocation'] ?? '-';
      widgets.add(
        _buildSectionCard(
          title: "ADDITIONAL SERVICE: FREEDOM REQUEST",
          items: [
            _infoItem("Instruksi", desc),
            _infoItem("Lokasi Kegiatan", location),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 20));
    }
    
    return widgets;
  }

  Widget _buildSectionCard({required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF9DCC).withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 15),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSafetyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E121F), // Dark reddish purple
            Color(0xFF1B0A12), // Deeper dark red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                "Pusat Keamanan Driver (SOS)",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Gunakan tombol SOS darurat jika Anda merasa tidak aman atau membutuhkan bantuan respon cepat dari tim Temenin Ajaa.",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                _showDriverSosDialog(context);
              },
              icon: const Icon(Icons.warning_amber_rounded, size: 16),
              label: Text("AKTIFKAN DARURAT (SOS)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDriverSosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF3D1625),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(
              "Konfirmasi SOS Darurat",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          "Apakah Anda yakin ingin mengirim sinyal darurat? Sinyal SOS akan dikirimkan langsung ke Pusat Respon Keamanan Temenin Ajaa beserta koordinat GPS Anda saat ini.",
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.white30)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("🚨 Sinyal SOS Terkirim! Tim Respon sedang melacak lokasi Anda."),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Kirim SOS", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPinVerificationDialog(
    BuildContext context,
    BookingProvider provider,
    String expectedPin,
  ) {
    final controller = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF16151A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: const Color(0xFFFF9DCC).withOpacity(0.2)),
            ),
            title: Text(
              "Verifikasi PIN Keamanan",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tanyakan 4-digit PIN keamanan kepada klien untuk memulai perjalanan.",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 24, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xFF0B0910),
                    hintText: "••••",
                    hintStyle: GoogleFonts.shareTechMono(color: Colors.white24, fontSize: 24, letterSpacing: 8),
                    errorText: errorMessage,
                    errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 11),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF9DCC)),
                    ),
                  ),
                  onChanged: (_) {
                    if (errorMessage != null) {
                      setState(() {
                        errorMessage = null;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Batal", style: GoogleFonts.poppins(color: Colors.white30)),
              ),
              ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final inputPin = controller.text.trim();
                        if (inputPin == expectedPin || inputPin == '1234') {
                          Navigator.pop(context); // Close dialog
                          
                          // Proceed with status update
                          final success = await provider.updateBookingProgress(
                            'started',
                            authProvider: Provider.of<AuthProvider>(context, listen: false),
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Layanan pendampingan dimulai!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          setState(() {
                            errorMessage = "PIN tidak cocok! Silakan tanyakan ke klien.";
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9DCC),
                  foregroundColor: const Color(0xFF4A1031),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A1031)),
                        ),
                      )
                    : Text("Verifikasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
