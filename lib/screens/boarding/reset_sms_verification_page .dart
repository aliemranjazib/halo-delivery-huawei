import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/auth/login_page.dart';
import 'package:haloapp/screens/auth/reset_new_password_page.dart';
import 'package:haloapp/screens/general/confirmation_dialog.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ResetSMSVerificationPage extends StatefulWidget {
  static const String id = 'ResetSmsVerificationPage';

  @override
  _ResetSMSVerificationPageState createState() =>
      _ResetSMSVerificationPageState();
}

class _ResetSMSVerificationPageState extends State<ResetSMSVerificationPage> {
  bool _showSpinner = false;
  // List<String> _enteredCodeList = [null, null, null, null, null, null];
  // List<TextEditingController> _controllers = [
  //   TextEditingController(),
  //   TextEditingController(),
  //   TextEditingController(),
  //   TextEditingController(),
  //   TextEditingController(),
  //   TextEditingController(),
  // ];
  Timer _timer;
  int _countdown = 0;

  String _countryCode;
  String _phoneNumber;

  TextEditingController otpController = TextEditingController();
  String otp = "";

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
    _timer.cancel();
    super.dispose();
  }

  void reset() async {
    // for (String code in _enteredCodeList) {
    //   if (code == null || code.isEmpty) {
    //     showSimpleFlushBar(
    //         AppTranslations.of(context).text('please_enter_correct_code'),
    //         context);
    //     return;
    //   }
    // }
    //
    // var concatenate = StringBuffer();
    //
    // _enteredCodeList.forEach((item) {
    //   concatenate.write(item);
    // });

    if (otp == null || otp.isEmpty || otp.length!=6) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_correct_code'),
          context);
      return;
    }

    // String verifyCode = concatenate.toString();
    Navigator.pushNamed(context, ResetNewPasswordPage.id, arguments: {
      'otpCode': otp,
    });
  }

  void resendSmsCode() async {
    if (_countdown != 0) return;
    startTimer();

    Map<String, dynamic> params = {
      'data': {'phone': _countryCode + _phoneNumber}
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      String data = await AuthNetworking().resetPassword(params);
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
    final dynamic arguments = ModalRoute.of(context).settings.arguments;
    _countryCode = arguments["countryCode"];
    _phoneNumber = arguments["phoneNumber"];
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading:
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: AppTranslations.of(context).text('sms_verify_title'),
                        message: AppTranslations.of(context).text('msg_quit'),
                      )).then((value) {
                    if (value != null && value == 'confirm') {
                      Navigator.pop(context);
                    }
                  });
                },
                icon: arrowBack
            ),
            title: Text(
                AppTranslations.of(context).text('sms_verify_title'),
                textAlign: TextAlign.center,
                style: kAppBarTextStyle
            ),
            actions: [
              // IconButton(
              //   icon: Icon(
              //     Icons.close,
              //     color: Colors.white,
              //   ),
              //   onPressed: () => {},
              // ),
            ],
          ),
          body: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context)
                              .text('sms_verify_label')
                              .replaceAll("###", _countryCode+_phoneNumber),
                          style: TextStyle(
                            fontFamily: poppinsRegular,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        createPinCode(),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          AppTranslations.of(context)
                              .text('sms_verify_txt_no_receive'),
                          style: TextStyle(
                            fontFamily: poppinsRegular,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            ActionButtonOutline(
                              onPressed: () {
                                resendSmsCode();
                              },
                              buttonText: _countdown == 0
                                  ? AppTranslations.of(context)
                                      .text('sms_verify_btn_request')
                                  : AppTranslations.of(context)
                                          .text('sms_verify_btn_request') +
                                      " (${_countdown}s)",
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ActionButton(
                          onPressed: () {
                            reset();
                          },
                          buttonText:
                              AppTranslations.of(context).text('btn_continue'),
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

  Widget createPinCode(){
    return PinCodeTextField(
      length: 6,
      obscureText: false,
      cursorColor: kColorLightRed,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 50,
          fieldWidth: 40,
          activeColor: Colors.black,
          activeFillColor: Colors.white,
          borderWidth: 1,
          selectedColor: Colors.black,
          selectedFillColor: Colors.white,
          inactiveColor: Colors.grey,
          inactiveFillColor: Colors.white
      ),
      animationDuration: Duration(milliseconds: 300),
      backgroundColor: Colors.white,
      enableActiveFill: true,
      controller: otpController,
      onCompleted: (v) {
        reset();
      },
      onChanged: (value) {
        print(value);
        setState(() {
          otp = value;
        });
      },
      beforeTextPaste: (text) {
        print("Allowing to paste $text");
        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
        //but you can show anything you want here, like your pop up saying wrong paste format or etc
        return true;
      },
    );
  }

  // Create text fields
  // List<Widget> createTextFields() {
  //   List<Widget> textFields = [];
  //   var numOfCode = _enteredCodeList.length;
  //
  //   for (int i = 0; i < numOfCode; i++) {
  //     Widget textField = Expanded(
  //       child: InputTextField(
  //         controller: _controllers[i],
  //         inputType: TextInputType.number,
  //         onChange: (value) {
  //           // print
  //           if (value.length == 6) {
  //             // print(value.split(''));
  //             _enteredCodeList = value.split('');
  //             for (int i = 0; i < numOfCode; i++) {
  //               _controllers[i].text = _enteredCodeList[i];
  //             }
  //
  //             return;
  //           }
  //           _enteredCodeList[i] = value;
  //           if (value != '') {
  //             if (i == numOfCode - 1) {
  //               FocusScope.of(context).unfocus();
  //             } else {
  //               FocusScope.of(context).nextFocus();
  //             }
  //           }
  //         },
  //       ),
  //     );
  //
  //     SizedBox spacing = SizedBox(width: 5);
  //
  //     textFields.add(textField);
  //     if (i != numOfCode - 1) {
  //       textFields.add(spacing);
  //     }
  //   }
  //
  //   return textFields;
  // }
}
