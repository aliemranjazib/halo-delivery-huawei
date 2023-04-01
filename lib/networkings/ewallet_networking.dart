import 'dart:io';
import 'package:haloapp/models/top_up_transaction_model.dart';
import 'package:haloapp/models/wallet_transaction_model.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/services/networking_services.dart';
import 'dart:convert';
import 'package:http/http.dart' as HTTP;

class EwalletNetworking {
  Future<WalletTransactionsResponse> getEwalletTransaction(
      Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getWalletTransaction(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      return WalletTransactionsResponse.fromJson(decodedData);
      // List<FoodHistoryModel> orders =
      // _delegateHistoryOrderData(decodedData['response']);
      // return orders;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? 'Unexpected Error';
    } else {
      print('getEwalletTransaction Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<TopUpTransactionResponse> getTopUpTransaction(
      Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getWalletTopUpTransaction(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      return TopUpTransactionResponse.fromJson(decodedData);
      // List<FoodHistoryModel> orders =
      // _delegateHistoryOrderData(decodedData['response']);
      // return orders;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? 'Unexpected Error';
    } else {
      print('getTopUpTransaction Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<Map<String, dynamic>> topUp(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getWalletTopUp(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      // List<FoodHistoryModel> orders =
      // _delegateHistoryOrderData(decodedData['response']);
      return decodedData['response'];
    } else if (response.statusCode == 400) {
      return throw "Unexpected error";
    } else {
      print('topUp Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<Map<String, dynamic>> checkTopUpStatus(
      Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getWalletCheckStatus(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);

    if (response.statusCode == 200) {
      // List<FoodHistoryModel> orders =
      // _delegateHistoryOrderData(decodedData['response']);
      return decodedData['return'];
    } else if (response.statusCode == 400) {
      return throw decodedData['msg'];
    } else {
      print('topUp Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<Map<String, dynamic>> topUpCalculation(
      Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getWalletTopUpCalculation(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      // List<FoodHistoryModel> orders =
      // _delegateHistoryOrderData(decodedData['response']);
      return decodedData['response'];
    } else if (response.statusCode == 400) {
      return throw "Unexpected error";
    } else {
      print('topUp Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<List<dynamic>> getTopUpPaymentMethodList() async {
    print(APIUrls().getTopUpPaymentMethodList());
    HTTP.Response response = await NetworkingService()
        .getRequest(APIUrls().getTopUpPaymentMethodList());

    var result = [];
    print(response.statusCode);
    var decodedData = jsonDecode(response.body);
    print(decodedData);

    if (response.statusCode == 200) {
      result = decodedData['return']['availablePaymentMethodWithIcon'];
    }

    // print(result.runtimeType);

    return result;
    // print('hi');
    // return {};
    // String data = await response.transform(utf8.decoder).join();
    // var decodedData = jsonDecode(data);
    // // print(decodedData);

    // if (response.statusCode == 200) {
    //   // List<FoodHistoryModel> orders =
    //   // _delegateHistoryOrderData(decodedData['response']);
    //   return decodedData['response'];
    // } else if (response.statusCode == 400) {
    //   return throw "Unexpected error";
    // } else {
    //   print('get payment method failed: ' + decodedData['msg']);
    //   throw decodedData['msg'] ?? '';
    // }
  }
}
