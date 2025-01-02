import 'package:acu/screens/login_page.dart';
import 'package:acu/screens/signup_page.dart';
import 'package:acu/screens/splas.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupPage(),
    );
  }
}
