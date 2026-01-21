import 'package:cloture/view/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

toastInfo({
  required String msg,
  Color? backgroundColor,
  Color textColor = Colors.white,
}) {
  backgroundColor ??= primary200;
  return Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 5,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: 14,
  );
}

toastError({
  required String msg,
  Color? backgroundColor,
  Color textColor = Colors.white,
}) {
  backgroundColor ??= Colors.red;
  return Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP,
    timeInSecForIosWeb: 5,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: 14,
  );
}
