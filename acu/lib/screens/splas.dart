import 'package:acu/screens/components/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    return Scaffold(
      body: Stack(
        children: [
          // Horizontal scroll for onboarding pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnboardingPage(
                title: 'Choose Products',
                subtitle: 'Lorem ipsum dolor sit amet.',
                image: 'lib/assets/a1.svg',
              ),
              OnboardingPage(
                title: 'Make Payment',
                subtitle:
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                image: 'lib/assets/a2.svg',
              ),
              OnboardingPage(
                title: 'Get Your Order',
                subtitle: 'Finalize your choices here.',
                image: 'lib/assets/a3.svg',
              ),
            ],
          ),

          // Skip Button - Positioned at top right
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () => OnboardingController.instance.skip(),
              child: Text(
                'Skip',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),

          // Dot navigation
          OnboardingDotNavigation(),

          // Next Button - Bottom Right
          Positioned(
            bottom: 30,
            right: 20,
            child: TextButton(
              style: ElevatedButton.styleFrom(
                  shape: CircleBorder(), backgroundColor: Colors.red),
              onPressed: () => OnboardingController.instance.nextPage(),
              child: Icon(Icons.arrow_right_alt_outlined),
            ),
          ),

          // Prev Button - Bottom Left
          Positioned(
            bottom: 30,
            left: 20,
            child: Obx(() {
              return Visibility(
                visible: controller.currentPageIndex > 0,
                child: TextButton(
                  onPressed: () => OnboardingController.instance.previousPage(),
                  child: Text(
                    'Prev',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class OnboardingDotNavigation extends StatelessWidget {
  const OnboardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: SmoothPageIndicator(
          controller: controller.pageController,
          onDotClicked: controller.dot,
          count: 3,
          effect: ExpandingDotsEffect(
            activeDotColor: Colors.black,
            dotHeight: 6,
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            image,
            height: size.height * 0.35,
            width: size.width * 0.8,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
