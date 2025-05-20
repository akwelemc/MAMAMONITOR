import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeEmailPage extends StatelessWidget {
  const ChangeEmailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController oldEmailController = TextEditingController();
    final TextEditingController newEmailController = TextEditingController();
    final TextEditingController confirmEmailController = TextEditingController();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 54),

            // Back Icon
            GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(Icons.chevron_left, size: 30),
            ),

            const SizedBox(height: 10),

            const Text(
              'Change Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),
            const Text("Old email address", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildInputField(oldEmailController),

            const SizedBox(height: 20),
            const Text("New email address", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildInputField(newEmailController),

            const SizedBox(height: 20),
            const Text("Confirm email address", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildInputField(confirmEmailController),

            const SizedBox(height: 36),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Profile after saving
                  Get.toNamed('/profile');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3E95),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
