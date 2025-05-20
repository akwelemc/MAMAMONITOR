import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final dbRef = FirebaseDatabase.instance.ref();
  final picker = ImagePicker();
  File? selectedImage;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final dueDateController = TextEditingController();
  final countryController = TextEditingController();
  final trimesterController = TextEditingController();
  final allergiesController = TextEditingController();
  final conditionsController = TextEditingController();

  bool isLoading = true;
  String? profileImageUrl;
  String? selectedBloodType;

  final List<String> bloodTypes = [
    'A+',
    'A−',
    'B+',
    'B−',
    'AB+',
    'AB−',
    'O+',
    'O−',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (uid != null) {
      final snapshot = await dbRef.child('users/$uid').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          dobController.text = data['dateOfBirth'] ?? '';
          dueDateController.text = data['dueDate'] ?? '';
          countryController.text = data['country'] ?? '';
          trimesterController.text = data['trimester'] ?? '';
          allergiesController.text = data['allergies'] ?? '';
          conditionsController.text = data['medicalConditions'] ?? '';
          selectedBloodType = data['bloodType'];
          profileImageUrl = data['profileImage'];
          isLoading = false;
        });

        if (dueDateController.text.isNotEmpty) {
          _calculateTrimesterFromDueDate(DateTime.parse(dueDateController.text));
        }
      }
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && uid != null) {
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();

      await dbRef.child('users/$uid/profileImage').set(url);
      setState(() {
        profileImageUrl = url;
        selectedImage = file;
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller, {bool isDueDate = false}) async {
    DateTime initial = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        initial = DateTime.parse(controller.text);
      } catch (_) {}
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1960),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
      if (isDueDate) {
        _calculateTrimesterFromDueDate(picked);
      }
    }
  }

  void _calculateTrimesterFromDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final totalPregnancyWeeks = 40;
    final weeksLeft = dueDate.difference(now).inDays ~/ 7;
    final weeksPregnant = totalPregnancyWeeks - weeksLeft;

    if (weeksPregnant <= 12) {
      trimesterController.text = "First Trimester";
    } else if (weeksPregnant <= 27) {
      trimesterController.text = "Second Trimester";
    } else {
      trimesterController.text = "Third Trimester";
    }
  }

  Future<void> _saveProfile() async {
    if (uid != null) {
      final userMap = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'dateOfBirth': dobController.text.trim(),
        'dueDate': dueDateController.text.trim(),
        'country': countryController.text.trim(),
        'trimester': trimesterController.text.trim(),
        'bloodType': selectedBloodType ?? '',
        'allergies': allergiesController.text.trim(),
        'medicalConditions': conditionsController.text.trim(),
        'profileImage': profileImageUrl ?? '',
      };

      await dbRef.child('users/$uid').update(userMap);

      // ✅ Send result: true to signal ProfilePage to refresh
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 54),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.chevron_left, size: 30),
                      ),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? NetworkImage(profileImageUrl!)
                              : const AssetImage('assets/images/profile.png')) as ImageProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 20, color: Color(0xFFFF3E95)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildLabel("Name"),
                  _buildInputField(nameController),
                  const SizedBox(height: 20),

                  _buildLabel("Email"),
                  _buildInputField(emailController),
                  const SizedBox(height: 20),

                  _buildLabel("Phone Number"),
                  _buildInputField(phoneController),
                  const SizedBox(height: 20),

                  _buildLabel("Date of Birth"),
                  _buildDateField(dobController),
                  const SizedBox(height: 20),

                  _buildLabel("Due Date"),
                  _buildDateField(dueDateController, isDueDate: true),
                  const SizedBox(height: 20),

                  _buildLabel("Trimester"),
                  _buildReadOnlyField(trimesterController),
                  const SizedBox(height: 20),

                  _buildLabel("Country of Origin"),
                  _buildInputField(countryController),
                  const SizedBox(height: 20),

                  _buildLabel("Blood Type"),
                  _buildDropdownField(),
                  const SizedBox(height: 20),

                  _buildLabel("Allergies"),
                  _buildInputField(allergiesController),
                  const SizedBox(height: 20),

                  _buildLabel("Medical Conditions"),
                  _buildInputField(conditionsController),
                  const SizedBox(height: 36),

                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3E95),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _buildInputField(TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          controller.text.isEmpty ? "Auto-filled" : controller.text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, {bool isDueDate = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(controller, isDueDate: isDueDate),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: Icon(Icons.calendar_today),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedBloodType,
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        hint: const Text("Select Blood Type"),
        items: bloodTypes.map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedBloodType = value;
          });
        },
      ),
    );
  }
}
