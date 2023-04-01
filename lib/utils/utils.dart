import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/environment_widget.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;

import 'constants/fonts.dart';

class Utils {
  static final List<String> fields = [
    "address_components",
    "name",
    "place_id",
    "formatted_address",
    "geometry"
  ];

  static String getRandomUuid() {
    var uuid = Uuid();
    return uuid.v1().toString();
  }

  static Uuid parseUuid(String uuidString) {
    var uuid = Uuid();

    var bytes = Uuid.parse(uuidString);
    uuid.v1buffer(bytes);
    return uuid;
  }

  static Widget getEnvironment() {
    if (APIUrls.ENVIRONMENT == APIUrls.STAGING_ENVIRONMENT) {
      return BlinkingTextAnimation();
    } else {
      return SizedBox.shrink();
    }
  }

  static hideKeyboard() {
    Future.delayed(Duration(milliseconds: 100), () {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    });
  }

  static String getFormattedPrice(double price) {
    if (price == null) {
      return "";
    }
    return price.toStringAsFixed(2);
  }

  static double roundDouble(double value, int places) {
    double mod = math.pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  static void showChatConfirmationDialog(
    BuildContext context,
    Function() callBack,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Ready to chat?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: poppinsSemiBold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 32,
              ),
              Row(
                children: [
                  Container(
                    child: ActionButton(
                      onPressed: () {
                        Navigator.pop(context);
                        callBack();
                      },
                      buttonText: 'YES',
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: ActionButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      buttonText: 'NO',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
