import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/models/payment_method_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/ewallet_networking.dart';
import 'package:haloapp/screens/main/ramadan/order_response_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'dart:math' as math;

import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/utils/utils.dart';

class DonationPaymentMethodSelectionBox extends StatelessWidget {
  DonationPaymentMethodSelectionBox(
      {this.image,
      this.paymentMethod,
      this.onPressed,
      this.isShowBalance = false});

  final String image;
  final PaymentMethodWithIcon paymentMethod;
  final Function onPressed;
  final bool isShowBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 10.0,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: [
              Text(AppTranslations.of(context).text('payment_method'),
                  style: kAddressTextStyle),
            ],
          ),
          SizedBox(height: 10.0),
          GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 16),
                    child: (paymentMethod.methodIconUrl == null)
                        ? Image.asset(
                            'images/halo_logo.png',
                            width: 24,
                            height: 24,
                          )
                        : Image.network(
                            paymentMethod.methodIconUrl,
                            width: 24,
                            height: 24,
                          ),
                  ),
                  getContainer(context, paymentMethod),
                  Transform.rotate(
                    angle: -90 * math.pi / 180,
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getContainer(
      BuildContext context, PaymentMethodWithIcon paymentMethodModel) {
    try {
      if (paymentMethodModel.methodName == "haloWallet" &&
          User().walletTransactionsResponse?.response?.walletBalance != null &&
          isShowBalance) {
        return Expanded(
          child: Text(AppTranslations.of(context)
                  .text(paymentMethodModel.methodName) +
              " (${AppTranslations.of(context).text("currency_my")}" +
              "${Utils.getFormattedPrice(double.parse(User().walletTransactionsResponse?.response?.walletBalance))})"),
        );
      }
    } catch (e) {
      print(e);
    }
    return Expanded(
      child: Text(paymentMethodModel.methodDisplayName),
      // child: Text(AppTranslations.of(context).text(paymentMethodModel.name)),
    );
  }
}
