import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? fullName;
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          fullName = data['name'] ?? 'User';
          profileImageUrl = data['profileImage'];
          isLoading = false;
        });
      }
    }
  }

  Future<List<int>> loadHeartRateData() async {
    final String jsonString = await rootBundle.loadString('assets/json/DAYTHREE.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData.values.map((value) => value as int).toList();
  }

  Future<void> simulateHeartRateStream(String uid) async {
    final dbRef = FirebaseDatabase.instance.ref().child('patient_data/heart_rate/$uid');
    final heartRates = await loadHeartRateData();

    for (final bpm in heartRates) {
      final now = DateTime.now();
      final timestamp = DateFormat('yyyy-MM-dd_HH:mm:ss').format(now);
      await dbRef.child(timestamp).set(bpm);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Get.toNamed('/nav_page'),
                          child: const Icon(Icons.menu, size: 30),
                        ),
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : const AssetImage('assets/images/blank_profile.png') as ImageProvider,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            "Hello, ${fullName ?? 'User'}",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 26),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3E95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: const Text(
                      "Congratulations, Mama! Let’s see how your little one is doing!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Health Tips", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _healthTipCard("Stay Active", "Keep your body moving with gentle walks and stretches.",
                            "assets/images/runningpregnant.png", const Color(0xFFFFCDD2)),
                        const SizedBox(height: 14),
                        _healthTipCard("Stay Relaxed", "Meditate and breathe. Your baby feels your calm.",
                            "assets/images/africanwomanpregnant.jpg", const Color(0xFFF8BBD0)),
                        const SizedBox(height: 14),
                        _healthTipCard("Stay Connected", "Surround yourself with family and emotional support.",
                            "assets/images/pregnantwomen.png", const Color(0xFFF48FB1)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ElevatedButton(
                      onPressed: () async {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          simulateHeartRateStream(uid);
                          Get.toNamed('/live');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        backgroundColor: const Color(0xFFFF3E95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Start Monitoring",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthTipCard(String title, String subtitle, String imagePath, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(imagePath, height: 60, width: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
