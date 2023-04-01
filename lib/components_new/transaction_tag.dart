import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class TransactionTag extends StatelessWidget {
  final String tag;
  final Color bgColor;
  final Color titleColor;

  TransactionTag({
    this.tag,
    this.bgColor,
    this.titleColor
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? kColorLightRed3,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: titleColor ?? Colors.black,
          fontFamily: poppinsRegular,
          fontSize: 12,
        ),
      ),
    );
  }
}
