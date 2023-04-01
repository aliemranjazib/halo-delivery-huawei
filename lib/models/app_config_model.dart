import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:haloapp/models/shop_model.dart';
import 'package:haloapp/models/top_up_method_model.dart';
import 'package:haloapp/utils/filehelper.dart';

String appConfigToJson(AppConfig data) => json.encode(data.toJson());

class AppConfig {
  /// To check whether the page is in foreground
  static bool isShowMaintenancePage = false;
  static ValueNotifier<bool> isUnderMaintenance = ValueNotifier(false);

  static List<String> enabledOptions;
  static List<Language> language;
  static List<Service> services;

  static OperatingTime operatingTime;
  static List<New> news;
  static List<ShopModel> histories;
  static List<FoodOption> foodOptions;
  static List<PromoBanner> promoBanner;
  static String promoText;
  static String promoTextStatus;
  static List<CancelRemark> cancelRemarks = [
    CancelRemark(
      title: "my_order_is_taking_longer_than_expected",
      value: "My order is taking longer than expected.",
    ),
    CancelRemark(
      title: "i_accidentally_placed_the_order",
      value: "I accidentally placed the order.",
    ),
    CancelRemark(
      title: "my_promo_code_wasnt_applied_to_my_order",
      value: "My promo code wasn't applied to my order.",
    ),
    CancelRemark(
      title: "i_changed_my_mind",
      value: "I changed my mind.",
    ),
    CancelRemark(
      title: "this_is_a_duplicate_order",
      value: "This is a duplicate order.",
    ),
    CancelRemark(
      title: "others",
      value: "Others",
    ),
  ];
  static ConsumerConfig consumerConfig;

  static List<TopUpMethodModel> paymentMethods = <TopUpMethodModel>[];

  static AppConfig _instance;
  factory AppConfig() => _instance ??= new AppConfig._();

  void fromJson(Map<String, dynamic> json) {
    AppConfig.enabledOptions = List<String>.from(json["enabled_options"].map((x) => x));
    AppConfig.language = List<Language>.from(json["language"].map((x) => Language.fromJson(x)));

    if (json["news"] != null) {
      AppConfig.news = List<New>.from(json["news"].map((x) => New.fromJson(x)));
    }

    if (json["icon_list"] != null) {
      AppConfig.services = List<Service>.from(json["icon_list"].map((x) => Service.fromJson(x)));
    }

    if (json["order_again"] != null) {
      AppConfig.histories = _delegateHistoryShopList(json["order_again"]);
    }

    if (json["craving_for"] != null) {
      AppConfig.foodOptions =
          List<FoodOption>.from(json["craving_for"].map((x) => FoodOption.fromJson(x)));
    }

    if (json["promoBanner"] != null) {
      AppConfig.promoBanner =
          List<PromoBanner>.from(json["promoBanner"].map((x) => PromoBanner.fromJson(x)));
    }

    if (json["promoText"] != null) {
      AppConfig.promoText = json['promoText'] == null ? null : json["promoText"];
    }

    if (json["promoTextStatus"] != null) {
      AppConfig.promoTextStatus = json['promoTextStatus'] == null ? null : json["promoTextStatus"];
    }

    if (!(json["operatingTime"] is List<dynamic>)) {
      AppConfig.operatingTime = OperatingTime.fromJson(json["operatingTime"]);
    } else {
      AppConfig.operatingTime = null;
    }

    if (json["appSetting"] != null) {
      AppConfig.consumerConfig = ConsumerConfig.fromJson(json["appSetting"]);
      isUnderMaintenance.value = AppConfig.consumerConfig.isMaintenance;
      print("### ${AppConfig.consumerConfig.isConfirmOrderDelayTime}");
    }

    if (json["cancel_remarks"] != null) {
      AppConfig.cancelRemarks =
          List<CancelRemark>.from(json["cancel_remarks"].map((x) => CancelRemark.fromJson(x)));
    } else {
      AppConfig.cancelRemarks = [
        CancelRemark(
          title: "my_order_is_taking_longer_than_expected",
          value: "My order is taking longer than expected.",
        ),
        CancelRemark(
          title: "i_accidentally_placed_the_order",
          value: "I accidentally placed the order.",
        ),
        CancelRemark(
          title: "my_promo_code_wasnt_applied_to_my_order",
          value: "My promo code wasn't applied to my order.",
        ),
        CancelRemark(
          title: "i_changed_my_mind",
          value: "I changed my mind.",
        ),
        CancelRemark(
          title: "this_is_a_duplicate_order",
          value: "This is a duplicate order.",
        ),
        CancelRemark(
          title: "others",
          value: "Others",
        ),
      ];
    }

    paymentMethods.clear();
    paymentMethods.add(TopUpMethodModel(
        paymentIsActive: true,
        paymentType: "fpx",
        paymentTitle: "fpx",
        paymentIcon: "images/ic_payment_fpx.png"));
    paymentMethods.add(TopUpMethodModel(
        paymentIsActive: true,
        paymentType: "card",
        paymentTitle: "card",
        paymentIcon: "images/ic_payment_card.png"));
    paymentMethods.add(TopUpMethodModel(
        paymentIsActive: true,
        paymentType: "ewallet",
        paymentTitle: "ewallet",
        paymentIcon: "images/ic_payment_ewallet.png"));
    print("paymentMethods.length ${paymentMethods.length}");
  }

  void configJson(Map<String, dynamic> jsonContent) async {
    try {
      AppConfig.consumerConfig = ConsumerConfig.fromJson(jsonContent);
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() => {
        "enabled_options": List<dynamic>.from(enabledOptions.map((x) => x)),
        "language": List<dynamic>.from(language.map((x) => x.toJson())),
        "operatingTime:": operatingTime.toJson()
      };

  AppConfig._();

  _delegateHistoryShopList(List<dynamic> historyShops) {
    List<ShopModel> shopsList = [];

    for (int i = 0; i < historyShops.length; i++) {
      Map<String, dynamic> details = historyShops[i];

      ShopModel shop = _delegateHistoryShop(details);

      shopsList.add(shop);
    }

    return shopsList;
  }

  _delegateHistoryShop(Map<String, dynamic> details) {
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
      freeDeliveryStatus: (details['shop_free_delivery_status'] == 'true') ? true : false,
      featuresStatus: (details['shop_features_status'] == 'true') ? true : false,
      totalOrder: details['shop_total_order'] ?? '',
      rating: details['shop_rating'] ?? '0.0',
      shopOpenType: details['shop_open_type'] ?? '',
      shopOpenTimeRange: details['shop_open_time_json'],
      shopMinAmount: details['shop_minimum_amount'],
      shopMinCharges: details['shop_minimum_charges'],
      duration: int.parse(details['estimateTime'] ?? '0'),
      distance: double.parse(details['nearby'] ?? '0.0'),
      closeShopText: details['shop_close_text'] ?? '',
      shopDeliveryFee: double.parse(details['shop_delivery_fee'].toString() ?? "0.0"),
      shopClosePreOrder: (details['shop_close_preOrder'] == 'true'),
    );
    return shop;
  }
}

class Language {
  Language({
    this.code,
    this.name,
    this.file,
  });

  String code;
  String name;
  String file;

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        code: json["code"],
        name: json["name"],
        file: json["file"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "file": file,
      };
}

class Service {
  Service({this.iconName, this.iconUrl, this.iconDes});

  String iconName;
  String iconUrl;
  String iconDes;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        iconName: json["icon_name"],
        iconUrl: json["icon_url"],
        iconDes: json["icon_desc"] ?? null,
      );

  Map<String, dynamic> toJson() => {
        "icon_name": iconName,
        "icon_url": iconUrl,
      };
}

class OperatingTime {
  OperatingTime({
    this.zone_online_status,
    this.zone_open_time,
    this.zone_close_time,
    this.zone_friday_prayer_status,
    this.zone_friday_prayer_start,
    this.zone_friday_prayer_end,
    this.zone_offday_status,
    this.zone_offday_start_time,
    this.zone_offday_end_time,
    this.zone_remark,
    this.zone_raining_icon_status,
  });

  String zone_online_status;
  String zone_open_time;
  String zone_close_time;
  String zone_friday_prayer_status;
  String zone_friday_prayer_start;
  String zone_friday_prayer_end;
  String zone_offday_status;
  String zone_offday_start_time;
  String zone_offday_end_time;
  String zone_raining_icon_status;
  String zone_remark;

  factory OperatingTime.fromJson(Map<String, dynamic> json) => OperatingTime(
      zone_online_status: json["zone_online_status"],
      zone_open_time: json["zone_open_time"],
      zone_close_time: json["zone_close_time"],
      zone_friday_prayer_status: json["zone_friday_prayer_status"],
      zone_friday_prayer_start: json["zone_friday_prayer_start"],
      zone_friday_prayer_end: json["zone_friday_prayer_end"],
      zone_offday_status: json["zone_offday_status"],
      zone_offday_start_time: json["zone_offday_start_time"],
      zone_offday_end_time: json["zone_offday_end_time"],
      zone_remark: json['zone_remark'],
      zone_raining_icon_status: json["zone_raining_icon_status"]);

  Map<String, dynamic> toJson() => {
        "zone_online_status": zone_online_status,
        "zone_open_time": zone_open_time,
        "zone_close_time": zone_close_time,
        "zone_friday_prayer_status": zone_friday_prayer_status,
        "zone_friday_prayer_start": zone_friday_prayer_start,
        "zone_friday_prayer_end": zone_friday_prayer_end,
        "zone_offday_status": zone_offday_status,
        "zone_offday_start_time": zone_offday_start_time,
        "zone_offday_end_time": zone_offday_end_time,
        "zone_remark": zone_remark,
        "zone_raining_icon_status": zone_raining_icon_status
      };
}

class New {
  New({
    this.promoId,
    this.promoActionUrl,
    this.promoName,
    this.promoImageUrl,
    this.promoStatus,
    this.promoAdminDisplayStatus,
    this.promoCreatedDatetime,
    this.promoActionType,
    this.promoDisplayOrder,
    this.promoUpdateDatetime,
    this.promoDisplayType,
    this.promoDisplayZone,
  });

  String promoId;
  String promoActionUrl;
  String promoName;
  String promoImageUrl;
  String promoStatus;
  String promoAdminDisplayStatus;
  DateTime promoCreatedDatetime;
  String promoActionType;
  dynamic promoDisplayOrder;
  DateTime promoUpdateDatetime;
  String promoDisplayType;
  dynamic promoDisplayZone;

  factory New.fromJson(Map<String, dynamic> json) => New(
        promoId: json["promo_id"] ?? "",
        promoActionUrl: json["promo_action_url"] ?? "",
        promoName: json["promo_name"] ?? "",
        promoImageUrl: json["promo_image_url"] ?? "",
        promoStatus: json["promo_status"] ?? "",
        promoAdminDisplayStatus: json["promo_admin_display_status"] ?? "",
        promoCreatedDatetime: json["promo_created_datetime"] == null
            ? null
            : DateTime.parse(json["promo_created_datetime"]),
        promoActionType: json["promo_action_type"] ?? "",
        promoDisplayOrder: json["promo_display_order"] ?? "",
        promoUpdateDatetime: json["promo_update_datetime"] == null
            ? null
            : DateTime.parse(json["promo_update_datetime"]),
        promoDisplayType: json["promo_display_type"] ?? "",
        promoDisplayZone: json["promo_display_zone"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "promo_id": promoId,
        "promo_action_url": promoActionUrl,
        "promo_name": promoName,
        "promo_image_url": promoImageUrl,
        "promo_status": promoStatus,
        "promo_admin_display_status": promoAdminDisplayStatus,
        "promo_created_datetime": promoCreatedDatetime.toIso8601String(),
        "promo_action_type": promoActionType,
        "promo_display_order": promoDisplayOrder,
        "promo_update_datetime": promoUpdateDatetime.toIso8601String(),
        "promo_display_type": promoDisplayType,
        "promo_display_zone": promoDisplayZone,
      };
}

class FoodOption {
  FoodOption({
    this.iconName,
    this.iconUrl,
    this.iconDes,
    this.searchName,
    this.shopType,
  });

  String iconName;
  String iconUrl;
  String searchName;
  String shopType;
  String iconDes;

  factory FoodOption.fromJson(Map<String, dynamic> json) => FoodOption(
        iconName: json["icon_name"] ?? null,
        iconUrl: json["icon_url"] ?? null,
        searchName: json["search_name"] ?? null,
        shopType: json["shop_type"] ?? null,
      );

  Map<String, dynamic> toJson() => {
        "icon_name": iconName,
        "icon_url": iconUrl,
        "search_name": searchName,
        "shop_type": shopType,
      };
}

class ConsumerConfig {
  ConsumerConfig(
      {this.isConfirmOrderDelay,
      this.isConfirmOrderDelayTime,
      this.isMaintenance,
      this.highlightCategory,
      this.eWalletEnable,
      this.topUpMinAmount,
      this.topUpMaxAmount,
      this.topUpAmount,
      this.supportUrl,
      this.supportUrlBackup,
      this.servicesPos});

  bool isConfirmOrderDelay;
  int isConfirmOrderDelayTime;
  bool isMaintenance;
  bool eWalletEnable;
  List<String> highlightCategory;
  double topUpMinAmount;
  double topUpMaxAmount;
  List<double> topUpAmount;
  String supportUrl;
  String supportUrlBackup;
  List<String> servicesPos;

  factory ConsumerConfig.fromJson(Map<String, dynamic> json) => ConsumerConfig(
        isConfirmOrderDelay:
            json["isConfirmOrderDelay"] == null ? true : json["isConfirmOrderDelay"],
        isConfirmOrderDelayTime:
            json["isConfirmOrderDelayTime"] == null ? 5000 : json["isConfirmOrderDelayTime"],
        isMaintenance: json["isMaintenance"] == null ? false : json["isMaintenance"],
        highlightCategory: json["highlightCategory"] == null
            ? ["Non-Halal"]
            : List<String>.from(json["highlightCategory"].map((x) => x)),
        eWalletEnable: json["eWalletEnable"] ?? false,
        topUpMinAmount:
            json["topUpMinAmount"] == null ? 10.0 : double.parse(json["topUpMinAmount"].toString()),
        topUpMaxAmount: json["topUpMaxAmount"] == null
            ? 100.0
            : double.parse(json["topUpMaxAmount"].toString()),
        topUpAmount: json["topUpAmount"] == null
            ? [10.0, 30.0, 50.0, 100.0]
            : List<double>.from(json["topUpAmount"].map((x) => double.parse(x.toString()))),
        supportUrl: json["supportUrl"] == null
            ? "fb-messenger://user-thread/155381338364130"
            : json["supportUrl"],
        supportUrlBackup: json["supportUrlBackup"] == null
            ? "https://m.me/halo.com.my"
            : json["supportUrlBackup"],
        servicesPos: json["servicesPos"] == null
            ? ["craving", "featured", "order_again", "mynews"]
            : List<String>.from(json["servicesPos"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "isConfirmOrderDelay": isConfirmOrderDelay,
        "isConfirmOrderDelayTime": isConfirmOrderDelayTime,
        "isMaintenance": isMaintenance,
        "eWalletEnable": eWalletEnable,
        "highlightCategory": List<dynamic>.from(highlightCategory.map((x) => x)),
        "topUpMinAmount": topUpMinAmount == null ? null : topUpMinAmount,
        "topUpMaxAmount": topUpMaxAmount == null ? null : topUpMaxAmount,
        "topUpAmount": topUpAmount == null ? null : List<dynamic>.from(topUpAmount.map((x) => x)),
        "supportUrl": supportUrl == null ? null : supportUrl,
        "supportUrlBackup": supportUrlBackup == null ? null : supportUrlBackup,
        "servicesPos": List<dynamic>.from(servicesPos.map((x) => x)),
      };
}

class CancelRemark {
  CancelRemark({
    this.title,
    this.value,
  });

  String title;
  String value;

  factory CancelRemark.fromJson(Map<String, dynamic> json) => CancelRemark(
        title: json["title"] == null ? null : json["title"],
        value: json["value"] == null ? null : json["value"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "value": value == null ? null : value,
      };
}

/// promo_action_url : null
/// promo_image_url : "https://halorider.oss-ap-southeast-3.aliyuncs.com/1682976680banner-test.png"

class PromoBanner {
  PromoBanner({
    this.promoActionUrl,
    this.promoImageUrl,
  });

  String promoActionUrl;
  String promoImageUrl;

  factory PromoBanner.fromJson(Map<String, dynamic> json) => PromoBanner(
        promoActionUrl: json['promo_action_url'] == null ? null : json["promo_action_url"],
        promoImageUrl: json['promo_image_url'] == null ? null : json["promo_image_url"],
      );

  // Map<String, dynamic> toJson() {
  //   var map = <String, String>{};
  //   map['promo_action_url'] = _promoActionUrl;
  //   map['promo_image_url'] = _promoImageUrl;
  //   return map;
  // }
}
