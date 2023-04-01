import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';

class CustomCheckBox extends StatelessWidget {
  CustomCheckBox({
    this.isChecked,
  });
  final isChecked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(
          color: kColorRed,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        shape: BoxShape.circle,
      ),
      child: isChecked
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kColorRed,
              ),
            )
          : null,
    );
  }
}
