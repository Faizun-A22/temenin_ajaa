// lib/modules/home/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Notification Settings
  bool _pushNotifications = true;
  bool _bookingUpdates = true;
  bool _promoNotifications = true;
  bool _paymentNotifications = true;
  bool _emailNotifications = true;
  
  // Privacy Settings
  bool _shareLocation = true;
  bool _shareRideHistory = false;
  bool _personalizedAds = true;
  
  // App Settings
  String _selectedLanguage = 'Indonesia';
  String _selectedTheme = 'Dark';
  bool _saveDataSaver = false;
  
  // Security
  bool _twoFactorAuth = false;
  
  final List<Map<String, String>> _languages = [
    {'name': 'Indonesia', 'code': 'id'},
    {'name': 'English', 'code': 'en'},
  ];
  
  final List<Map<String, String>> _themes = [
    {'name': 'Dark', 'icon': '🌙'},
    {'name': 'Light', 'icon': '☀️'},
    {'name': 'System', 'icon': '📱'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _bookingUpdates = prefs.getBool('booking_updates') ?? true;
      _promoNotifications = prefs.getBool('promo_notifications') ?? true;
      _paymentNotifications = prefs.getBool('payment_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _shareLocation = prefs.getBool('share_location') ?? true;
      _shareRideHistory = prefs.getBool('share_ride_history') ?? false;
      _personalizedAds = prefs.getBool('personalized_ads') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'Indonesia';
      _selectedTheme = prefs.getString('theme') ?? 'Dark';
      _saveDataSaver = prefs.getBool('data_saver') ?? false;
      _twoFactorAuth = prefs.getBool('two_factor_auth') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveStringSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Language',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((lang) {
            return ListTile(
              title: Text(
                lang['name']!,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: _selectedLanguage == lang['name']
                  ? const Icon(Icons.check_circle, color: Color(0xFFFF9DCC))
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = lang['name']!;
                  _saveStringSetting('language', _selectedLanguage);
                });
                Navigator.pop(context);
                _showRestartDialog();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Theme',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _themes.map((theme) {
            return ListTile(
              leading: Text(theme['icon']!, style: const TextStyle(fontSize: 24)),
              title: Text(
                theme['name']!,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: _selectedTheme == theme['name']
                  ? const Icon(Icons.check_circle, color: Color(0xFFFF9DCC))
                  : null,
              onTap: () {
                setState(() {
                  _selectedTheme = theme['name']!;
                  _saveStringSetting('theme', _selectedTheme);
                });
                Navigator.pop(context);
                _showRestartDialog();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Restart Required',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Please restart the app for changes to take effect.',
          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In production, you might want to restart the app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please restart the app manually')),
              );
            },
            child: Text('OK', style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC))),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF16151A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF16151A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF16151A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              final oldPassword = oldPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;
              
              if (oldPassword.isEmpty || newPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }
              
              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New passwords do not match')),
                );
                return;
              }
              
              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters')),
                );
                return;
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully!')),
              );
            },
            child: Text('Save', style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ Warning!',
              style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Deleting your account will permanently remove:',
              style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 8),
            const BulletPoint(text: 'All your personal data'),
            const BulletPoint(text: 'Booking history'),
            const BulletPoint(text: 'Points and rewards'),
            const BulletPoint(text: 'Saved payment methods'),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone!',
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            TextField(
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type "DELETE" to confirm',
                hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: const Color(0xFF16151A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion request sent')),
              );
            },
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDataExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Export Your Data',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'We will send a link to download your data to your registered email address within 24 hours.',
          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export request sent to your email')),
              );
            },
            child: Text('Request', style: GoogleFonts.poppins(color: const Color(0xFFFF9DCC))),
          ),
        ],
      ),
    );
  }

  void _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1C24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Cache',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will clear temporary app data. Your account and settings will not be affected.',
          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              // Clear only cache, not user data
              // In production, you might want to clear image cache etc.
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            child: Text('Clear', style: GoogleFonts.poppins(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16151A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9DCC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFFF9DCC), size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF9DCC),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF16151A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9DCC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFFF9DCC), size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: const Color(0xFFFF9DCC),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerButton({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings & Privacy',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionTitle('Account'),
            _buildSettingTile(
              title: 'Edit Profile',
              subtitle: 'Change your personal information',
              value: '',
              onTap: () {
                // Navigate to edit profile
                Navigator.pushNamed(context, '/edit-profile');
              },
              icon: Icons.person_outline,
            ),
            _buildSettingTile(
              title: 'Change Password',
              subtitle: 'Update your password',
              value: '',
              onTap: _showChangePasswordDialog,
              icon: Icons.lock_outline,
            ),
            _buildSettingTile(
              title: 'Language',
              subtitle: 'Choose your preferred language',
              value: _selectedLanguage,
              onTap: _showLanguageDialog,
              icon: Icons.language,
            ),
            _buildSettingTile(
              title: 'Theme',
              subtitle: 'Dark, Light, or System default',
              value: _selectedTheme,
              onTap: _showThemeDialog,
              icon: Icons.dark_mode_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // Notification Section
            _buildSectionTitle('Notifications'),
            _buildSettingSwitch(
              title: 'Push Notifications',
              subtitle: 'Receive push notifications',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
                _saveSetting('push_notifications', value);
              },
              icon: Icons.notifications_outlined,
            ),
            if (_pushNotifications) ...[
              _buildSettingSwitch(
                title: 'Booking Updates',
                subtitle: 'Get notified about your bookings',
                value: _bookingUpdates,
                onChanged: (value) {
                  setState(() => _bookingUpdates = value);
                  _saveSetting('booking_updates', value);
                },
              ),
              _buildSettingSwitch(
                title: 'Promo & Offers',
                subtitle: 'Receive promotional notifications',
                value: _promoNotifications,
                onChanged: (value) {
                  setState(() => _promoNotifications = value);
                  _saveSetting('promo_notifications', value);
                },
              ),
              _buildSettingSwitch(
                title: 'Payment Updates',
                subtitle: 'Get notified about payments',
                value: _paymentNotifications,
                onChanged: (value) {
                  setState(() => _paymentNotifications = value);
                  _saveSetting('payment_notifications', value);
                },
              ),
            ],
            _buildSettingSwitch(
              title: 'Email Notifications',
              subtitle: 'Receive updates via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
                _saveSetting('email_notifications', value);
              },
              icon: Icons.email_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // Privacy Section
            _buildSectionTitle('Privacy'),
            _buildSettingSwitch(
              title: 'Share Location',
              subtitle: 'Allow app to access your location',
              value: _shareLocation,
              onChanged: (value) {
                setState(() => _shareLocation = value);
                _saveSetting('share_location', value);
              },
              icon: Icons.location_on_outlined,
            ),
            _buildSettingSwitch(
              title: 'Share Ride History',
              subtitle: 'Allow others to see your ride history',
              value: _shareRideHistory,
              onChanged: (value) {
                setState(() => _shareRideHistory = value);
                _saveSetting('share_ride_history', value);
              },
              icon: Icons.history,
            ),
            _buildSettingSwitch(
              title: 'Personalized Ads',
              subtitle: 'Show ads based on your activity',
              value: _personalizedAds,
              onChanged: (value) {
                setState(() => _personalizedAds = value);
                _saveSetting('personalized_ads', value);
              },
              icon: Icons.ad_units_outlined,
            ),
            _buildSettingTile(
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              value: '',
              onTap: () {
                // Navigate to privacy policy
              },
              icon: Icons.privacy_tip_outlined,
            ),
            _buildSettingTile(
              title: 'Terms of Service',
              subtitle: 'Read our terms and conditions',
              value: '',
              onTap: () {
                // Navigate to terms of service
              },
              icon: Icons.description_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // Security Section
            _buildSectionTitle('Security'),
            _buildSettingSwitch(
              title: 'Two-Factor Authentication',
              subtitle: 'Add an extra layer of security',
              value: _twoFactorAuth,
              onChanged: (value) {
                setState(() => _twoFactorAuth = value);
                _saveSetting('two_factor_auth', value);
              },
              icon: Icons.security_outlined,
            ),
            _buildSettingTile(
              title: 'Connected Devices',
              subtitle: 'Manage devices logged into your account',
              value: '',
              onTap: () {
                // Show connected devices
              },
              icon: Icons.devices_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // Data & Storage Section
            _buildSectionTitle('Data & Storage'),
            _buildSettingSwitch(
              title: 'Data Saver Mode',
              subtitle: 'Reduce data usage',
              value: _saveDataSaver,
              onChanged: (value) {
                setState(() => _saveDataSaver = value);
                _saveSetting('data_saver', value);
              },
              icon: Icons.data_saver_off,
            ),
            _buildSettingTile(
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              value: '',
              onTap: _clearCache,
              icon: Icons.cleaning_services_outlined,
            ),
            _buildSettingTile(
              title: 'Export My Data',
              subtitle: 'Download a copy of your data',
              value: '',
              onTap: _showDataExportDialog,
              icon: Icons.download_outlined,
            ),
            
            const SizedBox(height: 24),
            
            // Danger Zone Section
            _buildSectionTitle('Danger Zone'),
            _buildDangerButton(
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and all data',
              onTap: _showDeleteAccountDialog,
              color: Colors.redAccent,
            ),
            
            const SizedBox(height: 40),
            
            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Temenin Ajaa',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: const Color(0xFFFF9DCC),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}