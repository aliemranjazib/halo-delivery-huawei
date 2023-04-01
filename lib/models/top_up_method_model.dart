// To parse this JSON data, do
//
//     final topUpMethodModel = topUpMethodModelFromJson(jsonString);

import 'dart:convert';

TopUpMethodModel topUpMethodModelFromJson(String str) => TopUpMethodModel.fromJson(json.decode(str));

String topUpMethodModelToJson(TopUpMethodModel data) => json.encode(data.toJson());

class TopUpMethodModel {
  TopUpMethodModel({
    this.paymentType,
    this.paymentIcon,
    this.paymentTitle,
    this.paymentIsActive,
  });

  String paymentType;
  String paymentIcon;
  String paymentTitle;
  bool paymentIsActive;

  factory TopUpMethodModel.fromJson(Map<String, dynamic> json) => TopUpMethodModel(
    paymentType: json["paymentType"] == null ? null : json["paymentType"],
    paymentIcon: json["paymentIcon"] == null ? null : json["paymentIcon"],
    paymentTitle: json["paymentTitle"] == null ? null : json["paymentTitle"],
    paymentIsActive: json["paymentIsActive"] == null ? null : json["paymentIsActive"],
  );

  Map<String, dynamic> toJson() => {
    "paymentType": paymentType == null ? null : paymentType,
    "paymentIcon": paymentIcon == null ? null : paymentIcon,
    "paymentTitle": paymentTitle == null ? null : paymentTitle,
    "paymentIsActive": paymentIsActive == null ? null : paymentIsActive,
  };
}
