import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class ChangePasswordPage extends StatefulWidget {
  static const String id = 'changePasswordPage';

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _showSpinner = false;
  String _oldPasswordTFValue;
  String _passwordTFValue;
  String _confirmPasswordTFValue;
  TextEditingController _oldPasswordTextController;
  TextEditingController _newPasswordTextController;
  TextEditingController _confirmPasswordTextController;

  @override
  void initState() {
    super.initState();

    _oldPasswordTextController =
        TextEditingController(text: _oldPasswordTFValue);
    _newPasswordTextController = TextEditingController(text: _passwordTFValue);
    _confirmPasswordTextController =
        TextEditingController(text: _confirmPasswordTFValue);
  }

  void changePassword() async {
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
        "oldPassword": _oldPasswordTFValue,
        "newPassword": _passwordTFValue,
        "newConfirmPassword": _passwordTFValue
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      String data = await AuthNetworking().changePassword(params);

      showSimpleFlushBar(data, context, isError: false);

      setState(() {
        _oldPasswordTextController.clear();
        _newPasswordTextController.clear();
        _confirmPasswordTextController.clear();
      });
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
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppTranslations.of(context).text('change_password'),
            style: kAppBarTextStyle,
          ),
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
                        AppTranslations.of(context).text('old_password'),
                        style:
                            TextStyle(fontFamily: poppinsRegular, fontSize: 15),
                      ),
                      InputTextField(
                        obscureText: true,
                        controller: _oldPasswordTextController,
                        onChange: (value) {
                          _oldPasswordTFValue = value;
                        },
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        AppTranslations.of(context).text('new_password'),
                        style:
                            TextStyle(fontFamily: poppinsRegular, fontSize: 15),
                      ),
                      InputTextField(
                        obscureText: true,
                        controller: _newPasswordTextController,
                        onChange: (value) {
                          _passwordTFValue = value;
                        },
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        AppTranslations.of(context)
                            .text('confirm_new_password'),
                        style:
                            TextStyle(fontFamily: poppinsRegular, fontSize: 15),
                      ),
                      InputTextField(
                        obscureText: true,
                        controller: _confirmPasswordTextController,
                        onChange: (value) {
                          _confirmPasswordTFValue = value;
                        },
                      ),
                    ],
                  ),
                  ActionButton(
                    buttonText: AppTranslations.of(context).text('change'),
                    onPressed: () {
                      changePassword();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
