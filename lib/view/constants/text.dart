import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget reusableText(
  String text,
  double fontSize,
  FontWeight fontWeight,
  Color color,
  double letterSpacing,
  TextAlign? textAlign,
) {
  return Text(
    text,
    style: GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    ),
    textAlign: textAlign,
  );
}
