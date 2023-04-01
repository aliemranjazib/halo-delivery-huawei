import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components_new/custom_check_box.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/payment_method_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/ewallet_networking.dart';
import 'package:haloapp/screens/main/ewallet_top_up_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/payment_method.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/utils.dart';

class PaymentMethodSelectionDialog extends StatefulWidget {
  PaymentMethodSelectionDialog({
    @required this.bookingType,
    @required this.onChanged,
    this.selectedMethod,
    this.filters,
  });

  final String bookingType;
  final String selectedMethod;
  final Function(String) onChanged;
  final List<String> filters;

  @override
  _PaymentMethodSelectionDialogState createState() =>
      _PaymentMethodSelectionDialogState();
}

class _PaymentMethodSelectionDialogState
    extends State<PaymentMethodSelectionDialog> {
  List<PaymentMethodModel> _paymentMethods =
      PaymentMethod().getPaymentMethods();

  @override
  void initState() {
    super.initState();
    List<dynamic> validPaymentMethods = [];
    if (widget.bookingType == 'food') {
      validPaymentMethods = FoodOrderModel().getPaymentMethods();
    } else if (widget.bookingType == 'express') {
      validPaymentMethods = BookingModel().getPaymentMethods();
    }

    _paymentMethods = PaymentMethod()
        .getPaymentMethods()
        .where((e) => validPaymentMethods.any((ie) => e.name == ie))
        .toList();

    _initWalletBalance();
  }

  Widget buildList() {
    List<Widget> list = [];

    for (int i = 0; i < _paymentMethods.length; i++) {
      PaymentMethodModel method = _paymentMethods[i];

      Widget radioBtn = GestureDetector(
        onTap: () {
          widget.onChanged(method.name);
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: lightGrey,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.only(right: 16),
                child: Image.asset(
                  method.image,
                  width: 24,
                  height: 24,
                ),
              ),
              getContainer(method),
              CustomCheckBox(isChecked: widget.selectedMethod == method.name),
            ],
          ),
        ),
      );

      list.add(radioBtn);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }

  Widget getContainer(PaymentMethodModel paymentMethodModel) {
    try {
      if (paymentMethodModel.name == "haloWallet" &&
          User().walletTransactionsResponse?.response?.walletBalance != null) {
        return Expanded(
            child: ValueListenableBuilder(
          valueListenable: User.walletTransactionsResponseNotifier,
          builder: (BuildContext context, dynamic value, Widget child) {
            return Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(AppTranslations.of(context).text(paymentMethodModel.name) +
                    " (${AppTranslations.of(context).text("currency_my")}" +
                    "${Utils.getFormattedPrice(double.parse(User().walletTransactionsResponse?.response?.walletBalance))})"),
                if (isInSufficientBalance())
                  Container(
                      width: 80.0,
                      height: 30.0,
                      margin: EdgeInsets.only(left: 6.0),
                      child: ActionSmallButton(
                        buttonText: AppTranslations.of(context).text("top_up"),
                        onPressed: () {
                          checking();
                        },
                      ))
              ],
            );
          },
        ));
      }
    } catch (e) {
      print(e);
    }
    return Expanded(
      child: Text(AppTranslations.of(context).text(paymentMethodModel.name)),
    );
  }

  bool isInSufficientBalance() {
    try {
      if (widget.bookingType == 'food') {
        return User().walletTransactionsResponse != null &&
            double.parse(
                    User().walletTransactionsResponse.response.walletBalance) <
                double.parse(FoodOrderModel().getFinalPrice());
      } else if (widget.bookingType == 'express') {
        return User().walletTransactionsResponse != null &&
            double.parse(
                    User().walletTransactionsResponse.response.walletBalance) <
                double.parse(BookingModel().getTotalPrice());
      }
    } catch (e) {
      print(e);
    }

    return false;
  }

  void checking() async {
    try {
      double requiredAmount = double.parse(FoodOrderModel().getFinalPrice()) -
          double.parse(
              User().walletTransactionsResponse.response.walletBalance);

      var isTopUp = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EwalletTopUpPage(
            requiredAmount: Utils.roundDouble(requiredAmount, 2),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
    return;
  }

  _initWalletBalance() async {
    Map<String, dynamic> params = {
      "data": {
        "userToken": User().getUserToken(),
      }
    };
    print(params);

    try {
      var data = await EwalletNetworking().getEwalletTransaction(params);
      print("DATA == ${data.toJson()}");
      User().setEwalletTransaction(data);
    } catch (e) {
      print(e.toString());
      if (e is Map<String, dynamic>) {
      } else {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppTranslations.of(context).text('payment_method'),
                  style: kTitleTextStyle,
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 10.0),
            buildList(),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
