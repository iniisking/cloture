// ignore_for_file: deprecated_member_use_from_same_package, deprecated_member_use

import 'package:cloture/gen/assets.gen.dart';
import 'package:cloture/view/screens/home/home_page.dart';
import 'package:cloture/view/screens/favourites/favourites_screen.dart';
import 'package:cloture/view/screens/orders/orders_screen.dart';
import 'package:cloture/view/screens/profile/profile_screen.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/theme_colors.dart';
import 'package:cloture/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  // This will keep track of the selected index for the BottomNavigationBar
  int _selectedIndex = 0;

  // List of screens for different tabs
  List<Widget> get _screens => [
    HomePage(onNavigateToCart: () => _onItemTapped(1)),
    OrdersScreen(),
    FavouritesScreen(),
    ProfileScreen(),
  ];

  // Function to handle navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Public method to navigate to a specific tab (for use by child screens)
  void navigateToTab(int index) {
    _onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        final themeColors = AppThemeColors(themeController.isDarkMode);
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: _screens[_selectedIndex], // Display the selected screen
              ),
              // Bottom Navigation Bar
              Container(
                padding: EdgeInsets.only(bottom: 20.spMin, top: 6.spMin),
                height: 82.spMin,
                width: double.infinity,
                decoration: BoxDecoration(color: themeColors.bottomNavBarColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Home
                    _buildNavItem(
                      index: 0,
                      isSelected: _selectedIndex == 0,
                      icon: SvgPicture.asset(
                        Assets.svg.home,
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 0 ? white100 : black50,
                          BlendMode.srcIn,
                        ),
                        height: 23.spMin,
                        width: 23.spMin,
                      ),
                    ),

                    // Bag
                    _buildNavItem(
                      index: 1,
                      isSelected: _selectedIndex == 1,
                      icon: SvgPicture.asset(
                        Assets.svg.orders,
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 1 ? white100 : black50,
                          BlendMode.srcIn,
                        ),
                        height: 23.spMin,
                        width: 23.spMin,
                      ),
                    ),

                    // Like
                    _buildNavItem(
                      index: 2,
                      isSelected: _selectedIndex == 2,
                      icon: SvgPicture.asset(
                        Assets.svg.favorite,
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 2 ? white100 : black50,
                          BlendMode.srcIn,
                        ),
                        height: 23.spMin,
                        width: 23.spMin,
                      ),
                    ),

                    // Profile
                    _buildNavItem(
                      index: 3,
                      isSelected: _selectedIndex == 3,
                      icon: SvgPicture.asset(
                        Assets.svg.profile,
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 3 ? white100 : black50,
                          BlendMode.srcIn,
                        ),
                        height: 23.spMin,
                        width: 23.spMin,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required Widget icon,
    required bool isSelected,
  }) {
    final item = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [icon],
    );

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: isSelected
          ? Container(
              height: 54.spMin,
              width: 57.spMin,
              decoration: BoxDecoration(
                color: primary200,
                borderRadius: BorderRadius.circular(8.spMin),
              ),
              child: Center(child: item),
            )
          : item,
    );
  }
}
