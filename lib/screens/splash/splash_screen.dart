import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_referral_app/screens/authentication/login_page.dart';
import 'package:flutter_referral_app/screens/home/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  void navigate() {
    Future.delayed(const Duration(seconds: 2), () {
      if (auth.currentUser != null) {
        //Navigate to Home Page
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => const HomePage()),
            (route) => false);
      } else {
        //Navigate to Login Page
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => const LoginPage()),
            (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: FlutterLogo(),
      ),
    );
  }
}
