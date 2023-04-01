import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class BookingConfirmationDialog extends StatelessWidget {
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
              AppTranslations.of(context).text('booking_confirmation'),
              textAlign: TextAlign.center,
              style: kTitleTextStyle,
            ),
            SizedBox(height: 20.0),
            Text(
              AppTranslations.of(context)
                  .text('confirm_to_book_ques_please_select_payment_method'),
              textAlign: TextAlign.center,
              style: kDetailsTextStyle,
            ),
            SizedBox(height: 40.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'images/cash_payment.png',
                            height: 60.0,
                          ),
                          Text(
                            AppTranslations.of(context).text('cod'),
                            style: TextStyle(
                                fontFamily: poppinsMedium, fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, 'cod');
                    },
                  ),
                ),
                SizedBox(
                  width: 8.0,
                  child: Divider(
                    thickness: 2,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'images/online_payment.png',
                            height: 60.0,
                          ),
                          Text(
                            AppTranslations.of(context).text('online'),
                            style: TextStyle(
                                fontFamily: poppinsMedium, fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, 'online');
                    },
                  ),
                )
              ],
            ),
            SizedBox(height: 20.0),
            ActionButtonLight(
              buttonText: AppTranslations.of(context).text('cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
