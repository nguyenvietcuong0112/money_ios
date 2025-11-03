import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;

  void toggleTheme() {
    _themeMode.value = _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(_themeMode.value);
  }
}
