import 'package:cloture/controller/theme_controller.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppThemeColors {
  final bool isDark;

  AppThemeColors(this.isDark);

  Color get backgroundColor => isDark ? bgDark1 : white100;
  Color get cardColor => isDark ? bgDark2 : bgLight2;
  Color get primaryTextColor => isDark ? white100 : black100;
  Color get secondaryTextColor => isDark ? black50 : black50;
  Color get bottomNavBarColor => isDark ? bgDark1 : white100;
}

extension ThemeColorsExtension on BuildContext {
  AppThemeColors get themeColors {
    final themeController = Provider.of<ThemeController>(this, listen: false);
    return AppThemeColors(themeController.isDarkMode);
  }
}
