import 'dart:convert';
import 'dart:io';

import 'package:haloapp/models/activity_question_model.dart';
import 'package:haloapp/models/banner_model.dart';
import 'package:haloapp/models/referral_details_model.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/services/networking_services.dart';
import 'package:http/http.dart' as HTTP;

class UserNetworking {
  static decode(HttpClientResponse something) async {
    return jsonDecode((await something.transform(utf8.decoder).join()));
  }

  static getSavedAddressList() async {
    // HttpClientResponse response = await NetworkingService()
    //     .postRequestWithAuth(APIUrls().getSavedAddressListUrl(), {});

    // var a = await decode(response);
    // print(a);
    // var data = jsonDecode(a);
    // // var decodedData = jsonDecode(data);

    // print(data);
    // print(await decode(await NetworkingService()
    //     .postRequestWithAuth(APIUrls().getSavedAddressListUrl(), {})));
    return (await decode(await NetworkingService().postRequestWithAuth(
        APIUrls().getSavedAddressListUrl(), {})))['response'];
  }

  static saveAddress(params, [addressId]) async {
    params = Map<String, dynamic>.from(params);
    if (addressId != null) params['addressId'] = addressId;
    return (await decode(await NetworkingService().postRequestWithAuth(
        (addressId != null)
            ? APIUrls().getEditAddressUrl()
            : APIUrls().getSaveAddressUrl(),
        {"data": params})));
  }

  static removeAddress(addressId) async {
    return decode(await NetworkingService()
        .postRequestWithAuth(APIUrls().getRemoveAddressUrl(), {
      'data': {'addressId': addressId}
    }));
  }

  static nearbyAddress(params) async {
    params = Map<String, dynamic>.from(params);
    return (await decode(await NetworkingService().postRequestWithAuth(
        APIUrls().getNearbySavedAddresstUrl(), params)))['response'];
  }

  //Update Profile
  static Future updateProfile(Map<String, dynamic> params) async {
    return (await decode(await NetworkingService()
        .postRequestWithAuth(APIUrls().getUpdateProfileUrl(), params)));
  }

  Future getHomeBanner(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getHomeBannerUrl(), params);

    var decodedData = jsonDecode(response.body);
    // print(decodedData);

    if (response.statusCode == 200) {
      return BannerModel.fromJson(decodedData['response']);
    } else {
      print('getHomeBanner Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future getReviewBanner(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getReviewBannerUrl(), params);

    var decodedData = jsonDecode(response.body);
    // print(decodedData);

    if (response.statusCode == 200) {
      return BannerModel.fromJson(decodedData['response']);
    } else {
      print('getReviewBanner Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future getUserSupportQuestion(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getUserSupportUrl(), params);

    String data = await response.transform(utf8.decoder).join();

    var decodedData = jsonDecode(data);

    print(decodedData);

    if (response.statusCode == 200) {
      Map<String, dynamic> questions = decodedData['response'];
      return ActivityQuestionModel.fromJson(questions);
    } else {
      print('getUserSupportQuestion Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future getUserReferralDetails(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getUserReferralDetailUrl(), params);

    String data = await response.transform(utf8.decoder).join();

    var decodedData = jsonDecode(data);

    print(decodedData);

    if (response.statusCode == 200) {
      Map<String, dynamic> referralDetails = decodedData['response'];
      return ReferralDetailsModel.fromJson(referralDetails);
    } else {
      print('getReferrals Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }
}
