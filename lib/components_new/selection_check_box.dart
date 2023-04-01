import 'package:flutter/material.dart';
import 'package:haloapp/components_new/custom_check_box.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class SelectionCheckBox extends StatelessWidget {
  SelectionCheckBox({
    this.onPressed,
    this.isSelected,
    this.label,
  });
  final Function onPressed;
  final bool isSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: 45.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: poppinsRegular,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            CustomCheckBox(
              isChecked: isSelected,
            ),
          ],
        ),
      ),
    );
  }
}
