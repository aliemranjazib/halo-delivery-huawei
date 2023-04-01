import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/constants/styles.dart';

class CustomButtonAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final Function buttonOnClick;
  final String buttonText2;
  final Function buttonOnClick2;

  CustomButtonAlertDialog({
    this.title,
    this.message,
    this.buttonText,
    this.buttonOnClick,
    this.buttonText2,
    this.buttonOnClick2
  });

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
                      SizedBox(width: 6.0,),
                      Flexible(
                        child: Text(
                          title,
                          textAlign: TextAlign.start,
                          style: kAddressTextStyle,
                        ),
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
            Container(
              width: double.infinity,
              child: Text(
                message,
                textAlign: TextAlign.start,
                style: kDetailsTextStyle,
              ),
            ),
            SizedBox(height: 40.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: ActionButtonLight(
                    buttonText: buttonText,
                    onPressed: buttonOnClick,
                  ),
                ),
                SizedBox(
                  width: 6.0,
                ),
                Expanded(
                  child: ActionButton(
                    buttonText: buttonText2,
                    onPressed: buttonOnClick2,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
