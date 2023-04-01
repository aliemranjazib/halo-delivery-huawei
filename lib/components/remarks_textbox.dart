import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/styles.dart';
import '../utils/constants/fonts.dart';

class RemarksTextBox extends StatelessWidget {
  final String hintText;
  final Function onChanged;
  final TextEditingController controller;

  RemarksTextBox({this.hintText, this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(
            style: BorderStyle.solid,
            color: Colors.grey,
            width: 1,
          )),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 120.0,
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            reverse: true,
            child: SizedBox(
              height: 100.0,
              child: TextField(
                onChanged: onChanged,
                keyboardType: TextInputType.multiline,
                maxLines: 80,
                controller: controller,
                style: kInputTextStyle,
                decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: kInputTextStyle,
                    contentPadding: EdgeInsets.symmetric(horizontal: 5),
                    border: OutlineInputBorder(borderSide: BorderSide.none)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
