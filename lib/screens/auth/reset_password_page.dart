import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/auth/reset_new_password_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/components/model_progress_hud.dart';

class ResetPasswordPage extends StatefulWidget {
  static const String id = 'resetPasswordPage';

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _showSpinner = false;
  String _mobileNoTFValue;
  String _selectedCountry = '+60';
  Map _countryFlag = {
    '+60': '🇲🇾',
    '+65': '🇸🇬',
    '+62': '🇮🇩',
    '+66': '🇹🇭',
    '+673': '🇧🇳',
    '+44': '🇬🇧',
  };

  void resetPassword() async {
    if (_mobileNoTFValue == null || _mobileNoTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_mobile_number'),
          context);
      return;
    }

    Map<String, dynamic> params = {
      'data': {'phone': _selectedCountry + _mobileNoTFValue}
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      String data = await AuthNetworking().resetPassword(params);

      showSimpleFlushBar(data, context, isError: false);
      Navigator.pushNamed(context, ResetNewPasswordPage.id);
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
                margin: EdgeInsets.symmetric(vertical: 50.0, horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context).text('reset_password'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: poppinsSemiBold,
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          AppTranslations.of(context).text(
                              'please_enter_phone_num_registered_with_us_to_reset'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: poppinsMedium, fontSize: 16),
                        ),
                        SizedBox(height: 30.0),
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
                          hintText:
                              AppTranslations.of(context).text('phone_number'),
                          inputType: TextInputType.number,
                          onChange: (value) {
                            _mobileNoTFValue = value;
                          },
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ActionButton(
                          buttonText: AppTranslations.of(context)
                              .text('reset_password'),
                          onPressed: () {
                            resetPassword();
                          },
                        ),
                        SizedBox(height: 10.0),
                        ActionButtonLight(
                          buttonText:
                              AppTranslations.of(context).text('cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    )
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
