import 'package:cloture/view/screens/authentication/email_sent.dart';
import 'package:cloture/view/widgets/buttons.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:cloture/view/constants/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white100,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 23.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 63.spMin),
              backButton(() {
                Navigator.of(context).pop();
              }),
              SizedBox(height: 20.spMin),
              reusableText(
                'Forgot Password',
                32.spMin,
                FontWeight.bold,
                black100,
                -0.41,
                TextAlign.left,
              ),
              SizedBox(height: 32.spMin),
              authTextField(
                hintText: 'Enter Email Address',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 24.spMin),
              appButton(
                'Continue',
                primary200,
                white100,
                47.spMin,
                344.spMin,
                100.spMin,
                16.spMin,
                FontWeight.w500,
                Colors.transparent,
                -0.5,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const EmailSent()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
