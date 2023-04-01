import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class AddressText extends StatelessWidget {
  AddressText({
    this.onCardPressed,
    this.primaryText,
    this.secondaryText,
    this.isSaved = false,
    this.showSaveBtn = true,
    this.onSavePressed,
  });
  final onCardPressed;
  final primaryText;
  final secondaryText;
  final isSaved;
  final showSaveBtn;
  final onSavePressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardPressed,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryText,
                    style: TextStyle(fontFamily: poppinsMedium),
                  ),
                  Text(
                    secondaryText,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            if (showSaveBtn)
              IconButton(
                onPressed: onSavePressed,
                icon: Icon(
                  // isSaved ? Icons.favorite : Icons.favorite_border,
                  isSaved
                      ? Icons.edit_outlined
                      : Icons.bookmark_border_outlined,
                  color: kColorLightRed,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
