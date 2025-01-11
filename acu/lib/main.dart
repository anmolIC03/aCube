import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/drawer_screen.dart';
import 'package:acu/screens/components/hidden_drawer.dart';
import 'package:acu/screens/components/wishlist_controller.dart';
import 'package:acu/screens/home.dart';
import 'package:acu/screens/login_page.dart';
import 'package:acu/screens/signup_page.dart';
import 'package:acu/screens/splas.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    Get.put(WishlistController());
    Get.put(CartController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}
