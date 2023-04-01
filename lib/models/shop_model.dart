import 'package:haloapp/models/shop_menu_model.dart';

import 'app_config_model.dart';

class ShopModel {
  String id;
  String uniqueCode;
  String customAddress;
  String street;
  String zip;
  String city;
  String state;
  String lat;
  String lng;
  String shopStatus;
  String shopPromo;
  String openTime;
  String closeTime;
  String shopName;
  String phone;
  String fullAddress;
  bool partner;
  String merchantId;
  String logoUrl;
  String headerImgUrl;
  String buildingName;
  bool buildingUnit;
  List<ShopMenuModel> shopMenu;
  List<dynamic> category;
  List<dynamic> shopTag;
  bool freeDeliveryStatus;
  bool featuresStatus;
  String featuresDisplay;
  String totalOrder;
  String rating;
  String shopOpenType;
  String shopMinAmount;
  String shopType;
  String shopMinCharges;
  dynamic shopOpenTimeRange;
  double distance;
  int duration;
  String closeShopText;
  double shopDeliveryFee;
  bool shopClosePreOrder;
  String estimateTime;
  String shopDeliveryInterval;
  bool shopUserFavourite;
  List<dynamic> availableDates = [];
  bool notInAreaStatus;
  bool showPreOrderStatus;
  ShopModel(
      {this.id,
      this.uniqueCode,
      this.customAddress,
      this.street,
      this.zip,
      this.city,
      this.state,
      this.lat,
      this.lng,
      this.shopStatus,
      this.shopPromo,
      this.openTime,
      this.closeTime,
      this.shopName,
      this.phone,
      this.shopType,
      this.fullAddress,
      this.partner,
      this.merchantId,
      this.logoUrl,
      this.headerImgUrl,
      this.buildingName,
      this.buildingUnit,
      this.shopMenu,
      this.category,
      this.freeDeliveryStatus,
      this.featuresStatus,
      this.totalOrder,
      this.rating,
      this.shopOpenType,
      this.shopMinAmount,
      this.shopMinCharges,
      this.shopOpenTimeRange,
      this.distance,
      this.duration,
      this.closeShopText,
      this.shopDeliveryFee,
      this.shopClosePreOrder,
      this.estimateTime,
      this.shopTag,
      this.shopUserFavourite,
      this.availableDates,
      this.shopDeliveryInterval,
      this.notInAreaStatus,
      this.showPreOrderStatus,
      this.featuresDisplay});

  static bool isHighLightCategory(String category) {
    try {
      String isFoundCategory;
      if (AppConfig.consumerConfig != null &&
          AppConfig.consumerConfig.highlightCategory.isNotEmpty) {
        isFoundCategory = AppConfig.consumerConfig.highlightCategory
            .firstWhere((element) => element == category);
      }
      return isFoundCategory != null;
    } catch (e) {
      print(e);
    }

    return false;
  }
}
