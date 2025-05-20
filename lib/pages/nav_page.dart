import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavPage extends StatelessWidget {
  const NavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95), // slightly transparent
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: const [
                  Text(
                    "MAMA MONITOR",
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 226, 3, 137),
                      
                    ),
                  ),
                  Spacer(),
                  
                ],
              ),
              const SizedBox(height: 40),

              _buildNavItem("Home", Icons.home, '/home'),
              _buildNavItem("Profile", Icons.person, '/profile'),
              _buildNavItem("Live Data", Icons.favorite, '/live'),
              _buildNavItem("History", Icons.history, '/history'),
              _buildNavItem("Contractions", Icons.monitor_heart, '/contractions'),
              _buildNavItem("Logout", Icons.logout, '/login'),

              const Spacer(),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
