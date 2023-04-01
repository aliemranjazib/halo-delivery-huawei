import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/screens/auth/reset_password_page.dart';
import 'package:haloapp/screens/auth/signup_page.dart';
import 'package:haloapp/screens/auth/sms_verification_page.dart';
import 'package:haloapp/screens/general/custom_alert_dialog.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/services/package_info_service.dart';
import 'package:haloapp/utils/services/push_notifications.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/utils.dart';
import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';

import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'loginPage';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showSpinner = false;
  TextEditingController _phoneNoTFController;
  TextEditingController _passwordTFController;
  String _phoneNoTFValue;
  String _passwordTFValue;
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

  @override
  void initState() {
    super.initState();

    // getLastLogin();

    _phoneNoTFController = TextEditingController(text: _phoneNoTFValue);
    _passwordTFController = TextEditingController(text: _passwordTFValue);
  }

  void getLastLogin() async {
    Map<String, dynamic> info = await SharedPrefService().getLoginInfo();
    String username = info['username'];
    String password = info['password'];
    if (username != null &&
        username != '' &&
        password != null &&
        password != '') {
      setState(() {
        _phoneNoTFValue = username;
        _passwordTFValue = password;
      });

      login(context);
    }
  }

  void login(context) async {
    if (_phoneNoTFValue == null || _phoneNoTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_phone_number'),
          context);
      return;
    }

    if (_passwordTFValue == null || _passwordTFValue.isEmpty) {
      showSimpleFlushBar(
          AppTranslations.of(context).text('please_enter_password'), context);
      return;
    }

    PushNotificationsManager().init();
    String fcmToken = "";
    String huaweiToken = "";

    huaweiToken = MyApp.huaweiToken;
    fcmToken = await PushNotificationsManager().getFCMToken();
    if (await FlutterHmsGmsAvailability.isHmsAvailable) {
      huaweiToken = MyApp.huaweiToken;
    } else {
      fcmToken = await PushNotificationsManager().getFCMToken();
    }
    Map<String, dynamic> params = {
      'data': {
        'phone': _selectedCountry + _phoneNoTFValue,
        'password': _passwordTFValue,
        'fcmToken': fcmToken,
        'huaweiToken': huaweiToken,
      }
    };
    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await AuthNetworking().login(params);

      print("Data: $data");
      if (data is String && data == 'login') {
        SharedPrefService().setLoginInfo(_selectedCountry + _phoneNoTFValue,
            _passwordTFValue, SharedPrefService.normalLogin);
        Navigator.pushNamedAndRemoveUntil(
            context, TabBarPage.id, (Route<dynamic> route) => false);

        setState(() {
          _phoneNoTFController.clear();
          _passwordTFController.clear();
        });

        if (FoodOrderModel().getOfflineAddress().length > 0) {
          await UserNetworking.saveAddress(
              FoodOrderModel().getOfflineAddress());
          FoodOrderModel().setOfflineAddress({});
        }
      } else if (data is String && data == 'app_update') {
        _showAppUpdateDialog();
      } else {
        if (data is Map<String, dynamic>) {
          String token = data["response"]["userToken"] ?? '';
          Navigator.pushNamed(context, SMSVerificationPage.id, arguments: {
            'tokenKey': token,
            'phoneNumber': _phoneNoTFValue,
          });
        } else {
          showSimpleFlushBar(
              AppTranslations.of(context).text('failed_to_load'), context);
        }
      }
    } catch (e) {
      print(e.toString());
      if (e is String) {
        showSimpleFlushBar(e, context);
      }
    } finally {
      if (mounted)
        setState(() {
          _showSpinner = false;
        });
    }
  }

  void _showAppUpdateDialog() {
    showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
              title: AppTranslations.of(context).text('new_version_available'),
              message: AppTranslations.of(context)
                  .text('the_new_version_of_app_is_available_please_update'),
            )).then((value) async {
      String url = '';
      if (Platform.isAndroid) {
        String packageName = await PackageInfoService().getPackageName();

        url = 'market://details?id=' + packageName;
        if (!(await canLaunchUrl(Uri.parse(url)))) {
          url = 'https://play.google.com/store/apps/details?id=' + packageName;
        }
      } else if (Platform.isIOS) {
        url = 'itms-apps://itunes.apple.com/my/app/id1525518223';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        launchUrl(Uri.parse(url));
      } else {
        print('Could not launch');
      }
    });
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
        // backgroundColor: kLightBackground,
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 34),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Utils.getEnvironment(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 40),
                          child: Container(
                            alignment: FractionalOffset.center,
                            height: 150,
                            width: 150,
                            child: Transform(
                              alignment: FractionalOffset.center,
                              transform: new Matrix4.identity()
                                ..scale(2.3, 2.3),
                              child: Image.asset(
                                'images/haloje_logo.png',
                                height: 250,
                                width: 250,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
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
                          onChange: (value) {
                            _phoneNoTFValue = value;
                          },
                          controller: _phoneNoTFController,
                          inputType: TextInputType.number,
                          hintText:
                              AppTranslations.of(context).text('phone_number'),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InputTextField(
                          obscureText: true,
                          onChange: (value) {
                            _passwordTFValue = value;
                          },
                          controller: _passwordTFController,
                          hintText:
                              AppTranslations.of(context).text('password'),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        ActionButton(
                          buttonText: AppTranslations.of(context).text('login'),
                          onPressed: () {
                            login(context);
                          },
                        ),
                        SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, ResetPasswordPage.id);
                          },
                          child: Text(
                            AppTranslations.of(context)
                                .text('forgot_password_ques'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: poppinsRegular,
                                fontSize: 14,
                                color: kColorLightRed),
                          ),
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context).text('no_account_ques'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: poppinsRegular,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        ActionButtonLight(
                          onPressed: () {
                            Navigator.pushNamed(context, SignUpPage.id);
                          },
                          buttonText:
                              AppTranslations.of(context).text('register'),
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
    );
  }
}
