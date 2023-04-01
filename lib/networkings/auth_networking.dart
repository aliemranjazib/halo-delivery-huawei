import 'package:haloapp/models/notification_model.dart';
import 'package:haloapp/models/user_model.dart';
import 'package:haloapp/utils/services/networking_services.dart';
import 'package:haloapp/utils/services/package_info_service.dart';
import 'package:haloapp/utils/services/shared_pref_service.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert';
import '../utils/constants/api_urls.dart';
import 'dart:io';

class AuthNetworking {
  Future isAppRequireUpdate() async {
    Map<String, String> headers = await APIUrls().getHeader();
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getCheckAppUpdateUrl(), headers);
    print(response.reasonPhrase);
    return (response.statusCode == 400);
    // var decodedData = jsonDecode(response.body);
  }

  //Social Login
  Future socialLogin(Map<String, dynamic> params) async {
    Map<String, String> headers = await APIUrls().getHeader();

    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getSocialLoginUrl(), params, headers);

    print(headers);
    var decodedData = jsonDecode(response.body);
    print(decodedData);
    print(response.statusCode);
    if (response.statusCode == 200) {
      _storeUserData(decodedData['response']);
      return 'login';
    }
    //Update Phone Number
    else if (response.statusCode == 340) {
      return decodedData;
    }
    else if (response.statusCode == 333) {
      return 'app_update';
    } else {
      print('Login Failed: ' + decodedData['msg'].toString());
      throw decodedData['msg'].toString() ?? '';
    }
  }

  //Social Merge Account
  Future socialBindOldAccount(Map<String, dynamic> params) async {
    Map<String, String> headers = await APIUrls().getHeader();

    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getSocialBindOldAccountUrl(), params, headers);

    print(headers);
    var decodedData = jsonDecode(response.body);
    print(decodedData);
    print(response.statusCode);
    if (response.statusCode == 200) {
      _storeUserData(decodedData['response']);
      return 'login';
    } else if (response.statusCode == 333) {
      return 'app_update';
    } else {
      // print('Login Failed: ' + decodedData['msg'].toString());
      throw decodedData['msg'].toString() ?? '';
    }
  }

  //Social Update Account
  Future socialUpdateAccount(Map<String, dynamic> params) async {
    Map<String, String> headers = await APIUrls().getHeader();

    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getSocialUpdatePhoneNumberUrl(), params, headers);

    print(headers);
    var decodedData = jsonDecode(response.body);
    print(decodedData);
    print(response.statusCode);
    if (response.statusCode == 200) {
      _storeUserData(decodedData['response']);
      return 'login';
    }else if(response.statusCode == 341){
      // var oldUser = decodedData['response']['oldUser'];
      return decodedData;
    }
    else if(response.statusCode == 340){
      // var oldUser = decodedData['response']['oldUser'];
      return decodedData;
    }
    else if (response.statusCode == 333) {
      return 'app_update';
    } else {
      // print('Login Failed: ' + decodedData['msg'].toString());
      throw decodedData['msg'].toString() ?? '';
    }
  }

  Future login(Map<String, dynamic> params) async {
    Map<String, String> headers = await APIUrls().getHeader();

    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getLoginUrl(), params, headers);

    var decodedData = jsonDecode(response.body);
    print(decodedData);
    print(response.statusCode);
    if (response.statusCode == 200) {
      _storeUserData(decodedData['response']);
      return 'login';
    } else if (response.statusCode == 301) {
      return decodedData;
    } else if (response.statusCode == 333) {
      return 'app_update';
    } else {
      print('Login Failed: ' + decodedData['msg'].toString());
      throw decodedData['msg'].toString() ?? '';
    }
  }

  void _storeUserData(Map<String, dynamic> data) {
    Map<String, dynamic> userData = data['user'];
    String authToken = data['authToken'] ?? '';
    User().setUserData(
        userId: userData['user_id'] ?? '',
        username: userData['user_name'] ?? '',
        userEmail: userData['user_email'] ?? '',
        userPhone: userData['user_phone'] ?? '',
        userPhoneCountryCode: userData['user_phone_country_code'] ?? '',
        userDOB: userData['user_dob'] ?? '',
        userToken: userData['user_token'] ?? '',
        authToken: authToken,
        userChatId: userData['user_chat_id'] ?? '',
        userRefCode: userData['user_ref_code'] ?? '',
        userRefLink: userData['refUrl'] ?? '',
        refTotalCommission: userData['ref_total_commission'] ?? '',
        referLeaderShipBoard: userData['ref_leadership_board_url'] ?? '',
        enabledOptions: data['enabled_options'] ?? [],
        enableFood: (userData['user_food_option'] == 'true') ? true : false,
        enableFrozen: (userData['user_frozen_option'] == 'true') ? true : false,
        enableFestival:
            (userData['user_festival_option'] == 'true') ? true : false,
        enablePharmacy:
            (userData['user_pharmacy_option'] == 'true') ? true : false,
        enableGroceries:
            (userData['user_groceries_option'] == 'true') ? true : false);
  }

  Future register(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getRegisterUrl(), params);
    print(response.body);
    var decodedData = jsonDecode(response.body);
    // print(decodedData);

    if (response.statusCode == 200) {
      return decodedData["response"]["userToken"] ?? '';
    } else {
      print('Register Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future resetPassword(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getForgotPasswordUrl(), params);

    var decodedData = jsonDecode(response.body);
    // print(decodedData);

    if (response.statusCode == 200) {
      String token = decodedData["response"]["userToken"] ?? '';
      User().setUserToken(token);

      return decodedData['msg'] ?? '';
    } else {
      print('resetPassword Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future smsVerification(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getSmsVerificationUrl(), params);

    var decodedData = jsonDecode(response.body);
    // print(decodedData);

    if (response.statusCode == 200) {
      // _storeUserData(decodedData['response']);
      return decodedData['msg'] ?? '';
    } else {
      print('smsVerification Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future resendVerificationCode(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getResendVerificationCodeUrl(), params);

    var decodedData = jsonDecode(response.body);
    // print(decodedData);

    if (response.statusCode == 200) {
      return decodedData['msg'] ?? '';
    } else {
      print('resendVerificationCode Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future changePassword(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getChangePasswordUrl(), params);

    var decodedData = jsonDecode(response.body);
    // print(decodedData);

    if (response.statusCode == 200) {
      return decodedData['msg'] ?? '';
    } else {
      print('changePassword Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future getNotificationList(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getNotificationListUrl(), params);

    var decodedData = jsonDecode(response.body);
    // print(decodedData);

    if (response.statusCode == 200) {
      return NotificationModel.fromJson(decodedData['response']);
    } else {
      print('getNotificationList Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future changePhone(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getChangePhoneUrl(), params);

    var decodedData = jsonDecode(response.body);
    print(decodedData);

    if (response.statusCode == 200) {
      return decodedData['msg'] ?? '';
    } else {
      print('changePhone Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future removeAccount(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getRemoveAccountUrl(), params);

    var decodedData = jsonDecode(response.body);
    print(decodedData);

    if (response.statusCode == 200) {
      return decodedData['msg'] ?? '';
    } else {
      print('removeAccount Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }
}
