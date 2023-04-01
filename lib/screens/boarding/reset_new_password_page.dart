import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/auth/login_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/constants/styles.dart';

class ResetNewPasswordPage extends StatefulWidget {
  static const String id = 'resetNewPasswordPage';

  @override
  _ResetNewPasswordPageState createState() => _ResetNewPasswordPageState();
}

class _ResetNewPasswordPageState extends State<ResetNewPasswordPage> {
  bool _showSpinner = false;
  String _otpCodeTFValue;
  String _passwordTFValue;
  String _confirmPasswordTFValue;

  void changePassword() async {
    if (_otpCodeTFValue == null || _otpCodeTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_otp_code'), context);
      return;
    }

    if (_passwordTFValue == null || _passwordTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_password'), context);
      return;
    }

    if (_confirmPasswordTFValue == null || _confirmPasswordTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context)
              .text('please_enter_your_confirm_password'),
          context);
      return;
    }

    if (_passwordTFValue != _confirmPasswordTFValue) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('your_confirm_pass_is_not_same'),
          context);
      return;
    }

    Map<String, dynamic> params = {
      'data': {
        "userToken": User().getUserToken(),
        "passwordOtp": _otpCodeTFValue,
        "newPassword": _passwordTFValue,
        "newConfirmPassword": _passwordTFValue
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      String data = await AuthNetworking().changePassword(params);

      Navigator.popUntil(context, ModalRoute.withName(LoginPage.id));
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
    _otpCodeTFValue = arguments["otpCode"];
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
            leading: IconButton(
              icon: arrowBack,
              onPressed: () => {Navigator.pop(context)},
            ),
            title: Text(
                AppTranslations.of(context).text('set_new_password_title'),
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
                padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context)
                              .text('set_new_password_label'),
                          style: TextStyle(
                            fontFamily: poppinsRegular,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        PasswordInputTextField(
                          hintText:
                              AppTranslations.of(context).text('new_password'),
                          onChange: (value) {
                            _passwordTFValue = value;
                          },
                        ),
                        SizedBox(height: 10.0),
                        PasswordInputTextField(
                          hintText: AppTranslations.of(context)
                              .text('confirm_new_password'),
                          onChange: (value) {
                            _confirmPasswordTFValue = value;
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ActionButton(
                          buttonText: AppTranslations.of(context)
                              .text('set_new_password_btn'),
                          onPressed: () {
                            changePassword();
                          },
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
}
