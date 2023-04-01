import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';

import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FacebookLoginButton extends StatelessWidget {
  // final FacebookLogin facebook = new FacebookLogin();
  Map<String, dynamic> _userData;
  AccessToken _accessToken;
  bool _checking = true;

  // Future<Null> _fblogin(BuildContext context) async {
  //   final FacebookLoginResult result = await facebook.logIn([
  //     'email',
  //   ]);
  //   switch (result.status) {
  //     case FacebookLoginStatus.loggedIn:
  //       final FacebookAccessToken accessToken = result.accessToken;
  //       final token = accessToken.token;
  //       final graphResponse = await http.get(
  //           'https://graph.facebook.com/v2.12/me?fields=name,email&access_token=${token}');
  //       final profile = json.decode(graphResponse.body);
  //       _showMessage(graphResponse.body);
  //       Navigator.pop(context);
  //       break;
  //     case FacebookLoginStatus.cancelledByUser:
  //       _showMessage('Login cancelled by the user.');
  //       break;
  //     case FacebookLoginStatus.error:
  //       _showMessage('Something went wrong with the login process.\n'
  //           'Here\'s the error Facebook gave us: ${result.errorMessage}');
  //       break;
  //   }
  // }

  String prettyPrint(Map json) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String pretty = encoder.convert(json);
    return pretty;
  }

  void _printCredentials() {
    print(
      prettyPrint(_accessToken.toJson()),
    );
  }

  Future<void> _fblogin2() async {
    final LoginResult result = await FacebookAuth.instance
        .login(); // by default we request the email and the public profile

    // loginBehavior is only supported for Android devices, for ios it will be ignored
    // final result = await FacebookAuth.instance.login(
    //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
    //   loginBehavior: LoginBehavior
    //       .DIALOG_ONLY, // (only android) show an authentication dialog instead of redirecting to facebook app
    // );

    if (result.status == LoginStatus.success) {
      _accessToken = result.accessToken;
      _printCredentials();
      // get the user data
      // by default we get the userId, email,name and picture
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      print(userData);
      _userData = userData;
    } else {
      print(result.status);
      print(result.message);
    }
  }

  void _showMessage(String message) {
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return ActionIconButtonOutline(
      icon: Container(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'images/facebook.png',
          width: socialIconSize,
          height: socialIconSize,
        ),
      ),
      onPressed: () {
        // _fblogin(context);
        _fblogin2();
      },
      buttonText: AppTranslations.of(context).text('login_btn_fb'),
    );
  }
}
