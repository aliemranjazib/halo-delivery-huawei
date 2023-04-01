import 'dart:io';

import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/history_model.dart';
import 'package:haloapp/utils/services/networking_services.dart';
import 'package:http/http.dart' as HTTP;
import 'dart:convert';
import '../utils/constants/api_urls.dart';

class HistoryNetworking {
  Future<List<HistoryModel>> getBookingHistory(
      Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getBookingHistoryUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);
    print("123213123"+response.statusCode.toString());
    if (response.statusCode == 200) {
      List<HistoryModel> history = _delegateHistoryData(decodedData['return']);
      return history;
    } else if (response.statusCode == 400) {
      return [];
    } else {
      print('getBookingHistory Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  List<HistoryModel> _delegateHistoryData(Map<String, dynamic> returnData) {
    List<HistoryModel> historyList = [];

    List<dynamic> bookingDetailsList = returnData['bookingDetail'];
    if (bookingDetailsList != null) {
      if (bookingDetailsList.length > 0) {
        for (int i = 0; i < bookingDetailsList.length; i++) {
          Map<String, dynamic> details = bookingDetailsList[i];
          List<dynamic> addressesList = details['bookingAddress'];
          List<AddressModel> addresses = [];

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
                  unitNo: addr['building_unit_number'] ?? '',
                  buildingName: addr['building_name'] ?? '',
                  receiverName: addr['recipient_name'] ?? '',
                  receiverPhone: addr['recipient_phone'] ?? '',
                  paymentCollect:
                      (addr['payment_collect'] == 'true') ? true : false);

              addresses.add(address);
            }
          }

          HistoryModel history = HistoryModel(
            bookingId: details['booking_id'] ?? '',
            bookingUniqueKey: details['booking_unique_key'] ?? '',
            bookingNumber: details['booking_number'] ?? '',
            orderStatus: details['order_status'] ?? '',
            bookingDate: details['booking_date'] ?? '',
            pickupDatetime: details['pickup_datetime'] ?? '',
            pickupDate: details['pickup_date'] ?? '',
            pickupTime: details['pickup_time'] ?? '',
            vehicleTypeId: details['vehicle_type'] ?? '',
            distance: details['distance'] ?? '',
            distancePrice: details['distance_price'] ?? '',
            totalPrice: details['total_price'] ?? '',
            totalPriceOri: details['total_price_ori'] ?? '',
            discountedPrice: details['discounted_price'] ?? '',
            remarks: details['remarks'] ?? '',
            paymentMethod: details['payment_method'] ?? '',
            customerRating: details['customer_rating'] ?? '0',
            addresses: addresses,
            bookingHaloWalletAmount: details['booking_halowallet_amount'] ?? '',
            bookingCodAmount: details['booking_cod_amount'] ?? '',
          );

          historyList.add(history);
        }
      }
    }

    return historyList;
  }

  Future getHistoryDetails(Map<String, dynamic> params) async {
    HTTP.Response response = await NetworkingService()
        .postRequest(APIUrls().getBookingDetailsUrl(), params);

    var decodedData = jsonDecode(response.body);
    print(decodedData);

    if (response.statusCode == 200) {
      HistoryModel history = _delegateHistoryDetailsData(decodedData['return']);

      if (history != null) {
        return history;
      } else {
        throw 'Failed to load';
      }
    } else {
      print('getHistoryDetails Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  HistoryModel _delegateHistoryDetailsData(Map<String, dynamic> returnData) {
    Map<String, dynamic> details = returnData['bookingDetail'];
    Map<String, dynamic> costDetails = returnData['bookingCost'];
    if (details == null) {
      return null;
    }

    List<AddressModel> addresses = [];
    List<dynamic> addressesList = returnData['bookingAddress'];

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
            unitNo: addr['building_unit_number'] ?? '',
            buildingName: addr['building_name'] ?? '',
            receiverName: addr['recipient_name'] ?? '',
            receiverPhone: addr['recipient_phone'] ?? '',
            paymentCollect: (addr['payment_collect'] == 'true') ? true : false);

        addresses.add(address);
      }
    }

    HistoryModel history = HistoryModel(
        bookingId: details['booking_id'] ?? '',
        bookingUniqueKey: details['booking_unique_key'] ?? '',
        bookingNumber: details['booking_number'] ?? '',
        orderStatus: details['order_status'] ?? '',
        bookingDate: details['booking_date'] ?? '',
        pickupDatetime: details['pickup_datetime'] ?? '',
        pickupDate: details['pickup_date'] ?? '',
        pickupTime: details['pickup_time'] ?? '',
        driverName: (costDetails != null) ? costDetails['user_fullname'] : '',
        driverPhone: (costDetails != null)
            ? (costDetails['user_phone_country'] ?? '') +
                (costDetails['user_phone'] ?? '')
            : '',
        driverPlateNumber:
            (costDetails != null) ? costDetails['plate_number'] : '',
        vehicleTypeId: details['vehicle_type'] ?? '',
        distance: details['distance'] ?? '',
        distancePrice: details['distance_price'] ?? '',
        totalPrice: details['total_price'] ?? '',
        totalPriceOri: details['total_price_ori'] ?? '',
        discountedPrice: details['discounted_price'] ?? '',
        remarks: details['remarks'] ?? '',
        paymentMethod: details['payment_method'] ?? '',
        customerComment: details['customer_comment'] ?? '',
        customerRating: details['customer_rating'] ?? '0',
        couponName: details['coupon_name'] ?? '',
        couponType: details['coupon_type'] ?? '',
        couponDiscount: details['coupon_discount'] ?? '',
        itemType: details['item_type'] ?? '',
        itemTypeDesc: details['item_type_desc'] ?? '',
        priorityFee: details['priority_fee'] ?? '',
        buildingName: details['building_name'] ?? '',
        buildingUnitNumber: details['building_unit_number'] ?? '',
        addresses: addresses,
        bookingHaloWalletAmount: details['booking_halowallet_amount'] ?? '',
        bookingCodAmount: details['booking_cod_amount'] ?? '',
    );

    return history;
  }

  Future cancelBooking(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getCancelBookingUrl(), params);

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
        return decodedData['msg'] ?? '';
      }
    } else {
      print('cancelBooking Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future rateBooking(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getRateRiderUrl(), params);

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
        return decodedData['msg'] ?? '';
      }
    } else {
      print('rateBooking Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future getTrackingInfo(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getTrackingInfoUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      return decodedData['return'];
    } else if (response.statusCode == 514) {
      // TODO: expired token, re-login
      throw decodedData;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('getTrackingInfo Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future getBookingRefund(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getBookingRefundUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      return decodedData['msg'] ?? '';
    } else if (response.statusCode == 514) {
      // TODO: expired token, re-login
      throw decodedData;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('getBookingRefund Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }
}
