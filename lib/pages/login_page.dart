import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color mamaPink = const Color(0xFFFF3E95);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String _error = '';
  bool _isPasswordVisible = false;

  Future<void> _signInUser() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, '/welcome1');
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      setState(() {
        if (e.code == 'user-not-found') {
          _error = 'Incorrect! Email account does not exist.';
        } else if (e.code == 'wrong-password') {
          _error = 'Incorrect! Password is wrong.';
        } else if (e.code == 'invalid-email') {
          _error = 'Invalid email format.';
        } else if (e.code == 'too-many-requests') {
          _error = 'Too many failed attempts. Try again later.';
        } else {
          _error = 'Login failed. Please double-check your credentials.';
        }
      });
    } catch (e) {
      print("Unexpected error: $e");
      setState(() {
        _error = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration customInputDecoration(String label, IconData icon, {bool isPassword = false}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: mamaPink),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mamaPink, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 60),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.bold,
                          color: mamaPink,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Congratulations, Mama! Sign In to Continue.",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 40),

                      // Email
                      TextField(
                        controller: emailController,
                        decoration: customInputDecoration("Email", Icons.email),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration:
                            customInputDecoration("Password", Icons.lock, isPassword: true),
                      ),
                      SizedBox(height: 30),

                      if (_error.isNotEmpty)
                        Text(
                          _error,
                          style: TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),

                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mamaPink,
                                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _signInUser,
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                      Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/register'),
                            child: Text(
                              "Sign Up!",
                              style: TextStyle(
                                color: mamaPink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
