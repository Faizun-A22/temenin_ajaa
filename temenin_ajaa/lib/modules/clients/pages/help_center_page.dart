// lib/modules/home/pages/help_center_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _reportController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  
  String _selectedProblemType = 'Booking Issue';
  final List<String> _problemTypes = [
    'Booking Issue',
    'Payment Problem',
    'Driver Issue',
    'Account Problem',
    'App Bug',
    'Other',
  ];

  final List<Map<String, dynamic>> _faqList = [
    {
      'question': 'How do I book a ride?',
      'answer': 'Open the app, enter your pickup and destination locations, select your preferred vehicle type, and tap "Book Now". You will be matched with a nearby driver.',
      'category': 'Booking',
    },
    {
      'question': 'How to cancel a booking?',
      'answer': 'Go to your active booking, tap "Cancel Booking". Note that cancellation fees may apply depending on how long before the ride you cancel.',
      'category': 'Booking',
    },
    {
      'question': 'How do I add payment method?',
      'answer': 'Go to Profile → Payment Methods → Add Payment Method. You can add bank cards, e-wallets, or use cash as payment.',
      'category': 'Payment',
    },
    {
      'question': 'How to top up balance?',
      'answer': 'Go to Profile → Top Up, select the amount you want to add, choose payment method, and complete the transaction.',
      'category': 'Payment',
    },
    {
      'question': 'How do I track my driver?',
      'answer': 'After booking is confirmed, you can see your driver\'s real-time location on the map. You can also contact them via chat.',
      'category': 'Ride',
    },
    {
      'question': 'What should I do if driver doesn\'t arrive?',
      'answer': 'Contact the driver via in-app chat or call. If they don\'t respond, cancel the booking and report to customer support.',
      'category': 'Driver',
    },
    {
      'question': 'How do I change my profile?',
      'answer': 'Go to Profile → Edit Profile. You can change your name, phone number, and profile picture.',
      'category': 'Account',
    },
    {
      'question': 'How do points work?',
      'answer': 'You earn points for every completed ride. Points can be redeemed for rewards and vouchers in the Rewards section.',
      'category': 'Rewards',
    },
    {
      'question': 'What is the cancellation policy?',
      'answer': 'Free cancellation within 5 minutes of booking. After that, a cancellation fee of Rp 5,000 - Rp 10,000 may apply.',
      'category': 'Policy',
    },
    {
      'question': 'How to contact customer support?',
      'answer': 'You can reach us via email at support@temeninajaa.com, WhatsApp +62 812-3456-7890, or through the contact form below.',
      'category': 'Support',
    },
  ];

  final List<Map<String, String>> _guides = [
    {
      'title': 'How to Book a Ride',
      'icon': '🚗',
      'steps': '1. Open the app\n2. Enter pickup location\n3. Enter destination\n4. Choose vehicle type\n5. Tap "Book Now"\n6. Wait for driver confirmation',
    },
    {
      'title': 'How to Use Vouchers',
      'icon': '🎫',
      'steps': '1. Go to Profile → Rewards & Vouchers\n2. Find available voucher\n3. Tap "Claim"\n4. Use voucher code at checkout\n5. Discount applied automatically',
    },
    {
      'title': 'How to Earn Points',
      'icon': '⭐',
      'steps': '1. Complete rides regularly\n2. Refer friends to the app\n3. Participate in promotions\n4. Leave reviews for drivers\n5. Reach higher tiers for bonus points',
    },
    {
      'title': 'Safety Tips',
      'icon': '🛡️',
      'steps': '1. Verify driver and vehicle before boarding\n2. Share your trip with family\n3. Use emergency button if needed\n4. Rate your driver after ride\n5. Report any safety concerns',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reportController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@temeninajaa.com',
      query: 'subject=Help%20Center%20Inquiry',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showSnackBar('Could not open email client');
    }
  }

  Future<void> _launchWhatsApp() async {
    final String phoneNumber = '6281234567890'; // Ganti dengan nomor WhatsApp support
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      _showSnackBar('Could not open WhatsApp');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '021-12345678');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showSnackBar('Could not make phone call');
    }
  }

  void _submitReport() {
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _reportController.text.trim();
    
    if (email.isEmpty || subject.isEmpty || message.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }
    
    // Simulate sending report
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
        content: Text(
          'Report sent successfully!\nWe will respond within 24 hours.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _emailController.clear();
                _subjectController.clear();
                _reportController.clear();
              },
              child: Text('OK', style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC))),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showGuideDialog(Map<String, String> guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(guide['icon']!, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                guide['title']!,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          guide['steps']!,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Help Center',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF9DCC),
          labelColor: const Color(0xFFFF9DCC),
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Guides'),
            Tab(text: 'Contact'),
            Tab(text: 'Report'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqTab(),
          _buildGuidesTab(),
          _buildContactTab(),
          _buildReportTab(),
        ],
      ),
    );
  }

  Widget _buildFaqTab() {
    final categories = _faqList.map((f) => f['category'] as String).toSet().toList();
    
    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          Container(
            height: 45,
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: TabBar(
              isScrollable: true,
              indicatorColor: const Color(0xFFFF9DCC),
              labelColor: const Color(0xFFFF9DCC),
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              tabs: categories.map((category) => Tab(text: category)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: categories.map((category) {
                final faqs = _faqList.where((f) => f['category'] == category).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    return _buildFaqItem(faqs[index]);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            faq['question'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                faq['answer'],
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _guides.length,
      itemBuilder: (context, index) {
        final guide = _guides[index];
        return GestureDetector(
          onTap: () => _showGuideDialog(guide),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2D1121),
                  const Color(0xFF1A0D15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Text(
                  guide['icon']!,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    guide['title']!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFFF9DCC),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Email Support
          _buildContactCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            description: 'Send us an email and we will respond within 24 hours',
            actionText: 'support@temeninajaa.com',
            onTap: _launchEmail,
            color: const Color(0xFF4CAF50),
          ),
          
          const SizedBox(height: 16),
          
          // WhatsApp Support
          _buildContactCard(
            icon: Icons.chat_outlined,
            title: 'WhatsApp Support',
            description: 'Chat with our support team instantly',
            actionText: '+62 812-3456-7890',
            onTap: _launchWhatsApp,
            color: const Color(0xFF25D366),
          ),
          
          const SizedBox(height: 16),
          
          // Phone Support
          _buildContactCard(
            icon: Icons.phone_outlined,
            title: 'Phone Support',
            description: 'Call our customer service (Mon-Fri, 9AM-6PM)',
            actionText: '021-12345678',
            onTap: _launchPhone,
            color: const Color(0xFFFF9DCC),
          ),
          
          const SizedBox(height: 16),
          
          // Office Address
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16151A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9DCC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFFFF9DCC),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Office Address',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jl. Sudirman No. 123\nJakarta Selatan, 12190\nIndonesia',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Business Hours
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16151A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9DCC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Color(0xFFFF9DCC),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Hours',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 9:00 AM - 2:00 PM\nSunday & Public Holidays: Closed',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actionText,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16151A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report a Problem',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Having an issue? Let us know and we will help you as soon as possible.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Problem Type Dropdown
          Text(
            'Problem Type',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF16151A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProblemType,
                dropdownColor: const Color(0xFF16151A),
                style: GoogleFonts.poppins(color: Colors.white),
                isExpanded: true,
                items: _problemTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProblemType = value!;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Email Field
          Text(
            'Your Email',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            style: GoogleFonts.poppins(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: const Color(0xFF16151A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subject Field
          Text(
            'Subject',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _subjectController,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Brief summary of your issue',
              hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: const Color(0xFF16151A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Message Field
          Text(
            'Message',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reportController,
            style: GoogleFonts.poppins(color: Colors.white),
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe your problem in detail...',
              hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: const Color(0xFF16151A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9DCC),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Submit Report',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}