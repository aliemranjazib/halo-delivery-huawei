import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class ShopTag extends StatelessWidget {
  ShopTag({
    this.tag,
    this.isHighlight = false,
  });

  final String tag;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? kColorRed : kColorLightRed3,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tag,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isHighlight ? Colors.white : kColorRed,
          fontFamily: isHighlight ? poppinsSemiBold : poppinsRegular,
          fontSize: 10,
        ),
      ),
    );
  }
}
