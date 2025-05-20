import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ContractionsPage extends StatefulWidget {
  const ContractionsPage({Key? key}) : super(key: key);

  @override
  State<ContractionsPage> createState() => _ContractionsPageState();
}

class _ContractionsPageState extends State<ContractionsPage> {
  int _contractionCount = 0;
  List<String> _timestamps = [];

  final uid = FirebaseAuth.instance.currentUser?.uid;
  final dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadTodaysContractions();
  }

  String getTodayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _loadTodaysContractions() async {
    if (uid != null) {
      final today = getTodayDate();
      final snapshot = await dbRef.child('patient_data/contractions/$uid/$today').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final times = data.keys.toList()..sort();
        setState(() {
          _contractionCount = times.length;
          _timestamps = times;
        });
      } else {
        setState(() {
          _contractionCount = 0;
          _timestamps = [];
        });
      }
    }
  }

  void _recordContraction() async {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    final today = getTodayDate();

    setState(() {
      _contractionCount++;
      _timestamps.add(formattedTime);
    });

    if (uid != null) {
      await dbRef
          .child('patient_data/contractions/$uid/$today/$formattedTime')
          .set(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 54),

              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed('/nav_page'),
                      child: const Icon(Icons.menu, size: 30),
                    ),
                    const Spacer(),
                    const Text(
                      "Contractions",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF3E95),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.chevron_left, size: 30),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "Track your contractions here!\nTap the plus anytime you feel one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 30),

              // Big counter circle
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$_contractionCount',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                getTodayDate(),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 12),

              // View historical contractions
              TextButton(
                onPressed: () {
                  Get.toNamed('/historyContractions', arguments: {
                    'date': getTodayDate(),
                    'uid': uid,
                  });
                },
                child: const Text(
                  "See Historical Contractions",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFF3E95),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          // Plus sign
          Positioned(
            bottom: 110,
            right: 24,
            child: GestureDetector(
              onTap: _recordContraction,
              child: Image.asset(
                'assets/images/plus_sign.jpeg',
                height: 56,
              ),
            ),
          ),

          // Bottom nav bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem('assets/images/live_icon.png', 'Live Data', '/live'),
                  _buildNavItem('assets/images/history.png', 'History', '/history'),
                  _buildNavItem('assets/images/bang.png', 'Contractions', '/contractions'),
                  _buildNavItem('assets/images/logout_icon.png', 'Logout', '/login'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String assetPath, String label, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetPath, height: 30),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
