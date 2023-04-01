import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/cupertino_datetime_picker_popup.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/auth/sms_verification_page.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'dart:io';

import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/widget/social_login_container.dart';

class SocialMergePage extends StatefulWidget {
  static const String id = 'socialMergePage';

  @override
  SocialMergePageState createState() => SocialMergePageState();
}

class SocialMergePageState extends State<SocialMergePage> {
  bool _showSpinner = false;
  String _fullNameTFValue = "";
  String _emailTFValue = "";
  String _mobileNoTFValue = "";
  String _passwordTFValue = "";
  bool isMergeAcc = false;

  String _selectedCountry = '+60';
  String _tokenKey = "";
  SocialLoginInfoModel socialLoginInfoModel;

  Map _countryFlag = {
    '+60': '🇲🇾',
    '+65': '🇸🇬',
    '+62': '🇮🇩',
    '+66': '🇹🇭',
    '+673': '🇧🇳',
    '+44': '🇬🇧',
  };

  TextEditingController fullNameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController mobileNoEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  void socialBindOldAccount() async {
    // if (_fullNameTFValue == null || _fullNameTFValue.isEmpty) {
    //   showSimpleFlushBar(
    //       AppTranslations.of(context).text('please_enter_your_name'), context);
    //   return;
    // }

    // if (_emailTFValue == null || _emailTFValue.isEmpty) {
    //   showSimpleFlushBar(
    //       AppTranslations.of(context).text('please_enter_your_email'), context);
    //   return;
    // }

    if (_passwordTFValue == null || _passwordTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_password'), context);
      return;
    }

    if (_mobileNoTFValue == null || _mobileNoTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_your_mobile_num'),
          context);
      return;
    }

    Map<String, dynamic> params = {
      "data": {
        "userToken": "${_tokenKey}",
        "phone": _selectedCountry + _mobileNoTFValue,
        "password": _passwordTFValue
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await AuthNetworking().socialBindOldAccount(params);
      SharedPrefService()
          .setSocialLoginInfo(socialLoginInfoModel);
      Navigator.pushNamedAndRemoveUntil(
          context, TabBarPage.id, (Route<dynamic> route) => false);
    } catch (e) {
      showSimpleFlushBar(e, context);
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }
  }

  Future<bool> checkIsPhoneExist()async{
    Map<String, dynamic> params = {
      "data": {
        "userToken": "${_tokenKey}",
        "phone": _selectedCountry + _mobileNoTFValue,
      }
    };

    setState(() {
      _showSpinner = true;
    });

    try {
      print(params);
      var data = await AuthNetworking().socialUpdateAccount(params);
      if (data is String && data == 'login') {

        SharedPrefService().setSocialLoginInfo(socialLoginInfoModel);
        Navigator.pushNamedAndRemoveUntil(
            context, TabBarPage.id, (Route<dynamic> route) => false);

      } else {
        var oldUser = data["response"]["oldUser"];
        setState(() {
          isMergeAcc = true;
          _fullNameTFValue = oldUser["user_name"];
          _emailTFValue = oldUser["user_email"];
          _mobileNoTFValue = oldUser["user_phone"];

          fullNameEditingController.text = _fullNameTFValue;
          emailEditingController.text = _emailTFValue;
          mobileNoEditingController.text = _mobileNoTFValue;
        });

      }

    } catch (e) {
      print(e.toString());
      showSimpleFlushBar(e, context);
      return false;
    } finally {
      setState(() {
        _showSpinner = false;
      });
    }

    return true;
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String,dynamic> arguments = ModalRoute.of(context).settings.arguments;
    _tokenKey = arguments["tokenKey"];
    if(arguments["socialInfoModel"]!=null){
      print("Go in Merge Social Acc");
      socialLoginInfoModel = socialInfoModelFromJson(arguments["socialInfoModel"]);

      if(socialLoginInfoModel.name!=null && socialLoginInfoModel.name.isNotEmpty){
        _fullNameTFValue = socialLoginInfoModel.name ?? "";
        fullNameEditingController.text = _fullNameTFValue;
      }

      if(socialLoginInfoModel.email!=null && socialLoginInfoModel.email.isNotEmpty){
        _emailTFValue = socialLoginInfoModel.email ?? "";
        emailEditingController.text = _emailTFValue;
      }

    }

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
            title: Text(
                AppTranslations.of(context).text('title_update_account'),
                textAlign: TextAlign.center,
                style: kAppBarTextStyle
            ),
            actions: [
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
                        enabled: !isMergeAcc,
                        controller: mobileNoEditingController,
                      ),
                      SizedBox(height: 10),
                      if(isMergeAcc)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InputTextField(
                            hintText: AppTranslations.of(context).text('name'),
                            onChange: (value) {
                              print('>>> ' + value);
                              _fullNameTFValue = value;
                            },
                            enabled: !isMergeAcc,
                            controller: fullNameEditingController,
                          ),
                          SizedBox(height: 10),
                          InputTextField(
                            hintText: AppTranslations.of(context).text('email'),
                            inputType: TextInputType.emailAddress,
                            onChange: (value) {
                              _emailTFValue = value;
                            },
                            enabled: !isMergeAcc,
                            controller: emailEditingController,
                          ),
                          SizedBox(height: 10),
                          InputTextField(
                            hintText: AppTranslations.of(context).text('password'),
                            obscureText: true,
                            onChange: (value) {
                              _passwordTFValue = value;
                            },
                            controller: passwordEditingController,
                          ),
                        ],
                      ),
                      SizedBox(height: 40.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ActionButton(
                            buttonText:
                            AppTranslations.of(context).text('btn_update'),
                            onPressed: () {
                              if(isMergeAcc){
                                socialBindOldAccount();
                              }else{
                                checkIsPhoneExist();
                              }
                            },
                          ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                          // ActionButtonLight(
                          //   buttonText:
                          //   AppTranslations.of(context).text('cancel'),
                          //   onPressed: () {
                          //     Navigator.pop(context);
                          //   },
                          // )
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


}
