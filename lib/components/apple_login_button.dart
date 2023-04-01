import 'package:flutter/material.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';

class AppleLoginButton extends StatelessWidget {

  AppleLoginButton();

  appleLogin(BuildContext context) async {
    AuthorizationCredentialAppleID credential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'com.halo.haloexpress',
        redirectUri: Uri.parse(
            'https://workable-alabaster-lemongrass.glitch.me/callback/sign_in_with_apple'),
      ),
    );
    print('login success');

    _showMessage(credential.email);
    _showMessage(credential.authorizationCode);
    _showMessage(credential.identityToken);
    _showMessage(parseJwtPayLoad(credential.identityToken)['email']);
  }

  void _showMessage(String message) {
    print(message);
  }

  Map<String, dynamic> parseJwtPayLoad(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  @override
  Widget build(BuildContext context) {
    return ActionIconButtonOutline(
      icon: Container(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'images/apple.png',
          width: socialIconSize,
          height: socialIconSize,
        ),
      ),
      onPressed: () {
        appleLogin(context);
      },
      buttonText: AppTranslations.of(context).text('login_btn_apple'),
    );
  }
}
