import 'package:cloture/controller/gender_controller.dart';
import 'package:cloture/controller/splash_controller.dart';
import 'package:cloture/controller/theme_controller.dart';
import 'package:cloture/controller/cart_controller.dart';
import 'package:cloture/controller/favorites_controller.dart';
import 'package:cloture/services/auth_service.dart';
import 'package:cloture/services/cart_service.dart';
import 'package:cloture/services/favorites_service.dart';
import 'package:cloture/utils/logger.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/screens/authentication/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logger
  await AppLogger.initialize();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Ensure screen size for ScreenUtil
  await ScreenUtil.ensureScreenSize();

  // Load saved theme preference (with error handling)
  bool isDarkMode = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  } catch (e) {
    // If SharedPreferences fails to initialize, default to light mode
    AppLogger.error('Error loading theme preference', e);
    isDarkMode = false;
  }

  // Run the app after everything is initialized
  runApp(MyApp(initialTheme: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool initialTheme;

  const MyApp({super.key, this.initialTheme = false});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Set your design size here
      minTextAdapt: true, // Ensure text adapts
      splitScreenMode: true, // Enable split screen support
      builder: (context, child) {
        final authService = AuthService();
        final cartService = CartService();
        final favoritesService = FavoritesService();

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  SplashController(authService: authService)..start(),
            ),
            ChangeNotifierProvider(
              create: (_) => GenderController()..loadUserGender(),
            ),
            ChangeNotifierProvider(
              create: (_) => ThemeController(initialTheme: initialTheme),
            ),
            ChangeNotifierProvider(
              create: (_) {
                final controller = CartController(
                  cartService: cartService,
                  authService: authService,
                );
                // Start listening to cart changes and load cart
                controller.startListening();
                controller.loadCart();
                return controller;
              },
            ),
            ChangeNotifierProvider(
              create: (_) {
                final controller = FavoritesController(
                  favoritesService: favoritesService,
                  authService: authService,
                );
                // Start listening to favorites changes and load favorites
                controller.startListening();
                controller.loadFavorites();
                return controller;
              },
            ),
          ],
          child: Consumer<ThemeController>(
            builder: (context, themeController, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.light,
                  scaffoldBackgroundColor: white100,
                  textTheme: GoogleFonts.interTextTheme(),
                  fontFamily: GoogleFonts.inter().fontFamily,
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: bgDark1,
                  textTheme: GoogleFonts.interTextTheme(
                    ThemeData.dark().textTheme,
                  ),
                  fontFamily: GoogleFonts.inter().fontFamily,
                ),
                themeMode: themeController.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: const SplashScreen(), // Initial screen of the app
              );
            },
          ),
        );
      },
    );
  }
}
