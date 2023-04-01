import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class ProfileOption extends StatelessWidget {
  ProfileOption({
    this.icon,
    this.label,
    this.onPressed,
  });

  final String icon;
  final String label;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            color: lightGrey,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3),
              child: Image.asset(
                icon,
                width: 25,
              ),
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(fontFamily: poppinsSemiBold, fontSize: 15),
            )
          ],
        ),
      ),
    );
  }
}
