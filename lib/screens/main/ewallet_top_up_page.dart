import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/components/labeled_checkbox.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/components/search_bar_input.dart';
import 'package:haloapp/components_new/shop_card.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/models/top_up_method_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/ewallet_networking.dart';
import 'package:haloapp/networkings/food_networking.dart';
import 'package:haloapp/screens/auth/login_page.dart';
import 'package:haloapp/screens/boarding/success_page_ewallet.dart';
import 'package:haloapp/screens/general/ewallet_top_up_pop_up.dart';
import 'package:haloapp/screens/general/online_payment_page.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/debouncer.dart';
import 'package:haloapp/utils/services/datetime_formatter.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/utils/utils.dart';

import 'ewallet_online_payment_page.dart';

class EwalletTopUpPage extends StatefulWidget {
  static const String id = 'ewalletTopUpPage';

  EwalletTopUpPage({
    this.requiredAmount = 0,
  });

  final double requiredAmount;

  @override
  _EwalletTopUpPageState createState() => _EwalletTopUpPageState();
}

class _EwalletTopUpPageState extends State<EwalletTopUpPage> {
  bool _showSpinner = false;
  List<double> topUpAmount = [10.0, 50.0, 100.0, 150.0, 200.0, 300.0];
  List<TopUpMethodModel> _paymentMethods = <TopUpMethodModel>[];
  TextEditingController topUpAmountTextController = TextEditingController();
  double finalTopUpAmount = 0.00;
  SizedBox space = SizedBox(
    height: 10.0,
  );
  int selectedAmountPos = -1;
  int selectedPaymentMethod = 0;
  bool isEnableTopUp = false;

  @override
  void initState() {
    super.initState();
    if (widget.requiredAmount > 0) {
      selectTopUpAmount(widget.requiredAmount);
    }
    _paymentMethods.addAll(AppConfig.paymentMethods);
    topUpAmount.clear();
    topUpAmount.addAll(AppConfig.consumerConfig.topUpAmount);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: arrowBack),
          ),
          title: Text('${AppTranslations.of(context).text("title_top_up")}',
              textAlign: TextAlign.center, style: kAppBarTextStyle),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "${AppTranslations.of(context).text("title_top_up_desc")}",
                        style: kLabelSemiBoldTextStyle,
                      ),
                      space,
                      InputTextFormField(
                        prefixText:
                            "${AppTranslations.of(context).text("currency_my")}",
                        controller: topUpAmountTextController,
                        inputType:
                            TextInputType.numberWithOptions(decimal: true),
                        onChange: (value) {
                          setState(() {
                            selectedAmountPos = -1;
                            if (value.toString().isNotEmpty &&
                                double.parse(value) != 0.0) {
                              isEnableTopUp = true;
                            } else {
                              isEnableTopUp = false;
                            }
                          });
                        },
                        textInputFormatter:
                            DecimalTextInputFormatter(decimalRange: 2),
                        hintText:
                            "${AppTranslations.of(context).text("title_top_up_amount")}",
                      ),
                      space,
                      Wrap(
                        children: List.generate(topUpAmount.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              if (selectedAmountPos == index) {
                                setState(() {
                                  selectedAmountPos = -1;
                                  selectTopUpAmount(0.00);
                                });
                              } else {
                                setState(() {
                                  selectedAmountPos = index;
                                  selectTopUpAmount(topUpAmount[index]);
                                });
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: isSelected(index)
                                        ? Colors.black
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      width: 1.4,
                                      color: Colors.black,
                                    ),
                                  ),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 3.0, vertical: 6.0),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 10.0),
                                  width: 120.0,
                                  child: Center(
                                    child: Text(
                                      "${AppTranslations.of(context).text("currency_my")} ${Utils.getFormattedPrice(topUpAmount[index])}",
                                      style: kLabelSemiBoldTextStyle.copyWith(
                                          color: isSelected(index)
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                                isSelected(index)
                                    ? Positioned(
                                        right: 0.0,
                                        top: 0.0,
                                        child: Image.asset(
                                          "images/ic_red_tick.png",
                                          width: 15.0,
                                          height: 15.0,
                                        ))
                                    : SizedBox.shrink()
                              ],
                            ),
                          );
                        }),
                      ),
                      space,
                      Text(
                        "${AppTranslations.of(context).text("title_payment_option")}",
                        style: kLabelSemiBoldTextStyle,
                      ),
                      ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return CheckboxWithContents(
                              onChanged: (value) {
                                if (selectedPaymentMethod != index) {
                                  setState(() {
                                    selectedPaymentMethod = index;
                                  });
                                }
                              },
                              value: selectedPaymentMethod == index,
                              padding: EdgeInsets.only(top: 0),
                              content: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        _paymentMethods[index].paymentIcon,
                                        width: 50.0,
                                        height: 40.0,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                          "${AppTranslations.of(context).text(_paymentMethods[index].paymentTitle)}",
                                          style: kDetailsTextStyle),
                                    ],
                                  )),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Container();
                          },
                          itemCount: _paymentMethods.length)
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: ActionButton(
                    buttonText:
                        "${AppTranslations.of(context).text("title_top_up")}",
                    onPressed: isEnableTopUp
                        ? () {
                            checkTopUpCalculation();
                            // performTopUp();
                          }
                        : null,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void selectTopUpAmount(double amount) {
    setState(() {
      topUpAmountTextController.text = Utils.getFormattedPrice(amount);
      topUpAmountTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: topUpAmountTextController.text.length));
      if (amount != 0.0) {
        isEnableTopUp = true;
      } else {
        isEnableTopUp = false;
      }
    });
  }

  void checkTopUpCalculation() async {
    double topUpAmount = double.parse(topUpAmountTextController.text);

    if (topUpAmount < AppConfig.consumerConfig.topUpMinAmount) {
      showSimpleFlushBar(
          "${AppTranslations.of(context).text('ewallet_min_top_alert')} ${AppTranslations.of(context).text("currency_my")} ${Utils.getFormattedPrice(AppConfig.consumerConfig.topUpMinAmount)}",
          context);
      return;
    } else if (topUpAmount > AppConfig.consumerConfig.topUpMaxAmount) {
      showSimpleFlushBar(
          "${AppTranslations.of(context).text('ewallet_max_top_alert')} ${AppTranslations.of(context).text("currency_my")} ${Utils.getFormattedPrice(AppConfig.consumerConfig.topUpMaxAmount)}",
          context);
      return;
    } else if (topUpAmount < widget.requiredAmount) {
      showSimpleFlushBar(
          "${AppTranslations.of(context).text('ewallet_min_top_alert')} ${AppTranslations.of(context).text("currency_my")} ${widget.requiredAmount}",
          context);
      return;
    }

    Map<String, dynamic> params = {
      "data": {
        "amount": "${double.parse(topUpAmountTextController.text)}",
        "paymentMethod": "${_paymentMethods[selectedPaymentMethod].paymentType}"
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await EwalletNetworking().topUpCalculation(params);

      print(data);
      if (data is Map<String, dynamic>) {
        showDialog(
            context: context,
            builder: (context) => EwalletAlertDialog(
                  title: "${AppTranslations.of(context).text("title_top_up")}",
                  topUpAmount: double.tryParse(topUpAmountTextController.text),
                  feeAmount: double.tryParse(data["paymentFee"]),
                )).then((value) {
          if (value != null && value == 'confirm') {
            performTopUp();
          }
        });
      }
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void performTopUp() async {
    if (topUpAmountTextController.text.isEmpty) {
      showSimpleFlushBar(
          "${AppTranslations.of(context).text("error_select_an_amount")}",
          context);
      return;
    } else if (topUpAmountTextController.text.isNotEmpty &&
        (double.parse(topUpAmountTextController.text) < topUpAmount.first ||
            double.parse(topUpAmountTextController.text) > topUpAmount.last)) {
      showSimpleFlushBar(
          "${AppTranslations.of(context).text("error_select_an_amount_within")} RM${Utils.getFormattedPrice(topUpAmount.first)} - RM${Utils.getFormattedPrice(topUpAmount.last)}",
          context);
      return;
    }

    Map<String, dynamic> params = {
      "data": {
        "amount": "${double.parse(topUpAmountTextController.text)}",
        "paymentMethod": "${_paymentMethods[selectedPaymentMethod].paymentType}"
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await EwalletNetworking().topUp(params);

      print(data);
      if (data is Map<String, dynamic>) {
        // Online payment
        proceedToOnlinePayment(data['paymentUrl']);
      } else {
        // _showSuccessOrderPopup();
      }
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void checkTopUpStatus(String paymentId) async {
    Map<String, dynamic> params = {
      "apiKey": APIUrls().getWebApiKey(),
      "data": {
        "authNumber": "${paymentId}",
        "paymentMethod": "${_paymentMethods[selectedPaymentMethod].paymentType}"
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await EwalletNetworking().checkTopUpStatus(params);

      print(data);
      if (data is Map<String, dynamic>) {
        //Result
        // String status = data["payment"]["topup_status"];
        // print("payment : ${data["billPlz"]["paid"]}");
        // print("payment : ${data["billPlz"]["paid"] == "true"}");
        bool status = data["billPlz"]["paid"];
        String topUpDateTime = DatetimeFormatter().getFormattedDateStr(
          format: "dd/MM/yyyy HH:mm:ss",
          datetime: data["payment"]["topup_datetime"],
        );
        // String refNo = data["billPlz"]["description"];
        String refNo = data["billPlz"]["reference_2"];
        _showSuccessPopup(status, topUpDateTime, refNo);
      } else {
        // _showSuccessOrderPopup();
      }
    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  bool isSelected(int pos) {
    return pos == selectedAmountPos;
  }

  void proceedToOnlinePayment(String paymentLink) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              EwalletOnlinePaymentPage(paymentLink: paymentLink)),
    ).then((value) async {
      if (value != null && value == 'onlinePaymentSuccess') {
        String paymentId = paymentLink.split("/").last;
        checkTopUpStatus(paymentId);
        // _showSuccessPopup(true);
      } else {
        Navigator.popUntil(context, ModalRoute.withName(TabBarPage.id));
      }
    });
  }

  _initWalletBalance() async {
    setState(() {
      _showSpinner = true;
    });

    Map<String, dynamic> params = {
      "data": {
        "userToken": User().getUserToken(),
      }
    };
    print(params);

    try {
      var data = await EwalletNetworking().getEwalletTransaction(params);
      print("DATA == ${data.toJson()}");
      setState(() {
        User().setEwalletTransaction(data);
      });
    } catch (e) {
      print(e.toString());
      if (e is Map<String, dynamic>) {
        if (e['status_code'] == 514) {
          SharedPrefService().removeLoginInfo();
          Navigator.popUntil(context, ModalRoute.withName(LoginPage.id));
        }
      } else {
        showSimpleFlushBar(e.toString(), context);
      }
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  _showSuccessPopup(bool status, String createdDate, String refNo) async {
    if (status) {
      await _initWalletBalance();
      if (widget.requiredAmount > 0) {
        Navigator.pop(context, status);
      } else {
        Navigator.popUntil(context, ModalRoute.withName(TabBarPage.id));
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessEwalletPage(
          status: status,
          topUpAmount: double.tryParse(topUpAmountTextController.text),
          dateTime: createdDate,
          refNo: refNo,
          topUpMethodModel: _paymentMethods[selectedPaymentMethod],
        ),
      ),
    );
  }
}
