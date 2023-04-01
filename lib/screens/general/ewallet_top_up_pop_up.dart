import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/utils.dart';

class EwalletAlertDialog extends StatelessWidget {
  final String title;
  final double topUpAmount;
  final double feeAmount;

  EwalletAlertDialog({this.title, @required this.topUpAmount, @required this.feeAmount});

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
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${AppTranslations.of(context).text("title_top_up_amount")}",
                      textAlign: TextAlign.start,
                      style: kLabelTextStyle,
                    ),
                  ),
                ),
                Text(
                  ":",
                  textAlign: TextAlign.center,
                  style: kLabelSemiBoldTextStyle,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${AppTranslations.of(context).text("currency_my")} ${Utils.getFormattedPrice(topUpAmount)}",
                      textAlign: TextAlign.end,
                      style: kDetailsTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${AppTranslations.of(context).text("title_fee_amount")}",
                      textAlign: TextAlign.start,
                      style: kLabelTextStyle,
                    ),
                  ),
                ),
                Text(
                  ":",
                  textAlign: TextAlign.center,
                  style: kLabelSemiBoldTextStyle,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${AppTranslations.of(context).text("currency_my")} ${Utils.getFormattedPrice(feeAmount)}",
                      textAlign: TextAlign.end,
                      style: kDetailsTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${AppTranslations.of(context).text("title_total_amount")}",
                      textAlign: TextAlign.start,
                      style: kLabelTextStyle,
                    ),
                  ),
                ),
                Text(
                  ":",
                  textAlign: TextAlign.center,
                  style: kLabelSemiBoldTextStyle,
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${AppTranslations.of(context).text("currency_my")} ${Utils.getFormattedPrice(topUpAmount+feeAmount)}",
                      textAlign: TextAlign.end,
                      style: kDetailsTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: ActionButtonLight(
                    buttonText: 'Cancel',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 6.0,),
                Expanded(
                  child: ActionButton(
                    buttonText: 'Confirm',
                    onPressed: () {
                      Navigator.pop(context,"confirm");
                    },
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
