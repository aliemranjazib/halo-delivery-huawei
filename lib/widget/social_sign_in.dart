import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:haloapp/components/action_button.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/widget/social_login_container.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum SocialLoginButtonType{
  icon,button
}

enum SocialLogin{
  facebook,instagram,google,apple
}

class SignInIconButtonBuilder extends StatelessWidget {

  final String imagePath;

  /// onPressed should be specified as a required field to indicate the callback.
  final Function onPressed;

  /// padding is default to `EdgeInsets.all(3.0)`
  final EdgeInsets padding, innerPadding;

  /// the height of the button
  final double height;

  /// width is default to be 1/1.5 of the screen
  final double width;

  final bool isLoading;

  /// The constructor is self-explanatory.
  SignInIconButtonBuilder({
    Key key,
    @required this.onPressed,
    this.imagePath,
    this.padding,
    this.innerPadding,
    this.height,
    this.width,
    this.isLoading = false
  });

  /// The build funtion will be help user to build the signin button widget.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding ?? EdgeInsets.all(6),
        child: Image.asset(imagePath,width: width,height: height,),
      ),
    );
  }

}

class SignInButtonBuilder extends StatelessWidget {
  /// This is a builder class for signin button
  ///
  /// Icon can be used to define the signin method
  /// User can use Flutter built-in Icons or font-awesome flutter's Icon
  final IconData icon;

  /// Override the icon section with a image logo
  /// For example, Google requires a colorized logo,
  /// which FontAwesome cannot display. If both image
  /// and icon are provided, image will take precedence
  final Widget image;

  /// `mini` tag is used to switch from a full-width signin button to
  final bool mini;

  /// the button's text
  final String text;

  /// The size of the label font
  final double fontSize;

  /// backgroundColor is required but textColor is default to `Colors.white`
  /// splashColor is defalt to `Colors.white30`
  final Color textColor,
      iconColor,
      backgroundColor,
      splashColor,
      highlightColor;

  /// onPressed should be specified as a required field to indicate the callback.
  final Function onPressed;

  /// padding is default to `EdgeInsets.all(3.0)`
  final EdgeInsets padding, innerPadding;

  /// shape is to specify the custom shape of the widget.
  /// However the flutter widgets contains restriction or bug
  /// on material button, hence, comment out.
  final ShapeBorder shape;

  /// elevation has defalt value of 2.0
  final double elevation;

  /// the height of the button
  final double height;

  /// width is default to be 1/1.5 of the screen
  final double width;

  final bool isLoading;

  /// The constructor is self-explanatory.
  SignInButtonBuilder({
    Key key,
    @required this.backgroundColor,
    @required this.onPressed,
    @required this.text,
    this.icon,
    this.image,
    this.fontSize = 14.0,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.splashColor = Colors.white30,
    this.highlightColor = Colors.white30,
    this.padding,
    this.innerPadding,
    this.mini = false,
    this.elevation = 2.0,
    this.shape,
    this.height,
    this.width,
    this.isLoading = false
  });

  /// The build funtion will be help user to build the signin button widget.
  @override
  Widget build(BuildContext context) {
    print("isLoading :${isLoading}");
    return MaterialButton(
      key: key,
      minWidth: mini ? width ?? 35.0 : null,
      height: height,
      elevation: elevation,
      padding: padding ?? EdgeInsets.all(0),
      color: backgroundColor,
      onPressed: onPressed as void Function(),
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: _getButtonChild(context),
      shape: shape ?? ButtonTheme.of(context).shape,
    );
  }

  /// Get the inner content of a button
  Container _getButtonChild(BuildContext context) {
    if (mini) {
      return Container(
        width: height ?? 35.0,
        height: width ?? 35.0,
        child: _getIconOrImage(),
      );
    }
    return Container(
      constraints: BoxConstraints(
        maxWidth: width ?? 220,
      ),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: innerPadding ??
                  EdgeInsets.symmetric(
                    horizontal: 13,
                  ),
              child: _getIconOrImage(),
            ),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                backgroundColor: Color.fromRGBO(0, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the icon or image widget
  Widget _getIconOrImage() {
    if (image != null) {
      return image;
    }
    return Icon(
      icon,
      size: 20,
      color: this.iconColor,
    );
  }
}

class SocialLoginButton{

  SocialLoginButtonType socialLoginButtonType;

  SocialLogin socialLogin;

  /// The constructor is self-explanatory.
  SocialLoginButton({
    Key key,
    @required this.socialLoginButtonType,
    @required this.socialLogin,
  });

  @override
  Widget build(BuildContext context) {
    switch(socialLogin){
      case SocialLogin.facebook:
        return FacebookSignInButton(socialLoginButtonType: socialLoginButtonType,);

      case SocialLogin.google:
        return GoogleSignInButton(socialLoginButtonType: socialLoginButtonType,);

      case SocialLogin.apple:
        return FacebookSignInButton(socialLoginButtonType: socialLoginButtonType,);

      case SocialLogin.instagram:
        return FacebookSignInButton(socialLoginButtonType: socialLoginButtonType,);
    }
  }
}

class FacebookSignInButton extends StatefulWidget {

  final SocialLoginButtonType socialLoginButtonType;
  final bool enable;
  final SocialListenerCallback socialListenerCallback;

  FacebookSignInButton({
    Key key,
    this.socialLoginButtonType = SocialLoginButtonType.button,
    this.enable = true,
    this.socialListenerCallback
  }):super(key: key);

  @override
  FacebookSignInButtonState createState() => FacebookSignInButtonState();
}

class FacebookSignInButtonState extends State<FacebookSignInButton> {

  bool _checking = false;

  SocialLoginInfoModel socialLoginInfoModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(widget.socialLoginButtonType){
      case SocialLoginButtonType.icon:
        return SignInIconButtonBuilder(
          key: ValueKey("Facebook"),
          onPressed: widget.enable?(){
            fbLogin();
          }:null,
          imagePath: "images/facebook.png",
          width: socialIconSize,
          height: socialIconSize,
        );

      default:
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
            fbLogin();
          },
          buttonText: AppTranslations.of(context).text('login_btn_fb'),
        );
    }

  }

  void callBack(){
    if(widget.socialListenerCallback!=null){
      widget.socialListenerCallback(_checking,socialLoginInfoModel);
      socialLoginInfoModel = null;
    }
  }

  void fbLogin()async{
    try {
      setState(() {
        _checking = true;
      });
      callBack();

      // by default the login method has the next permissions ['email','public_profile']
      LoginResult accessToken = await FacebookAuth.instance.login();
      if(accessToken!=null){
        // DebugApi.debugModels.add(DebugApiModel(plainText: "FACEBOOK LOGIN: \n"+accessToken.toJson().toString(),type: DebugApiModel.TYPE_SOCIAL_LOGIN));
      }

      switch (accessToken.status) {
        case LoginStatus.operationInProgress:
          print("You have a previous login operation in progress");
          break;
        case LoginStatus.cancelled:
          print("login cancelled");
          break;
        case LoginStatus.failed:
          print("login failed");
          break;

        case LoginStatus.success:

          break;
      }

      // print("accessToken: ${accessToken.accessToken.toJson()}");
      // get the user data
      final userData = await FacebookAuth.instance.getUserData();
      if(userData!=null){
        socialLoginInfoModel = SocialLoginInfoModel(
            type: SocialLoginInfoModel.FACEBOOK,
            userId: userData["id"],
            email: userData["email"],
            name: userData["name"],
            image: userData["picture"]["data"]["url"],
            socialDataRaw:jsonEncode(userData)
        );
        // DebugApi.debugModels.add(DebugApiModel(plainText: "FACEBOOK LOGIN: \n"+jsonEncode(userData),type: DebugApiModel.TYPE_SOCIAL_LOGIN));
      }
      print(userData);

    } catch (e) {
      print("FB error : $e");

    }

    setState(() {
      _checking = false;
    });
    callBack();
  }

  Future<void> _checkIfIsLogged() async {
    final AccessToken accessToken = await FacebookAuth.instance.accessToken;
    setState(() {
      _checking = false;
    });
    if (accessToken != null) {
      print("is Logged:::: ${(accessToken.toJson())}");
      // now you can call to  FacebookAuth.instance.getUserData();
      final userData = await FacebookAuth.instance.getUserData();
    }
  }

}

class GoogleSignInButton extends StatefulWidget {
  final SocialLoginButtonType socialLoginButtonType;
  final bool enable;
  final SocialListenerCallback socialListenerCallback;

  GoogleSignInButton({
    Key key,
    this.socialLoginButtonType = SocialLoginButtonType.button,
    this.enable = true,
    this.socialListenerCallback
  }):super(key: key);

  @override
  GoogleSignInButtonState createState() => GoogleSignInButtonState();
}

class GoogleSignInButtonState extends State<GoogleSignInButton> {

  bool _checking = false;
  SocialLoginInfoModel socialLoginInfoModel;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  @override
  void initState() {
    super.initState();
  }

  void callBack(){
    if(widget.socialListenerCallback!=null){
      widget.socialListenerCallback(_checking,socialLoginInfoModel);
      socialLoginInfoModel = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch(widget.socialLoginButtonType){
      case SocialLoginButtonType.icon:
        return SignInIconButtonBuilder(
          key: ValueKey("Google"),
          onPressed: widget.enable?(){
            googleLogin();
          }:null,
          imagePath: "images/google.png",
          width: socialIconSize,
          height: socialIconSize,
        );

      default:
        return ActionIconButtonOutline(
          icon: Container(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'images/google.png',
              width: socialIconSize,
              height: socialIconSize,
            ),
          ),
          onPressed: () {
            googleLogin();
          },
          buttonText: AppTranslations.of(context).text('login_btn_google'),
        );

    }
  }

  void googleLogin()async{
    try {
      setState(() {
        _checking = true;
      });
      callBack();

      _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
        // setState(() {
        //   _currentUser = account;
        // });
        // if (_currentUser != null) {
        //   _handleGetContact(_currentUser!);
        // }
        print(account.id);
        print(account.displayName);
        print(account.photoUrl);
        print(account.email);
      });
      var result = await _googleSignIn.signIn();
      print("result : ${result}");

      if(result!=null){
        socialLoginInfoModel = SocialLoginInfoModel(
            type: SocialLoginInfoModel.GOOGLE,
            userId: result.id,
            name: result.displayName,
            email: result.email,
            image: result.photoUrl,
            socialDataRaw:result.toString()
        );
        // DebugApi.debugModels.add(DebugApiModel(plainText: "GOOGLE LOGIN: \n"+result.toString(),type: DebugApiModel.TYPE_SOCIAL_LOGIN));
      }
    }catch(e){
      print(e);
    }

    setState(() {
      _checking = false;
    });
    callBack();
  }

  Future<void> _checkIfIsLogged() async {
    // final AccessToken accessToken = await FacebookAuth.instance.isLogged;
    // setState(() {
    //   _checking = false;
    // });
    // if (accessToken != null) {
    //   print("is Logged:::: ${(accessToken.toJson())}");
    //   // now you can call to  FacebookAuth.instance.getUserData();
    //   final userData = await FacebookAuth.instance.getUserData();
    // }
  }

}

class AppleSignInButton extends StatefulWidget {

  final SocialLoginButtonType socialLoginButtonType;
  final bool enable;
  final SocialListenerCallback socialListenerCallback;

  AppleSignInButton({
    Key key,
    this.socialLoginButtonType = SocialLoginButtonType.button,
    this.enable = true,
    this.socialListenerCallback
  }):super(key: key);

  @override
  AppleSignInButtonState createState() => AppleSignInButtonState();
}

class AppleSignInButtonState extends State<AppleSignInButton> {

  bool _checking = false;
  SocialLoginInfoModel socialLoginInfoModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch(widget.socialLoginButtonType){
      case SocialLoginButtonType.icon:
        return SignInIconButtonBuilder(
          key: ValueKey("Apple"),
          onPressed: widget.enable?(){
            appleLogin();
          }:null,
          imagePath: "images/apple.png",
          width: socialIconSize,
          height: socialIconSize,
        );

      default:
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
            appleLogin();
          },
          buttonText: AppTranslations.of(context).text('login_btn_apple'),
        );
    }
  }

  void callBack(){
    if(widget.socialListenerCallback!=null){
      widget.socialListenerCallback(_checking,socialLoginInfoModel);
      socialLoginInfoModel=null;
    }
  }

  void appleLogin()async{
    try {
      setState(() {
        _checking = true;
      });

      callBack();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId:
          'com.halo.haloexpress.applesignin',
          redirectUri: Uri.parse(
            'https://invited-olive-worm.glitch.me/callbacks/sign_in_with_apple',
          ),
        ),
      );
      print(credential.toString());
      print(credential.authorizationCode);
      print(credential.identityToken);
      print( parseJwt(credential.identityToken));

      if(credential!=null){
        String email = credential.email;
        String userIdentifier = credential.userIdentifier;
        var model = parseJwt(credential.identityToken);
        email = model["email"];
        userIdentifier = model["sub"];

        socialLoginInfoModel = SocialLoginInfoModel(
          type: SocialLoginInfoModel.APPLE,
          userId: userIdentifier,
          email: email,
          name: credential.givenName,
          image: "",
          socialDataRaw: credential.toString()
        );
        // DebugApi.debugModels.add(DebugApiModel(plainText: "APPLE LOGIN: \n"+credential.toString(),type: DebugApiModel.TYPE_SOCIAL_LOGIN));
      }
      print(credential.userIdentifier);

    }catch(e){
      print(e);
    }

    setState(() {
      _checking = false;
    });
    callBack();
  }

  Map<String, dynamic> parseJwt(String token) {
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

  Future<void> _checkIfIsLogged() async {
    // final AccessToken accessToken = await FacebookAuth.instance.isLogged;
    // setState(() {
    //   _checking = false;
    // });
    // if (accessToken != null) {
    //   print("is Logged:::: ${(accessToken.toJson())}");
    //   // now you can call to  FacebookAuth.instance.getUserData();
    //   final userData = await FacebookAuth.instance.getUserData();
    // }
  }

}
