import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:haloapp/main.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/networkings/auth_networking.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/services/push_notifications.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:haloapp/widget/social_login_container.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert';

class NetworkingService {
  static Future<Map<String, dynamic>> decode(
      HttpClientResponse something) async {
    return jsonDecode((await something.transform(utf8.decoder).join()));
  }

  NetworkingService._privateConstructor();
  static final NetworkingService _instance =
      NetworkingService._privateConstructor();

  factory NetworkingService() {
    return _instance;
  }

  Future getRequest(String url) async {
    HTTP.Response response = await HTTP.get(url);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      print('Error: ' + response.body);
      throw 'Error';
    }
  }

  Future postRequest(String url, Map<String, dynamic> params,
      [Map<String, String> headers]) async {
    Map<String, String> postHeaders =
        (headers == null) ? await APIUrls().getHeader() : headers;

    HTTP.Response response =
        await HTTP.post(url, headers: postHeaders, body: jsonEncode(params));
    print("### " + url);
    print(params);
    print(postHeaders);

    if (response.statusCode >= 200 && response.statusCode <= 400) {
      return response;
    } else {
      print('Error: ' + response.body.toString());
      throw 'Error';
    }
  }

  Future postRequestWithAuth(String url, Map<String, dynamic> params) async {
    try{
      print(User().getAuthToken());
      print(url);
      print(jsonEncode(params));
      print('----');
      HttpClient client = HttpClient();
      client.connectionTimeout = Duration(seconds: 30);
      var request = await client.postUrl(Uri.parse(url));
      request.headers.add("Content-Type", 'application/json; charset=utf-8');

      if (User().getAuthToken() != null)
        request.headers.add("Authorization", User().getAuthToken());

      String languageCode = await SharedPrefService().getLanguage();
      request.headers.add('language', languageCode);

      Map<String, String> customHeaders = await APIUrls().getHeader();
      customHeaders.forEach((key, value) {
        request.headers.add(key, value);
      });

      List<int> body = utf8.encode(json.encode(params));
      request.add(body);
//    request.write(body);

      final response = await request.close();

      if (response.statusCode >= 200 && response.statusCode <= 400) {
        return response;
      } else if (response.statusCode == 514) {
        // await autoLogin();
        User().resetUserData();
        throw 'Expired Token, please logout and login again';
      } else {
        print('Response code: ${response.statusCode}');
        print('Error: ' + response.toString());
        throw 'Error';
      }
    }catch(e){
      print(e);
      if(e is SocketException){
        throw "Connection timed out";
      }
    }

  }

  Future<void> autoLogin() async {
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
          if (data is String && data == 'login') {}
        } catch (e) {
          throw e;
        }
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
              // force refresh app after success login
            }
          } catch (e) {
            throw e;
          }
        }
      }
    }
  }
}
