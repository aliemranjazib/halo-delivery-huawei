import 'dart:io';

import 'package:flutter/material.dart';
import 'package:haloapp/components/custom_flushbar.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/screens/boarding/login_page.dart';
import 'package:haloapp/screens/boarding/step_page.dart';
import 'package:haloapp/screens/general/custom_alert_dialog.dart';
import 'package:haloapp/screens/main/tab_bar_controller.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/page_route_animation.dart';
import 'package:haloapp/utils/services/location_service.dart';
import 'package:haloapp/utils/services/package_info_service.dart';
import 'package:haloapp/utils/services/push_notifications.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/widget/social_login_container.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class SplashPage extends StatefulWidget {
  static const String id = 'SplashPage';

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final String titleTxt = 'splash_title';
  final String descTxt = 'splash_description';

  @override
  void initState() {
    super.initState();

    autoLogin().then((value) {
      if (value) {
        Navigator.pushAndRemoveUntil(
            context,
            FadeInRoute(
              routeName: TabBarPage.id,
              page: TabBarPage(),
            ),
            (Route<dynamic> route) => false);
      } else {
        Future.delayed(Duration(milliseconds: 1000), () async {
          if (await SharedPrefService().isFirstTime()) {
            Navigator.pushAndRemoveUntil(
                context,
                FadeInRoute(
                  routeName: StepPage.id,
                  page: StepPage(),
                ),
                (Route<dynamic> route) => false);
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                FadeInRoute(
                  routeName: TabBarPage.id,
                  page: TabBarPage(),
                ),
                (Route<dynamic> route) => false);
          }
        });
      }
    });
  }

  Future<bool> autoLogin() async {
    Map<String, dynamic> info = await SharedPrefService().getLoginInfo();
    String username = info['username'];
    String password = info['password'];
    String socialType = info["socialType"];
    String socialModel = info["socialModelKey"];
    SocialLoginInfoModel socialLoginInfoModel;

    if (socialModel != null && socialModel.isNotEmpty) {
      socialLoginInfoModel = socialInfoModelFromJson(socialModel);
    }

    if (socialType != null) {
      if (socialType != SharedPrefService.normalLogin &&
          socialLoginInfoModel != null) {
        PushNotificationsManager().init();
        String fcmToken = await PushNotificationsManager().getFCMToken();
        String huaweiToken = MyApp.huaweiToken;

        Map<String, dynamic> params = {
          "data": {
            "socialEmail": socialLoginInfoModel != null
                ? socialLoginInfoModel.email
                : null,
            "socialName":
                socialLoginInfoModel != null ? socialLoginInfoModel.name : null,
            "socialId": socialLoginInfoModel != null
                ? socialLoginInfoModel.userId
                : null,
            "socialType":
                socialLoginInfoModel != null ? socialLoginInfoModel.type : null,
            "fcmToken": fcmToken,
            "huaweiToken": huaweiToken
          }
        };

        print(params);

        try {
          var data = await AuthNetworking().socialLogin(params);

          print("Data: $data");
          if (data is String && data == 'login') {
            return true;
          }
        } catch (e) {
          print(e.toString());
          if (e is String) {
            showSimpleFlushBar(e, context);
          }
        } finally {}
      } else {
        if (username != null &&
            username != '' &&
            password != null &&
            password != '') {
          PushNotificationsManager().init();
          String fcmToken = await PushNotificationsManager().getFCMToken();
          String huaweiToken = MyApp.huaweiToken;
          Map<String, dynamic> params = {
            'data': {
              'phone': username,
              'password': password,
              'fcmToken': fcmToken,
              'huaweiToken': huaweiToken,
            }
          };
          try {
            var data = await AuthNetworking().login(params);

            if (data is String && data == 'login') {
              // success slogin
              print('LOGINNED');
              return true;
              // force refresh app after success login
            }
          } catch (e) {
            // print('ggwo');
            print(e);
            if (e is String) {
              showSimpleFlushBar(e, context);
            }
          } finally {}
        }
      }
    }

    return false;
  }

  // Future<void> autoLogin() async {
  //
  //   Map<String, String> info = await SharedPrefService().getLoginInfo();
  //   String username = info['username'];
  //   String password = info['password'];
  //   if (username == null) {
  //     return;
  //   }
  //   PushNotificationsManager().init();
  //   String fcmToken = await PushNotificationsManager().getFCMToken();
  //   String huaweiToken = MyApp.huaweiToken;
  //   Map<String, dynamic> params = {
  //     'data': {
  //       'phone': username,
  //       'password': password,
  //       'fcmToken': fcmToken,
  //       'huaweiToken': huaweiToken,
  //     }
  //   };
  //   try {
  //     var data = await AuthNetworking().login(params);
  //
  //     if (data is String && data == 'login') {
  //       // success slogin
  //       print('LOGINNED');
  //       // force refresh app after success login
  //     }
  //   } catch (e) {
  //     // print('ggwo');
  //     print(e);
  //     if (e is String) {
  //       showSimpleFlushBar(e, context);
  //     }
  //   } finally {}
  // }

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
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
          body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 500,
              width: 600,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/splash_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: null /* add child content here */,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'images/haloje_logo.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Text(
                    AppTranslations.of(context).text(titleTxt),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Text(
                    AppTranslations.of(context).text(descTxt),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: light2Grey,
                      fontFamily: poppinsRegular,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
