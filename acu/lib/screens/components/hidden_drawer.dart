import 'package:acu/screens/components/products/exhausts.dart';
import 'package:acu/screens/help.dart';
import 'package:acu/screens/home.dart';
import 'package:flutter/material.dart';
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

  final myTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();

    _pages = [
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'ACUBE MART',
          baseStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          selectedStyle: myTextStyle,
          colorLineSelected: Color.fromRGBO(185, 28, 28, 1.0),
        ),
        HomeScreen(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Exhausts',
          baseStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          selectedStyle: myTextStyle,
          colorLineSelected: Color.fromRGBO(185, 28, 28, 1.0),
        ),
        Exhausts(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'Help & FAQ',
          baseStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          selectedStyle: myTextStyle,
          colorLineSelected: Color.fromRGBO(185, 28, 28, 1.0),
        ),
        HelpFAQ(),
      ),
      ScreenHiddenDrawer(
        ItemHiddenMenu(
          name: 'By Parts',
          baseStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          selectedStyle: myTextStyle,
          colorLineSelected: Color.fromRGBO(185, 28, 28, 1.0),
        ),
        HomeScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      disableAppBarDefault: false,
      screens: _pages,
      leadingAppBar: const Icon(
        Icons.menu,
        size: 28,
      ),
      backgroundColorAppBar: Colors.white,
      styleAutoTittleName: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
      backgroundColorMenu: Colors.white,
      initPositionSelected: 0,
      slidePercent: 40,
      elevationAppBar: 0,
      contentCornerRadius: 80,
      boxShadow: [
        BoxShadow(
          offset: Offset.zero,
          color: Colors.transparent,
        )
      ],
      actionsAppBar: [
        IconButton(
            onPressed: () {},
            icon: Icon(
              (Icons.notifications_none),
              size: 28,
            )),
      ],
    );
  }
}
