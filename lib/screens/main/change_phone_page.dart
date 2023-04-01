import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/screens/main/change_phone_verification_page.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class ChangePhonePage extends StatefulWidget {
  static const String id = 'changePhonePage';

  @override
  ChangePhonePageState createState() => ChangePhonePageState();
}

class ChangePhonePageState extends State<ChangePhonePage> {
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

  TextEditingController mobileNoEditingController;

  @override
  void initState() {
    super.initState();

  }

  void updatePhone() async {

    if (_mobileNoTFValue == null || _mobileNoTFValue.isEmpty) {
      showSimpleFlushBar(AppTranslations.of(context).text('please_enter_email'), context);
      return;
    }

    Map<String, dynamic> params = {
      "data": {
        "userToken": User().getUserToken(),
        "phone": _mobileNoTFValue,
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      String data = await AuthNetworking().changePhone(params);

      showSimpleFlushBar(data, context, isError: false);
      Navigator.pushNamed(context, ChangePhoneVerificationPage.id);

    } catch (e) {
      print(e);
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
    return;
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
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: arrowBack,
            onPressed: () => {Navigator.pop(context)},
          ),
          title: Text(
            AppTranslations.of(context).text('enter_new_phone'),
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
                        AppTranslations.of(context).text('phone_no'),
                        style: TextStyle(fontFamily: poppinsRegular, fontSize: 15),
                      ),
                      SizedBox(height: 10.0),
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
                        AppTranslations.of(context).text('mobile_number'),
                        inputType: TextInputType.number,
                        onChange: (value) {
                          _mobileNoTFValue = value;
                        },
                        controller: mobileNoEditingController,
                      ),
                    ],
                  ),
                  ActionButton(
                    buttonText: AppTranslations.of(context).text('change'),
                    onPressed: () {
                      updatePhone();
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
