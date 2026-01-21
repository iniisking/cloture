// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cloture/view/screens/authentication/forgot_password.dart';
import 'package:cloture/services/auth_service.dart';
import 'package:cloture/view/constants/bottom_nav_screen.dart';
import 'package:cloture/view/widgets/buttons.dart';
import 'package:cloture/view/widgets/toast_widget.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:cloture/view/constants/textfield.dart';
import 'package:cloture/controller/cart_controller.dart';
import 'package:cloture/controller/favorites_controller.dart';
import 'package:cloture/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  bool isLoading = false;
  bool isPasswordVisible = false;

  // Function to toggle password visibility
  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Convert email to lowercase to avoid case sensitivity issues
    String email = emailController.text.trim().toLowerCase();
    String password = passwordController.text;

    setState(() {
      isLoading = true;
    });

    try {
      // Check if email is registered with password sign-in method
      List<String> signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(email);

      if (signInMethods.contains('password')) {
        // Email is registered with password sign-in method, proceed to sign in
        var user = await authService.signInWithEmail(email, password);

        setState(() {
          isLoading = false;
        });

        if (user != null) {
          // Sign in successful - load cart and favorites
          final cartController = context.read<CartController>();
          final favoritesController = context.read<FavoritesController>();
          await Future.wait([
            cartController.loadCart(),
            favoritesController.loadFavorites(),
          ]);
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BottomNavScreen()),
          );
        } else {
          // Show an error message
          toastError(msg: 'Failed to sign in. Please check your credentials.');
        }
      } else if (signInMethods.isNotEmpty) {
        // Email is registered with another provider (Google, Facebook, etc.)
        String provider = signInMethods.join(', ');
        toastInfo(
          msg:
              'This email is registered with $provider. Please use that sign-in method.',
        );
        setState(() {
          isLoading = false;
        });
      } else {
        // Email is not registered
        toastError(msg: 'Email is not registered. Please create an account.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle Firebase-specific errors
      if (e is FirebaseAuthException) {
        AppLogger.error('FirebaseAuthException', e, StackTrace.current);
        toastError(msg: 'FirebaseAuth error: ${e.message ?? 'Unknown error'}');
      } else {
        // Handle other errors
        AppLogger.error('Error during sign in', e, StackTrace.current);
        toastError(msg: 'An unexpected error occurred: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 123),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reusableText(
                  'Sign in',
                  32.spMin,
                  FontWeight.bold,
                  black100,
                  -0.41,
                  TextAlign.left,
                ),
                SizedBox(height: 32.spMin),
                authTextField(
                  hintText: 'Email Address',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.spMin),
                authTextField(
                  hintText: 'Password',
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  obscureText: !isPasswordVisible,
                  suffixIcon: IconButton(
                    onPressed: togglePasswordVisibility,
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.spMin),
                appButton(
                  isLoading ? 'Signing in...' : 'Continue',
                  primary200,
                  white100,
                  47.spMin,
                  344.spMin,
                  100.spMin,
                  16.spMin,
                  FontWeight.w500,
                  Colors.transparent,
                  -0.5,
                  isLoading ? () {} : signIn,
                ),
                SizedBox(height: 16.spMin),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    reusableText(
                      'Forgot Password?',
                      12.spMin,
                      FontWeight.w500,
                      black100,
                      -0.5,
                      TextAlign.left,
                    ),
                    SizedBox(width: 8.spMin),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
                      child: reusableText(
                        'Reset',
                        12.spMin,
                        FontWeight.bold,
                        primary200,
                        -0.5,
                        TextAlign.left,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 71.spMin),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
