// To parse this JSON data, do
//
//     final foodRiderTracking = foodRiderTrackingFromJson(jsonString);

import 'dart:convert';

FoodRiderTracking foodRiderTrackingFromJson(String str) =>
    FoodRiderTracking.fromJson(json.decode(str));

String foodRiderTrackingToJson(FoodRiderTracking data) =>
    json.encode(data.toJson());

class FoodRiderTracking {
  FoodRiderTracking(
      {this.riderName = '',
      this.riderPhone,
      this.isJobCompleted = true,
      this.orderStatus,
      this.lat,
      this.lng,
      this.cancelStatus = true});

  String riderName;
  String riderPhone;
  String orderStatus;
  double lat;
  double lng;
  bool isJobCompleted;
  bool cancelStatus;

  factory FoodRiderTracking.fromJson(Map<String, dynamic> json) =>
      FoodRiderTracking(
        orderStatus: json["orderStatus"],
        riderName: json["rider_name"],
        riderPhone: json["rider_phone"],
        isJobCompleted: json["is_job_completed"] == 'true',
        lat: double.tryParse(json["lat"] ?? ''),
        lng: double.tryParse(json["lng"] ?? ''),
        cancelStatus: json["cancelStatus"] == 'true',
      );

  Map<String, dynamic> toJson() => {
        "order_status": orderStatus,
        "rider_name": riderName,
        "rider_phone": riderPhone,
        "isJobCompleted": isJobCompleted,
        "lat": lat,
        "lng": lng,
        "cancelStatus" : cancelStatus
      };
}
