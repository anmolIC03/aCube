import 'package:acu/screens/dummy.dart';
import 'package:acu/screens/productByType.dart';
import 'package:acu/screens/components/cart_components/cart_controller.dart';
import 'package:acu/screens/components/drawer_screen.dart';
import 'package:acu/screens/components/hidden_drawer.dart';
import 'package:acu/screens/components/wishlist_controller.dart';
import 'package:acu/screens/home.dart';
import 'package:acu/screens/login_page.dart';
import 'package:acu/screens/signup_page.dart';
import 'package:acu/screens/view_all.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    Get.put(WishlistController());
    Get.put(CartController());
  }

  // Widget getInitialScreen() {
  //   bool isLoggedIn = storage.read("isLoggedIn") ?? false;
  //   return isLoggedIn ? HiddenDrawer() : OnboardingScreen();
  // }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HiddenDrawer(),
    );
  }
}
