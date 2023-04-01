import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/styles.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  ConfirmationDialog({this.title, this.message});

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
                          textAlign: TextAlign.center,
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
                    buttonText: AppTranslations.of(context).text('cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: ActionButton(
                    buttonText: AppTranslations.of(context).text('confirm'),
                    onPressed: () {
                      Navigator.pop(context, 'confirm');
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
