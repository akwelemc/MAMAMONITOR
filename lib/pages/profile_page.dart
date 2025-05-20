import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (uid != null) {
      final snapshot = await dbRef.child('users/$uid').get();
      if (snapshot.exists) {
        setState(() {
          userData = Map<String, dynamic>.from(snapshot.value as Map);
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String profileImage = userData['profileImage'] ?? '';
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 54),

                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.menu, size: 30),
                      ),
                      const Text(
                        'Profile Page',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile Picture
                  ClipOval(
                    child: profileImage.isNotEmpty
                        ? Image.network(
                            profileImage,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/blank_profile.png',
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 30),

                  _buildLabel("Name"),
                  _buildValueBox(userData['name'] ?? ''),

                  const SizedBox(height: 20),
                  _buildLabel("Email"),
                  _buildValueBox(userData['email'] ?? ''),

                  const SizedBox(height: 20),
                  _buildLabel("Phone Number"),
                  _buildValueBox(userData['phone'] ?? ''),

                  const SizedBox(height: 20),
                  _buildLabel("Date of Birth"),
                  _buildValueBox(userData['dateOfBirth'] ?? ''),

                  const SizedBox(height: 20),
                  _buildLabel("Due Date"),
                  _buildValueBox(userData['dueDate'] ?? ''),

                  const SizedBox(height: 20),
                  _buildLabel("Trimester"),
                  _buildValueBox(userData['trimester'] ?? ''),

                  const SizedBox(height: 20),
                  _buildLabel("Country of Origin"),
                  _buildValueBox(userData['country'] ?? ''),

                  const SizedBox(height: 20),
                  _buildLabel("Blood Type"),
                  _buildValueBox(userData['bloodType'] ?? ''),

                  const SizedBox(height: 20),
                  _buildLabel("Allergies"),
                  _buildValueBox(userData['allergies'] ?? ''),

                  const SizedBox(height: 20),
                  _buildLabel("Medical Conditions"),
                  _buildValueBox(userData['medicalConditions'] ?? ''),

                  const SizedBox(height: 36),

                  // 🔁 Updated: triggers refresh after EditProfilePage returns
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed('/editProfile')?.then((result) {
                        if (result == true) {
                          setState(() {
                            isLoading = true;
                          });
                          _fetchUserData(); // refresh updated data
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3E95),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildValueBox(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value.isEmpty ? 'Not set' : value,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
