import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DarkModeController extends GetxController {
  RxBool isDarkMode = Get.isDarkMode.obs;

  void toggleDarkMode() {
    Get.changeThemeMode(isDarkMode.isTrue ? ThemeMode.light : ThemeMode.dark);
    isDarkMode.toggle();
  }
}
