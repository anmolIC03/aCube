import 'package:acu/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  /// Updates the current page indicator value
  void updatePageIndicator(index) => currentPageIndex.value = index;

  /// Handles dot navigation clicks
  void dot(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// Navigates to the next page or the login screen if on the last page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      Get.to(() => LoginPage());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigates to the previous page
  void previousPage() {
    if (currentPageIndex.value > 0) {
      int page = currentPageIndex.value - 1;
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Skips directly to the last page
  void skip() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2);
  }
}
