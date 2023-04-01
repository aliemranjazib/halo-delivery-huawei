import 'dart:io';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:haloapp/models/address_model.dart';
import 'package:haloapp/models/coupon_model.dart';
import 'package:haloapp/models/food_model.dart';
import 'package:haloapp/models/food_order_model.dart';
import 'package:haloapp/models/food_rider_tacking.dart';
import 'package:haloapp/models/food_variant_model.dart';
import 'package:haloapp/models/shop_menu_model.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/models/shop_review_model.dart';
import 'package:haloapp/utils/constants/api_urls.dart';
import 'package:haloapp/utils/services/google_map_places_service.dart';
import 'package:haloapp/utils/services/networking_services.dart';
import 'dart:convert';

import 'package:huawei_map/components/latLng.dart';

class FoodNetworking {
  static Future<FoodRiderTracking> getFoodRiderTracking(
      String bookingUniqueKey) async {
    Map<String, dynamic> param = {
      "apiKey": APIUrls().getApiKey(),
      "data": {"bookingUniqueKey": bookingUniqueKey}
    };
    HttpClientResponse res = await NetworkingService().postRequestWithAuth(
        APIUrls.uri + '/Consumer/booking/foodLiveTracking', param);
    var data = (await NetworkingService.decode(res));
    print('&#(!@&#(*!@&*#&@*(!#&(!&#*!&#*!&#(&!#(&!(#*&!*(#&(!#&(!*');
    print(data['response']);
    print('&#(!@&#(*!@&*#&@*(!#&(!&#*!&#*!&#(&!#(&!(#*&!*(#&(!#&(!*');
    if (res.statusCode == 200)
      return FoodRiderTracking.fromJson(data['response']);
    throw data['msg'];
  }

  Future<List<ShopModel>> getNearbyShops(Map<String, dynamic> params) async {
    print('what gg');
    var isSearchByKeyword =
        (params['data']['keyword'] ?? null) != null ? "Search" : "";
    print(APIUrls().getNearbyShopUrl() + isSearchByKeyword);
    print('what gg');
    HttpClientResponse response = await NetworkingService().postRequestWithAuth(
        APIUrls().getNearbyShopUrl() + isSearchByKeyword, params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);

    if (response.statusCode == 200) {
      List<ShopModel> shops =
          await _delegateNearbyShopsData(decodedData['response']);
      print("erer ${shops.first.category}");

      return shops;
    } else if (response.statusCode == 400) {
      return [];
    } else {
      print('getNearbyShops Failed statuscode: ${response.statusCode}');
      print('getNearbyShops Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<List<ShopModel>> getNearbyFeaturedShops(
      Map<String, dynamic> params) async {
    print('what gg');
    var isSearchByKeyword =
        (params['data']['keyword'] ?? null) != null ? "Search" : "";
    print(APIUrls().getNearbyFeaturedShopUrl() + isSearchByKeyword);
    print('what gg');
    HttpClientResponse response = await NetworkingService().postRequestWithAuth(
        APIUrls().getNearbyFeaturedShopUrl() + isSearchByKeyword, params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);

    if (response.statusCode == 200) {
      List<ShopModel> shops =
          await _delegateNearbyShopsData(decodedData['response']);
      return shops;
    } else if (response.statusCode == 400) {
      return [];
    } else {
      print('getNearbyShops Failed statuscode: ${response.statusCode}');
      print('getNearbyShops Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<List<ShopModel>> getNearbyPromoteItem(
      Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getNearbyPromoItemUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);

    if (response.statusCode == 200) {
      List<ShopModel> shops =
          await _delegateNearbyShopsData(decodedData['response']);
      return shops;
    } else if (response.statusCode == 400) {
      return [];
    } else {
      print('getNearbyPromoteItem Failed statuscode: ${response.statusCode}');
      print('getNearbyPromoteItem Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<List<ShopReview>> getShopReview(Map<String, dynamic> params) async {
    print(APIUrls().getShopReview());
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getShopReview(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);

    if (response.statusCode == 200) {
      List<ShopReview> shopReviews =
          await _delegateShopsReviewData(decodedData['response']);
      return shopReviews;
    } else if (response.statusCode == 400) {
      return [];
    } else {
      print('getShopReview Failed statuscode: ${response.statusCode}');
      print('getShopReview Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future<List<ShopReview>> _delegateShopsReviewData(
    Map<String, dynamic> returnData,
  ) async {
    List<ShopReview> shopReviews = [];

    List<dynamic> reviewsArr = returnData['reviews'];

    if (reviewsArr != null) {
      if (reviewsArr.length > 0) {
        for (int i = 0; i < reviewsArr.length; i++) {
          Map<String, dynamic> details = reviewsArr[i];
          ShopReview shopReview = ShopReview(
            customerComment: details['customer_comment'] ?? '',
            customerRating: details['customer_rating'] ?? '',
            orderRatingDatetime: details['order_rating_datetime'] ?? '',
          );

          shopReviews.add(shopReview);
        }
      }
    }

    return shopReviews;
  }

  Future<List<ShopModel>> _delegateNearbyShopsData(
      Map<String, dynamic> returnData) async {
    List<ShopModel> shopsList = [];

    List<dynamic> shopsArr = returnData['shops'];

    if (shopsArr != null) {
      if (shopsArr.length > 0) {
        for (int i = 0; i < shopsArr.length; i++) {
          Map<String, dynamic> details = shopsArr[i];

          ShopModel shop = await _delegateShopDetailsData(details);

          shopsList.add(shop);
        }
      }
    }

    return shopsList;
  }

  Future<ShopModel> _delegateShopDetailsData(
      Map<String, dynamic> details) async {
    // extract shop menu arr
    List<dynamic> shopMenuArr = details['shop_menu'];
    List<ShopMenuModel> shopMenu = [];

    if (shopMenuArr != null) {
      if (shopMenuArr.length > 0) {
        for (int i = 0; i < shopMenuArr.length; i++) {
          Map<String, dynamic> menuDetails = shopMenuArr[i];

          // extract food arr
          List<dynamic> foodsArr = menuDetails['foods'];
          List<FoodModel> foods = [];

          if (foodsArr != null) {
            if (foodsArr.length > 0) {
              for (int i = 0; i < foodsArr.length; i++) {
                Map<String, dynamic> foodsDetails = foodsArr[i];

                // extract variants arr
                List<dynamic> variantsArr = foodsDetails['variants'];
                List<FoodVariantModel> variants = [];

                if (variantsArr != null) {
                  if (variantsArr.length > 0) {
                    for (int i = 0; i < variantsArr.length; i++) {
                      Map<String, dynamic> variantDetails = variantsArr[i];

                      // extract variant items arr
                      List<dynamic> variantItemsArr =
                          variantDetails['variantLists'];
                      List<FoodVariantItemModel> variantItems = [];

                      if (variantItemsArr != null) {
                        if (variantItemsArr.length > 0) {
                          for (int i = 0; i < variantItemsArr.length; i++) {
                            Map<String, dynamic> variantItemDetails =
                                variantItemsArr[i];

                            FoodVariantItemModel variantItem =
                                FoodVariantItemModel(
                              variantId: variantItemDetails['variantId'] ?? '',
                              name: variantItemDetails['listName'] ?? '',
                              extraPrice:
                                  variantItemDetails['extraPrice'] ?? '',
                              status: (variantItemDetails['status'] == 'true')
                                  ? true
                                  : false,
                              selected: false,
                            );

                            variantItems.add(variantItem);
                          } // End of variant items loop
                        }
                      }

                      FoodVariantModel variant = FoodVariantModel(
                        variantListId: variantDetails['variantListId'] ?? '',
                        variantMin: variantDetails['variantMin'] ?? '0',
                        variantMax: variantDetails['variantMax'] ?? '0',
                        variantName: variantDetails['variantName'] ?? '',
                        variantOption: variantDetails['variantOption'] ?? '',
                        variantList: variantItems,
                      );

                      variants.add(variant);
                    } // End of variants loop
                  }
                }

                FoodModel food = FoodModel(
                  foodId: foodsDetails['foodId'] ?? '',
                  name: foodsDetails['name'] ?? '',
                  price: foodsDetails['price'] ?? '',
                  description: foodsDetails['description'] ?? '',
                  imageUrl: foodsDetails['imageUrl'] ?? '',
                  status: (foodsDetails['status'] == 'true') ? true : false,
                  priceDiscountStatus:
                      (foodsDetails['priceDiscountStatus'] == 'true')
                          ? true
                          : false,
                  priceDiscounted: foodsDetails['priceDiscounted'] ?? '',
                  imgPromoTag:
                      (foodsDetails['imgPromoTag'] == 'true') ? true : false,
                  imgPromoTagText: foodsDetails['imgPromoTagText'] ?? '',
                  variants: variants,
                );

                foods.add(food);
              } // End of foods loop
            }
          }

          ShopMenuModel menu = ShopMenuModel(
            categoryId: menuDetails['categoryId'] ?? '',
            categoryName: menuDetails['categoryName'] ?? '',
            categoryStatus:
                (menuDetails['categoryStatus'] == 'true') ? true : false,
            foods: foods,
          );

          shopMenu.add(menu);
        } // End of shop menu loop
      }
    }

    ShopModel shop = ShopModel(
      id: details['shop_id'] ?? '',
      uniqueCode: details['shop_unique_code'] ?? '',
      customAddress: details['shop_custom_address'] ?? '',
      street: details['shop_street'] ?? '',
      zip: details['shop_zip'] ?? '',
      city: details['shop_city'] ?? '',
      state: details['shop_state'] ?? '',
      lat: details['shop_lat'] ?? '',
      lng: details['shop_lng'] ?? '',
      shopStatus: details['shop_status'] ?? '',
      shopPromo: details['shop_promo'] ?? '',
      openTime: details['shop_open_time'] ?? '',
      closeTime: details['shop_close_time'] ?? '',
      shopName: details['shop_name'] ?? '',
      phone: details['shop_phone'] ?? '',
      fullAddress: details['shop_fulladdress'] ?? '',
      partner: (details['shop_partner'] == 'true') ? true : false,
      merchantId: details['merchant_id'] ?? '',
      logoUrl: details['shop_logo_url'] ?? '',
      headerImgUrl: details['shop_header_url'] ?? '',
      buildingName: details['shop_building_name'] ?? '',
      buildingUnit: (details['shop_building_unit'] == 'true') ? true : false,
      category: details['shop_category'] ?? [],
      shopTag: details['shop_tag'] ?? [],
      freeDeliveryStatus:
          (details['shop_free_delivery_status'] == 'true') ? true : false,
      featuresStatus:
          (details['shop_features_status'] == 'true') ? true : false,
      featuresDisplay: details['shop_feature_tag'] ?? '',
      totalOrder: details['shop_total_order'] ?? '',
      rating: details['shop_rating'] ?? '0.0',
      shopOpenType: details['shop_open_type'] ?? '',
      shopOpenTimeRange: details['shop_open_time_json'],
      shopMinAmount: details['shop_minimum_amount'],
      shopMinCharges: details['shop_minimum_charges'],
      shopMenu: shopMenu,
      duration: int.parse(details['estimateTime'] ?? '0'),
      distance: double.parse(details['nearby'] ?? '0.0'),
      closeShopText: details['shop_close_text'] ?? '',
      shopDeliveryInterval: details['shop_order_interval'],
      shopDeliveryFee:
          double.parse(details['shop_delivery_fee'].toString() ?? "0.0"),
      shopClosePreOrder: (details['shop_close_preOrder'] == 'true'),
      shopUserFavourite:
          (details['shop_user_favourite'] == 'true') ? true : false,
      availableDates: (details['preOrder'] ?? []),
      notInAreaStatus: (details['notInAreaStatus'] == 'true') ? true : false,
      showPreOrderStatus:
          (details['showPreOrderStatus'] == 'true') ? true : false,
    );

    return shop;
  }

  Future<ShopModel> getShopDetails(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getShopDetailsUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData['response']['shop']);

    if (response.statusCode == 200) {
      ShopModel shop =
          await _delegateShopDetailsData(decodedData['response']['shop']);
      return shop;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('getShopDetails Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future calculateOrder(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getCalculateFoodOrderUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      String finalPrice =
          decodedData['response']['finalPrice'].toString() ?? '';
      FoodOrderModel().setCalculatedFoodFinalPrice(finalPrice);

      return true;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('getShopDetails Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  _delegateOrderDetails(Map<String, dynamic> responseData) {
    FoodOrderModel().clearOrderDetails();

    List<dynamic> details = responseData['orderDetails'];
    List<FoodOrderCart> orders = [];

    if (details.length > 0) {
      for (int i = 0; i < details.length; i++) {
        Map<String, dynamic> food = details[i];

        List<dynamic> variantsArr = food['variants'];
        List<FoodVariantItemModel> variants = [];

        if (variantsArr != null && variantsArr.length > 0) {
          for (int i = 0; i < variantsArr.length; i++) {
            Map<String, dynamic> v = variantsArr[i];

            FoodVariantItemModel item = FoodVariantItemModel(
              variantId: v['variantId'] ?? '',
              name: v['name'] ?? '',
              extraPrice: v['extraPrice'] ?? '',
              status: true,
              selected: true,
            );

            variants.add(item);
          }
        }

        FoodOrderCart order = FoodOrderCart(
          foodId: food['foodId'] ?? '',
          name: food['name'] ?? '',
          quantity: food['quantity'] ?? '',
          options: variants,
          price: food['price'].toString() ?? '',
          finalPrice: food['finalPrice'].toString() ?? '',
          remark: food['remark'] ?? '',
        );

        orders.add(order);
      }
    }

    FoodOrderModel().setOrderCart(orders);
  }

  Future createOrder(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getCreateFoodOrderUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    print(decodedData);

    if (response.statusCode == 200) {
      _delegateOrderDetails(decodedData['response']);
      String orderUniqueKey = decodedData['response']['orderUniqueKey'] ?? '';

      FoodOrderModel().setOrderUniqueKey(orderUniqueKey);
      FoodOrderModel().setCreatedOrderPrice(
          finalPrice: decodedData['response']['finalPrice'].toString() ?? '',
          foodFinalPrice:
              decodedData['response']['foodFinalPrice'].toString() ?? '',
          estDuration: decodedData['response']['estDuration'].toString() ?? '',
          deliveryFee: decodedData['response']['deliveryFee'].toString() ?? '',
          orderFoodSST:
              decodedData['response']['order_food_sst'].toString() ?? '0',
          minFee: decodedData['response']['min_fee'].toString() ?? '0',
          paymentFee: decodedData['response']['paymentFee'].toString() ?? '0',
          packingFee: decodedData['response']['packing_fee'].toString() ?? '0',
          autoDiscount:
              decodedData['response']['autoDiscount'].toString() ?? '0.00');
      FoodOrderModel().setPaymentMethodSelected(
          decodedData['response']['paymentMethodSelected']);
      FoodOrderModel().setDeliveryInterval(
          int.tryParse(decodedData['response']['shop_delivery_interval']) ?? 0);
      FoodOrderModel()
          .setAvailableDates(decodedData['response']['preOrder'] ?? []);
      FoodOrderModel()
          .setPaymentMethods(decodedData['response']['paymentMethod'] ?? []);
      FoodOrderModel().setOvertimeStatus(
          decodedData['response']['overtimeStatus'].toString() ?? '');
      FoodOrderModel().setPaymentMethods(
          decodedData['response']['paymentMethodWithIcon'] ?? []);

      return true;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('createOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future confirmOrder(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getConfirmFoodOrderUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      Map<String, dynamic> returnData = decodedData['response'];

      String finalPrice = returnData['finalPrice'] ?? '';
      String orderUniqueKey = returnData['orderUniqueKey'] ?? '';

      if (returnData != null &&
          returnData['paymentMethod'] != null &&
          returnData['paymentMethod'] != 'cod' &&
          returnData['paymentUniqueKey'] != null) {
        Map<String, String> data = {
          "paymentUniqueKey": returnData['paymentUniqueKey'],
          "paymentUrl": returnData['paymentUrl'],
        };
        return data;
      } else {
        return decodedData['msg'] ?? '';
      }

//      return true;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('confirmOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future validateCoupon(Map<String, dynamic> params) async {
    print('gg le');
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getFoodValidateCouponUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    return {"status": response.statusCode, "json": decodedData ?? {}};
  }

  Future<List<Coupon>> foodCouponList(Map<String, dynamic> params) async {
    print('coupon list le');
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getFoodCouponListUrl(), params);

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

    List<dynamic> couponsArr = returnData['response']['couponList'];
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

  Future getZone(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getZoneListUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      Map<String, dynamic> returnData = decodedData['return'];

      List<dynamic> zonesArr = returnData['zones'];
      List<dynamic> zones = [];

      if (zonesArr != null) {
        if (zonesArr.length > 0) {
          for (int i = 0; i < zonesArr.length; i++) {
            List<dynamic> zoneDetailsArr = zonesArr[i]['zone_latlng'];

            List<LatLng> zoneLatLngs = [];
            if (zoneDetailsArr != null) {
              if (zoneDetailsArr.length > 0) {
                for (int i = 0; i < zoneDetailsArr.length; i++) {
                  String latlng = zoneDetailsArr[i];
                  List<String> splitStr = latlng.split(',');
                  String lat = splitStr[0];
                  String lng = splitStr[1];

                  zoneLatLngs.add(LatLng(double.parse(lat), double.parse(lng)));
                }
              }
            }

            zones.add(zoneLatLngs);
          }
        }
      }

      return zones;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('getZone Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future rateOrder(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getFoodRatingUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('rateOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future addFavShop(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getFoodAddFavShopUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('rateOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }

  Future removeFavShop(Map<String, dynamic> params) async {
    HttpClientResponse response = await NetworkingService()
        .postRequestWithAuth(APIUrls().getFoodRemoveFavShopUrl(), params);

    String data = await response.transform(utf8.decoder).join();
    var decodedData = jsonDecode(data);
    // print(decodedData);

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      throw decodedData['msg'] ?? '';
    } else {
      print('rateOrder Failed: ' + decodedData['msg']);
      throw decodedData['msg'] ?? '';
    }
  }
}
