import 'dart:io';
import 'package:haloapp/models/calculate_update_payment_model.dart';
import 'package:haloapp/models/food_history_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/food_variant_model.dart';
import 'package:haloapp/models/update_payment_model.dart';
import 'package:haloapp/models/available_online_payment_model.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/services/networking_services.dart';
import 'dart:convert';

class FoodHistoryNetworking {
  Future<List<FoodHistoryModel>> getFoodOrderHistory(
      Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getFoodOrderHistoryUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);

    if (response.statusCode == 200) {
      List<FoodHistoryModel> orders = _delegateHistoryOrderData(decodedData['response']);
      return orders;
    } else if (response.statusCode == 400) {
      return [];
    } else {
      print('getFoodOrderHistory Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  List<FoodHistoryModel> _delegateHistoryOrderData(
      Map<String, dynamic> responseData) {
    List<dynamic> ordersList = responseData['orders'];
    List<FoodHistoryModel> histories = [];

    if (ordersList.length > 0) {
      for (int i = 0; i < ordersList.length; i++) {
        Map<String, dynamic> order = ordersList[i];

        List<FoodOrderCart> orderItems =
            _delegateOrderDetails(order['orderItems']);

        order['order_items'] = orderItems;

        FoodHistoryModel history = FoodHistoryModel.fromJson(order);

        histories.add(history);
      }
    }

    return histories;
  }

  List<FoodOrderCart> _delegateOrderDetails(List<dynamic> orderItemsList) {
    List<FoodOrderCart> orders = [];

    if (orderItemsList.length > 0) {
      for (int i = 0; i < orderItemsList.length; i++) {
        Map<String, dynamic> food = orderItemsList[i];

        List<dynamic> variantsArr = food['variants'];
        List<FoodVariantItemModel> variants = [];

        if (variantsArr != null && variantsArr.length > 0) {
          for (int i = 0; i < variantsArr.length; i++) {
            Map<String, dynamic> v = variantsArr[i];

            FoodVariantItemModel item = FoodVariantItemModel(
                variantId: v['order_item_extra_id'] ?? '',
                name: v['order_item_extra_name'] ?? '',
                extraPrice: v['order_item_extra_price'] ?? '',
                status: true,
                selected: true);

            variants.add(item);
          }
        }

        FoodOrderCart order = FoodOrderCart(
          foodId: food['order_item_id'] ?? '',
          name: food['order_item_name'] ?? '',
          quantity: food['order_item_quantity'] ?? '',
          options: variants,
          price: food['order_item_price'].toString() ?? '',
          finalPrice: food['order_item_final_price'].toString() ?? '',
          remark: food['order_item_remark'] ?? '',
        );

        orders.add(order);
      }
    }

    return orders;
  }

  Future getFoodOrderHistoryDetails(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getFoodOrderDetailsUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      FoodHistoryModel order =
          _delegateHistoryOrderDetailsData(decodedData['response']);
      return order;
    } else if (response.statusCode == 400) {
      return [];
    } else {
      print('getFoodOrderHistoryDetails Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  FoodHistoryModel _delegateHistoryOrderDetailsData(
      Map<String, dynamic> responseData) {
    Map<String, dynamic> order = responseData['orders'];

    // print("_delegateHistoryOrderDetailsData -- ${order}");
    List<FoodOrderCart> orderItems = _delegateOrderDetails(order['orderItems']);

    order['order_items'] = orderItems;
    FoodHistoryModel history = FoodHistoryModel.fromJson(order);

    return history;
  }

  Future rateOrder(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getFoodRatingUrl(), params);

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
      print('rateOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future orderRefund(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getBookingRefundUrl(), params);

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
      print('rateOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future getAvailableOnlinePaymentMethod(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getAvailableOnlineMethods(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);

    if (response.statusCode == 200) {
      Map<String, dynamic> availableOnlinePaymentModel = decodedData['return'];
      return AvailableOnlinePaymentModel.fromJson(availableOnlinePaymentModel);
      if (decodedData['status_code'] == 514) {
        // TODO: expired token, re-login
        throw decodedData;
      } else if (decodedData['status_code'] == 400) {
        throw decodedData['msg'] ?? '';
      } else {
        return decodedData['msg'] ?? '';
      }
    } else {
      print('rateOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future updatePaymentMethodCalculate(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getUpdatePaymentCalculate(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);

    if (response.statusCode == 200) {
      Map<String, dynamic> calculateUpdatePaymentModel = decodedData['response'];
      return CalculateUpdatePaymentModel.fromJson(calculateUpdatePaymentModel);
      if (decodedData['status_code'] == 514) {
        // TODO: expired token, re-login
        throw decodedData;
      } else if (decodedData['status_code'] == 400) {
        throw decodedData['msg'] ?? '';
      } else {
        return CalculateUpdatePaymentModel.fromJson(decodedData['response']) ?? '';
      }
    } else {
      print('rateOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future updatePaymentMethod(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getUpdatePaymentMethods(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);

    if (response.statusCode == 200) {
      Map<String, dynamic> updatePaymentModel = decodedData['response'];
      return UpdatePaymentModel.fromJson(updatePaymentModel);
      if (decodedData['status_code'] == 514) {
        // TODO: expired token, re-login
        throw decodedData;
      } else if (decodedData['status_code'] == 400) {
        throw decodedData['msg'] ?? '';
      } else {
        //return CalculateUpdatePaymentModel.fromJson(decodedData['response']) ?? '';
      }
    } else {
      print('rateOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

}

