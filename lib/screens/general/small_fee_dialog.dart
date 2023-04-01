import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/constants/styles.dart';

class SmallFeeAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  SmallFeeAlertDialog({this.title, this.message,this.buttonText});

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.asset("images/ic_notice.png",width: 30.0,height: 30.0,),
                      SizedBox(width: 3.0,),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: kAddressTextStyle,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Image.asset("images/ic_cancel.png",width: 30.0,height: 30.0,)
                ),
              ],
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
                    buttonText: buttonText,
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
