import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';

class DividerWithText extends StatelessWidget {
  DividerWithText({
    this.leftDividerPadding,
    this.rightDividerPadding,
    this.color,
    this.text,
    this.height,
  });

  final Color color;
  final EdgeInsetsGeometry leftDividerPadding;
  final EdgeInsetsGeometry rightDividerPadding;
  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        child: Container(
            margin: leftDividerPadding,
            child: Divider(
              color: color,
              height: height,
              thickness: 1,
            )),
      ),
      Container(
        margin: EdgeInsets.only(left: 12, right: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: light2Grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(
        child: Container(
            margin: rightDividerPadding,
            child: Divider(
              color: color,
              height: height,
              thickness: 1,
            )),
      ),
    ]);
  }
}
