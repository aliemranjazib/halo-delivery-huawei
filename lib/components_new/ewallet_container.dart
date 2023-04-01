import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/screens/boarding/success_page_ewallet.dart';
import 'package:haloapp/screens/general/online_payment_page.dart';
import 'package:haloapp/screens/main/ewallet_top_up_page.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/utils.dart';

class EwalletContainer extends StatelessWidget {
  EwalletContainer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.all(16.0),
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: light3Grey,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: [elevation]),
            child: Row(
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "images/haloje_logo_small.png",
                          width: 50.0,
                          height: 50.0,
                        ),
                        SizedBox(
                          width: 6.0,
                        ),
                        Text(
                          "${AppTranslations.of(context).text("currency_my")}",
                          style: kSmallLabelTextStyle,
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "${getTotalAmount()}",
                                  style: kLargeTitleSemiBoldTextStyle,
                                  maxLines: 1,
                                )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      width: 150.0,
                      child: ActionButton(
                        buttonText: "+Top Up",
                        onPressed: () {
                          Navigator.pushNamed(context, EwalletTopUpPage.id);
                        },
                      ),
                    )
                  ],
                )),
                Image.asset(
                  "images/ic_ewallet.png",
                  width: 60.0,
                  height: 60.0,
                ),
              ],
            )),
      ],
    );
  }

  String getTotalAmount() {
    if (User().walletTransactionsResponse != null) {
      try {
        return Utils.getFormattedPrice(double.tryParse(
            User().walletTransactionsResponse.response.walletBalance));
      } catch (e) {
        print(e);
      }
    }
    return "0.00";
  }
}
