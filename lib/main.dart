import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

// Pages
import 'pages/splash_2.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/welcome_1.dart';
import 'pages/welcome_2.dart';
import 'pages/welcome_3.dart';
import 'pages/welcome_4.dart';
import 'pages/home_page.dart';
import 'pages/live_page.dart';
import 'pages/history_page.dart';
import 'pages/report_page.dart';
import 'pages/profile_page.dart';
import 'pages/nav_page.dart';
import 'pages/edit_profile.dart';
import 'pages/contractions_page.dart';
import 'pages/history_contractions_page.dart';
import 'pages/change_password.dart';
import 'pages/change_email.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Only initialize if not already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
          authDomain: "mamamonitor-bc144.firebaseapp.com",
          databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
          projectId: "mamamonitor-bc144",
          storageBucket: "mamamonitor-bc144.appspot.com",
          messagingSenderId: "1053977602705",
          appId: "1:1053977602705:web:e86144988a193e5633ad30",
          measurementId: "G-C3PWJBLXRQ",
        ),
      );
    }
  } catch (e) {
    print("⚠️ Firebase already initialized or error: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MamaMonitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/splash2',
      getPages: [
        GetPage(name: '/splash2', page: () => Splash2Page()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/welcome1', page: () => Welcome1Page()),
        GetPage(name: '/welcome2', page: () => Welcome2Page()),
        GetPage(name: '/welcome3', page: () => Welcome3Page()),
        GetPage(name: '/welcome4', page: () => Welcome4Page()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/live', page: () => LivePage()),
        GetPage(name: '/history', page: () => HistoryPage()),
        GetPage(name: '/report', page: () => ReportPage()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/editProfile', page: () => EditProfilePage()),
        GetPage(name: '/contractions', page: () => ContractionsPage()),
        GetPage(name: '/historyContractions', page: () => HistoryContractionsPage()),
        GetPage(name: '/changeEmail', page: () => ChangeEmailPage()),
        GetPage(name: '/changePassword', page: () => ChangePasswordPage()),
        GetPage(name: '/nav_page', page: () => NavPage()),
      ],
    );
  }
}
