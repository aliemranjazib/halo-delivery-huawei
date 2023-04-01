import 'dart:io';
import 'package:haloapp/models/activity_model.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/booking_model.dart';
import 'package:haloapp/models/coupon_model.dart';
import 'package:haloapp/utils/services/networking_services.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert';
import '../utils/constants/api_urls.dart';

class BookingNetworking {
  Future getDistancePrice(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getDistancePriceUrl(), params);

    var decodedData = jsonDecode(response.body);
    // print(decodedData);

    if (response.statusCode == 200) {
      if (decodedData['status'] == true) {
        return decodedData['return']['distance_price'];
      } else {
        throw decodedData['msg'] ?? '';
      }
    } else {
      print('getDistancePrice Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future createBooking(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getCreateBookingUrl(), params);

    var decodedData = jsonDecode(response.body);
//    print(decodedData);
    printWrapped(decodedData.toString());

    if (response.statusCode == 200) {
      List<AddressModel> addresses = [];
      List<dynamic> addressesData = decodedData['return']['bookingAddress'];

      if (addressesData != null && addressesData.length > 0) {
        for (int i = 0; i < addressesData.length; i++) {
          Map<String, dynamic> addr = addressesData[i];
          AddressModel address = AddressModel(
              type: addr['type'] ?? '',
              fullAddress: addr['full_address'] ?? '',
              lat: addr['lat'] ?? '',
              lng: addr['lng'] ?? '',
              street: addr['street'] ?? '',
              zip: addr['zip'] ?? '',
              city: addr['city'] ?? '',
              state: addr['state'] ?? '',
              unitNo: addr['building_unit_number'] ?? '',
              buildingName: addr['building_name'] ?? '',
              receiverName: addr['recipient_name'] ?? '',
              receiverPhone: addr['recipient_phone'] ?? '',
              addressId: addr['address_id'] ?? '');

          addresses.add(address);
        }
      }

      BookingModel().setCreatedBookingData(
        key: decodedData['return']['bookingUniqueKey'] ?? '',
        totalPrice: decodedData['return']['totalPrice'] ?? '',
        addresses: addresses,
      );

      BookingModel()
          .setPaymentMethods(decodedData['return']['paymentMethod'] ?? []);

      return decodedData['msg'] ?? '';
    } else {
      print('createBooking Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future confirmBooking(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getConfirmBookingUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      if (decodedData['status_code'] == 514) {
        // TODO: expired token, re-login
        throw decodedData;
      } else {
        Map<String, dynamic> returnData = decodedData['return'];
        if (returnData != null &&
            returnData['paymentMethod'] != null &&
            returnData['paymentMethod'] == 'online' &&
            returnData['paymentUniqueKey'] != null) {
          Map<String, String> data = {
            "paymentUniqueKey": returnData['paymentUniqueKey']
          };
          return data;
        } else {
          return decodedData['msg'] ?? '';
        }
      }
    } else {
      print('confirmBooking Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future validateCoupon(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getValidateCouponUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      if (decodedData['status_code'] == 514) {
        // TODO: expired token, re-login
        throw decodedData;
      } else if (decodedData['status_code'] == 400) {
        throw decodedData['msg'] ?? '';
      } else {
        return decodedData;
      }
    } else {
      print('validateCoupon Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<List<Coupon>> couponList(Map<String, dynamic> params) async {
    print('coupon list le');
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getCouponListUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);

    print(decodedData);

    if (response.statusCode == 200) {
      List<Coupon> shops = await _delegateCouponList(decodedData);

      return shops;
    } else if (response.statusCode == 400) {
      return [];
    } else {
      print('get coupon List Failed statuscode: ${response.statusCode}');
      print('get coupon List Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }

    // print(decodedData);
  }

  Future<List<Coupon>> _delegateCouponList(
      Map<String, dynamic> returnData) async {
    List<Coupon> couponList = [];

    List<dynamic> couponsArr = returnData['return']['couponList'];
    if (couponsArr != null) {
      if (couponsArr.length > 0) {
        for (int i = 0; i < couponsArr.length; i++) {
          Map<String, dynamic> details = couponsArr[i];
          Coupon coupon = Coupon.fromJson(details);

          couponList.add(coupon);
        }
      }
    }

    return couponList;
  }

  Future uploadPhoto(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getUploadPhotoUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      String imgUrl = decodedData['return']['imgUrl'];
      if (imgUrl != null) {
        return imgUrl;
      } else {
        throw 'Upload Photo Failed';
      }
    } else {
      print('uploadPhoto Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future getAvailableBookingDates(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getAvailableBookingDatesUrl(), params);

    var decodedData = jsonDecode(response.body);
    print(decodedData);

    if (response.statusCode == 200) {
      if (decodedData['status'] == true) {
        return decodedData['return']['availableDate'];
      } else {
        throw decodedData['msg'] ?? '';
      }
    } else {
      print('getAvailableBookingDates Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future getRecentAddresses(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getRecentAddressesUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      List<AddressModel> addresses =
          _delegateAddressData(decodedData['return']);
      return addresses;
    } else {
      print('getRecentAddresses Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  List<AddressModel> _delegateAddressData(Map<String, dynamic> returnData) {
    List<AddressModel> addresses = [];
    List<dynamic> addressesList = returnData['recentAddress'];

    if (addressesList != null && addressesList.length > 0) {
      for (int i = 0; i < addressesList.length; i++) {
        Map<String, dynamic> addr = addressesList[i];
        AddressModel address = AddressModel(
            type: addr['type'] ?? '',
            fullAddress: addr['full_address'] ?? '',
            lat: addr['lat'] ?? '',
            lng: addr['lng'] ?? '',
            street: addr['street'] ?? '',
            zip: addr['zip'] ?? '',
            city: addr['city'] ?? '',
            state: addr['state'] ?? '',
            unitNo: '',
            buildingName: '',
            receiverName: '',
            receiverPhone: '',
            paymentCollect: false);

        addresses.add(address);
      }
    }

    return addresses;
  }

  Future getRecentActivity(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getRecentActivityUrl(), params);

    String data = await response.transform(utf8.decoder).join();

    var decodedData = jsonDecode(data);

    print(decodedData);

    if (response.statusCode == 200) {
      Map<String, dynamic> bookingDetail = decodedData['return'];
      print(bookingDetail);
      return ActivityModel.fromJson(bookingDetail);
    } else {
      print('getActivity Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future getAllRecentActivity(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getAllRecentActivityUrl(), params);

    String data = await response.transform(utf8.decoder).join();

    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      Map<String, dynamic> bookingDetail = decodedData['return'];
      print(bookingDetail);
      return ActivityModel.fromJson(bookingDetail);    } else {
      print('getActivity Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }
}
