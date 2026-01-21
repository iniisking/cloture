import 'package:cloture/view/screens/authentication/sign_in_screen.dart';
import 'package:cloture/services/auth_service.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:cloture/controller/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userName;
  String? userEmail;
  String? userPhone;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? 'User';
        userEmail = user.email ?? '';
        userPhone = user.phoneNumber;
        profileImageUrl = user.photoURL;
      });

      // Try to get additional data from Firestore
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            userName = data?['firstName'] != null && data?['lastName'] != null
                ? '${data!['firstName']} ${data['lastName']}'
                : userName;
            userPhone = data?['phoneNumber'] ?? userPhone;
            profileImageUrl = data?['profileImageUrl'] ?? profileImageUrl;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDarkMode;
    final backgroundColor = isDark ? bgDark1 : white100;
    final cardColor = isDark ? bgDark2 : bgLight2;
    final textColor = isDark ? white100 : black100;
    final secondaryTextColor = isDark ? black50 : black50;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 32.spMin),

              // Profile Picture
              CircleAvatar(
                radius: 50.spMin,
                backgroundColor: cardColor,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? Icon(Icons.person, size: 50.spMin, color: secondaryTextColor)
                    : null,
              ),

              SizedBox(height: 24.spMin),

              // User Info Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.spMin),
                child: Container(
                  padding: EdgeInsets.all(16.spMin),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8.spMin),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: reusableText(
                              userName ?? 'User',
                              18.spMin,
                              FontWeight.bold,
                              textColor,
                              -0.41,
                              TextAlign.left,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Implement edit functionality
                            },
                            child: reusableText(
                              'Edit',
                              14.spMin,
                              FontWeight.w500,
                              primary200,
                              -0.41,
                              TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.spMin),
                      reusableText(
                        userEmail ?? 'No email',
                        14.spMin,
                        FontWeight.normal,
                        secondaryTextColor,
                        -0.41,
                        TextAlign.left,
                      ),
                      if (userPhone != null && userPhone!.isNotEmpty) ...[
                        SizedBox(height: 8.spMin),
                        reusableText(
                          userPhone!,
                          14.spMin,
                          FontWeight.normal,
                          secondaryTextColor,
                          -0.41,
                          TextAlign.left,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.spMin),

              // Dark Mode Toggle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.spMin),
                child: Consumer<ThemeController>(
                  builder: (context, themeController, child) {
                    return _buildThemeToggle(themeController);
                  },
                ),
              ),

              SizedBox(height: 40.spMin),

              // Sign Out Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.spMin),
                child: GestureDetector(
                  onTap: () async {
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const SigninScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.spMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.spMin),
                    ),
                    child: Center(
                      child: reusableText(
                        'Sign Out',
                        16.spMin,
                        FontWeight.w500,
                        Colors.red,
                        -0.41,
                        TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.spMin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeController themeController) {
    final isDark = themeController.isDarkMode;
    final cardColor = isDark ? bgDark2 : bgLight2;
    final textColor = isDark ? white100 : black100;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 16.spMin),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8.spMin),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          reusableText(
            themeController.isDarkMode ? 'Dark Mode' : 'Light Mode',
            16.spMin,
            FontWeight.normal,
            textColor,
            -0.41,
            TextAlign.left,
          ),
          Switch(
            value: themeController.isDarkMode,
            onChanged: (value) {
              themeController.toggleTheme();
            },
            activeColor: primary200,
          ),
        ],
      ),
    );
  }
}
