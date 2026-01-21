import 'package:cloture/gen/assets.gen.dart';
import 'package:cloture/view/constants/bottom_nav_screen.dart';
import 'package:cloture/view/screens/authentication/sign_in_screen.dart';
import 'package:cloture/controller/splash_controller.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VoidCallback? _disposeListener;

  @override
  void initState() {
    super.initState();
    // Start splash logic + listen for navigation transitions
    final controller = context.read<SplashController>();
    controller.start();

    void listener() {
      final status = controller.status;
      if (!mounted) return;

      if (status == SplashStatus.authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavScreen()),
        );
      } else if (status == SplashStatus.unauthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SigninScreen()),
        );
      }
    }

    controller.addListener(listener);
    _disposeListener = () => controller.removeListener(listener);
  }

  @override
  void dispose() {
    _disposeListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary200,
      body: Consumer<SplashController>(
        builder: (context, controller, _) {
          // Navigation is handled in the controller listener; here we just show the splash UI.
          return Center(
            child: Assets.images.clotoureLogo.image(height: 270, width: 350),
          );
        },
      ),
    );
  }
}
