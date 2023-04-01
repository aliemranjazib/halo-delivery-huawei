import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';

void showSimpleFlushBar(String msg, BuildContext context,
    {bool isError = true}) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    messageText: Text(
      msg,
      style: TextStyle(
        fontSize: 15,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    ),
    backgroundColor: isError ? kColorRed : Colors.green,
    duration: Duration(seconds: 3),
    animationDuration: Duration(milliseconds: 700),
  ).show(context);
}
