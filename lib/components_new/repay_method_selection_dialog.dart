import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components_new/custom_check_box.dart';
import 'package:haloapp/models/available_online_payment_model.dart';
import 'package:haloapp/models/calculate_update_payment_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/payment_method_model.dart';
import 'package:haloapp/models/update_payment_model.dart';
import 'package:haloapp/networkings/food_history_networking.dart';
import 'package:haloapp/screens/general/online_payment_page.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/payment_method.dart';
import 'package:haloapp/utils/constants/styles.dart';

class RepayMethodSelectionDialog extends StatefulWidget {
  RepayMethodSelectionDialog({
    @required this.orderUniqueKey,
    @required this.bookingType,
  });

  final String orderUniqueKey;
  final String bookingType;

  @override
  _RepayMethodSelectionDialogState createState() =>
      _RepayMethodSelectionDialogState();
}

class _RepayMethodSelectionDialogState
    extends State<RepayMethodSelectionDialog> {
  List<PaymentMethodModel> _paymentMethods =
      PaymentMethod().getPaymentMethods();
  String finalPrice = '0';
  String paymentMethods;
  CalculateUpdatePaymentModel _calculateUpdatePaymentModel =
      new CalculateUpdatePaymentModel();
  UpdatePaymentModel _updatePaymentModel = new UpdatePaymentModel();
  AvailableOnlinePaymentModel _availableOnlinePaymentModel =
      new AvailableOnlinePaymentModel();

  @override
  void initState() {
    super.initState();
    _availableOnlinePaymentMethod();
  }

  Widget buildList() {
    List<Widget> list = [];

    for (int i = 0; i < _paymentMethods.length; i++) {
      PaymentMethodModel method = _paymentMethods[i];

      Widget radioBtn = GestureDetector(
        onTap: () {
          paymentMethods = method.name;
          _calculateUpdatePayment();
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
              Expanded(
                child: Text(AppTranslations.of(context).text(method.name)),
              ),
              CustomCheckBox(isChecked: paymentMethods == method.name),
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

  _availableOnlinePaymentMethod() async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getApiKey(),
      "data": {'orderUniqueKey': widget.orderUniqueKey},
    };
    print(params);

    try {
      _availableOnlinePaymentModel =
          await FoodHistoryNetworking().getAvailableOnlinePaymentMethod(params);

      List<dynamic> validPaymentMethods = [];

      for (int i = 0;
          i < _availableOnlinePaymentModel.availablePaymentMethod.length;
          i++) {
        if (_availableOnlinePaymentModel.availablePaymentMethod
            .contains(PaymentMethod().getPaymentMethods)) {
          validPaymentMethods.add(PaymentMethod().getPaymentMethods()[i]);
        }
      }

      setState(() {
        _paymentMethods = PaymentMethod()
            .getPaymentMethods()
            .where((e) => _availableOnlinePaymentModel.availablePaymentMethod
                .any((ie) => e.name == ie))
            .toList();
      });
    } catch (e) {
      print(e.toString());
      if (e is Map<String, dynamic>) {
      } else {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {}
  }

  _calculateUpdatePayment() async {
    Map<String, dynamic> params = {
      "data": {
        "orderUniqueKey": widget.orderUniqueKey,
        "paymentMethod": paymentMethods,
      }
    };
    print(params);

    try {
      _calculateUpdatePaymentModel =
          await FoodHistoryNetworking().updatePaymentMethodCalculate(params);
      setState(() {
        finalPrice = _calculateUpdatePaymentModel.finalPrice;
      });
    } catch (e) {
      print(e.toString());
      if (e is Map<String, dynamic>) {
      } else {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {}
  }

  _updatePayment() async {
    Map<String, dynamic> params = {
      "data": {
        "orderUniqueKey": widget.orderUniqueKey,
        "paymentMethod": paymentMethods,
      }
    };
    print(params);

    try {
      _updatePaymentModel =
          await FoodHistoryNetworking().updatePaymentMethod(params);
      proceedToOnlinePayment(_updatePaymentModel.paymentUrl);
    } catch (e) {
      print(e.toString());
      if (e is Map<String, dynamic>) {
      } else {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {}
  }

  void proceedToOnlinePayment(String paymentLink) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OnlinePaymentPage(paymentLink: paymentLink)),
    ).then((value) async {
      if (value != null && value == 'onlinePaymentSuccess') {
        Navigator.pop(context);
        //_showSuccessOrderPopup();
      } else {
        Navigator.popUntil(context, ModalRoute.withName(TabBarPage.id));
        FoodOrderModel().clearFoodOrderData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 500,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
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
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        AppTranslations.of(context).text('final_price'),
                        style: kDetailsTextStyle,
                      ),
                      Text(
                        '${AppTranslations.of(context).text('currency_my')} ' +
                            finalPrice,
                        style: kTitleTextStyle,
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                ActionButtonGreen(
                  buttonText: AppTranslations.of(context).text('pay_again'),
                  onPressed: () {
                    _updatePayment();
                  },
                )
              ],
            ),
            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
