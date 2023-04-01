import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';

class SearchBarInput extends StatelessWidget {
  SearchBarInput({
    this.onChange,
    this.defaultBorderColor,
    this.onTap,
    this.isAutoFocus = false,
  });

  final Function onChange;
  final Function onTap;
  final Color defaultBorderColor;
  final bool isAutoFocus;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Colors.white,
          // boxShadow: [
          //   elevation
          // ],
        ),
        child: TextField(
          onChanged: (key) {
            onChange(key);
          },
          // autofocus: onTap == null,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8),
            prefixIcon: Icon(
              Icons.search,
              color: kColorRed,
            ),
            enabled: isAutoFocus,
            hintText: 'Search',
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: defaultBorderColor != null
                      ? defaultBorderColor
                      : Colors.white,
                  width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              // borderSide: BorderSide(color: kColorLightRed, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kColorLightRed, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: defaultBorderColor != null
                      ? defaultBorderColor
                      : Colors.white,
                  width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
