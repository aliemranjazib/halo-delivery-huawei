import 'package:flutter/material.dart';
import 'package:haloapp/components/apple_login_button.dart';
import 'package:haloapp/components/facebook_login_button.dart';
import 'package:haloapp/components/google_login_button.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/components/divider_with_text.dart';
import 'package:haloapp/components/input_textfield.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/networkings/home_networking.dart';
import 'package:haloapp/networkings/user_networking.dart';
import 'package:haloapp/screens/auth/reset_password_page.dart';
import 'package:haloapp/screens/auth/signup_page.dart';
import 'package:haloapp/screens/auth/sms_verification_page.dart';
import 'package:haloapp/screens/boarding/location_access_page.dart';
import 'package:haloapp/screens/boarding/social_merge_page.dart';
import 'package:haloapp/screens/general/custom_alert_dialog.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/screens/main/update_server_update.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:haloapp/utils/services/package_info_service.dart';
import 'package:haloapp/utils/services/push_notifications.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/utils.dart';
import 'package:haloapp/widget/social_login_container.dart';
import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class LoginArguments{
  bool isShowBack;
  LoginArguments(this.isShowBack);
}

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
  LoginArguments loginArguments;

  SocialLoginInfoModel socialLoginInfoModel;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(
    //     LifecycleEventHandler(
    //       resumeCallBack: () async {
    //         checkMaintenance();
    //       },
    //     )
    // );
    //
    // checkMaintenance();

    // getLastLogin();
    _phoneNoTFController = TextEditingController(text: _phoneNoTFValue);
    _passwordTFController = TextEditingController(text: _passwordTFValue);
  }

  void checkMaintenance()async{
    // var position = await LocationService.getLastKnownLocation();
    // if(position!=null){
      await HomeNetworking.initAppConfig();

      if(AppConfig.isUnderMaintenance.value && !AppConfig.isShowMaintenancePage){
        AppConfig.isShowMaintenancePage = true;
        Navigator.pushNamed(context, UpdateServerPage.id);
      }
    // }
  }

  void getLastLogin() async {
    Map<String, dynamic> info = await SharedPrefService().getLoginInfo();
    String username = info['username'];
    String password = info['password'];
    String socialType = info["socialType"];
    String socialModel = info["socialModelKey"];
    if(socialModel!=null && socialModel.isNotEmpty){
      socialLoginInfoModel = socialInfoModelFromJson(socialModel);
    }

    if(socialType!=null){
      if(socialType != SharedPrefService.normalLogin){
        if(socialType!=null && socialType.isNotEmpty && socialLoginInfoModel != null){
          socialLogin(context);
        }
      }else{
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
    }
  }

  void socialLogin(context) async {
    // if (_phoneNoTFValue == null || _phoneNoTFValue.isEmpty) {
    //   showSimpleFlushBar(
    //       AppTranslations.of(context).text('please_enter_phone_number'),
    //       context);
    //   return;
    // }
    //
    // if (_passwordTFValue == null || _passwordTFValue.isEmpty) {
    //   showSimpleFlushBar(
    //       AppTranslations.of(context).text('please_enter_password'), context);
    //   return;
    // }

    PushNotificationsManager().init();
    String fcmToken = "";
    String huaweiToken = "";

    huaweiToken = MyApp.huaweiToken;
    fcmToken = await PushNotificationsManager().getFCMToken();

//    if(await FlutterHmsGmsAvailability.isHmsAvailable){
//      huaweiToken = MyApp.huaweiToken;
//    }else{
//      fcmToken = await PushNotificationsManager().getFCMToken();
//    }

    Map<String, dynamic> params = {
      "data": {
        "socialEmail": socialLoginInfoModel != null ? socialLoginInfoModel.email : null,
        "socialName": socialLoginInfoModel != null ? socialLoginInfoModel.name : null,
        "socialId": socialLoginInfoModel != null ? socialLoginInfoModel.userId : null,
        "socialType": socialLoginInfoModel != null ? socialLoginInfoModel.type : null,
        "fcmToken":fcmToken,
        "huaweiToken":huaweiToken
      }
    };

    print(params);

    setState(() {
      _showSpinner = true;
    });

    try {
      var data = await AuthNetworking().socialLogin(params);

      print("Data: $data");
      if (data is String && data == 'login') {


        setState(() {
          _phoneNoTFController.clear();
          _passwordTFController.clear();
        });

        if (FoodOrderModel().getOfflineAddress().length > 0) {
          await UserNetworking.saveAddress(
              FoodOrderModel().getOfflineAddress());
          FoodOrderModel().setOfflineAddress({});
        }

        SharedPrefService().setSocialLoginInfo(socialLoginInfoModel);
        Navigator.pushNamedAndRemoveUntil(
            context, TabBarPage.id, (Route<dynamic> route) => false);

      } else if (data is String && data == 'app_update') {
        _showAppUpdateDialog();
      } else {
        if (data is Map<String, dynamic>) {
          String token = data["response"]["userToken"] ?? '';
          var arguments = {
            "tokenKey":token,
            "socialInfoModel":socialInfoModelToJson(socialLoginInfoModel)
          };
          Navigator.pushNamed(context, SocialMergePage.id, arguments: arguments);
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

//    if(await FlutterHmsGmsAvailability.isHmsAvailable){
//      huaweiToken = MyApp.huaweiToken;
//    }else{
//      fcmToken = await PushNotificationsManager().getFCMToken();
//    }
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

        setState(() {
          _phoneNoTFController.clear();
          _passwordTFController.clear();
        });

        if (FoodOrderModel().getOfflineAddress().length > 0) {
          await UserNetworking.saveAddress(
              FoodOrderModel().getOfflineAddress());
          FoodOrderModel().setOfflineAddress({});
        }

        SharedPrefService()
            .setLoginInfo(_selectedCountry + _phoneNoTFValue, _passwordTFValue,SharedPrefService.normalLogin);
        // Navigator.popUntil(this.context, (Route<dynamic> route) => false);
        // Navigator.of(context).popUntil((route) => route.isFirst);
        // Navigator.pushNamed(this.context, TabBarPage.id);
        Navigator.of(this.context).pushNamedAndRemoveUntil(TabBarPage.id, (Route<dynamic> route) => false);


      } else if (data is String && data == 'app_update') {
        _showAppUpdateDialog();
      } else {
        if (data is Map<String, dynamic>) {
          String token = data["response"]["userToken"] ?? '';
          Navigator.pushNamed(this.context, SMSVerificationPage.id,
              arguments: token);
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
        if (!(await canLaunch(url))) {
          url = 'https://play.google.com/store/apps/details?id=' + packageName;
        }
      } else if (Platform.isIOS) {
        url = 'itms-apps://itunes.apple.com/my/app/id1525518223';
      }

      if (await canLaunch(url)) {
        launch(url);
      } else {
        print('Could not launch');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("SETTING -- ${ModalRoute.of(context).settings.arguments}");
    if(ModalRoute.of(context).settings.arguments!=null){
      loginArguments = ModalRoute.of(context).settings.arguments as LoginArguments;
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        // backgroundColor: kLightBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          leading:
          (loginArguments!=null && loginArguments.isShowBack)?
          IconButton(
            icon: arrowBack,
            onPressed: () => {Navigator.pop(context)},
          ):null,
          automaticallyImplyLeading:  (loginArguments!=null && loginArguments.isShowBack),
          title: Text(
            AppTranslations.of(context).text('login_title'),
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
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 10.0),
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
                          margin: EdgeInsets.only(top: 20),
                          child: Container(
                            alignment: FractionalOffset.center,
                            height: 75,
                            width: 75,
                            child: Transform(
                              alignment: FractionalOffset.center,
                              transform: new Matrix4.identity()
                                ..scale(2.3, 2.3),
                              child: Image.asset(
                                'images/haloje_logo.png',
                                height: 75,
                                width: 75,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                          child: Text(
                            AppTranslations.of(context).text('login_subtitle'),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InputTextTLTRBorderField(
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
                        PasswordInputBLBRBorderTextField(
                          onChange: (value) {
                            _passwordTFValue = value;
                          },
                          controller: _passwordTFController,
                          hintText:
                              AppTranslations.of(context).text('password'),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, ResetPasswordPage.id);
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 16, bottom: 30),
                            child: Text(
                              AppTranslations.of(context)
                                  .text('forgot_password_ques'),
                              style: TextStyle(
                                fontFamily: poppinsRegular,
                                fontSize: 14,
                                color: kColorLightRed,
                              ),
                            ),
                          ),
                        ),
                        ActionButton(
                          buttonText:
                              AppTranslations.of(context).text('btn_continue'),
                          onPressed: () {
                            login(context);
                          },
                        ),
                        SizedBox(height: 20.0),
                        DividerWithText(
                          leftDividerPadding:
                              EdgeInsets.only(left: 4.0, right: 4.0),
                          rightDividerPadding:
                              EdgeInsets.only(left: 4.0, right: 4.0),
                          color: lightGrey,
                          height: 16,
                          text:
                              AppTranslations.of(context).text("login_div_txt"),
                        ),
                      ],
                    ),
                    SocialLoginContainer(
                      enable: !_showSpinner,
                      socialListenerCallback: (bool isLoading, SocialLoginInfoModel socialLoginInfo)async{
                        setState(() {
                          this._showSpinner = isLoading;
                        });
                        if(socialLoginInfo!=null){
                          setState(() {
                            this.socialLoginInfoModel = socialLoginInfo;
                          });
                          socialLogin(context);
                        }
                        return;
                      },
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.stretch,
                    //   children: <Widget>[
                    //     SizedBox(
                    //       height: 16,
                    //     ),
                    //     AppleLoginButton(),
                    //     SizedBox(
                    //       height: 6,
                    //     ),
                    //     FacebookLoginButton(),
                    //     SizedBox(
                    //       height: 6,
                    //     ),
                    //     GoogleLoginButton(),
                    //     SizedBox(
                    //       height: 6,
                    //     ),
                    //     ActionIconButtonOutline(
                    //       icon: Container(
                    //         alignment: Alignment.centerLeft,
                    //         child: Image.asset(
                    //           'images/phone.png',
                    //           width: socialIconSize,
                    //           height: socialIconSize,
                    //           color: Colors.black,
                    //         ),
                    //       ),
                    //       onPressed: () {
                    //         Navigator.pushNamed(context, SignUpPage.id);
                    //       },
                    //       buttonText: AppTranslations.of(context)
                    //           .text('login_btn_register'),
                    //     )
                    //   ],
                    // )
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
