import 'package:acu/screens/components/products/exhausts.dart';
import 'package:acu/screens/help.dart';
import 'package:acu/screens/home.dart';
import 'package:acu/screens/order_history.dart';
import 'package:acu/screens/profile.dart';
import 'package:acu/screens/view_all.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:hidden_drawer_menu/model/item_hidden_menu.dart';
import 'package:hidden_drawer_menu/model/screen_hidden_drawer.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  List<ScreenHiddenDrawer> _pages = [];
  final storage = GetStorage();
  final myTextStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _buildMenu();
  }

  void _buildMenu() {
    final userId = storage.read("userId");

    _pages = [
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'ACUBE MART',
          baseStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          selectedStyle: myTextStyle,
          colorLineSelected: const Color.fromRGBO(185, 28, 28, 1.0),
        ),
        HomeScreen(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'By Performance',
          baseStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          selectedStyle: myTextStyle,
          colorLineSelected: const Color.fromRGBO(185, 28, 28, 1.0),
        ),
        Exhausts(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'By Parts',
          baseStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          selectedStyle: myTextStyle,
          colorLineSelected: const Color.fromRGBO(185, 28, 28, 1.0),
        ),
        ViewAllScreen(fromDrawer: true),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Help & FAQ',
          baseStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          selectedStyle: myTextStyle,
          colorLineSelected: const Color.fromRGBO(185, 28, 28, 1.0),
        ),
        HelpFAQ(),
      ),
    ];

    if (userId != null && userId.isNotEmpty) {
      _pages.add(
        ScreenHiddenDrawer(
          ItemHiddenMenu(
            name: 'Logout',
            baseStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
            selectedStyle: myTextStyle,
            colorLineSelected: Colors.red,
            onTap: logout,
          ),
          HomeScreen(),
        ),
      );
    }
  }

  void logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();

        storage.erase();

        Future.delayed(const Duration(milliseconds: 100), () {
          Get.offAll(() => const HiddenDrawer());
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      disableAppBarDefault: false,
      screens: _pages,
      leadingAppBar: const Icon(Icons.menu, size: 28),
      backgroundColorAppBar: Colors.white,
      styleAutoTittleName:
          const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
      backgroundColorMenu: Colors.white,
      initPositionSelected: 0,
      slidePercent: 40,
      elevationAppBar: 0,
      contentCornerRadius: 80,
      boxShadow: const [
        BoxShadow(
          offset: Offset.zero,
          color: Colors.transparent,
        )
      ],
      actionsAppBar: [
        IconButton(
          onPressed: () {
            final userId = storage.read("userId");
            if (userId != null && userId.isNotEmpty) {
              Get.to(() => OrderHistoryScreen(userId: userId));
            } else {
              Get.snackbar('Error', 'User not logged in');
            }
          },
          icon: const Icon(Icons.work_history, size: 28),
        ),
        GestureDetector(
          onTap: () {
            Get.to(() => ProfileScreen());
          },
          child: const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('lib/assets/hero1.jpeg'),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
