import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset('lib/assets/img1.svg'),
      ),
    );
  }
}
