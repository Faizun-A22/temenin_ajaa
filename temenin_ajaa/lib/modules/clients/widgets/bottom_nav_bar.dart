// lib/modules/clients/widgets/bottom_nav_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24), // Float above bottom edge
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9DCC).withOpacity(0.08), // Glowing pink shadow
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xE0131218), // Glass tint
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.07),
                width: 1.5,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFFFF9DCC),
              unselectedItemColor: Colors.white.withOpacity(0.35),
              selectedLabelStyle: GoogleFonts.poppins(
                fontSize: 11, 
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              items: [
                _buildNavItem(Icons.home_outlined, Icons.home_filled, 'Home', 0),
                _buildNavItem(Icons.directions_bike_outlined, Icons.directions_bike_rounded, 'Driver', 1),
                _buildNavItem(Icons.book_online_outlined, Icons.book_online_rounded, 'Booking', 2),
                _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat', 3),
                _buildNavItem(Icons.person_outline, Icons.person, 'Profil', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData inactiveIcon, 
    IconData activeIcon, 
    String label, 
    int index,
  ) {
    final isActive = selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: isActive ? 6 : 4, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFFFF9DCC).withOpacity(0.12) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          size: isActive ? 24 : 22,
        ),
      ),
      label: label,
    );
  }
}