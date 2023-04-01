import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/cupertino_datetime_picker_popup.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/auth/sms_verification_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'dart:io';

import 'package:haloapp/components/model_progress_hud.dart';

class SignUpPage extends StatefulWidget {
  static const String id = 'signupPage';

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _showSpinner = false;
  String _fullNameTFValue;
  String _emailTFValue;
  String _mobileNoTFValue;
  String _referralTFValue;
  String _passwordTFValue;
  String _confirmPasswordTFValue;
  DateTime _dateOfBirthValue;
  String _selectedCountry = '+60';
  Map _countryFlag = {
    '+60': '🇲🇾',
    '+65': '🇸🇬',
    '+62': '🇮🇩',
    '+66': '🇹🇭',
    '+673': '🇧🇳',
    '+44': '🇬🇧',
    '+57': '🇨🇴'
  };

  TextEditingController fullNameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController mobileNoEditingController = TextEditingController();
  TextEditingController referralEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController confirmPasswordEditingController = TextEditingController();

  void registerAccount() async {
    if (_fullNameTFValue == null || _fullNameTFValue.isEmpty) {
      showSimpleFlushBar(AppTranslations.of(context).text('please_enter_your_name'), context);
      return;
    }

    if (_emailTFValue == null || _emailTFValue.isEmpty) {
      showSimpleFlushBar(AppTranslations.of(context).text('please_enter_your_email'), context);
      return;
    }

    if (_mobileNoTFValue == null || _mobileNoTFValue.isEmpty) {
      showSimpleFlushBar(AppTranslations.of(context).text('please_enter_your_mobile_num'), context);
      return;
    }

    if (_passwordTFValue == null || _passwordTFValue.isEmpty) {
      showSimpleFlushBar(AppTranslations.of(context).text('please_enter_password'), context);
      return;
    }

    if (_confirmPasswordTFValue == null || _confirmPasswordTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_your_confirm_password'), context);
      return;
    }

    if (_passwordTFValue != _confirmPasswordTFValue) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('your_confirm_pass_is_not_same'), context);
      return;
    }

    Map<String, dynamic> params = {
      "data": {
        "email": _emailTFValue,
        "userRef": _referralTFValue,
        "name": _fullNameTFValue,
        "phone": _selectedCountry + _mobileNoTFValue,
        "password": _passwordTFValue,
        "confirmPassword": _passwordTFValue,
        "dob": (_dateOfBirthValue != null)
            ? "${_dateOfBirthValue.year}-${_dateOfBirthValue.month}-${_dateOfBirthValue.day}"
            : '',
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await AuthNetworking().register(params);

      Navigator.pushNamed(context, SMSVerificationPage.id,
          arguments: {"phoneNumber": _selectedCountry + _mobileNoTFValue, "tokenKey": data});
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
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          // FocusScopeNode currentFocus = FocusScope.of(context);

          // if (!currentFocus.hasPrimaryFocus) {
          //   currentFocus.unfocus();
          // }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
              icon: arrowBack,
              onPressed: () => {Navigator.pop(context)},
            ),
            title: Text(AppTranslations.of(context).text('register_title'),
                textAlign: TextAlign.center, style: kAppBarTextStyle),
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
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 35, horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      InputTextField(
                        hintText: AppTranslations.of(context).text('name'),
                        onChange: (value) {
                          print('>>> ' + value);
                          _fullNameTFValue = value;
                        },
                        controller: fullNameEditingController,
                      ),
                      SizedBox(height: 10),
                      InputTextField(
                        hintText: AppTranslations.of(context).text('email'),
                        inputType: TextInputType.emailAddress,
                        onChange: (value) {
                          _emailTFValue = value;
                        },
                        controller: emailEditingController,
                      ),
                      SizedBox(height: 10),
                      InputTextField(
                        prefix: Container(
                          alignment: Alignment.center,
                          width: 100,
                          height: 50,
                          child: DropdownButton(
                            value: _selectedCountry,
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: kColorRed,
                              size: 20,
                            ),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(
                              fontSize: 16,
                              color: kColorRed,
                            ),
                            underline: Container(
                              height: 0,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedCountry = newValue;
                              });
                            },
                            items: _countryFlag.keys
                                .toList()
                                .cast<String>()
                                .map<DropdownMenuItem>((String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(
                                  _countryFlag[value] + ' ' + value,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: poppinsMedium,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        hintText: AppTranslations.of(context).text('mobile_number'),
                        inputType: TextInputType.number,
                        onChange: (value) {
                          _mobileNoTFValue = value;
                        },
                        controller: mobileNoEditingController,
                      ),
                      SizedBox(height: 10),
                      PasswordInputTextField(
                        hintText: AppTranslations.of(context).text('password'),
                        onChange: (value) {
                          _passwordTFValue = value;
                        },
                        controller: passwordEditingController,
                      ),
                      SizedBox(height: 10),
                      PasswordInputTextField(
                        hintText: AppTranslations.of(context).text('confirm_password'),
                        onChange: (value) {
                          _confirmPasswordTFValue = value;
                        },
                        controller: confirmPasswordEditingController,
                      ),
                      SizedBox(height: 10),
                      InputTextField(
                        hintText: AppTranslations.of(context).text('referral_code'),
                        // inputType: TextInputType.emailAddress,
                        onChange: (value) {
                          _referralTFValue = value;
                        },
                      ),
                      SizedBox(height: 40.0),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 12),
                          children: [
                            TextSpan(
                              text: AppTranslations.of(context).text('register_t&c1'),
                            ),
                            TextSpan(
                              style: TextStyle(
                                color: kColorRed,
                                decoration: TextDecoration.underline,
                              ),
                              text: AppTranslations.of(context).text('register_t&c2'),
                            ),
                            TextSpan(
                              text: AppTranslations.of(context).text('register_t&c3'),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ActionButton(
                            buttonText: AppTranslations.of(context).text('register_btn_submit'),
                            onPressed: () {
                              registerAccount();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show iOS date picker
  void _showIOSDatePicker() {
    CupertinoDatetimePickerPopup().showCupertinoPicker(context,
        mode: CupertinoDatePickerMode.date,
        minDate: DateTime(DateTime.now().year - 100),
        lastDate: DateTime(DateTime.now().year),
        initialDate: DateTime(DateTime.now().year - 1), onChanged: (DateTime value) {
      if (value != null) {
        setState(() {
          _dateOfBirthValue = value;
        });
      }
    });
  }

  // Android Date picker
  void _showAndroidDatePicker() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 100),
      lastDate: DateTime(DateTime.now().year),
      initialDate: DateTime(DateTime.now().year - 1),
    );

    if (date != null)
      setState(() {
        _dateOfBirthValue = date;
      });
  }
}
