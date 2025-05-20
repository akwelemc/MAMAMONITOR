import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:core';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users');

  bool _isLoading = false;
  String _error = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Password validation flags
  bool _hasUppercase = false;
  bool _hasSymbol = false;
  bool _hasMinLength = false;

  bool _validateInputs() {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    if (fullName.isEmpty) {
      setState(() => _error = 'Full name is required.');
      return false;
    }

    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return false;
    }

    if (!_hasMinLength || !_hasUppercase || !_hasSymbol) {
      setState(() => _error =
          'Password must be at least 8 characters,\ninclude one uppercase letter and one symbol.');
      return false;
    }

    if (password != confirmPassword) {
      setState(() => _error = 'Passwords do not match.');
      return false;
    }

    return true;
  }

  Future<void> _registerUser() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final String uid = userCredential.user!.uid;

      await _dbRef.child(uid).set({
        'name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'patient', // All users of the mobile app are patients
      });

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? "Registration failed.";
      });
    } catch (e) {
      setState(() {
        _error = "An unexpected error occurred.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updatePasswordChecks(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasSymbol = password.contains(RegExp(r'[!@#\$&*~%^(),.?":{}|<>]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Text("Sign Up",
                  style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Color(0xFFFF3E95))),
              const SizedBox(height: 10),
              Text("Congratulations Mama! To get started, register here!",
                  style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 50),

              Align(alignment: Alignment.centerLeft, child: _buildLabel("Full Name")),
              _buildInputField(fullNameController, "Enter full name here"),
              const SizedBox(height: 20),

              Align(alignment: Alignment.centerLeft, child: _buildLabel("Email")),
              _buildInputField(emailController, "Enter your email here"),
              const SizedBox(height: 20),

              Align(alignment: Alignment.centerLeft, child: _buildLabel("Password")),
              _buildInputField(passwordController, "Enter your password here",
                  isPassword: true, onChanged: _updatePasswordChecks),
              _buildPasswordChecklist(),
              const SizedBox(height: 20),

              Align(alignment: Alignment.centerLeft, child: _buildLabel("Confirm Password")),
              _buildInputField(confirmPasswordController, "Re-enter your password",
                  isPassword: true, isConfirm: true),
              const SizedBox(height: 20),

              const SizedBox(height: 10),
              if (_error.isNotEmpty)
                Text(_error, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF3E95),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text("Register", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: Text("Sign In!",
                        style: TextStyle(color: Color(0xFFFF3E95), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF3E95)),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint,
      {bool isPassword = false, bool isConfirm = false, Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword
          ? (isConfirm ? !_isConfirmPasswordVisible : !_isPasswordVisible)
          : false,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (isConfirm ? _isConfirmPasswordVisible : _isPasswordVisible)
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirm) {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    } else {
                      _isPasswordVisible = !_isPasswordVisible;
                    }
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildPasswordChecklist() {
    return Column(
      children: [
        _buildChecklistItem("At least 8 characters", _hasMinLength),
        _buildChecklistItem("Contains uppercase letter", _hasUppercase),
        _buildChecklistItem("Contains a symbol", _hasSymbol),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
