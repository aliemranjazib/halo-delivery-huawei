import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/auth/reset_new_password_page.dart';
import 'package:haloapp/screens/boarding/reset_sms_verification_page%20.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/constants/styles.dart';

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
    '+57': '🇨🇴'
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
      Navigator.pushNamed(context, ResetSMSVerificationPage.id, arguments: {
        "countryCode": _selectedCountry,
        "phoneNumber": _mobileNoTFValue
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
                AppTranslations.of(context).text('reset_password_title'),
                textAlign: TextAlign.center,
                style: kAppBarTextStyle
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => {},
              ),
            ],
          ),
          body: ModalProgressHUD(
            inAsyncCall: _showSpinner,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context)
                              .text('reset_password_label'),
                          style: TextStyle(
                            fontFamily: poppinsMedium,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 15.0),
                        Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                            border: Border.all(
                              style: BorderStyle.solid,
                              color: Colors.grey,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton(
                                value: _selectedCountry,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
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
                            ],
                          ),
                        ),
                        InputTextBLBRBorderField(
                          hintText:
                              AppTranslations.of(context).text('phone_number'),
                          inputType: TextInputType.number,
                          onChange: (value) {
                            _mobileNoTFValue = value;
                          },
                        ),
                        SizedBox(height: 20),
                        ActionButton(
                          buttonText:
                              AppTranslations.of(context).text('btn_continue'),
                          onPressed: () {
                            resetPassword();
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
