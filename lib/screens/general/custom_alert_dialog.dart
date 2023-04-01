import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/constants/styles.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  CustomAlertDialog({this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 26.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              textAlign: TextAlign.center,
              style: kTitleTextStyle,
            ),
            SizedBox(height: 20.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: kDetailsTextStyle,
            ),
            SizedBox(height: 40.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: ActionButton(
                    buttonText: 'OK',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
