import 'package:flutter/cupertino.dart';
import 'package:haloapp/widget/social_login_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static ValueNotifier<bool> isLoadingLanguage = ValueNotifier<bool>(false);
  static const String _usernameKey = 'usernameSPKey';
  static const String _passwordKey = 'passwordSPKey';
  static const String _languageKey = 'languageSPKey';
  static const String _socialLoginTypeKey = 'socialLoginTypeKey';
  static const String _socialModelKey = 'socialModelKey';
  static const String _isFirstTimeKey = 'isFirstTimeKey';

  //Social Login
  static const String normalLogin = 'normalLogin';
  // static const String appleSocialLogin = 'apple';
  // static const String googleSocialLogin = 'google';
  // static const String facebookSocialLogin = 'facebook';

  void setSocialLoginInfo(SocialLoginInfoModel socialLoginInfoDataModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(socialLoginInfoDataModel!=null){
      prefs.setString(_socialModelKey, socialInfoModelToJson(socialLoginInfoDataModel));
      prefs.setString(_socialLoginTypeKey, socialLoginInfoDataModel.type);
    }
  }

  void setLoginInfo(String username, String password, String socialLoginType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_usernameKey, username);
    prefs.setString(_passwordKey, password);
    prefs.setString(_socialLoginTypeKey, socialLoginType);
  }

  Future getLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usernameValue = prefs.getString(_usernameKey);
    String passwordValue = prefs.getString(_passwordKey);
    String socialLoginTypeValue = prefs.getString(_socialLoginTypeKey);
    String socialLoginInfoModel = prefs.getString(_socialModelKey);

    Map<String, dynamic> info = {
      "username": usernameValue,
      "password": passwordValue,
      "socialType":socialLoginTypeValue,
    };

    print("socialLoginInfoModel : ${socialLoginInfoModel}");
    if(socialLoginInfoModel != null && socialLoginInfoModel.isNotEmpty){
      info.addAll({
        "socialModelKey":socialLoginInfoModel
      });
    }

    return info;
  }

  void removeLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_usernameKey);
    prefs.remove(_passwordKey);
    prefs.remove(_socialModelKey);
    prefs.remove(_socialLoginTypeKey);
  }

  void setLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_languageKey, languageCode);
  }

  Future getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString(_languageKey);

    return languageCode;
  }

  void setFirstTime(bool isFirstTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_isFirstTimeKey, isFirstTime);
  }

  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey(_isFirstTimeKey)){
      return prefs.getBool(_isFirstTimeKey);
    }

    return true;
  }
}
