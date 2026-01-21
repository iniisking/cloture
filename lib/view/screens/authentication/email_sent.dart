import 'package:cloture/gen/assets.gen.dart';
import 'package:cloture/view/screens/authentication/sign_in_screen.dart';
import 'package:cloture/view/widgets/buttons.dart';
import 'package:cloture/view/constants/colors.dart';
import 'package:cloture/view/constants/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmailSent extends StatelessWidget {
  const EmailSent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.mailSent.image(height: 120),
            SizedBox(height: 24.spMin),
            reusableText(
              'We Sent you an Email to reset\nyour password',
              24.spMin,
              FontWeight.bold,
              black100,
              0.0,
              TextAlign.center,
            ),
            SizedBox(height: 24.spMin),
            appButton(
              'Return to Sign In',
              primary200,
              white100,
              52.spMin,
              159.spMin,
              100.spMin,
              16.spMin,
              FontWeight.w500,
              Colors.transparent,
              0,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SigninScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
