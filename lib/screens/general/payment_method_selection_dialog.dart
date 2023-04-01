import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/styles.dart';

class PaymentMethodSelectionDialog extends StatefulWidget {
  PaymentMethodSelectionDialog({@required this.bookingType});

  final String bookingType;

  @override
  _PaymentMethodSelectionDialogState createState() =>
      _PaymentMethodSelectionDialogState();
}

class _PaymentMethodSelectionDialogState
    extends State<PaymentMethodSelectionDialog> {
  final List<String> _paymentMethods = ['cod', 'card', 'fpx', 'ewallet'];

  String _selectedMethod;

  @override
  void initState() {
    super.initState();

    if (widget.bookingType == 'food') {
      _selectedMethod = FoodOrderModel().getPaymentMethod() ?? 'cod';
    } else if (widget.bookingType == 'express') {
      _selectedMethod = BookingModel().getPaymentMethod() ?? 'cod';
    }
  }

  Widget buildList() {
    List<Widget> list = [];

    for (int i = 0; i < _paymentMethods.length; i++) {
      String method = _paymentMethods[i];

      Widget radioBtn = ListTile(
        contentPadding: EdgeInsets.all(0),
        title: GestureDetector(
          onTap: () {
            setState(() {
              _selectedMethod = method;
            });
          },
          child: Text(
            AppTranslations.of(context).text(method),
            style: kDetailsTextStyle,
          ),
        ),
        leading: Radio(
          value: method,
          groupValue: _selectedMethod,
          onChanged: (value) {
            setState(() {
              _selectedMethod = value;
            });
          },
        ),
      );

      list.add(radioBtn);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }

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
              AppTranslations.of(context).text('payment_method'),
              textAlign: TextAlign.center,
              style: kTitleTextStyle,
            ),
            SizedBox(height: 40.0),
            buildList(),
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
                      Navigator.pop(context, _selectedMethod);
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
