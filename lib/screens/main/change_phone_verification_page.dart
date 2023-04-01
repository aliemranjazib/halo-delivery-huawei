import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/boarding/login_page.dart';
import 'package:haloapp/screens/boarding/success_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';

class ChangePhoneVerificationPage extends StatefulWidget {
  static const String id = 'ChangePhoneVerificationPage';

  @override
  _ChangePhoneVerificationPageState createState() => _ChangePhoneVerificationPageState();
}

class _ChangePhoneVerificationPageState extends State<ChangePhoneVerificationPage> {
  bool _showSpinner = false;
  List<String> _enteredCodeList = [null, null, null, null, null, null];
  List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  Timer _timer;
  int _countdown = 0;

  String _tokenKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void startTimer() {
    _countdown = 120;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_countdown == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _countdown--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
  }

  void verify() async {
    for (String code in _enteredCodeList) {
      if (code == null || code.isEmpty) {
        showSimpleFlushBar(AppTranslations.of(context).text('please_enter_correct_code'), context);
        return;
      }
    }

    var concatenate = StringBuffer();

    _enteredCodeList.forEach((item) {
      concatenate.write(item);
    });

    String verifyCode = concatenate.toString();

    // Navigator.pushNamedAndRemoveUntil(
    //     context, DeliveryMainPage.id, (route) => route.isFirst);

    Map<String, dynamic> params = {
      "data": {
        "tokenKey": User().getUserToken(),
        "otpCode": verifyCode,
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await AuthNetworking().smsVerification(params);
      showSimpleFlushBar(data, context);
      SharedPrefService().removeLoginInfo();
      BookingModel().clearBookingData();
      FoodOrderModel().clearFoodOrderData();
      User().resetUserData();
      Navigator.of(context).pushNamedAndRemoveUntil(LoginPage.id, (Route<dynamic> route) => false);
    } catch (e) {
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  void resendSmsCode() async {
    if (_countdown != 0) return;
    startTimer();
    Map<String, dynamic> params = {
      "data": {
        "tokenKey": _tokenKey,
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await AuthNetworking().resendVerificationCode(params);

      showSimpleFlushBar(data, context, isError: false);
    } catch (e) {
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String tokenKey = ModalRoute.of(context).settings.arguments;
    _tokenKey = tokenKey;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          body: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 35, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context).text('verify_your_account'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: poppinsSemiBold,
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(
                          height: 55,
                        ),
                        Text(
                          AppTranslations.of(context)
                              .text('we_sent_verification_code_via_sms_for_verification'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: poppinsRegular, fontSize: 16),
                        ),
                        SizedBox(
                          height: 55,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: createTextFields(),
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        ActionButton(
                          onPressed: () {
                            verify();
                          },
                          buttonText: AppTranslations.of(context).text('verify'),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context).text('did_not_receive_the_code_ques'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: poppinsLight, fontSize: 14),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ActionButtonLight(
                          onPressed: () {
                            resendSmsCode();
                          },
                          buttonText: _countdown == 0
                              ? AppTranslations.of(context).text('resend_sms_code')
                              : AppTranslations.of(context).text('resend_sms_code') +
                                  " (${_countdown}s)",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Create text fields
  List<Widget> createTextFields() {
    List<Widget> textFields = [];
    var numOfCode = _enteredCodeList.length;

    for (int i = 0; i < numOfCode; i++) {
      Widget textField = Expanded(
        child: InputTextField(
          controller: _controllers[i],
          inputType: TextInputType.number,
          onChange: (value) {
            // print
            if (value.length == 6) {
              // print(value.split(''));
              _enteredCodeList = value.split('');
              for (int i = 0; i < numOfCode; i++) {
                _controllers[i].text = _enteredCodeList[i];
              }

              return;
            }
            _enteredCodeList[i] = value;
            if (value != '') {
              if (i == numOfCode - 1) {
                FocusScope.of(context).unfocus();
              } else {
                FocusScope.of(context).nextFocus();
              }
            }
          },
        ),
      );

      SizedBox spacing = SizedBox(width: 5);

      textFields.add(textField);
      if (i != numOfCode - 1) {
        textFields.add(spacing);
      }
    }

    return textFields;
  }
}
